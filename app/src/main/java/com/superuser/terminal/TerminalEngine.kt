package com.superuser.terminal

import android.content.Context
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.*
import java.util.concurrent.TimeUnit

class TerminalEngine(private val context: Context) {
    
    private val superuserScriptPath = "/data/superuser/bin/Superuser_main"
    private val fallbackScriptPath = "/data/local/tmp/Superuser_main"
    private var isInitialized = false
    
    data class CommandResult(
        val output: String,
        val error: String,
        val exitCode: Int,
        val executionTime: Long
    )
    
    suspend fun initialize(): Boolean = withContext(Dispatchers.IO) {
        try {
            // Check if superuser script exists
            if (!File(superuserScriptPath).exists() && !File(fallbackScriptPath).exists()) {
                // Try to extract from assets
                extractSuperuserScript()
            }
            
            // Test basic command execution
            val testResult = executeBasicCommand("echo 'Terminal engine test'")
            isInitialized = testResult.exitCode == 0
            
            if (isInitialized) {
                Log.d("TerminalEngine", "Terminal engine initialized successfully")
            } else {
                Log.e("TerminalEngine", "Terminal engine initialization failed")
            }
            
            isInitialized
        } catch (e: Exception) {
            Log.e("TerminalEngine", "Initialization error", e)
            false
        }
    }
    
    suspend fun executeCommand(command: String, workingDirectory: String): CommandResult = withContext(Dispatchers.IO) {
        val startTime = System.currentTimeMillis()
        
        try {
            when {
                command.startsWith("su-") -> executeSuperuserCommand(command, workingDirectory)
                command.startsWith("cd ") -> handleChangeDirectory(command, workingDirectory)
                command in listOf("help", "status", "monitor") -> executeBuiltinCommand(command)
                else -> executeShellCommand(command, workingDirectory)
            }
        } catch (e: Exception) {
            CommandResult(
                output = "",
                error = "Command execution failed: ${e.message}",
                exitCode = -1,
                executionTime = System.currentTimeMillis() - startTime
            )
        }
    }
    
    private fun executeSuperuserCommand(command: String, workingDirectory: String): CommandResult {
        val scriptPath = when {
            File(superuserScriptPath).exists() -> superuserScriptPath
            File(fallbackScriptPath).exists() -> fallbackScriptPath
            else -> return CommandResult("", "Superuser script not found", 1, 0)
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
            "su-benchmark" -> "benchmark"
            else -> command.removePrefix("su-")
        }
        
        return executeRootCommand("cd '$workingDirectory' && '$scriptPath' $superuserCommand")
    }
    
    private fun executeRootCommand(command: String): CommandResult {
        val startTime = System.currentTimeMillis()
        
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", command))
            val output = StringBuilder()
            val error = StringBuilder()
            
            // Read output streams
            val outputReader = BufferedReader(InputStreamReader(process.inputStream))
            val errorReader = BufferedReader(InputStreamReader(process.errorStream))
            
            // Read output
            outputReader.useLines { lines ->
                lines.forEach { line ->
                    output.appendLine(line)
                }
            }
            
            // Read error
            errorReader.useLines { lines ->
                lines.forEach { line ->
                    error.appendLine(line)
                }
            }
            
            val exitCode = process.waitFor()
            val executionTime = System.currentTimeMillis() - startTime
            
            CommandResult(
                output = output.toString().trim(),
                error = error.toString().trim(),
                exitCode = exitCode,
                executionTime = executionTime
            )
        } catch (e: Exception) {
            CommandResult(
                output = "",
                error = "Root command execution failed: ${e.message}",
                exitCode = -1,
                executionTime = System.currentTimeMillis() - startTime
            )
        }
    }
    
    private fun executeShellCommand(command: String, workingDirectory: String): CommandResult {
        val startTime = System.currentTimeMillis()
        
        return try {
            val processBuilder = ProcessBuilder("/system/bin/sh", "-c", command)
            processBuilder.directory(File(workingDirectory))
            
            val process = processBuilder.start()
            val output = StringBuilder()
            val error = StringBuilder()
            
            // Read output streams
            val outputReader = BufferedReader(InputStreamReader(process.inputStream))
            val errorReader = BufferedReader(InputStreamReader(process.errorStream))
            
            // Read output
            outputReader.useLines { lines ->
                lines.forEach { line ->
                    output.appendLine(line)
                }
            }
            
            // Read error
            errorReader.useLines { lines ->
                lines.forEach { line ->
                    error.appendLine(line)
                }
            }
            
            val exitCode = if (process.waitFor(10, TimeUnit.SECONDS)) {
                process.exitValue()
            } else {
                process.destroyForcibly()
                -1
            }
            
            val executionTime = System.currentTimeMillis() - startTime
            
            CommandResult(
                output = output.toString().trim(),
                error = error.toString().trim(),
                exitCode = exitCode,
                executionTime = executionTime
            )
        } catch (e: Exception) {
            CommandResult(
                output = "",
                error = "Shell command execution failed: ${e.message}",
                exitCode = -1,
                executionTime = System.currentTimeMillis() - startTime
            )
        }
    }
    
    private fun executeBasicCommand(command: String): CommandResult {
        return executeShellCommand(command, "/data")
    }
    
    private fun handleChangeDirectory(command: String, currentDirectory: String): CommandResult {
        val targetDir = command.substringAfter("cd ").trim()
        val newDir = if (targetDir.startsWith("/")) {
            targetDir
        } else {
            "$currentDirectory/$targetDir"
        }
        
        return if (File(newDir).exists() && File(newDir).isDirectory) {
            CommandResult("", "", 0, 0)
        } else {
            CommandResult("", "cd: $targetDir: No such file or directory", 1, 0)
        }
    }
    
    private fun executeBuiltinCommand(command: String): CommandResult {
        val output = when (command) {
            "help" -> getHelpText()
            "status" -> getSystemStatus()
            "monitor" -> getSystemMonitor()
            else -> "Unknown builtin command: $command"
        }
        
        return CommandResult(output, "", 0, 0)
    }
    
    private fun getHelpText(): String {
        return """
Enhanced Superuser Terminal Commands:

BASIC COMMANDS:
  help            - Show this help
  clear           - Clear screen
  exit            - Exit terminal
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
  su-benchmark    - Performance benchmark

FILE SYSTEM:
  ls [path]       - List directory
  cd <path>       - Change directory
  pwd             - Current directory
  mkdir <dir>     - Create directory
  rm <file>       - Remove file
  cat <file>      - Read file
  cp <src> <dst>  - Copy file
  mv <src> <dst>  - Move file
  find <pattern>  - Find files
  grep <pattern>  - Search text

SYSTEM INFO:
  ps              - Process list
  top             - System resources
  df              - Disk usage
  free            - Memory usage
  mount           - Mount points
  uname           - System information
  date            - Current date/time
  whoami          - Current user
  id              - User ID info
  env             - Environment variables

NETWORK:
  ping <host>     - Ping host
  netstat         - Network connections
  ifconfig        - Network interfaces

TERMINAL FEATURES:
  • Use arrow keys for command history
  • Tab for auto-completion
  • Ctrl+C to interrupt commands
  • Swipe down to refresh status

Type any command to execute it.
        """.trimIndent()
    }
    
    fun getSystemStatus(): String {
        val rootStatus = if (RootUtils.isDeviceRooted()) "✓ Available" else "✗ Not available"
        val superuserDir = if (File("/data/superuser").exists()) "✓ Present" else "✗ Missing"
        val timestamp = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date())
        
        return """
System Status Report:
==================
Root Access: $rootStatus
Superuser Directory: $superuserDir
Android Version: ${android.os.Build.VERSION.RELEASE}
API Level: ${android.os.Build.VERSION.SDK_INT}
Device Model: ${android.os.Build.MODEL}
Device Brand: ${android.os.Build.BRAND}
Architecture: ${System.getProperty("os.arch")}
Terminal Engine: ${if (isInitialized) "✓ Initialized" else "✗ Not initialized"}
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
==============
App Memory Usage: ${usedMemory}MB / ${totalMemory}MB (${(usedMemory * 100 / totalMemory)}%)
Available Processors: ${runtime.availableProcessors()}
Current Time: ${java.util.Date()}

For comprehensive monitoring, use 'su-health' command.
        """.trimIndent()
    }
    
    private fun extractSuperuserScript(): Boolean {
        return try {
            val inputStream = context.assets.open("Superuser_main")
            val outputFile = File(fallbackScriptPath)
            
            outputFile.parentFile?.mkdirs()
            outputFile.writeBytes(inputStream.readBytes())
            outputFile.setExecutable(true)
            
            inputStream.close()
            true
        } catch (e: Exception) {
            Log.e("TerminalEngine", "Failed to extract superuser script", e)
            false
        }
    }
    
    fun exportHistory(commandHistory: List<TerminalCommand>): String? {
        return try {
            val exportDir = File(context.getExternalFilesDir(null), "exports")
            exportDir.mkdirs()
            
            val timestamp = java.text.SimpleDateFormat("yyyyMMdd_HHmmss", java.util.Locale.getDefault()).format(java.util.Date())
            val exportFile = File(exportDir, "terminal_history_$timestamp.txt")
            
            exportFile.writeText(buildString {
                appendLine("Enhanced Superuser Terminal History Export")
                appendLine("Generated: ${java.util.Date()}")
                appendLine("=" * 50)
                appendLine()
                
                commandHistory.forEach { cmd ->
                    val timestamp = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.getDefault()).format(java.util.Date(cmd.timestamp))
                    appendLine("[$timestamp] [${cmd.type}] ${cmd.directory}")
                    appendLine(cmd.command)
                    appendLine("-" * 30)
                }
            })
            
            exportFile.absolutePath
        } catch (e: Exception) {
            Log.e("TerminalEngine", "Failed to export history", e)
            null
        }
    }
    
    fun cleanup() {
        // Cleanup resources if needed
        Log.d("TerminalEngine", "Terminal engine cleanup completed")
    }
}
