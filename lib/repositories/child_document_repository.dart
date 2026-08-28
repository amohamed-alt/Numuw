import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors/app_error.dart';
import '../services/media_picker_service.dart';

class UploadedChildDocument {
  const UploadedChildDocument({
    required this.id,
    required this.childId,
    required this.bucket,
    required this.path,
    required this.mimeType,
    required this.sizeBytes,
    required this.title,
  });

  final String id;
  final String childId;
  final String bucket;
  final String path;
  final String mimeType;
  final int sizeBytes;
  final String title;
}

class ChildDocumentRepository {
  ChildDocumentRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const bucket = 'numuw-child-documents';
  static const maxAssistantBytes = 5 * 1024 * 1024;

  final SupabaseClient _client;

  Future<UploadedChildDocument> uploadAssistantAttachment({
    required String childId,
    required NumuwPickedFile file,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const InvalidSessionException();
    if (file.bytes.isEmpty) {
      throw const LocalValidationException('الملف فارغ. اختاري ملفًا آخر.');
    }
    if (file.bytes.length > maxAssistantBytes) {
      throw const LocalValidationException(
        'ملف المساعد أكبر من 5 ميجابايت. اختاري ملفًا أصغر.',
      );
    }

    final mimeType = _mimeType(file.name, file.mimeHint);
    if (mimeType == null) {
      throw const LocalValidationException(
        'المساعد يدعم PDF وJPG وPNG وWebP فقط.',
      );
    }

    final safeName = _safeName(file.name);
    final nonce = DateTime.now().toUtc().microsecondsSinceEpoch;
    final path = '$childId/assistant/$nonce-$safeName';
    final bytes = Uint8List.fromList(file.bytes);

    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              contentType: mimeType,
              upsert: false,
            ),
          );

      final inserted = await _client
          .from('child_documents')
          .insert({
            'child_id': childId,
            'uploaded_by': user.id,
            'document_type': 'other',
            'title': file.name.trim().isEmpty ? 'مرفق للمساعد' : file.name.trim(),
            'storage_bucket': bucket,
            'storage_path': path,
            'mime_type': mimeType,
            'size_bytes': bytes.length,
            'notes': 'assistant_attachment',
          })
          .select('id,child_id,storage_bucket,storage_path,mime_type,size_bytes,title')
          .single();

      return UploadedChildDocument(
        id: inserted['id'].toString(),
        childId: inserted['child_id'].toString(),
        bucket: inserted['storage_bucket'].toString(),
        path: inserted['storage_path'].toString(),
        mimeType: inserted['mime_type']?.toString() ?? mimeType,
        sizeBytes: (inserted['size_bytes'] as num?)?.toInt() ?? bytes.length,
        title: inserted['title']?.toString() ?? file.name,
      );
    } catch (_) {
      // Keep database and object storage consistent when metadata insertion or
      // a later upload step fails. Removing a non-existent object is safe.
      try {
        await _client.storage.from(bucket).remove([path]);
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> remove(UploadedChildDocument document) async {
    final storageError = await _client.storage
        .from(document.bucket)
        .remove([document.path]);
    if (storageError.isNotEmpty) {
      throw AppException('تعذر حذف المرفق من التخزين.');
    }
    await _client.from('child_documents').delete().eq('id', document.id);
  }

  static String? _mimeType(String name, String? hint) {
    final extension = (hint?.trim().isNotEmpty == true
            ? hint!
            : name.split('.').last)
        .toLowerCase()
        .replaceFirst('.', '');
    return switch (extension) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      _ => null,
    };
  }

  static String _safeName(String value) {
    final trimmed = value.trim();
    final source = trimmed.isEmpty ? 'attachment' : trimmed;
    return source
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^[-.]+|[-.]+$'), '')
        .toLowerCase()
        .isEmpty
        ? 'attachment'
        : source
            .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .replaceAll(RegExp(r'^[-.]+|[-.]+$'), '')
            .toLowerCase();
  }
}
