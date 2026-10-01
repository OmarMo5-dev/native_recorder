package com.example.native_recorder.recorder.file

import android.content.Context
import java.io.File

class RecordingFileManager(
    private val context: Context
) {
    private val recordingsDirectory: File by lazy {
        File(context.filesDir, "recordings").apply {
            if (!exists()) mkdirs()
        }
    }

    fun createRecordingFile(): File {
        return File(
            recordingsDirectory,
            "recording_${System.currentTimeMillis()}.m4a"
        )
    }

    fun getRecordings(): List<File> {
        return recordingsDirectory
            .listFiles()
            ?.filter { it.isFile }
            ?.sortedByDescending { it.lastModified() }
            ?: emptyList()
    }

    fun deleteRecording(path: String): Boolean {
        return File(path).delete()
    }
}
