# Changelog

## [0.3.0] - 2025-06-10

### 🆕 Major New Features

#### 🔊 Noise Detection & Audio Quality Analysis
- **Comprehensive Audio Analysis**: Deep analysis of audio quality with detailed metrics
- **15+ Noise Type Detection**: Identify background noises like car horns, dog barking, construction, etc.
- **Audio Quality Metrics**: Peak levels, SNR, dynamic range, LUFS loudness measurement
- **Frequency Analysis**: Spectral analysis with problematic frequency band detection
- **Quality Grading**: Automatic quality scoring (Excellent, Good, Fair, Poor, Very Poor)
- **Issue Detection**: Automatic detection of clipping, distortion, and balance problems
- **Network Analysis**: Analyze audio quality directly from URLs

#### 🎨 Enhanced Waveform Generation
- **25+ Waveform Patterns**: Expanded from 7 to 25+ realistic patterns
- **New Pattern Categories**:
  - **Basic Waveforms**: `square`, `sawtooth`, `triangle` (added to existing sine, random, etc.)
  - **Musical Patterns**: `electronic`, `classical`, `rock`, `jazz`, `ambient`
  - **Voice & Speech**: `podcast`, `audiobook` (improved speech patterns)
  - **Nature & Relaxation**: `whiteNoise`, `pinkNoise`, `heartbeat`, `ocean`, `rain`, `binauralBeats`
- **Visual Styling System**: 9 predefined color schemes with customizable visual properties
- **Themed Generation**: Automatic pattern-to-style matching for optimal visual presentation
- **Style Application**: Apply visual styles to existing waveform data

#### 📊 Advanced Metadata Extraction
- **Comprehensive Metadata**: Extract 35+ metadata fields from audio files
- **Cover Art Support**: Extract and handle embedded album artwork
- **Technical Details**: Detailed codec, bitrate, and encoding information
- **Date/Time Fields**: Recording dates, release dates with proper DateTime handling
- **Custom Fields**: Support for additional metadata through extensible system

### 🔧 Enhanced Features
- **Improved Algorithm Accuracy**: Better pattern generation algorithms for all waveform types
- **Memory Optimization**: More efficient audio processing and analysis
- **Progress Tracking**: Enhanced progress callbacks for all new operations
- **Error Handling**: Robust error handling for network operations and file processing

### 🎛️ New API Methods
```dart
// Noise Detection & Analysis
final analysisResult = await toolkit.analyzeAudioNoise(inputPath);
final networkAnalysis = await toolkit.analyzeAudioNoiseFromUrl(url, localPath);

// Enhanced Waveform Generation
final themedWaveform = toolkit.generateThemedWaveform(pattern: WaveformPattern.jazz);
final styledWaveform = toolkit.generateStyledWaveform(pattern: WaveformPattern.electronic, style: WaveformColorSchemes.neon);
final waveformWithStyle = existingWaveform.withStyle(WaveformColorSchemes.fire);

// Advanced Metadata
final metadata = await toolkit.extractMetadata(inputPath);
final networkMetadata = await toolkit.extractMetadataFromUrl(url, localPath);
```

### 🏗️ Architecture Improvements
- **Modular Design**: Separated concerns into specialized analyzer and generator modules
- **Type Safety**: Enhanced type definitions for all new models
- **Documentation**: Comprehensive dartdoc documentation for all new APIs
- **Testing**: 100+ new test cases covering all noise detection and enhanced waveform features

### 📋 New Data Models
- `NoiseDetectionResult` - Complete analysis results
- `AudioQualityMetrics` - Detailed quality measurements
- `FrequencyAnalysis` - Spectral analysis data
- `DetectedNoise` - Individual noise detection results
- `WaveformStyle` - Visual styling configuration
- `AudioMetadata` - Comprehensive metadata container

## [0.2.0] - 2025-06-08

### Added
- **Multi-Platform Support**: Added support for macOS, Linux, and Windows platforms
- **macOS Implementation**: Full native implementation using AVFoundation (same as iOS)
- **Linux & Windows**: Basic plugin structure with platform-specific error handling
- **Platform Documentation**: Updated README with comprehensive platform support matrix
- **Desktop Compatibility**: Plugin now declares support for all desktop platforms

### Enhanced
- Updated platform support matrix in README
- Added platform-specific implementation notes
- Improved plugin architecture for cross-platform compatibility

### Technical Details
- macOS: Complete AVFoundation implementation for audio conversion, trimming, and waveform extraction
- Linux: GTK-based plugin structure (requires FFmpeg/GStreamer for full functionality)
- Windows: Win32 plugin structure (requires Media Foundation/FFmpeg for full functionality)

### Notes
- Desktop platforms (Linux, Windows) have basic plugin structure but require additional audio processing libraries
- macOS has full feature parity with iOS using the same AVFoundation APIs

## [0.1.0] - 2025-06-07

### Added
- **Fake Waveform Generation**: Generate realistic waveform patterns for testing and previews
- **7 Waveform Patterns**: Sine, Random, Music, Speech, Pulse, Fade, and Burst patterns
- **Network URL Support**: Process audio files from network URLs with fake waveform generation
- **Modular Architecture**: Complete refactoring of example app with Provider state management
- **Enhanced Example App**: Added fake waveform UI with pattern selection and color-coded display
- Pattern-specific amplitude algorithms for realistic waveform simulation
- URL validation and network audio file support
- Comprehensive testing for fake waveform functionality

### Enhanced
- Example app refactored from 1180 lines to 122 lines (89% reduction)
- Added Provider state management pattern
- Extracted business logic into service classes
- Modularized UI components into reusable widgets
- Improved error handling and progress tracking

### Fixed
- Library formatting and method signature issues
- Enhanced dependency management

## [0.0.1] - 2025-06-07

### Added
- Initial release of flutter_audio_toolkit plugin
- Audio conversion from MP3, WAV, OGG to AAC/M4A formats
- Audio trimming with precise time range selection
- Waveform data extraction for visualization
- Native implementations for Android (MediaCodec/MediaMuxer) and iOS (AVFoundation)
- Progress tracking for all operations
- Audio file information retrieval
- Comprehensive example app with UI for all features
- Full test coverage including unit and widget tests
- Platform-specific permission handling
- Error handling and validation
- Performance optimized for large audio files

### Platform Support
- Android: API 21+ using MediaCodec, MediaMuxer, MediaExtractor
- iOS: 12.0+ using AVAssetExportSession, AVAudioConverter, AVAssetReader

### Features
- Convert audio files between formats
- Trim audio files to specific time ranges  
- Extract waveform amplitude data
- Get detailed audio file information
- Real-time progress callbacks
- Native performance optimization
