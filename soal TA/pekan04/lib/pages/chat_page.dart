import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final pesanController = TextEditingController();

  final List<Map<String, dynamic>> pesan = [
    {
      'teks': 'Halo, ada yang bisa kami bantu?',
      'dariSaya': false,
    },
  ];

  void kirimPesan() {
    final teks = pesanController.text.trim();

    if (teks.isEmpty) return;

    setState(() {
      pesan.add({
        'teks': teks,
        'dariSaya': true,
      });

      pesanController.clear();
    });
  }

  @override
  void dispose() {
    pesanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanya Petugas'),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pesan.length,
              itemBuilder: (context, index) {
                final data = pesan[index];
                final dariSaya = data['dariSaya'] as bool;

                return Align(
                  alignment: dariSaya
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      maxWidth: 300,
                    ),
                    decoration: BoxDecoration(
                      color: dariSaya
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      data['teks'],
                      style: TextStyle(
                        color: dariSaya
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pesanController,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => kirimPesan(),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: kirimPesan,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}