package com.kaeset.messagesystem

import android.database.Cursor
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.kaeset.messagesystem/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSmsMessages" -> {
                    try {
                        val messages = readSmsMessages()
                        result.success(messages)
                    } catch (e: Exception) {
                        result.error("SMS_READ_ERROR", e.localizedMessage, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun readSmsMessages(): List<Map<String, Any?>> {
        val messageList = mutableListOf<Map<String, Any?>>()
        val uri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("_id", "address", "body", "date")
        
        // Filter for MPESA messages or messages containing confirmation keywords
        val selection = "address LIKE '%MPESA%' OR address LIKE '%M-PESA%' OR body LIKE '%Confirmed.%' OR body LIKE '%Ksh%'"
        val cursor: Cursor? = contentResolver.query(uri, projection, selection, null, "date DESC")

        cursor?.use {
            val idIdx = it.getColumnIndex("_id")
            val addressIdx = it.getColumnIndex("address")
            val bodyIdx = it.getColumnIndex("body")
            val dateIdx = it.getColumnIndex("date")

            while (it.moveToNext()) {
                val item = HashMap<String, Any?>()
                if (idIdx >= 0) item["id"] = it.getString(idIdx)
                if (addressIdx >= 0) item["address"] = it.getString(addressIdx)
                if (bodyIdx >= 0) item["body"] = it.getString(bodyIdx)
                if (dateIdx >= 0) item["date"] = it.getLong(dateIdx)
                messageList.add(item)
            }
        }
        return messageList
    }
}
