package com.example.zero_touch_car_diagnostics

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.zero_touch_car_diagnostics.ObdPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up OBD native channel for ELM327 and USB serial adapters
        ObdPlugin.setupChannel(flutterEngine, this)
    }
}
