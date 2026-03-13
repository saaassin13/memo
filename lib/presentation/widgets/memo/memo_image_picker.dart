import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();
  static const _uuid = Uuid();

  /// 从相册选择图片
  static Future<String?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 80,
    );
    if (image != null) {
      return await _saveImage(image);
    }
    return null;
  }

  /// 拍照
  static Future<String?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      imageQuality: 80,
    );
    if (image != null) {
      return await _saveImage(image);
    }
    return null;
  }

  /// 保存图片到应用目录
  static Future<String> _saveImage(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}.jpg';
    final savedPath = '${imagesDir.path}/$fileName';

    await File(image.path).copy(savedPath);
    return savedPath;
  }

  /// 删除图片
  static Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

class MemoImagePicker extends StatelessWidget {
  final List<String> images;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  const MemoImagePicker({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await ImagePickerHelper.pickFromGallery();
                if (path != null) {
                  onAdd(path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await ImagePickerHelper.pickFromCamera();
                if (path != null) {
                  onAdd(path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('取消'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除图片'),
        content: const Text('确定要删除这张图片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRemove(index);
            },
            child: Text('删除', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + (images.length < 9 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == images.length) {
                // 添加按钮
                return GestureDetector(
                  onTap: () => _showPickerOptions(context),
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }

              // 图片
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showImagePreview(context, index),
                    onLongPress: () => _confirmDelete(context, index),
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(images[index]),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.broken_image,
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showImagePreview(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _ImagePreviewScreen(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ImagePreviewScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImagePreviewScreen({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<_ImagePreviewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                File(widget.images[index]),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
