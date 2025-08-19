package com.superuser.terminal

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class SuperuserIntegration(private val context: Context) {
    
    private val superuserScriptPath = "/data/superuser/bin/Superuser_main"
    private val fallbackScriptPath = "/data/local/tmp/Superuser_main"
    
    suspend fun executeCommand(command: String): String = withContext(Dispatchers.IO) {
        try {
            when {
                command.startsWith("su-") -> executeSuperuserCommand(command)
                command == "help" -> getHelpText()
                command == "status" -> getSystemStatus()
                command == "monitor" -> getSystemMonitor()
                command == "benchmark" -> runBenchmark()
                else -> executeShellCommand(command)
            }
        } catch (e: Exception) {
            "Error: ${e.message}"
        }
    }
    
    private fun executeSuperuserCommand(command: String): String {
        val scriptPath = when {
            File(superuserScriptPath).exists() -> superuserScriptPath
            File(fallbackScriptPath).exists() -> fallbackScriptPath
            else -> return "Superuser script not found. Please run setup first."
        }
        
        val superuserCommand = when (command) {
            "su-check" -> "check"
            "su-fix" -> "fix"
            "su-backup" -> "backup"
            "su-setup" -> "setup"
            "su-health" -> "health"
            "su-network" -> "network"
            "su-security" -> "security"
            "su-optimize" -> "optimize"
            "su-full" -> "full"
            else -> command.removePrefix("su-")
        }
        
        return executeRootCommand("$scriptPath $superuserCommand")
    }
    
    private fun executeRootCommand(command: String): String {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", command))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val errorReader = BufferedReader(InputStreamReader(process.errorStream))
            
            val output = StringBuilder()
            var line: String?
            
            while (reader.readLine().also { line = it } != null) {
                output.appendLine(line)
            }
            
            while (errorReader.readLine().also { line = it } != null) {
                output.appendLine("ERROR: $line")
            }
            
            val exitCode = process.waitFor()
            reader.close()
            errorReader.close()
            
            if (exitCode != 0) {
                output.appendLine("Command exited with code: $exitCode")
            }
            
            output.toString().trimEnd()
        } catch (e: Exception) {
            "Failed to execute root command: ${e.message}"
        }
    }
    
    private fun executeShellCommand(command: String): String {
        return try {
            val process = Runtime.getRuntime().exec(command)
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = reader.readText()
            process.waitFor()
            reader.close()
            output.ifEmpty { "Command executed successfully" }
        } catch (e: Exception) {
            "Command failed: ${e.message}"
        }
    }
    
    private fun getHelpText(): String {
        return """
Enhanced Superuser Terminal Commands:

BASIC COMMANDS:
  help            - Show this help
  clear           - Clear screen
  status          - System status
  monitor         - System monitor

SUPERUSER COMMANDS:
  su-check        - Run system check
  su-fix          - Fix su permissions
  su-backup       - Create backup
  su-setup        - Run setup
  su-health       - Health monitor
  su-network      - Network diagnostics
  su-security     - Security audit
  su-optimize     - Optimization suggestions
  su-full         - Full diagnostic suite

FILE SYSTEM:
  ls [path]       - List directory
  cd <path>       - Change directory
  pwd             - Current directory
  mkdir <dir>     - Create directory
  cat <file>      - Read file
  df              - Disk usage
  free            - Memory usage

SYSTEM INFO:
  ps              - Process list
  top             - System resources
  uname           - System information
  date            - Current date/time
  whoami          - Current user
  id              - User ID info

NETWORK:
  ping <host>     - Ping host
  netstat         - Network connections
  ifconfig        - Network interfaces

Type any command to execute it.
        """.trimIndent()
    }
    
    private fun getSystemStatus(): String {
        val rootStatus = if (RootUtils.isDeviceRooted()) "✓ Rooted" else "✗ Not rooted"
        val superuserDir = if (File("/data/superuser").exists()) "✓ Present" else "✗ Missing"
        val timestamp = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date())
        
        return """
System Status Report:
Root Access: $rootStatus
Superuser Directory: $superuserDir
Android Version: ${android.os.Build.VERSION.RELEASE}
Device Model: ${android.os.Build.MODEL}
Architecture: ${System.getProperty("os.arch")}
Timestamp: $timestamp

Use 'su-check' for detailed system analysis.
        """.trimIndent()
    }
    
    private fun getSystemMonitor(): String {
        val runtime = Runtime.getRuntime()
        val totalMemory = runtime.totalMemory() / (1024 * 1024)
        val freeMemory = runtime.freeMemory() / (1024 * 1024)
        val usedMemory = totalMemory - freeMemory
        
        return """
System Monitor:
Memory Usage: ${usedMemory}MB / ${totalMemory}MB (${(usedMemory * 100 / totalMemory)}%)
Available Processors: ${runtime.availableProcessors()}
Current Time: ${java.util.Date()}

For continuous monitoring, use 'su-health' command.
        """.trimIndent()
    }
    
    private fun runBenchmark(): String {
        val startTime = System.currentTimeMillis()
        
        // Simple CPU benchmark
        var result = 0
        for (i in 1..100000) {
            result += i
        }
        
        val endTime = System.currentTimeMillis()
        val duration = endTime - startTime
        
        return """
Quick Benchmark Results:
CPU Test Duration: ${duration}ms
Calculation Result: $result
Performance: ${if (duration < 100) "Good" else if (duration < 500) "Average" else "Slow"}

For comprehensive benchmarking, use 'su-benchmark' command.
        """.trimIndent()
    }
    
    fun installSuperuserScript(): Boolean {
        return try {
            // Copy script from assets to executable location
            val scriptContent = context.assets.open("Superuser_main").bufferedReader().use { it.readText() }
            
            // Try to create directories and install script
            val installCommand = """
                mkdir -p /data/superuser/bin
                mkdir -p /data/local/tmp
                echo '$scriptContent' > /data/superuser/bin/Superuser_main
                chmod +x /data/superuser/bin/Superuser_main
                echo '$scriptContent' > /data/local/tmp/Superuser_main
                chmod +x /data/local/tmp/Superuser_main
            """.trimIndent()
            
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", installCommand))
            process.waitFor() == 0
        } catch (e: Exception) {
            false
        }
    }
}
