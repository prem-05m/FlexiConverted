abstract class MediaEngine {
  /// Base interface for all media engines (Video, Audio, Image).
  /// This ensures future engines can share core lifecycle methods if needed.
  
  /// Checks if the engine is ready and available on this platform.
  Future<bool> isReady() async {
    return true; // Default to true
  }
}
