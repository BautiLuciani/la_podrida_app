import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:la_podrida_app/application/providers/player_avatars_provider.dart';
import 'package:la_podrida_app/application/providers/saved_players_provider.dart';

class _Entry {
  final String key;
  final TextEditingController controller;
  final FocusNode focusNode;

  _Entry({required this.key, required this.controller, required this.focusNode});
}

class SavedPlayersScreen extends ConsumerStatefulWidget {
  const SavedPlayersScreen({super.key});

  @override
  ConsumerState<SavedPlayersScreen> createState() => _SavedPlayersScreenState();
}

class _SavedPlayersScreenState extends ConsumerState<SavedPlayersScreen> {
  final List<_Entry> _entries = [];
  int _keyCounter = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final players = ref.read(savedPlayersProvider);
      setState(() {
        _initialized = true;
        _entries.addAll(players.map(_createEntry));
      });
    });
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.controller.dispose();
      entry.focusNode.dispose();
    }
    super.dispose();
  }

  _Entry _createEntry(String name) {
    final controller = TextEditingController(text: name);
    final focusNode = FocusNode();
    final entry = _Entry(key: 'sp${_keyCounter++}', controller: controller, focusNode: focusNode);

    focusNode.addListener(() {
      if (!focusNode.hasFocus && controller.text.trim().isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final index = _entries.indexOf(entry);
          if (index >= 0) _removeEntry(index);
        });
      }
    });

    return entry;
  }

  void _saveAll() {
    final names = _entries
        .map((e) => e.controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    ref.read(savedPlayersProvider.notifier).setAll(names);
  }

  void _addEntry() {
    final entry = _createEntry('');
    setState(() => _entries.add(entry));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) entry.focusNode.requestFocus();
    });
  }

  void _removeEntry(int index) {
    _entries[index].controller.dispose();
    _entries[index].focusNode.dispose();
    setState(() => _entries.removeAt(index));
    _saveAll();
  }

  Future<void> _pickAvatar(String playerName) async {
    final trimmed = playerName.trim();
    if (trimmed.isEmpty) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;
    await ref.read(playerAvatarsProvider.notifier).setAvatar(trimmed, picked.path);
  }

  Widget _buildAvatar(String playerName, Map<String, String> avatars) {
    final trimmed = playerName.trim();
    final avatarPath = trimmed.isNotEmpty ? avatars[trimmed] : null;

    return GestureDetector(
      onTap: () => _pickAvatar(playerName),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade300,
        child: ClipOval(
          child: avatarPath != null
              ? Image.file(
                  File(avatarPath),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.person, size: 24, color: Colors.grey.shade600),
                )
              : Icon(Icons.person, size: 24, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatars = ref.watch(playerAvatarsProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          label: const Text(
            'Volver',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
        ),
        title: const Text('Jugadores'),
        centerTitle: true,
      ),
      body: FadeInUp(
        duration: const Duration(milliseconds: 320),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _initialized ? _entries.length + 1 : 0,
          itemBuilder: (context, index) {
            if (index == _entries.length) {
              return InkWell(
                onTap: _addEntry,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Agregar Jugador',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Icon(Icons.add, size: 28),
                    ],
                  ),
                ),
              );
            }

            final entry = _entries[index];
            return Container(
              key: ValueKey(entry.key),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black54),
              ),
              child: Row(
                children: [
                  _buildAvatar(entry.controller.text, avatars),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: entry.controller,
                      focusNode: entry.focusNode,
                      onTapOutside: (_) => entry.focusNode.unfocus(),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                      ),
                      onChanged: (_) {
                        setState(() {}); // Rebuild so avatar key updates with name
                        _saveAll();
                      },
                      onSubmitted: (_) {
                        if (entry.controller.text.trim().isEmpty) {
                          final i = _entries.indexOf(entry);
                          if (i >= 0) _removeEntry(i);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeEntry(index),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
