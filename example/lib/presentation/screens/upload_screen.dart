import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

import '/presentation/viewmodel/auth_viewmodel.dart'; // ✅ 추가

class UploadScreen extends StatefulWidget {
  final String baseUrl; // ex: http://192.168.0.19:5000/api

  const UploadScreen({super.key, required this.baseUrl});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _imageFile;
  Uint8List? _webImage;
  String? _resultImageUrl;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _resultImageUrl = null;
    });

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImage = bytes;
        _imageFile = null;
      });
    } else {
      setState(() {
        _imageFile = File(picked.path);
        _webImage = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null && _webImage == null) return;

    final authViewModel = context.read<AuthViewModel>();
    final registerId = authViewModel.currentUser?.registerId;

    if (registerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 없습니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('${widget.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = registerId; // ✅ 사용자 ID 전달

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _imageFile!.path,
          contentType: MediaType('image', 'png'),
        ));
      } else if (_webImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _webImage!,
          filename: 'web_image.png',
          contentType: MediaType('image', 'png'),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        final processedPath = responseData['processed_image_path'] as String?;
        if (processedPath != null) {
          final baseStaticUrl = widget.baseUrl.replaceFirst('/api', '');
          setState(() {
            _resultImageUrl = '$baseStaticUrl$processedPath';
          });
        } else {
          throw Exception('processed_image_path 없음');
        }
      } else {
        print('서버 오류: ${response.statusCode}');
        print('응답 본문: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 오류 발생')),
        );
      }
    } catch (e) {
      print('업로드 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 업로드 실패')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사진으로 예측하기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 200)
            else if (_webImage != null)
              Image.memory(_webImage!, height: 200)
            else
              const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('사진 선택'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadImage,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: const Text('업로드'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_resultImageUrl != null)
              Column(
                children: [
                  const Text('📌 예측 결과'),
                  const SizedBox(height: 10),
                  Image.network(_resultImageUrl!),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
