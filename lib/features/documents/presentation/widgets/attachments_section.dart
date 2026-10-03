import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/formatting/file_size.dart';
import '../../../../core/media/image_picker_provider.dart';
import '../../../../core/media/photo_picker.dart';
import '../../../../core/network/asset_url.dart';
import '../../../../core/platform/link_launcher.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/document.dart';
import '../providers/document_repository_provider.dart';

const maxAttachments = 5;
const _maxBytes = 5 * 1024 * 1024;

/// A reason the photo cannot be attached that the user can act on; [canRetry] is false when trying the same
/// photo again could never work.
class _AttachProblem implements Exception {
  const _AttachProblem(this.message, {this.canRetry = true});

  final String message;
  final bool canRetry;
}

/// The files kept with a document. It owns its list because adding or removing a file changes nothing else on
/// the document, so the screen around it need not reload.
class AttachmentsSection extends ConsumerStatefulWidget {
  const AttachmentsSection({super.key, required this.documentId, required this.initial});

  final String documentId;
  final List<DocumentAttachment> initial;

  @override
  ConsumerState<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<AttachmentsSection> {
  late List<DocumentAttachment> _files = widget.initial;
  bool _busy = false;
  String? _error;
  // What Retry does again, kept whole so a retried upload sends the same photo without asking for it again.
  Future<void> Function()? _retry;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _retry = action;
    });
    try {
      await action();
      if (mounted) setState(() => _retry = null);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is _AttachProblem ? e.message : describeActionError(e);
          if (e is _AttachProblem && !e.canRetry) _retry = null;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    // Kept across a retry so a failed upload sends the same photo again instead of asking for another.
    PickedImage? photo;
    await _run(() async {
      try {
        photo ??= await ref.read(photoPickerProvider)(source);
      } on PlatformException {
        throw const _AttachProblem(
          "Couldn't open the camera or photos. Allow access in your phone's settings, then try again",
        );
      }
      final chosen = photo;
      if (chosen == null) return;
      if (chosen.bytes.length > _maxBytes) {
        throw const _AttachProblem('That photo is over 5 MB. Choose a smaller one or take it again', canRetry: false);
      }
      final saved = await ref.read(documentRepositoryProvider).uploadAttachment(
            widget.documentId,
            chosen.bytes,
            chosen.name,
          );
      if (mounted) setState(() => _files = [..._files, saved]);
    });
  }

  Future<void> _remove(DocumentAttachment file) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove this file?',
      content: file.fileName,
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;
    await _run(() async {
      await ref.read(documentRepositoryProvider).deleteAttachment(widget.documentId, file.id);
      if (mounted) setState(() => _files = _files.where((f) => f.id != file.id).toList());
    });
  }

  Future<void> _open(DocumentAttachment file) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(externalUrlOpenerProvider)(Uri.parse(resolveAssetUrl(file.url)));
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't open the file. Check your connection and try again")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final full = _files.length >= maxAttachments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
            Text('${_files.length} of $maxAttachments'),
          ],
        ),
        if (_files.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Keep a purchase order or proof of delivery with this document.'),
          ),
        for (final file in _files)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(file.isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined),
            title: Text(file.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(formatFileSize(file.sizeBytes)),
            trailing: IconButton(
              key: Key('attachment-remove-${file.id}'),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove ${file.fileName}',
              onPressed: _busy ? null : () => _remove(file),
            ),
            onTap: () => _open(file),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                if (_retry != null)
                  TextButton(
                    key: const Key('attachment-retry'),
                    onPressed: _busy ? null : () => _run(_retry!),
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
        if (full)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('A document can have 5 files. Remove one to add another'),
          )
        else
          OutlinedButton.icon(
            key: const Key('attachment-add'),
            onPressed: _busy ? null : _add,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(_busy ? 'Working...' : 'Add a photo'),
          ),
      ],
    );
  }
}
