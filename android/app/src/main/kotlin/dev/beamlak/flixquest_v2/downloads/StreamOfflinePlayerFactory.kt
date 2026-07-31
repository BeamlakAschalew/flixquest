package dev.beamlak.flixquest_v2.downloads

import android.content.Context
import android.graphics.Color
import android.view.View
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.offline.Download
import androidx.media3.exoplayer.offline.DownloadHelper
import androidx.media3.ui.PlayerView
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

@UnstableApi
class StreamOfflinePlayerFactory(
    private val store: StreamDownloadStore,
    codec: MessageCodec<Any?> = StandardMessageCodec.INSTANCE,
) : PlatformViewFactory(codec) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val id = (args as? Map<*, *>)?.get("id") as? String
            ?: throw IllegalArgumentException("An offline download id is required.")
        return StreamOfflinePlayerView(context, id, store)
    }
}

@UnstableApi
private class StreamOfflinePlayerView(
    context: Context,
    downloadId: String,
    store: StreamDownloadStore,
) : PlatformView {
    private val playerView = PlayerView(context).apply {
        setBackgroundColor(Color.BLACK)
        setShowBuffering(PlayerView.SHOW_BUFFERING_ALWAYS)
        setUseController(true)
        setShowSubtitleButton(true)
        controllerShowTimeoutMs = 3_500
    }
    private val player = ExoPlayer.Builder(context).build().apply {
        setAudioAttributes(
            AudioAttributes.Builder()
                .setContentType(C.AUDIO_CONTENT_TYPE_MOVIE)
                .setUsage(C.USAGE_MEDIA)
                .build(),
            true,
        )
    }

    init {
        val download = store.getDownload(downloadId)
            ?: throw IllegalArgumentException("Download not found: $downloadId")
        check(download.state == Download.STATE_COMPLETED) {
            "The download must complete before offline playback."
        }
        val mediaSource = DownloadHelper.createMediaSource(
            download.request,
            store.readOnlyCacheFactory(),
        )
        playerView.player = player
        player.setMediaSource(mediaSource)
        player.prepare()
        player.playWhenReady = true
    }

    override fun getView(): View = playerView

    override fun onFlutterViewAttached(flutterView: View) {
        playerView.onResume()
    }

    override fun onFlutterViewDetached() {
        playerView.onPause()
    }

    override fun dispose() {
        playerView.player = null
        player.release()
    }
}
