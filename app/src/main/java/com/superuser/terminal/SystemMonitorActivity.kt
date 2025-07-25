package com.superuser.terminal

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import com.superuser.terminal.databinding.ActivitySystemMonitorBinding
import java.io.File

class SystemMonitorActivity : AppCompatActivity() {
    private lateinit var binding: ActivitySystemMonitorBinding
    private val handler = Handler(Looper.getMainLooper())
    private var isMonitoring = false
    
    private val updateRunnable = object : Runnable {
        override fun run() {
            if (isMonitoring) {
                updateSystemInfo()
                handler.postDelayed(this, 2000) // Update every 2 seconds
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySystemMonitorBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupUI()
        startMonitoring()
    }
    
    private fun setupUI() {
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "System Monitor"
        
        binding.refreshButton.setOnClickListener {
            updateSystemInfo()
        }
        
        binding.startStopButton.setOnClickListener {
            if (isMonitoring) {
                stopMonitoring()
            } else {
                startMonitoring()
            }
        }
    }
    
    private fun startMonitoring() {
        isMonitoring = true
        binding.startStopButton.text = "Stop Monitoring"
        binding.statusIndicator.text = "● MONITORING"
        binding.statusIndicator.setTextColor(getColor(android.R.color.holo_green_light))
        handler.post(updateRunnable)
    }
    
    private fun stopMonitoring() {
        isMonitoring = false
        binding.startStopButton.text = "Start Monitoring"
        binding.statusIndicator.text = "● STOPPED"
        binding.statusIndicator.setTextColor(getColor(android.R.color.holo_red_light))
        handler.removeCallbacks(updateRunnable)
    }
    
    private fun updateSystemInfo() {
        lifecycleScope.launch {
            val systemInfo = withContext(Dispatchers.IO) {
                collectSystemInfo()
            }
            
            binding.systemInfoText.text = systemInfo
        }
    }
    
    private fun collectSystemInfo(): String {
        val info = StringBuilder()
        
        // System uptime
        try {
            val uptime = File("/proc/uptime").readText().split(" ")[0].toFloat()
            val hours = (uptime / 3600).toInt()
            val minutes = ((uptime % 3600) / 60).toInt()
            info.appendLine("Uptime: ${hours}h ${minutes}m")
        } catch (e: Exception) {
            info.appendLine("Uptime: Unknown")
        }
        
        // Memory info
        try {
            val memInfo = File("/proc/meminfo").readLines()
            val memTotal = memInfo.find { it.startsWith("MemTotal:") }?.split("\\s+".toRegex())?.get(1)?.toLong() ?: 0
            val memAvailable = memInfo.find { it.startsWith("MemAvailable:") }?.split("\\s+".toRegex())?.get(1)?.toLong() ?: 0
            val memUsed = memTotal - memAvailable
            val memUsagePercent = if (memTotal > 0) (memUsed * 100 / memTotal) else 0
            
            info.appendLine("Memory Usage: $memUsagePercent% (${memUsed/1024}MB/${memTotal/1024}MB)")
        } catch (e: Exception) {
            info.appendLine("Memory: Unknown")
        }
        
        // CPU load
        try {
            val loadAvg = File("/proc/loadavg").readText().split(" ")
            info.appendLine("CPU Load: ${loadAvg[0]} ${loadAvg[1]} ${loadAvg[2]}")
        } catch (e: Exception) {
            info.appendLine("CPU Load: Unknown")
        }
        
        // Temperature (if available)
        try {
            val tempFile = File("/sys/class/thermal/thermal_zone0/temp")
            if (tempFile.exists()) {
                val temp = tempFile.readText().trim().toInt() / 1000
                info.appendLine("Temperature: ${temp}°C")
            }
        } catch (e: Exception) {
            // Temperature not available
        }
        
        // Storage info
        try {
            val dataDir = File("/data")
            val totalSpace = dataDir.totalSpace / (1024 * 1024 * 1024)
            val freeSpace = dataDir.freeSpace / (1024 * 1024 * 1024)
            val usedSpace = totalSpace - freeSpace
            val storagePercent = if (totalSpace > 0) (usedSpace * 100 / totalSpace) else 0
            
            info.appendLine("Storage (/data): $storagePercent% (${usedSpace}GB/${totalSpace}GB)")
        } catch (e: Exception) {
            info.appendLine("Storage: Unknown")
        }
        
        // Process count
        try {
            val procCount = File("/proc").listFiles()?.count { it.name.matches("\\d+".toRegex()) } ?: 0
            info.appendLine("Running Processes: $procCount")
        } catch (e: Exception) {
            info.appendLine("Processes: Unknown")
        }
        
        // Root status
        val rootStatus = if (RootUtils.isDeviceRooted()) "✓ Available" else "✗ Not available"
        info.appendLine("Root Access: $rootStatus")
        
        // SELinux status
        try {
            val process = Runtime.getRuntime().exec("getenforce")
            val reader = process.inputStream.bufferedReader()
            val selinuxStatus = reader.readLine() ?: "Unknown"
            info.appendLine("SELinux: $selinuxStatus")
        } catch (e: Exception) {
            info.appendLine("SELinux: Unknown")
        }
        
        // Network interfaces
        try {
            val process = Runtime.getRuntime().exec("ip link show")
            val reader = process.inputStream.bufferedReader()
            val interfaces = reader.readLines().count { it.contains("state UP") }
            info.appendLine("Active Network Interfaces: $interfaces")
        } catch (e: Exception) {
            info.appendLine("Network: Unknown")
        }
        
        info.appendLine("\nLast Updated: ${java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date())}")
        
        return info.toString()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopMonitoring()
    }
    
    override fun onSupportNavigateUp(): Boolean {
        onBackPressed()
        return true
    }
}
