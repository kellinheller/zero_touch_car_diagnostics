package com.example.zero_touch_car_diagnostics

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID
import kotlin.concurrent.thread

object ObdPlugin : MethodCallHandler {
    private const val CHANNEL = "zero_touch.obd"
    private val adapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private var socket: BluetoothSocket? = null
    private var input: InputStream? = null
    private var output: OutputStream? = null
    private var appContext: Context? = null

    fun setupChannel(flutterEngine: FlutterEngine, context: Context) {
        appContext = context.applicationContext
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "connect" -> {
                val address = call.argument<String>("address")
                if (address == null) {
                    result.error("invalid_args", "Missing bluetooth address", null)
                    return
                }
                thread {
                    try {
                        connectDevice(address)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("connect_error", e.message, null)
                    }
                }
            }
            "disconnect" -> {
                thread {
                    try {
                        socket?.close()
                        socket = null
                        input = null
                        output = null
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("disconnect_error", e.message, null)
                    }
                }
            }
            "sendCommand" -> {
                val cmd = call.argument<String>("cmd") ?: ""
                thread {
                    try {
                        val resp = sendObdCommand(cmd)
                        result.success(resp)
                    } catch (e: Exception) {
                        result.error("send_error", e.message, null)
                    }
                }
            }
            "listPaired" -> {
                thread {
                    try {
                        val btAdapter = adapter ?: throw Exception("Bluetooth not supported")
                        val paired = btAdapter.bondedDevices
                        val list = paired.map { mapOf("name" to (it.name ?: ""), "address" to it.address) }
                        result.success(list)
                    } catch (e: Exception) {
                        result.error("list_error", e.message, null)
                    }
                }
            }
            "scan" -> {
                val timeout = call.argument<Int>("timeout") ?: 8
                thread {
                    try {
                        val ctx = appContext ?: throw Exception("Context not available")
                        val found = mutableMapOf<String, String>()
                        val filter = android.content.IntentFilter()
                        filter.addAction(BluetoothDevice.ACTION_FOUND)
                        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)

                        val receiver = object : android.content.BroadcastReceiver() {
                            override fun onReceive(c: Context?, intent: android.content.Intent?) {
                                val action = intent?.action
                                if (action == BluetoothDevice.ACTION_FOUND) {
                                    val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                                    if (device != null) {
                                        found[device.address] = device.name ?: ""
                                    }
                                }
                            }
                        }

                        ctx.registerReceiver(receiver, filter)
                        val btAdapter = adapter ?: throw Exception("Bluetooth not supported")
                        btAdapter.cancelDiscovery()
                        btAdapter.startDiscovery()
                        Thread.sleep((timeout * 1000).toLong())
                        btAdapter.cancelDiscovery()
                        try { ctx.unregisterReceiver(receiver) } catch (_: Exception) {}

                        val list = found.map { mapOf("name" to it.value, "address" to it.key) }
                        result.success(list)
                    } catch (e: Exception) {
                        result.error("scan_error", e.message, null)
                    }
                }
            }
            "pair" -> {
                val address = call.argument<String>("address")
                if (address == null) {
                    result.error("invalid_args", "Missing bluetooth address", null)
                    return
                }
                thread {
                    try {
                        val btAdapter = adapter ?: throw Exception("Bluetooth not supported")
                        val device = btAdapter.getRemoteDevice(address)
                        val ok = try { device.createBond() } catch (e: Exception) { false }
                        result.success(ok)
                    } catch (e: Exception) {
                        result.error("pair_error", e.message, null)
                    }
                }
            }
            "ping" -> {
                thread {
                    try {
                        // Use 0100 (request supported PIDs) as a lightweight health check
                        val resp = sendObdCommand("0100")
                        val healthy = resp.isNotEmpty()
                        result.success(mapOf("healthy" to healthy, "response" to resp))
                    } catch (e: Exception) {
                        result.error("ping_error", e.message, null)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    @Throws(Exception::class)
    private fun connectDevice(address: String) {
        val btAdapter = adapter ?: throw Exception("Bluetooth not supported")
        if (!btAdapter.isEnabled) throw Exception("Bluetooth is disabled")
        val device: BluetoothDevice = btAdapter.getRemoteDevice(address)
        val uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        socket = device.createRfcommSocketToServiceRecord(uuid)
        btAdapter.cancelDiscovery()
        socket?.connect()
        input = socket?.inputStream
        output = socket?.outputStream
        // Basic init sequence for ELM327
        sendObdCommand("ATZ")
        sendObdCommand("ATE0")
        sendObdCommand("ATL0")
        sendObdCommand("ATS0")
        sendObdCommand("ATSP0")
    }

    @Throws(Exception::class)
    private fun sendObdCommand(cmd: String, timeoutMs: Long = 1500): String {
        val out = output ?: throw Exception("Not connected")
        val `in` = input ?: throw Exception("Not connected")
        val command = if (cmd.endsWith("\r")) cmd else cmd + "\r"
        out.write(command.toByteArray())
        out.flush()

        val buffer = ByteArray(1024)
        val sb = StringBuilder()
        val start = System.currentTimeMillis()
        while (System.currentTimeMillis() - start < timeoutMs) {
            if (`in`.available() > 0) {
                val read = `in`.read(buffer)
                if (read > 0) {
                    val s = String(buffer, 0, read)
                    sb.append(s)
                    // ELM327 prompt '>' indicates ready for next command
                    if (s.contains(">")) break
                }
            } else {
                Thread.sleep(50)
            }
        }
        return sb.toString().trim()
    }
}
