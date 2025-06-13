import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/audio_player_config.dart';
import '../models/audio_player_state.dart';
import '../models/waveform_pattern.dart';
import '../core/audio_service.dart';
import '../generators/waveform_generator.dart';

/// Service for audio playback with waveform visualization
class AudioPlayerService {
  static const MethodChannel _channel = MethodChannel(
    'flutter_audio_toolkit/player',
  );

  /// Currently active player instances
  static final Map<String, AudioPlayerService> _instances = {};

  /// Unique identifier for this player instance
  final String playerId;

  /// State manager for this player
  final AudioPlayerStateManager stateManager;

  /// Timer for position updates
  Timer? _positionTimer;

  /// Whether this player is disposed
  bool _isDisposed = false;

  AudioPlayerService._({required this.playerId, required this.stateManager}) {
    _instances[playerId] = this;
    _setupAudioPlayerListeners();
    _setupMethodCallHandler();
  }

  /// Sets up audio player listeners for the mock implementation
  void _setupAudioPlayerListeners() {
    // Note: This is a mock implementation for demo purposes
    // The real implementation would set up native audio player listeners
    debugPrint(
      'Setting up audio player listeners for mock implementation: $playerId',
    );
  }

  /// Creates a new audio player instance
  static AudioPlayerService create({String? playerId}) {
    final id = playerId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final stateManager = AudioPlayerStateManager();
    return AudioPlayerService._(playerId: id, stateManager: stateManager);
  }

  /// Gets an existing player instance by ID
  static AudioPlayerService? getInstance(String playerId) {
    return _instances[playerId];
  }

  /// Sets up method call handler for platform callbacks
  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.arguments['playerId'] != playerId) return;

      switch (call.method) {
        case 'onStateChanged':
          final stateIndex = call.arguments['state'] as int;
          final state = AudioPlayerState.values[stateIndex];
          stateManager.updateState(state);
          break;

        case 'onPositionChanged':
          final positionMs = call.arguments['position'] as int;
          stateManager.updatePosition(Duration(milliseconds: positionMs));
          break;

        case 'onDurationChanged':
          final durationMs = call.arguments['duration'] as int;
          stateManager.updateDuration(Duration(milliseconds: durationMs));
          break;

        case 'onError':
          final error = call.arguments['error'] as String;
          stateManager.setError(error);
          break;
      }
    });
  }

  /// Loads an audio file for playback
  Future<void> loadAudio(String audioPath) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    debugPrint('AudioPlayerService: Loading audio file: $audioPath');
    try {
      stateManager.updateState(AudioPlayerState.loading);
      stateManager.clearError();

      // Check if it's a URL or local file
      bool isUrl =
          audioPath.startsWith('http://') || audioPath.startsWith('https://');
      debugPrint('AudioPlayerService: Is URL: $isUrl');

      int actualDurationMs;

      if (isUrl) {
        // For URLs, we need to download or at least get headers to determine duration
        // But in this example, we'll use a reasonable default
        debugPrint('AudioPlayerService: URL detected, using default duration');
        actualDurationMs = 30000; // Default 30 seconds for URLs

        // Simulate loading delay
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        // Verify local file exists
        final file = File(audioPath);
        if (!await file.exists()) {
          debugPrint('AudioPlayerService: File not found: $audioPath');
          throw FileSystemException('Audio file not found', audioPath);
        }

        // Mock implementation - simulate loading delay
        await Future.delayed(const Duration(milliseconds: 500));

        // Get the actual audio duration from audio metadata
        try {
          final audioInfo = await AudioService.getAudioInfo(audioPath);
          actualDurationMs =
              audioInfo['durationMs'] ?? audioInfo['duration'] ?? 30000;
          debugPrint(
            'AudioPlayerService: Got actual audio duration from metadata: ${actualDurationMs}ms',
          );
        } catch (e) {
          debugPrint(
            'AudioPlayerService: Failed to get audio duration from metadata: $e, using file size estimate',
          );
          // Fallback to file size estimate with a more reasonable range
          final fileStat = await file.stat();
          actualDurationMs =
              (fileStat.size / 1000)
                  .clamp(10000, 3600000)
                  .toInt(); // 10s to 60min based on file size
          debugPrint(
            'AudioPlayerService: Estimated duration from file size: ${actualDurationMs}ms',
          );
        }
      }

      stateManager.updateDuration(Duration(milliseconds: actualDurationMs));
      stateManager.setAudioPath(audioPath);
      stateManager.updateState(AudioPlayerState.stopped);

      debugPrint(
        'AudioPlayerService: Audio loaded: $audioPath (duration: ${actualDurationMs}ms)',
      );
    } catch (e, stackTrace) {
      debugPrint('AudioPlayerService: Failed to load audio: $e');
      debugPrint('AudioPlayerService: Stack trace: $stackTrace');
      stateManager.setError('Failed to load audio: $e');
      rethrow;
    }
  }

  /// Loads audio file and extracts true waveform data
  Future<void> loadAudioWithTrueWaveform(String audioPath) async {
    await loadAudio(audioPath);

    try {
      // Extract real waveform data
      final waveformData = await AudioService.extractWaveform(
        inputPath: audioPath,
        samplesPerSecond: 100,
      );

      stateManager.setWaveformData(waveformData);
    } catch (e) {
      // If waveform extraction fails, continue with audio loading
      // but log the error
      debugPrint('Warning: Failed to extract waveform data: $e');
    }
  }

  /// Loads audio file and generates fake waveform data
  Future<void> loadAudioWithFakeWaveform(
    String audioPath, {
    WaveformPattern pattern = WaveformPattern.music,
    int samplesPerSecond = 100,
  }) async {
    debugPrint(
      'AudioPlayerService: Loading audio with fake waveform: $audioPath',
    );

    try {
      await loadAudio(audioPath);

      debugPrint(
        'AudioPlayerService: Audio loaded, generating fake waveform with pattern: ${pattern.name}',
      );
      debugPrint(
        'AudioPlayerService: Duration for waveform: ${stateManager.duration.inMilliseconds}ms',
      );

      // Check if duration is valid
      if (stateManager.duration.inMilliseconds <= 0) {
        debugPrint(
          'AudioPlayerService: Invalid duration: ${stateManager.duration.inMilliseconds}ms. Using default 30 seconds.',
        );
        stateManager.updateDuration(const Duration(seconds: 30));
      }

      // Generate fake waveform based on pattern
      final fakeWaveform = WaveformGenerator.generateFakeWaveform(
        pattern: pattern,
        durationMs: stateManager.duration.inMilliseconds,
        samplesPerSecond: samplesPerSecond,
      );

      debugPrint(
        'AudioPlayerService: Generated fake waveform with ${fakeWaveform.amplitudes.length} samples',
      );

      stateManager.setWaveformData(fakeWaveform);
      debugPrint('AudioPlayerService: Waveform data set successfully');
    } catch (e, stackTrace) {
      debugPrint('AudioPlayerService: Failed to generate fake waveform: $e');
      debugPrint('AudioPlayerService: Stack trace: $stackTrace');
      // Create a simple default waveform as fallback
      try {
        final defaultWaveform = WaveformGenerator.generateFakeWaveform(
          pattern: WaveformPattern.sine,
          durationMs: 30000, // 30 seconds default
          samplesPerSecond: samplesPerSecond,
        );
        stateManager.setWaveformData(defaultWaveform);
        debugPrint('AudioPlayerService: Set default fallback waveform');
      } catch (e2) {
        debugPrint(
          'AudioPlayerService: Even fallback waveform generation failed: $e2',
        );
      }
    }
  }

  /// Starts or resumes playback
  Future<void> play() async {
    if (_isDisposed) throw StateError('Player has been disposed');

    try {
      // Mock implementation - simulate play
      stateManager.updateState(AudioPlayerState.playing);
      _startPositionTimer();
      debugPrint('Mock audio playback started for player: $playerId');
    } catch (e) {
      stateManager.setError('Failed to play audio: $e');
      rethrow;
    }
  }

  /// Pauses playback
  Future<void> pause() async {
    if (_isDisposed) throw StateError('Player has been disposed');

    try {
      // Mock implementation - simulate pause
      stateManager.updateState(AudioPlayerState.paused);
      _stopPositionTimer();
      debugPrint('Mock audio playback paused for player: $playerId');
    } catch (e) {
      stateManager.setError('Failed to pause audio: $e');
      rethrow;
    }
  }

  /// Stops playback and resets position
  Future<void> stop() async {
    if (_isDisposed) throw StateError('Player has been disposed');

    try {
      // Mock implementation - simulate stop
      stateManager.updateState(AudioPlayerState.stopped);
      _stopPositionTimer();
      stateManager.updatePosition(Duration.zero);
      debugPrint('Mock audio playback stopped for player: $playerId');
    } catch (e) {
      stateManager.setError('Failed to stop audio: $e');
      rethrow;
    }
  }

  /// Seeks to a specific position
  Future<void> seekTo(Duration position) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    try {
      // Mock implementation - simulate seek
      final clampedPosition = Duration(
        milliseconds: position.inMilliseconds.clamp(
          0,
          stateManager.duration.inMilliseconds,
        ),
      );
      stateManager.updatePosition(clampedPosition);
      debugPrint(
        'Mock seek to position: ${clampedPosition.inSeconds}s for player: $playerId',
      );
    } catch (e) {
      stateManager.setError('Failed to seek: $e');
      rethrow;
    }
  }

  /// Sets the playback volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    volume = volume.clamp(0.0, 1.0);

    try {
      // Mock implementation - simulate volume change
      stateManager.updateVolume(volume);
      debugPrint('Mock volume set to: $volume for player: $playerId');
    } catch (e) {
      stateManager.setError('Failed to set volume: $e');
      rethrow;
    }
  }

  /// Sets the playback speed (0.25 to 4.0)
  Future<void> setPlaybackSpeed(double speed) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    speed = speed.clamp(0.25, 4.0);

    try {
      // Mock implementation - simulate playback speed change
      stateManager.setPlaybackSpeed(speed);
      debugPrint('Mock playback speed set to: $speed for player: $playerId');
    } catch (e) {
      stateManager.setError('Failed to set playback speed: $e');
      rethrow;
    }
  }

  /// Toggles between play and pause
  Future<void> togglePlayPause() async {
    debugPrint(
      'AudioPlayerService: togglePlayPause called. Current state: ${stateManager.state}',
    );

    if (stateManager.isPlaying) {
      debugPrint('AudioPlayerService: Currently playing, will pause');
      await pause();
    } else {
      debugPrint('AudioPlayerService: Currently not playing, will play');
      // If we're in error state, try to reload the audio first
      if (stateManager.hasError) {
        debugPrint('AudioPlayerService: Recovering from error state');
        if (stateManager.audioPath != null) {
          try {
            await loadAudio(stateManager.audioPath!);
          } catch (e) {
            debugPrint('AudioPlayerService: Failed to reload audio: $e');
          }
        }
      }
      await play();
    }
  }

  /// Starts the position update timer
  void _startPositionTimer() {
    _stopPositionTimer();
    _positionTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _updatePosition(),
    );
  }

  /// Stops the position update timer
  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  /// Updates the current position from platform
  Future<void> _updatePosition() async {
    if (_isDisposed || !stateManager.isPlaying) return;

    try {
      // Mock implementation - simulate position progress
      final currentPosition = stateManager.position;
      final duration = stateManager.duration;

      if (duration.inMilliseconds > 0) {
        final newPositionMs =
            currentPosition.inMilliseconds + 100; // Advance by 100ms

        if (newPositionMs >= duration.inMilliseconds) {
          // Reached end of track
          stateManager.updatePosition(duration);
          stateManager.updateState(AudioPlayerState.stopped);
          _stopPositionTimer();
        } else {
          stateManager.updatePosition(Duration(milliseconds: newPositionMs));
        }
      }
    } catch (e) {
      // Ignore position update errors to avoid spam
    }
  }

  /// Disposes the player and releases resources
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    _stopPositionTimer();

    // Mock implementation - no native calls needed
    debugPrint('Mock player disposed: $playerId');

    _instances.remove(playerId);
    stateManager.dispose();
  }

  /// Gets the current audio duration
  Future<Duration?> getDuration() async {
    if (_isDisposed) return null;

    // Return the duration from state manager (set during loadAudio)
    return stateManager.duration;
  }

  /// Gets the current playback position
  Future<Duration> getPosition() async {
    if (_isDisposed) return Duration.zero;

    // Return the current position from state manager
    return stateManager.position;
  }
}
