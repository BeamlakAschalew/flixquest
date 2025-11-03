# Live TV Player Troubleshooting Guide

## Issue Description

The live TV streams work in VLC and other apps, and the app is consuming data (indicating network activity), but the video is not displaying. Error occurs at `StandardMethodCodec.decodeEnvelope` in the platform channel.

## Changes Made

### 1. Enhanced Error Handling

- Added error state tracking (`_hasError`, `_errorMessage`)
- Implemented event listeners to track player state
- Added comprehensive error logging
- Added retry functionality with visual feedback

### 2. Improved Buffering Configuration

```dart
bufferForPlaybackMs: 2500,
bufferForPlaybackAfterRebufferMs: 5000,
```

These parameters help with live stream buffering.

### 3. Added HTTP Headers

```dart
headers: {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  'Connection': 'keep-alive',
},
```

Some IPTV streams require proper user agent headers.

### 4. Specified Video Format

```dart
videoFormat: BetterPlayerVideoFormat.other,
```

This allows Better Player to auto-detect the stream format.

## Potential Causes and Solutions

### 1. **Codec Issues (Most Likely)**

The stream may be using a codec that ExoPlayer doesn't support by default.

**Solution:** Check the stream's codec using FFprobe:

```bash
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,profile -of default=noprint_wrappers=1 "YOUR_STREAM_URL"
```

If the codec is HEVC/H.265 or other advanced codecs, you may need to:

- Use a different player implementation
- Transcode the stream on the server side
- Use a different stream source

### 2. **DRM Protected Content**

If the stream has DRM, you need to configure DRM settings.

**Solution:** Check if the stream requires DRM and configure accordingly:

```dart
drmConfiguration: BetterPlayerDrmConfiguration(
  drmType: BetterPlayerDrmType.widevine,
  licenseUrl: 'YOUR_LICENSE_URL',
),
```

### 3. **Stream Format Issues**

The stream format might not be properly detected.

**Solution:** Try specifying different formats:

```dart
videoFormat: BetterPlayerVideoFormat.hls,  // for .m3u8
// or
videoFormat: BetterPlayerVideoFormat.dash,  // for MPEG-DASH
```

### 4. **SSL/Certificate Issues**

Some streams might have SSL certificate problems.

**Solution:** Add to your Android configuration (for debugging only):
In `AndroidManifest.xml`, ensure you have:

```xml
android:usesCleartextTraffic="true"
```

(Already present in your manifest)

### 5. **ExoPlayer Version Conflict**

Check if the Better Player version is using an outdated ExoPlayer.

**Solution:** Update Better Player or fork and update ExoPlayer dependency.

## Debug Steps

### Step 1: Check Stream Format

Run this command to analyze the stream:

```bash
ffprobe -v quiet -print_format json -show_format -show_streams "YOUR_STREAM_URL"
```

### Step 2: Monitor Flutter Logs

Watch for these specific events:

```bash
flutter run --verbose | grep -E "(Player event|Player exception|Buffering)"
```

### Step 3: Test with Different Streams

Try with known working streams to isolate the issue:

- BBC Live: `https://vs-cmaf-pushb-uk-live.akamaized.net/x=4/i=urn:bbc:pips:service:bbc_one_london/...`
- Big Buck Bunny: `https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8`

### Step 4: Check Android Logs

```bash
adb logcat | grep -E "(ExoPlayer|BetterPlayer|VideoPlayer)"
```

## Alternative Solutions

### Option 1: Use Video Player Package

If Better Player continues to have issues, try the official `video_player` package:

```yaml
dependencies:
  video_player: ^2.8.0
```

### Option 2: Use Chewie Package

A more stable alternative:

```yaml
dependencies:
  chewie: ^1.7.0
  video_player: ^2.8.0
```

### Option 3: Use Native Platform View

For critical apps, implement a native video player using platform channels.

## Testing Checklist

- [ ] Verify stream URL works in VLC/browser
- [ ] Check stream codec and format
- [ ] Test with a known working stream URL
- [ ] Monitor Android logcat for ExoPlayer errors
- [ ] Test on different Android versions
- [ ] Test with different network conditions
- [ ] Check if stream requires authentication/headers
- [ ] Verify Better Player version compatibility

## Additional Configuration

### For HLS Streams (.m3u8)

```dart
BetterPlayerDataSource dataSource = BetterPlayerDataSource(
  BetterPlayerDataSourceType.network,
  widget.videoUrl,
  liveStream: true,
  videoFormat: BetterPlayerVideoFormat.hls,
  headers: {
    'User-Agent': 'Mozilla/5.0',
    'Referer': 'YOUR_REFERER_IF_NEEDED',
  },
);
```

### For RTSP Streams

```dart
BetterPlayerDataSource dataSource = BetterPlayerDataSource(
  BetterPlayerDataSourceType.network,
  widget.videoUrl,
  liveStream: true,
  videoFormat: BetterPlayerVideoFormat.other,
  // RTSP may require native player
);
```

## Next Steps

1. **Run the app** and check the console logs for the new debug output
2. **Check the exact error message** from the event listener
3. **Test with a simple HLS stream** to isolate if it's a codec issue
4. **Check the ExoPlayer version** in your Better Player fork
5. **Consider updating ExoPlayer** in the Better Player native code if outdated

## Contact Points

If the issue persists:

1. Check Better Player GitHub issues
2. Review ExoPlayer documentation for supported codecs
3. Consider filing an issue with stream details (codec, format, etc.)
