package com.example.native_recorder.recorder.manager

import android.media.MediaPlayer

class PlaybackManager {
    private var mediaPlayer: MediaPlayer? = null

    fun play(path: String) {
        stop()

        mediaPlayer = MediaPlayer().apply {
            setDataSource(path)

            setOnCompletionListener {
                release()
                mediaPlayer = null
            }

            prepare()
            start()
        }
    }

    fun stop() {
        mediaPlayer?.let {
            if (it.isPlaying) it.stop()
            it.release()
        }

        mediaPlayer = null
    }
}
