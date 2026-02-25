import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../models/api_response.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _apiService = ApiService();

  File? _selectedFile;
  ApiResponse? _apiResponse;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _autoClearTimer;

  bool _isUrlFieldVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bannerController;

  @override
  void initState() {
    super.initState();
    _resetClearTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  void _resetClearTimer() {
    _autoClearTimer?.cancel();
    _autoClearTimer = Timer(const Duration(minutes: 10), _clearAll);
  }

  void _clearAll() {
    setState(() {
      _textController.clear();
      _videoUrlController.clear();
      _selectedFile = null;
      _apiResponse = null;
      _errorMessage = null;
      _isLoading = false;
      _isUrlFieldVisible = false;
    });
    _animationController.reverse();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final validationError = Validators.validateFile(file);
      setState(() {
        if (validationError != null) {
          _errorMessage = validationError;
          _selectedFile = null;
        } else {
          _selectedFile = file;
          _errorMessage = null;
        }
      });
    }
  }

  Future<void> _sendRequest() async {
    if (_isLoading) return;

    final text = _textController.text;
    final videoUrl = _videoUrlController.text;

    if (text.isEmpty && _selectedFile == null && videoUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez décrire votre situation, joindre un document ou fournir une URL.';
      });
      return;
    }

    final textValidationError = Validators.validateText(text);
    if (textValidationError != null) {
      setState(() {
        _errorMessage = textValidationError;
      });
      return;
    }

    final sanitizedText = Validators.sanitizeText(text);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _apiResponse = null;
    });
    _animationController.reverse();

    try {
      final response = await _apiService.analyze(
        text: sanitizedText,
        file: _selectedFile,
        videoUrl: videoUrl,
      );
      setState(() {
        _apiResponse = response;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur est survenue. Veuillez réessayer.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _resetClearTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildHeader(),
            ),
            _buildMarqueeBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      _buildTextInputSection(),
                      const SizedBox(height: 20),
                      _buildFileUpload(),
                      const SizedBox(height: 24),
                      if (_errorMessage != null) _buildErrorWidget(),
                      if (_isLoading) _buildLoadingIndicator(),
                      if (_apiResponse != null) _buildResponseWidget(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueeBanner() {
    const String message =
        "Les contenus diffusés via cette application sont fournis à titre informatif uniquement. Aucune garantie n’est donnée quant à leur exactitude ou exhaustivité.";
    final Color bannerColor = Color.lerp(Theme.of(context).colorScheme.primary, Colors.black, 0.2)!;

    return Container(
      height: 30,
      width: double.infinity,
      color: bannerColor,
      child: AnimatedBuilder(
        animation: _bannerController,
        builder: (context, child) {
          return ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      left: constraints.maxWidth - (_bannerController.value * (constraints.maxWidth + 1000)),
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: const Text(
                          message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 45,
                height: 45,
                child: Image.asset(
                  'assets/armoirie_gov.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Sin Dò",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.primary),
            onPressed: _clearAll,
            tooltip: 'Effacer la session',
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Description de la situation", style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: Icon(
                Icons.link_rounded,
                color: _isUrlFieldVisible ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              tooltip: 'Ajouter une URL de vidéo',
              onPressed: () {
                setState(() {
                  _isUrlFieldVisible = !_isUrlFieldVisible;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Expliquez ici les faits, le contexte, et vos questions...',
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          maxLength: 3000,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
          child: _isUrlFieldVisible
              ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: _videoUrlController,
                    decoration: const InputDecoration(
                      hintText: 'Coller l\'URL de la vidéo (optionnel)',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFileUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Pièce jointe (optionnel)", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_selectedFile == null) _buildFilePicker() else _buildFileCard(),
      ],
    );
  }

  Widget _buildFilePicker() {
    return GestureDetector(
      onTap: _pickFile,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        strokeWidth: 2,
        dashPattern: const [8, 4],
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  "Ajouter un document (PDF ou Image)",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Widget _buildFileCard() {
    final file = _selectedFile!;
    final fileExtension = p.extension(file.path).toLowerCase();
    final isPdf = fileExtension == '.pdf';
    final fileSize = _formatBytes(file.lengthSync());

    return Card(
      color: const Color(0xFFE8F5E9),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.basename(file.path),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fileSize,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.grey),
              onPressed: () => setState(() => _selectedFile = null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            const Text("Analyse en cours..."),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Card(
      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResponseSection('Qualification', _apiResponse?.qualification),
              _buildResponseSection('Articles de Loi', _apiResponse?.articles),
              _buildResponseSection('Risques & Enjeux', _apiResponse?.risques),
              _buildResponseSection('Conseils & Étapes', _apiResponse?.conseils),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const Divider(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final green = Theme.of(context).colorScheme.primary;
    final yellow = Theme.of(context).colorScheme.secondary;

    return Column(
      children: [
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isLoading ? null : _sendRequest,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [green, Color.lerp(green, yellow, 0.4)!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: green.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Lancer l\'analyse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "© 2026 Gouvernement du Bénin. Tous droits réservés.\n                Service supporté par l'ASIN",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _videoUrlController.dispose();
    _autoClearTimer?.cancel();
    _animationController.dispose();
    _bannerController.dispose();
    super.dispose();
  }
}