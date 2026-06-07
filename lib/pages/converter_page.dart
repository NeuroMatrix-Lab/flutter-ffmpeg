import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/format_info.dart';
import '../services/conversion_service.dart';

class ConverterPage extends StatefulWidget {
  final List<File> files;

  const ConverterPage({super.key, required this.files});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  int _selectedFileIndex = 0;
  String? _selectedFormat;
  bool _isConverting = false;
  final Map<String, double> _fileProgress = {};
  String _outputPath = '';

  late List<FormatInfo> _supportedFormats;
  late ConversionSettings _settings;

  final List<String> _videoCodecs = ['h264', 'h265', 'vp9', 'av1'];
  final List<String> _audioCodecs = ['aac', 'mp3', 'opus', 'flac', 'pcm_s16le'];
  final List<int> _videoBitrates = [500, 1000, 2000, 3000, 5000, 8000, 10000];
  final List<int> _audioBitrates = [64, 128, 192, 256, 320];
  final List<int> _framerates = [15, 24, 25, 30, 60];
  final List<String> _resolutions = ['1080p', '720p', '480p', '360p'];

  @override
  void initState() {
    super.initState();
    _supportedFormats = ConversionService.getSupportedFormats();
    _settings = ConversionSettings();
    for (var file in widget.files) {
      _fileProgress[file.path] = 0.0;
    }
    _generateOutputPath();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          '选择输出格式',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildFileList(colorScheme),
          ),
          Container(
            width: 1,
            color: colorScheme.outline,
          ),
          Expanded(
            flex: 5,
            child: _buildRightPanel(colorScheme),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatPanel(colorScheme),
    );
  }

  Widget _buildFileList(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '已选文件',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.files.length,
              itemBuilder: (context, index) {
                final file = widget.files[index];
                final isSelected = index == _selectedFileIndex;
                final fileName = file.path.split(Platform.pathSeparator).last;
                final extension = fileName.split('.').last.toUpperCase();

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFileIndex = index);
                    _generateOutputPath();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              extension.length > 3
                                  ? extension.substring(0, 3)
                                  : extension,
                              style: TextStyle(
                                color: isSelected 
                                    ? colorScheme.onPrimary 
                                    : colorScheme.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: TextStyle(
                                  color: isSelected
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_fileProgress[file.path]! > 0 &&
                                  _fileProgress[file.path]! < 100)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: LinearProgressIndicator(
                                    value: _fileProgress[file.path]! / 100,
                                    backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_fileProgress[file.path] == 100)
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(ColorScheme colorScheme) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '输出格式',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildFormatGrid(colorScheme),
            const SizedBox(height: 32),
            if (_selectedFormat != null) ...[
              Text(
                '参数配置',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsPanel(colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormatGrid(ColorScheme colorScheme) {
    final currentFile = widget.files[_selectedFileIndex];
    final currentExtension =
        currentFile.path.split('.').last.toLowerCase();

    final filteredFormats = _supportedFormats
        .where((f) => f.format != currentExtension)
        .toList();

    final videoFormats =
        filteredFormats.where((f) => f.isVideo).toList();
    final audioFormats =
        filteredFormats.where((f) => !f.isVideo).toList();

    return Column(
      children: [
        if (videoFormats.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: videoFormats.map((format) {
              return _buildFormatChip(format, colorScheme);
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (audioFormats.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: audioFormats.map((format) {
              return _buildFormatChip(format, colorScheme);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFormatChip(FormatInfo format, ColorScheme colorScheme) {
    final isSelected = _selectedFormat == format.format;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFormat = format.format;
          _settings = ConversionSettings();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline,
          ),
        ),
        child: Text(
          '.${format.format}',
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(ColorScheme colorScheme) {
    final outputIsVideo = _selectedFormat != null &&
        _supportedFormats
            .firstWhere((f) => f.format == _selectedFormat)
            .isVideo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          if (outputIsVideo) ...[
            Text(
              '视频设置',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingRow(colorScheme, '编码器',
              DropdownButton<String>(
                value: _settings.videoCodec,
                items: _videoCodecs
                    .map((codec) => DropdownMenuItem(
                          value: codec,
                          child: Text(codec.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _settings.videoCodec = value);
                  }
                },
                style: TextStyle(color: colorScheme.onSurface),
                dropdownColor: colorScheme.surface,
                underline: Container(),
              ),
            ),
            _buildSettingRow(colorScheme, '视频码率',
              DropdownButton<int>(
                value: _settings.videoBitrate,
                items: _videoBitrates
                    .map((bitrate) => DropdownMenuItem(
                          value: bitrate,
                          child: Text('$bitrate kbps'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _settings.videoBitrate = value);
                  }
                },
                style: TextStyle(color: colorScheme.onSurface),
                dropdownColor: colorScheme.surface,
                underline: Container(),
              ),
            ),
            _buildSettingRow(colorScheme, '帧率',
              DropdownButton<int>(
                value: _settings.framerate,
                items: _framerates
                    .map((fps) => DropdownMenuItem(
                          value: fps,
                          child: Text('$fps FPS'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _settings.framerate = value);
                  }
                },
                style: TextStyle(color: colorScheme.onSurface),
                dropdownColor: colorScheme.surface,
                underline: Container(),
              ),
            ),
            _buildSettingRow(colorScheme, '分辨率',
              DropdownButton<String>(
                value: _getResolutionLabel(),
                items: _resolutions
                    .map((res) => DropdownMenuItem(
                          value: res,
                          child: Text(res),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _setResolution(value));
                  }
                },
                style: TextStyle(color: colorScheme.onSurface),
                dropdownColor: colorScheme.surface,
                underline: Container(),
              ),
            ),
            _buildSettingRow(colorScheme, '硬件加速',
              Switch(
                value: _settings.hardwareAcceleration,
                onChanged: (value) {
                  setState(() => _settings.hardwareAcceleration = value);
                },
                activeThumbColor: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            '音频设置',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingRow(colorScheme, '音频编码器',
            DropdownButton<String>(
              value: _settings.audioCodec,
              items: _audioCodecs
                  .map((codec) => DropdownMenuItem(
                        value: codec,
                        child: Text(codec.toUpperCase().replaceAll('_', ' ')),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _settings.audioCodec = value);
                }
              },
              style: TextStyle(color: colorScheme.onSurface),
              dropdownColor: colorScheme.surface,
              underline: Container(),
            ),
          ),
          _buildSettingRow(colorScheme, '音频码率',
            DropdownButton<int>(
              value: _settings.audioBitrate,
              items: _audioBitrates
                  .map((bitrate) => DropdownMenuItem(
                        value: bitrate,
                        child: Text('$bitrate kbps'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _settings.audioBitrate = value);
                }
              },
              style: TextStyle(color: colorScheme.onSurface),
              dropdownColor: colorScheme.surface,
              underline: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(ColorScheme colorScheme, String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          child,
        ],
      ),
    );
  }

  String _getResolutionLabel() {
    if (_settings.resolutionWidth == 1920 && _settings.resolutionHeight == 1080) {
      return '1080p';
    } else if (_settings.resolutionWidth == 1280 && _settings.resolutionHeight == 720) {
      return '720p';
    } else if (_settings.resolutionWidth == 854 && _settings.resolutionHeight == 480) {
      return '480p';
    } else {
      return '360p';
    }
  }

  void _setResolution(String resolution) {
    switch (resolution) {
      case '1080p':
        _settings.resolutionWidth = 1920;
        _settings.resolutionHeight = 1080;
        break;
      case '720p':
        _settings.resolutionWidth = 1280;
        _settings.resolutionHeight = 720;
        break;
      case '480p':
        _settings.resolutionWidth = 854;
        _settings.resolutionHeight = 480;
        break;
      case '360p':
        _settings.resolutionWidth = 640;
        _settings.resolutionHeight = 360;
        break;
    }
  }

  Widget _buildFloatPanel(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '输出路径',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _outputPath.isNotEmpty ? _outputPath : '未设置',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedFormat != null && !_isConverting
                    ? _startConversion
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isConverting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        '开始转换',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateOutputPath() async {
    final currentFile = widget.files[_selectedFileIndex];
    final fileName = currentFile.path.split(Platform.pathSeparator).last;
    final nameWithoutExt = fileName.split('.').first;
    final outputFormat = _selectedFormat ?? 'mp4';
    
    final dir = await getApplicationDocumentsDirectory();
    setState(() {
      _outputPath = '${dir.path}/$nameWithoutExt.$outputFormat';
    });
  }

  Future<void> _startConversion() async {
    if (_selectedFormat == null) return;

    setState(() {
      _isConverting = true;
    });

    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _fileProgress[widget.files[_selectedFileIndex].path] = i.toDouble();
      });
    }

    if (!mounted) return;
    setState(() {
      _isConverting = false;
      _fileProgress[widget.files[_selectedFileIndex].path] = 100.0;
    });

    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('转换完成!', style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
    );
  }
}
