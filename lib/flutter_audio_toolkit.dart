import 'flutter_audio_toolkit_platform_interface.dart';
import 'src/flutter_audio_toolkit_src.dart';

// Re-export all models and types for public API
export 'src/models/models.dart';

// Export audio player widgets and services
export 'src/widgets/true_waveform_audio_player.dart';
export 'src/widgets/fake_waveform_audio_player.dart';
export 'src/widgets/audio_player_controls.dart';
export 'src/widgets/waveform_visualizer.dart';
export 'src/core/audio_player_service.dart';

// Export utilities
export 'src/utils/path_provider_util.dart';
export 'src/utils/audio_error_handler.dart';

/// Main class for audio conversion, trimming, and waveform extraction
///
/// This class provides a high-level API for audio processing operations
/// using native platform implementations. All heavy operations are delegated
/// to specialized service classes for better maintainability and testability.
class FlutterAudioToolkit {
  /// Gets the platform version
  Future<String?> getPlatformVersion() {
    return FlutterAudioToolkitPlatform.instance.getPlatformVersion();
  }

  /// Converts an audio file to the specified format
  ///
  /// [inputPath] - Path to the input audio file (mp3, wav, ogg)
  /// [outputPath] - Path where the converted file will be saved
  /// [format] - Target audio format (aac or m4a)
  /// [bitRate] - Target bit rate in kbps (default: 128)
  /// [sampleRate] - Target sample rate in Hz (default: 44100)
  /// [onProgress] - Optional callback for conversion progress
  Future<ConversionResult> convertAudio({
    required String inputPath,
    required String outputPath,
    required AudioFormat format,
    int bitRate = 128,
    int sampleRate = 44100,
    ProgressCallback? onProgress,
  }) {
    return AudioService.convertAudio(
      inputPath: inputPath,
      outputPath: outputPath,
      format: format,
      bitRate: bitRate,
      sampleRate: sampleRate,
      onProgress: onProgress,
    );
  }

  /// Extracts waveform data from an audio file
  ///
  /// [inputPath] - Path to the input audio file
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [onProgress] - Optional callback for extraction progress
  Future<WaveformData> extractWaveform({
    required String inputPath,
    int samplesPerSecond = 100,
    ProgressCallback? onProgress,
  }) {
    return AudioService.extractWaveform(
      inputPath: inputPath,
      samplesPerSecond: samplesPerSecond,
      onProgress: onProgress,
    );
  }

  /// Checks if the given audio format is supported for conversion
  Future<bool> isFormatSupported(String inputPath) {
    return AudioService.isFormatSupported(inputPath);
  }

  /// Gets audio file information without conversion
  Future<Map<String, dynamic>> getAudioInfo(String inputPath) {
    return AudioService.getAudioInfo(inputPath);
  }

  /// Gets basic audio file information without conversion
  /// This is a lightweight alternative to getAudioInfo for quick metadata checks
  Future<Map<String, dynamic>> getBasicAudioInfo(String inputPath) {
    return AudioService.getBasicAudioInfo(inputPath);
  }

  /// Trims an audio file to the specified time range
  ///
  /// [inputPath] - Path to the input audio file
  /// [outputPath] - Path where the trimmed file will be saved
  /// [startTimeMs] - Start time in milliseconds
  /// [endTimeMs] - End time in milliseconds
  /// [format] - Target audio format (aac or m4a)
  /// [bitRate] - Target bit rate in kbps (default: 128)
  /// [sampleRate] - Target sample rate in Hz (default: 44100)
  /// [onProgress] - Optional callback for trimming progress
  Future<ConversionResult> trimAudio({
    required String inputPath,
    required String outputPath,
    required int startTimeMs,
    required int endTimeMs,
    required AudioFormat format,
    int bitRate = 128,
    int sampleRate = 44100,
    ProgressCallback? onProgress,
  }) {
    return AudioService.trimAudio(
      inputPath: inputPath,
      outputPath: outputPath,
      startTimeMs: startTimeMs,
      endTimeMs: endTimeMs,
      format: format,
      bitRate: bitRate,
      sampleRate: sampleRate,
      onProgress: onProgress,
    );
  }

  /// Generates fake waveform data for testing or preview purposes
  ///
  /// [pattern] - Waveform pattern to generate
  /// [durationMs] - Duration of the waveform in milliseconds (default: 30000 = 30 seconds)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [frequency] - Base frequency for pattern generation (default: 440.0 Hz)
  /// [sampleRate] - Sample rate in Hz (default: 44100)
  /// [channels] - Number of audio channels (default: 2 for stereo)
  ///
  /// Returns a [WaveformData] object containing the generated waveform
  WaveformData generateFakeWaveform({
    required WaveformPattern pattern,
    int durationMs = 30000, // 30 seconds default
    int samplesPerSecond = 100,
    double frequency = 440.0,
    int sampleRate = 44100,
    int channels = 2,
  }) {
    return WaveformGenerator.generateFakeWaveform(
      pattern: pattern,
      durationMs: durationMs,
      samplesPerSecond: samplesPerSecond,
      frequency: frequency,
      sampleRate: sampleRate,
      channels: channels,
    );
  }

  /// Generates a styled waveform with visual configuration
  ///
  /// [pattern] - Waveform pattern to generate
  /// [style] - Visual style configuration for the waveform
  /// [durationMs] - Duration of the waveform in milliseconds (default: 30000 = 30 seconds)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [frequency] - Base frequency for pattern generation (default: 440.0 Hz)
  /// [sampleRate] - Sample rate in Hz (default: 44100)
  /// [channels] - Number of audio channels (default: 2 for stereo)
  ///
  /// Returns a [WaveformData] object with the specified style
  WaveformData generateStyledWaveform({
    required WaveformPattern pattern,
    required WaveformStyle style,
    int durationMs = 30000,
    int samplesPerSecond = 100,
    double frequency = 440.0,
    int sampleRate = 44100,
    int channels = 2,
  }) {
    return WaveformGenerator.generateStyledWaveform(
      pattern: pattern,
      style: style,
      durationMs: durationMs,
      samplesPerSecond: samplesPerSecond,
      frequency: frequency,
      sampleRate: sampleRate,
      channels: channels,
    );
  }

  /// Generates a themed waveform with automatic styling
  ///
  /// [pattern] - Waveform pattern to generate (style is automatically selected)
  /// [durationMs] - Duration of the waveform in milliseconds (default: 30000 = 30 seconds)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  ///
  /// Returns a [WaveformData] object with automatically selected styling
  WaveformData generateThemedWaveform({
    required WaveformPattern pattern,
    int durationMs = 30000,
    int samplesPerSecond = 100,
  }) {
    return WaveformGenerator.generateThemedWaveform(
      pattern: pattern,
      durationMs: durationMs,
      samplesPerSecond: samplesPerSecond,
    );
  }

  /// Downloads an audio file from a network URL and extracts its waveform
  ///
  /// [url] - URL of the audio file to download
  /// [localPath] - Local path where the downloaded file will be saved temporarily
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [onDownloadProgress] - Optional callback for download progress (0.0 to 0.5)
  /// [onExtractionProgress] - Optional callback for waveform extraction progress (0.5 to 1.0)
  ///
  /// Returns a [WaveformData] object containing the extracted waveform
  Future<WaveformData> extractWaveformFromUrl({
    required String url,
    required String localPath,
    int samplesPerSecond = 100,
    ProgressCallback? onDownloadProgress,
    ProgressCallback? onExtractionProgress,
  }) {
    return AudioService.extractWaveformFromUrl(
      url: url,
      localPath: localPath,
      samplesPerSecond: samplesPerSecond,
      onDownloadProgress: onDownloadProgress,
      onExtractionProgress: onExtractionProgress,
    );
  }

  /// Generates a fake waveform for a network audio file without downloading
  /// This is useful for quick previews or when you want to show a waveform
  /// without the overhead of downloading and processing the actual file
  ///
  /// [url] - URL of the audio file (used for consistent pattern generation)
  /// [pattern] - Waveform pattern to generate
  /// [estimatedDurationMs] - Estimated duration in milliseconds (default: 180000 = 3 minutes)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  ///
  /// Returns a [WaveformData] object with fake but realistic-looking waveform data
  WaveformData generateFakeWaveformForUrl({
    required String url,
    required WaveformPattern pattern,
    int estimatedDurationMs = 180000, // 3 minutes default
    int samplesPerSecond = 100,
  }) {
    return WaveformGenerator.generateFakeWaveformForUrl(
      url: url,
      pattern: pattern,
      estimatedDurationMs: estimatedDurationMs,
      samplesPerSecond: samplesPerSecond,
    );
  }

  /// Downloads an audio file from the given URL and saves it to the local file system
  ///
  /// [url] - URL of the audio file to download
  /// [outputPath] - Local path where the downloaded file will be saved
  /// [onProgress] - Optional callback for download progress
  Future<String> downloadFile(
    String url,
    String outputPath, {
    ProgressCallback? onProgress,
  }) {
    return AudioService.downloadFile(url, outputPath, onProgress: onProgress);
  }

  /// Extracts comprehensive metadata from an audio file
  ///
  /// [inputPath] - Path to the input audio file
  ///
  /// Returns an [AudioMetadata] object containing all available metadata including
  /// title, artist, album, duration, bitrate, sample rate, and more
  Future<AudioMetadata> extractMetadata(String inputPath) {
    return AudioService.extractMetadata(inputPath);
  }

  /// Extracts metadata from a network audio file
  ///
  /// [url] - URL of the audio file
  /// [localPath] - Temporary local path for downloading
  /// [onProgress] - Optional callback for download progress
  ///
  /// Returns an [AudioMetadata] object containing all available metadata
  Future<AudioMetadata> extractMetadataFromUrl({
    required String url,
    required String localPath,
    ProgressCallback? onProgress,
  }) {
    return AudioService.extractMetadataFromUrl(
      url: url,
      localPath: localPath,
      onProgress: onProgress,
    );
  }

  /// Analyzes an audio file for noise detection and quality assessment
  ///
  /// [inputPath] - Path to the input audio file
  /// [segmentDurationMs] - Duration of analysis segments in milliseconds (default: 5000)
  /// [onProgress] - Optional callback for analysis progress
  ///
  /// Returns a comprehensive [NoiseDetectionResult] with:
  /// - Overall noise level assessment
  /// - Volume level analysis
  /// - Detected background noises (traffic, dogs, etc.)
  /// - Audio quality metrics
  /// - Frequency analysis
  /// - Time-based segment analysis
  /// - Recommendations for improvement
  Future<NoiseDetectionResult> analyzeNoise({
    required String inputPath,
    int segmentDurationMs = 5000,
    ProgressCallback? onProgress,
  }) {
    return NoiseDetectionService.analyzeAudio(
      inputPath: inputPath,
      segmentDurationMs: segmentDurationMs,
      onProgress: onProgress,
    );
  }

  /// Analyzes audio from a network URL for noise detection
  ///
  /// [url] - URL of the audio file to analyze
  /// [localPath] - Temporary local path for downloading
  /// [segmentDurationMs] - Duration of analysis segments in milliseconds (default: 5000)
  /// [onDownloadProgress] - Optional callback for download progress (0.0 to 0.5)
  /// [onAnalysisProgress] - Optional callback for analysis progress (0.5 to 1.0)
  ///
  /// Returns a comprehensive [NoiseDetectionResult] with noise and quality analysis
  Future<NoiseDetectionResult> analyzeNoiseFromUrl({
    required String url,
    required String localPath,
    int segmentDurationMs = 5000,
    ProgressCallback? onDownloadProgress,
    ProgressCallback? onAnalysisProgress,
  }) {
    return NoiseDetectionService.analyzeAudioFromUrl(
      url: url,
      localPath: localPath,
      segmentDurationMs: segmentDurationMs,
      onDownloadProgress: onDownloadProgress,
      onAnalysisProgress: onAnalysisProgress,
    );
  }

  /// Performs a quick noise check without detailed analysis
  ///
  /// [inputPath] - Path to the input audio file
  /// [onProgress] - Optional callback for analysis progress
  ///
  /// Returns basic noise and volume information for quick assessment
  Future<Map<String, dynamic>> quickNoiseCheck({
    required String inputPath,
    ProgressCallback? onProgress,
  }) {
    return NoiseDetectionService.quickNoiseCheck(
      inputPath: inputPath,
      onProgress: onProgress,
    );
  }

  // Backward compatibility aliases

  /// Analyzes an audio file for noise detection and quality assessment
  ///
  /// This is an alias for [analyzeNoise] for backward compatibility.
  ///
  /// [inputPath] - Path to the input audio file
  /// [segmentDurationMs] - Duration of analysis segments in milliseconds (default: 5000)
  /// [onProgress] - Optional callback for analysis progress
  ///
  /// Returns a comprehensive [NoiseDetectionResult] with:
  /// - Overall noise level assessment
  /// - Volume level analysis
  /// - Detected background noises (traffic, dogs, etc.)
  /// - Audio quality metrics
  /// - Frequency analysis
  /// - Time-based segment analysis
  /// - Recommendations for improvement
  Future<NoiseDetectionResult> analyzeAudioNoise({
    required String inputPath,
    int segmentDurationMs = 5000,
    ProgressCallback? onProgress,
  }) {
    return analyzeNoise(
      inputPath: inputPath,
      segmentDurationMs: segmentDurationMs,
      onProgress: onProgress,
    );
  }

  /// Analyzes audio from a network URL for noise detection
  ///
  /// This is an alias for [analyzeNoiseFromUrl] for backward compatibility.
  ///
  /// [url] - URL of the audio file to analyze
  /// [localPath] - Temporary local path for downloading
  /// [segmentDurationMs] - Duration of analysis segments in milliseconds (default: 5000)
  /// [onDownloadProgress] - Optional callback for download progress (0.0 to 0.5)
  /// [onAnalysisProgress] - Optional callback for analysis progress (0.5 to 1.0)
  ///
  /// Returns a comprehensive [NoiseDetectionResult] with noise and quality analysis
  Future<NoiseDetectionResult> analyzeAudioNoiseFromUrl({
    required String url,
    required String localPath,
    int segmentDurationMs = 5000,
    ProgressCallback? onDownloadProgress,
    ProgressCallback? onAnalysisProgress,
  }) {
    return analyzeNoiseFromUrl(
      url: url,
      localPath: localPath,
      segmentDurationMs: segmentDurationMs,
      onDownloadProgress: onDownloadProgress,
      onAnalysisProgress: onAnalysisProgress,
    );
  }
}
