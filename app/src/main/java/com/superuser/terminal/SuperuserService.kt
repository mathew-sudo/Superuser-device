package com.superuser.terminal

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.util.Log
import kotlinx.coroutines.*

class SuperuserService : Service() {
    private val binder = SuperuserBinder()
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    inner class SuperuserBinder : Binder() {
        fun getService(): SuperuserService = this@SuperuserService
    }
    
    override fun onBind(intent: Intent): IBinder {
        return binder
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d("SuperuserService", "Service created")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
        Log.d("SuperuserService", "Service destroyed")
    }
    
    fun executeCommandAsync(command: String, callback: (String) -> Unit) {
        serviceScope.launch {
            try {
                val result = when {
                    command.startsWith("su ") -> {
                        val rootCommand = command.removePrefix("su ")
                        val (success, output) = RootUtils.executeRootCommand(rootCommand)
                        if (success) output else "Failed: $output"
                    }
                    command == "check-root" -> {
                        if (RootUtils.isDeviceRooted()) "Root access available" else "Root access not available"
                    }
                    command == "su-binaries" -> {
                        RootUtils.checkSuBinary()
                    }
                    else -> {
                        "Unknown command: $command"
                    }
                }
                
                withContext(Dispatchers.Main) {
                    callback(result)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    callback("Error: ${e.message}")
                }
            }
        }
    }
    
    fun checkSystemHealth(callback: (String) -> Unit) {
        serviceScope.launch {
            try {
                val healthReport = StringBuilder()
                
                // Check root status
                val rootStatus = if (RootUtils.isDeviceRooted()) "✓ Available" else "✗ Not available"
                healthReport.appendLine("Root Access: $rootStatus")
                
                // Check memory
                try {
                    val runtime = Runtime.getRuntime()
                    val totalMem = runtime.totalMemory() / (1024 * 1024)
                    val freeMem = runtime.freeMemory() / (1024 * 1024)
                    val usedMem = totalMem - freeMem
                    healthReport.appendLine("App Memory: ${usedMem}MB / ${totalMem}MB")
                } catch (e: Exception) {
                    healthReport.appendLine("Memory: Error - ${e.message}")
                }
                
                // Check storage
                try {
                    val dataDir = filesDir
                    val totalSpace = dataDir.totalSpace / (1024 * 1024)
                    val freeSpace = dataDir.freeSpace / (1024 * 1024)
                    healthReport.appendLine("Storage: ${freeSpace}MB free of ${totalSpace}MB")
                } catch (e: Exception) {
                    healthReport.appendLine("Storage: Error - ${e.message}")
                }
                
                withContext(Dispatchers.Main) {
                    callback(healthReport.toString())
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    callback("Health check failed: ${e.message}")
                }
            }
        }
    }
}
