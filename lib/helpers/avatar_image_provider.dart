import 'dart:convert';
import 'package:flutter/material.dart';

ImageProvider getAvatarImageProvider(String? imageSource) {
  if (imageSource == null || imageSource.trim().isEmpty) {
    return const AssetImage('assets/images/user.png');
  }

  final trimmed = imageSource.trim();

  // If it's a legacy or external URL
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return NetworkImage(trimmed);
  }

  // Handle base64 encoded strings
  try {
    String cleanBase64 = trimmed;
    if (trimmed.contains(',')) {
      cleanBase64 = trimmed.split(',').last;
    }
    final bytes = base64Decode(cleanBase64);
    return MemoryImage(bytes);
  } catch (_) {
    return const AssetImage('assets/images/user.png');
  }
}
