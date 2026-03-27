package com.choksiinfotech.sim_info_plugin

import android.content.Context
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.SubscriptionInfo
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SimInfoPlugin */
class SimInfoPlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sim_info_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "getSimCardsDirect") {
            val simList = getActiveSimCards()
            result.success(simList)
        } else {
            result.notImplemented()
        }
    }

    private fun getActiveSimCards(): List<Map<String, Any?>> {
        val simList = mutableListOf<Map<String, Any?>>()
        try {
            val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
            val activeSubscriptions: List<SubscriptionInfo>? = subscriptionManager.activeSubscriptionInfoList

            activeSubscriptions?.forEach { info ->
                val simData = mutableMapOf<String, Any?>()
                
                var number = ""
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    try {
                        number = subscriptionManager.getPhoneNumber(info.subscriptionId)
                    } catch (e: Exception) {
                        number = info.number ?: ""
                    }
                } else {
                    @Suppress("DEPRECATION")
                    number = info.number ?: ""
                }

                simData["number"] = number
                simData["carrierName"] = info.displayName.toString()
                simData["slotIndex"] = info.simSlotIndex
                simData["subscriptionId"] = info.subscriptionId
                
                simList.add(simData)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return simList
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
