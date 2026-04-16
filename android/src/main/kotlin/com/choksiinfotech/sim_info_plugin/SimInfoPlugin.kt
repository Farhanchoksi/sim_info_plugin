package com.choksiinfotech.sim_info_plugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.SubscriptionManager
import android.telephony.SubscriptionInfo
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SimInfoPlugin */
class SimInfoPlugin :
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private val mainHandler = Handler(Looper.getMainLooper())

    private var eventSink: EventChannel.EventSink? = null
    private var simStateReceiver: BroadcastReceiver? = null
    private var subscriptionsChangedListener: SubscriptionManager.OnSubscriptionsChangedListener? = null
    private var subscriptionManager: SubscriptionManager? = null
    private var isMonitoringSimChanges = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
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

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startSimMonitoring()
        emitActiveSimCards()
    }

    override fun onCancel(arguments: Any?) {
        stopSimMonitoring()
        eventSink = null
    }

    private fun startSimMonitoring() {
        if (isMonitoringSimChanges) {
            return
        }
        isMonitoringSimChanges = true
        registerSimBroadcastReceiver()
        registerSubscriptionsChangedListener()
    }

    private fun stopSimMonitoring() {
        if (!isMonitoringSimChanges) {
            return
        }
        isMonitoringSimChanges = false
        unregisterSimBroadcastReceiver()
        unregisterSubscriptionsChangedListener()
    }

    private fun registerSimBroadcastReceiver() {
        if (simStateReceiver != null) {
            return
        }

        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                emitActiveSimCards()
            }
        }

        val filter = IntentFilter().apply {
            addAction(ACTION_SIM_STATE_CHANGED)
            addAction(ACTION_SIM_CARD_STATE_CHANGED)
            addAction(ACTION_SIM_APPLICATION_STATE_CHANGED)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            context.registerReceiver(receiver, filter)
        }

        simStateReceiver = receiver
    }

    private fun unregisterSimBroadcastReceiver() {
        val receiver = simStateReceiver ?: return
        try {
            context.unregisterReceiver(receiver)
        } catch (_: IllegalArgumentException) {
            // Receiver was already unregistered.
        }
        simStateReceiver = null
    }

    private fun registerSubscriptionsChangedListener() {
        if (subscriptionsChangedListener != null) {
            return
        }

        val manager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager ?: return
        subscriptionManager = manager

        val listener = object : SubscriptionManager.OnSubscriptionsChangedListener() {
            override fun onSubscriptionsChanged() {
                emitActiveSimCards()
            }
        }

        subscriptionsChangedListener = listener

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            manager.addOnSubscriptionsChangedListener(context.mainExecutor, listener)
        } else {
            @Suppress("DEPRECATION")
            manager.addOnSubscriptionsChangedListener(listener)
        }
    }

    private fun unregisterSubscriptionsChangedListener() {
        val manager = subscriptionManager ?: return
        val listener = subscriptionsChangedListener ?: return
        manager.removeOnSubscriptionsChangedListener(listener)
        subscriptionsChangedListener = null
        subscriptionManager = null
    }

    private fun emitActiveSimCards() {
        val sink = eventSink ?: return
        val simList = getActiveSimCards()
        mainHandler.post {
            sink.success(simList)
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
        stopSimMonitoring()
        eventSink = null
        eventChannel.setStreamHandler(null)
        methodChannel.setMethodCallHandler(null)
    }

    private companion object {
        const val METHOD_CHANNEL_NAME = "sim_info_plugin"
        const val EVENT_CHANNEL_NAME = "sim_info_plugin_events"
        const val ACTION_SIM_STATE_CHANGED = "android.intent.action.SIM_STATE_CHANGED"
        const val ACTION_SIM_CARD_STATE_CHANGED = "android.telephony.action.SIM_CARD_STATE_CHANGED"
        const val ACTION_SIM_APPLICATION_STATE_CHANGED = "android.telephony.action.SIM_APPLICATION_STATE_CHANGED"
    }
}
