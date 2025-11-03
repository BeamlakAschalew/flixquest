#!/bin/bash

# Stream Testing Script for Live TV
# Usage: ./test_stream.sh "YOUR_STREAM_URL"

if [ -z "$1" ]; then
    echo "Usage: $0 <stream_url>"
    echo "Example: $0 'https://example.com/stream.m3u8'"
    exit 1
fi

STREAM_URL="$1"

echo "==========================================="
echo "Stream Analysis for Live TV Troubleshooting"
echo "==========================================="
echo ""

# Check if ffprobe is installed
if ! command -v ffprobe &> /dev/null; then
    echo "⚠️  ffprobe is not installed. Please install ffmpeg to use this tool."
    echo "   Install with: sudo apt-get install ffmpeg"
    exit 1
fi

echo "📡 Testing stream: $STREAM_URL"
echo ""

# Test 1: Basic connectivity
echo "1️⃣  Testing connectivity..."
if curl -I -s --connect-timeout 5 "$STREAM_URL" > /dev/null; then
    echo "   ✅ URL is reachable"
else
    echo "   ❌ URL is not reachable or timed out"
fi
echo ""

# Test 2: Get stream format and codec information
echo "2️⃣  Analyzing stream format and codecs..."
ffprobe -v quiet -print_format json -show_format -show_streams "$STREAM_URL" 2>&1 > /tmp/stream_info.json

if [ -s /tmp/stream_info.json ]; then
    echo "   Stream Information:"
    
    # Extract video codec
    VIDEO_CODEC=$(cat /tmp/stream_info.json | grep -o '"codec_name": "[^"]*"' | head -1 | cut -d'"' -f4)
    echo "   Video Codec: $VIDEO_CODEC"
    
    # Extract audio codec
    AUDIO_CODEC=$(cat /tmp/stream_info.json | grep -o '"codec_name": "[^"]*"' | tail -1 | cut -d'"' -f4)
    echo "   Audio Codec: $AUDIO_CODEC"
    
    # Extract format
    FORMAT=$(cat /tmp/stream_info.json | grep -o '"format_name": "[^"]*"' | cut -d'"' -f4)
    echo "   Format: $FORMAT"
    
    # Check if codec is supported by ExoPlayer/Media3
    echo ""
    echo "3️⃣  Codec Compatibility Check:"
    
    case $VIDEO_CODEC in
        h264|avc)
            echo "   ✅ H.264/AVC - Fully supported by ExoPlayer"
            ;;
        hevc|h265)
            echo "   ⚠️  HEVC/H.265 - May require hardware support"
            echo "      Note: Not all Android devices support HEVC"
            ;;
        vp8|vp9)
            echo "   ✅ VP8/VP9 - Supported by ExoPlayer"
            ;;
        av1)
            echo "   ⚠️  AV1 - Limited support, requires Android 10+"
            ;;
        mpeg2video)
            echo "   ⚠️  MPEG-2 - Limited support on newer Android versions"
            ;;
        *)
            echo "   ❓ Unknown codec: $VIDEO_CODEC"
            echo "      This may cause playback issues"
            ;;
    esac
    
    echo ""
    echo "4️⃣  Format Compatibility:"
    case $FORMAT in
        hls|m3u8)
            echo "   ✅ HLS - Fully supported"
            echo "   Recommendation: Use BetterPlayerVideoFormat.hls"
            ;;
        mpegts)
            echo "   ✅ MPEG-TS - Supported"
            echo "   Recommendation: Use BetterPlayerVideoFormat.other"
            ;;
        dash)
            echo "   ✅ MPEG-DASH - Supported"
            echo "   Recommendation: Use BetterPlayerVideoFormat.dash"
            ;;
        rtsp)
            echo "   ⚠️  RTSP - May have issues with Media3"
            echo "   Consider transcoding to HLS"
            ;;
        *)
            echo "   ❓ Format: $FORMAT"
            ;;
    esac
else
    echo "   ❌ Could not analyze stream"
    echo "   This could mean:"
    echo "   - Stream requires authentication"
    echo "   - Stream URL is invalid"
    echo "   - Network connectivity issues"
fi

echo ""
echo "5️⃣  Testing with different User-Agent..."
curl -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
     -I -s --connect-timeout 5 "$STREAM_URL" | head -5

echo ""
echo "==========================================="
echo "📋 Recommendations:"
echo "==========================================="

if [ "$VIDEO_CODEC" = "hevc" ] || [ "$VIDEO_CODEC" = "h265" ]; then
    echo "⚠️  HEVC codec detected. This is likely the issue!"
    echo "   Solutions:"
    echo "   1. Use a different stream with H.264 codec"
    echo "   2. Transcode the stream server-side"
    echo "   3. Check device hardware HEVC support"
fi

if [ "$FORMAT" = "rtsp" ]; then
    echo "⚠️  RTSP protocol detected."
    echo "   ExoPlayer/Media3 has limited RTSP support."
    echo "   Consider:"
    echo "   1. Converting to HLS format"
    echo "   2. Using a different player"
fi

echo ""
echo "📝 Full stream information saved to: /tmp/stream_info.json"
echo ""
