package com.reactnativetcpsocket

import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import java.io.InputStream
import java.io.OutputStream
import java.net.Socket

class TcpClientModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    private var socket: Socket? = null
    private var outputStream: OutputStream? = null
    private var inputStream: InputStream? = null
    private var listenThread: Thread? = null

    private val reactContext = reactContext

    override fun getName(): String {
        return "TcpClient"
    }

    private fun sendEvent(event: String, data: WritableMap = Arguments.createMap()) {
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(event, data)
    }

    @ReactMethod
    fun connect(host: String, port: Int) {
        Thread {
            try {
                socket = Socket(host, port)
                outputStream = socket?.getOutputStream()
                inputStream = socket?.getInputStream()

                sendEvent("connect")

                listenThread = Thread {
                    try {
                        val buffer = ByteArray(1024)
                        var bytes: Int

                        while (socket?.isClosed == false && inputStream?.read(buffer).also { bytes = it ?: -1 } != -1) {
                            val received = String(buffer, 0, bytes)
                            val params = Arguments.createMap()
                            params.putString("data", received)
                            sendEvent("data", params)
                        }
                    } catch (e: Exception) {
                        val err = Arguments.createMap()
                        err.putString("message", e.message)
                        sendEvent("error", err)
                    } finally {
                        sendEvent("close")
                    }
                }
                listenThread?.start()

            } catch (e: Exception) {
                val err = Arguments.createMap()
                err.putString("message", e.message)
                sendEvent("error", err)
            }
        }.start()
    }

    @ReactMethod
    fun write(message: String) {
        Thread {
            try {
                outputStream?.write(message.toByteArray())
                outputStream?.flush()
            } catch (e: Exception) {
                val err = Arguments.createMap()
                err.putString("message", e.message)
                sendEvent("error", err)
            }
        }.start()
    }

    @ReactMethod
    fun disconnect() {
        try {
            socket?.close()
            sendEvent("close")
        } catch (e: Exception) {
            val err = Arguments.createMap()
            err.putString("message", e.message)
            sendEvent("error", err)
        }
    }
}
