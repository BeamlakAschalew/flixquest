package dev.beamlak.flixquest_v2.downloads

import android.content.Context
import androidx.media3.common.util.Clock
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DataSourceBitmapLoader
import androidx.media3.exoplayer.offline.Download
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.transformer.Composition
import androidx.media3.transformer.DefaultAssetLoaderFactory
import androidx.media3.transformer.DefaultDecoderFactory
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.Transformer
import java.io.File
import java.util.concurrent.CancellationException

@UnstableApi
class StreamDownloadExporter(
    context: Context,
    private val store: StreamDownloadStore,
) {
    private val appContext = context.applicationContext
    private val exportDirectory = File(appContext.cacheDir, "offline_exports")
    private var activeExportId: String? = null
    private var activeTransformer: Transformer? = null
    private val callbacks = mutableListOf<(Result<File>) -> Unit>()

    fun export(downloadId: String, callback: (Result<File>) -> Unit) {
        val download = store.getDownload(downloadId)
        if (download == null || download.state != Download.STATE_COMPLETED) {
            callback(Result.failure(IllegalStateException("The download must finish before it can be exported.")))
            return
        }

        val output = outputFile(download)
        if (output.isFile && output.length() > 0) {
            callback(Result.success(output))
            return
        }
        if (activeExportId == downloadId) {
            callbacks.add(callback)
            return
        }
        if (activeExportId != null) {
            callback(Result.failure(IllegalStateException("Another video is already being prepared.")))
            return
        }
        if (!exportDirectory.exists() && !exportDirectory.mkdirs()) {
            callback(Result.failure(IllegalStateException("Could not create the video export directory.")))
            return
        }

        activeExportId = downloadId
        callbacks.add(callback)
        val mediaSourceFactory = DefaultMediaSourceFactory(store.readOnlyCacheFactory())
        val assetLoaderFactory = DefaultAssetLoaderFactory(
            appContext,
            DefaultDecoderFactory.Builder(appContext).build(),
            Clock.DEFAULT,
            mediaSourceFactory,
            DataSourceBitmapLoader(appContext),
        )
        val listener = object : Transformer.Listener {
            override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                finish(Result.success(output))
            }

            override fun onError(
                composition: Composition,
                exportResult: ExportResult,
                exportException: ExportException,
            ) {
                output.delete()
                finish(Result.failure(exportException))
            }
        }
        try {
            activeTransformer = Transformer.Builder(appContext)
                .setAssetLoaderFactory(assetLoaderFactory)
                .addListener(listener)
                .build()
                .also { it.start(download.request.toMediaItem(), output.absolutePath) }
        } catch (error: Exception) {
            output.delete()
            finish(Result.failure(error))
        }
    }

    fun deleteExport(downloadId: String) {
        if (activeExportId == downloadId) {
            activeTransformer?.cancel()
            finish(Result.failure(CancellationException("Video export was cancelled.")))
        }
        exportDirectory.listFiles()
            ?.filter { it.name.endsWith("-${Integer.toHexString(downloadId.hashCode())}.mp4") }
            ?.forEach(File::delete)
    }

    private fun finish(result: Result<File>) {
        val completedCallbacks = callbacks.toList()
        callbacks.clear()
        activeTransformer = null
        activeExportId = null
        completedCallbacks.forEach { it(result) }
    }

    private fun outputFile(download: Download): File {
        val metadata = StreamDownloadStore.requestMetadata(download.request)
        val title = metadata.optString("title", "FlixQuest video")
            .replace(Regex("[^a-zA-Z0-9._ -]"), "_")
            .trim(' ', '.')
            .take(80)
            .ifBlank { "FlixQuest video" }
        val suffix = Integer.toHexString(download.request.id.hashCode())
        return File(exportDirectory, "$title-$suffix.mp4")
    }
}
