import 'package:ble_chat/presentation/cubits/ble/ble_cubit.dart';
import 'package:ble_chat/presentation/cubits/ble/ble_state.dart';
import 'package:ble_chat/presentation/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ChatScreen extends StatefulWidget {
  final BluetoothDevice? connectedDevice;
  final bool isServer;

  const ChatScreen({
    super.key,
    required this.isServer,
    this.connectedDevice,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController controller = TextEditingController();
  late BLECubit bleCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bleCubit = context.read<BLECubit>();
    if (widget.isServer) {
      bleCubit.startGattServer();
      bleCubit.startAdvertising();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("🔄 App resumed — try reconnecting...");
      bleCubit.checkConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isServer ? "Server Mode" : "Client Mode"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            bleCubit.clearMessages();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          const Divider(height: 1),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return BlocBuilder<BLECubit, BLEState>(
      builder: (context, state) {
        final messages = state is BLEMessageReceived ? state.allMessages : [];

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            print(message);
            if (message.isEmpty) return const SizedBox.shrink();
            return ChatBubble(
              text: message,
            );
          },
        );
      },
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter message",
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                bleCubit.sendMessage(widget.connectedDevice, text);
                controller.clear();
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}
