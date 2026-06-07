class FormatInfo {
  final String format;
  final String name;
  final bool isVideo;

  const FormatInfo({
    required this.format,
    required this.name,
    required this.isVideo,
  });
}

class ConversionSettings {
  // 视频设置
  String videoCodec;
  int videoBitrate;
  int framerate;
  int resolutionWidth;
  int resolutionHeight;
  bool hardwareAcceleration;

  // 音频设置
  String audioCodec;
  int audioBitrate;
  int sampleRate;

  ConversionSettings({
    // 视频默认值
    this.videoCodec = 'h264',
    this.videoBitrate = 2000,
    this.framerate = 30,
    this.resolutionWidth = 1920,
    this.resolutionHeight = 1080,
    this.hardwareAcceleration = true,
    // 音频默认值
    this.audioCodec = 'aac',
    this.audioBitrate = 128,
    this.sampleRate = 44100,
  });
}
