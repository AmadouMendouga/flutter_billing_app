import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.imageBytes,
    this.size = 96,
  });

  final String name;
  final Uint8List? imageBytes;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final value =
        parts
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part.characters.first.toUpperCase())
            .join();
    return value.isEmpty ? 'S' : value;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bytes = imageBytes;
    final fallback = ColoredBox(
      color: scheme.primary,
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: size / 3,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
      ),
    );

    return Semantics(
      image: bytes != null,
      label: name,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.22),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipOval(
          child:
              bytes == null || bytes.isEmpty
                  ? fallback
                  : Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => fallback,
                  ),
        ),
      ),
    );
  }
}
