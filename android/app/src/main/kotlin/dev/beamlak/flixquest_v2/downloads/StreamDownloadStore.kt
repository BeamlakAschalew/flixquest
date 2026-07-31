package dev.beamlak.flixquest_v2.downloads

import android.content.Context
import android.net.Uri
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.TrackSelectionParameters
import androidx.media3.common.util.UnstableApi
import androidx.media3.database.StandaloneDatabaseProvider
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.datasource.cache.CacheDataSource
import androidx.media3.datasource.cache.NoOpCacheEvictor
import androidx.media3.datasource.cache.SimpleCache
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.dash.offline.DashDownloader
import androidx.media3.exoplayer.hls.offline.HlsDownloader
import androidx.media3.exoplayer.offline.DefaultDownloadIndex
import androidx.media3.exoplayer.offline.Download
import androidx.media3.exoplayer.offline.DownloadHelper
import androidx.media3.exoplayer.offline.DownloadManager
import androidx.media3.exoplayer.offline.DownloadRequest
import androidx.media3.exoplayer.offline.Downloader
import androidx.media3.exoplayer.offline.DownloaderFactory
import androidx.media3.exoplayer.offline.ProgressiveDownloader
import androidx.media3.exoplayer.scheduler.Requirements
import org.json.JSONObject
import java.io.File
import java.nio.charset.StandardCharsets
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

@UnstableApi
class StreamDownloadStore private constructor(context: Context) {
    private val appContext = context.applicationContext
    private val databaseProvider = StandaloneDatabaseProvider(appContext)
    private val downloadIndex = DefaultDownloadIndex(databaseProvider)
    private val downloadExecutor: ExecutorService = Executors.newFixedThreadPool(4)

    val cache = SimpleCache(
        File(appContext.filesDir, "offline_streams"),
        NoOpCacheEvictor(),
        databaseProvider,
    )

    val downloadManager = DownloadManager(
        appContext,
        downloadIndex,
        HeaderAwareDownloaderFactory(cache, downloadExecutor),
    ).apply {
        maxParallelDownloads = 2
        requirements = Requirements(Requirements.NETWORK)
    }

    fun prepareRequest(
        arguments: Map<*, *>,
        callback: (Result<DownloadRequest>) -> Unit,
    ) {
        val id = arguments["id"] as? String
        val url = arguments["url"] as? String
        val format = arguments["format"] as? String
        if (id.isNullOrBlank() || url.isNullOrBlank() || format.isNullOrBlank()) {
            callback(Result.failure(IllegalArgumentException("A download id, URL, and format are required.")))
            return
        }

        val mimeType = when (format.lowercase()) {
            "hls" -> MimeTypes.APPLICATION_M3U8
            "dash" -> MimeTypes.APPLICATION_MPD
            else -> {
                callback(Result.failure(IllegalArgumentException("Unsupported stream format: $format")))
                return
            }
        }
        val metadata = metadataJson(arguments)
        val headers = metadataHeaders(metadata)
        val httpFactory = httpFactory(headers)
        val maxVideoHeight = (arguments["maxVideoHeight"] as? Number)?.toInt()
            ?.takeIf { it > 0 }

        val trackParameters = TrackSelectionParameters.Builder(appContext)
            .setForceHighestSupportedBitrate(true)
            .apply {
                if (maxVideoHeight != null) {
                    setMaxVideoSize(Int.MAX_VALUE, maxVideoHeight)
                }
            }
            .build()
        val mediaItem = MediaItem.Builder()
            .setUri(Uri.parse(url))
            .setMimeType(mimeType)
            .setMediaId(id)
            .build()
        val helper = DownloadHelper.Factory()
            .setRenderersFactory(DefaultRenderersFactory(appContext))
            .setDataSourceFactory(httpFactory)
            .setTrackSelectionParameters(trackParameters)
            .create(mediaItem)

        helper.prepare(object : DownloadHelper.Callback {
            override fun onPrepared(helper: DownloadHelper, tracksInfoAvailable: Boolean) {
                try {
                    val request = helper.getDownloadRequest(
                        id,
                        metadata.toString().toByteArray(StandardCharsets.UTF_8),
                    )
                    callback(Result.success(request))
                } catch (error: Exception) {
                    callback(Result.failure(error))
                } finally {
                    helper.release()
                }
            }

            override fun onPrepareError(helper: DownloadHelper, error: java.io.IOException) {
                helper.release()
                callback(Result.failure(error))
            }
        })
    }

    fun getDownload(id: String): Download? = downloadIndex.getDownload(id)

    fun getDownloads(): List<Download> {
        val result = mutableListOf<Download>()
        downloadIndex.getDownloads().use { cursor ->
            while (cursor.moveToNext()) result.add(cursor.download)
        }
        return result
    }

    fun readOnlyCacheFactory(): CacheDataSource.Factory = CacheDataSource.Factory()
        .setCache(cache)
        .setUpstreamDataSourceFactory(null)
        .setCacheWriteDataSinkFactory(null)

    fun downloadToMap(download: Download): Map<String, Any?> {
        val metadata = requestMetadata(download.request)
        val state = when (download.state) {
            Download.STATE_QUEUED -> "queued"
            Download.STATE_STOPPED -> "stopped"
            Download.STATE_DOWNLOADING -> "downloading"
            Download.STATE_COMPLETED -> "completed"
            Download.STATE_FAILED -> "failed"
            Download.STATE_REMOVING -> "removing"
            Download.STATE_RESTARTING -> "restarting"
            else -> "unknown"
        }
        val percent = download.percentDownloaded
            .takeIf { !it.isNaN() && it >= 0f }
            ?.toDouble() ?: if (download.state == Download.STATE_COMPLETED) 100.0 else 0.0
        return mapOf(
            "id" to download.request.id,
            "title" to metadata.optString("title", "Untitled"),
            "subtitle" to metadata.optString("subtitle").ifBlank { null },
            "mediaType" to metadata.optString("mediaType", "video"),
            "quality" to metadata.optString("quality", "Auto"),
            "posterUrl" to metadata.optString("posterUrl").ifBlank { null },
            "state" to state,
            "progress" to percent,
            "bytesDownloaded" to download.bytesDownloaded,
            "contentLength" to download.contentLength,
            "createdAt" to download.startTimeMs,
            "error" to if (download.state == Download.STATE_FAILED) "The download failed. Retry to try again." else null,
        )
    }

    private fun metadataJson(arguments: Map<*, *>): JSONObject = JSONObject().apply {
        put("title", arguments["title"] as? String ?: "Untitled")
        put("subtitle", arguments["subtitle"] as? String ?: "")
        put("mediaType", arguments["mediaType"] as? String ?: "video")
        put("quality", arguments["quality"] as? String ?: "Auto")
        put("posterUrl", arguments["posterUrl"] as? String ?: "")
        put("format", arguments["format"] as? String ?: "")
        val headers = JSONObject()
        (arguments["headers"] as? Map<*, *>)?.forEach { (key, value) ->
            if (key is String && value is String) headers.put(key, value)
        }
        put("headers", headers)
    }

    companion object {
        @Volatile
        private var instance: StreamDownloadStore? = null

        fun get(context: Context): StreamDownloadStore = instance ?: synchronized(this) {
            instance ?: StreamDownloadStore(context).also { instance = it }
        }

        fun requestMetadata(request: DownloadRequest): JSONObject = try {
            JSONObject(String(request.data, StandardCharsets.UTF_8))
        } catch (_: Exception) {
            JSONObject()
        }

        fun metadataHeaders(metadata: JSONObject): Map<String, String> {
            val headers = metadata.optJSONObject("headers") ?: return emptyMap()
            return buildMap {
                headers.keys().forEach { key -> put(key, headers.optString(key)) }
            }
        }

        fun httpFactory(headers: Map<String, String>): DefaultHttpDataSource.Factory =
            DefaultHttpDataSource.Factory()
                .setAllowCrossProtocolRedirects(true)
                .setUserAgent("FlixQuest/4.0")
                .setDefaultRequestProperties(headers)
    }
}

@UnstableApi
private class HeaderAwareDownloaderFactory(
    private val cache: SimpleCache,
    private val executor: ExecutorService,
) : DownloaderFactory {
    override fun createDownloader(request: DownloadRequest): Downloader {
        val metadata = StreamDownloadStore.requestMetadata(request)
        val upstream = StreamDownloadStore.httpFactory(
            StreamDownloadStore.metadataHeaders(metadata),
        )
        val cacheFactory = CacheDataSource.Factory()
            .setCache(cache)
            .setUpstreamDataSourceFactory(upstream)
        val mediaItem = request.toMediaItem()
        return when (request.mimeType) {
            MimeTypes.APPLICATION_M3U8 -> HlsDownloader(mediaItem, cacheFactory, executor)
            MimeTypes.APPLICATION_MPD -> DashDownloader(mediaItem, cacheFactory, executor)
            else -> ProgressiveDownloader(mediaItem, cacheFactory, executor)
        }
    }
}
