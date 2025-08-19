package com.superuser.terminal

import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.text.SimpleDateFormat
import java.util.*

data class TerminalCommand(
    val command: String,
    val timestamp: Long,
    val directory: String,
    val type: Type
) {
    enum class Type {
        USER,       // User input command
        OUTPUT,     // Command output
        ERROR,      // Error output
        SYSTEM      // System messages
    }
}

class Terminal {
    private var currentDirectory = File("/")
    private val history = mutableListOf<String>()

    fun executeCommand(command: String): String {
        if (command.isBlank()) return ""
        
        history.add(command)
        val parts = command.trim().split(" ")
        val cmd = parts[0].lowercase()
        val args = parts.drop(1)

        return try {
            when (cmd) {
                "help" -> getHelpText()
                "clear" -> "CLEAR_SCREEN"
                "pwd" -> currentDirectory.absolutePath
                "ls" -> listDirectory(args)
                "cd" -> changeDirectory(args)
                "date" -> SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())
                "echo" -> args.joinToString(" ")
                "whoami" -> System.getProperty("user.name") ?: "android"
                "uname" -> "Android ${android.os.Build.VERSION.RELEASE}"
                "history" -> history.mapIndexed { index, cmd -> "${index + 1}: $cmd" }.joinToString("\n")
                "mkdir" -> createDirectory(args)
                "cat" -> readFile(args)
                "ps" -> "PID COMMAND\n1 init\n${android.os.Process.myPid()} terminal"
                else -> executeSystemCommand(command)
            }
        } catch (e: Exception) {
            "Error: ${e.message}"
        }
    }

    private fun getHelpText(): String {
        return """
Available commands:
  help     - Show this help message
  clear    - Clear the screen
  pwd      - Print working directory
  ls       - List directory contents
  cd       - Change directory
  date     - Show current date and time
  echo     - Display text
  whoami   - Show current user
  uname    - Show system info
  history  - Show command history
  mkdir    - Create directory
  cat      - Display file contents
  ps       - Show processes
        """.trimIndent()
    }

    private fun listDirectory(args: List<String>): String {
        val dir = if (args.isNotEmpty()) {
            File(currentDirectory, args[0])
        } else {
            currentDirectory
        }

        if (!dir.exists()) return "ls: ${dir.name}: No such file or directory"
        if (!dir.isDirectory) return "ls: ${dir.name}: Not a directory"

        val files = dir.listFiles() ?: return "Permission denied"
        return files.joinToString("\n") { file ->
            val type = if (file.isDirectory) "d" else "-"
            val perms = if (file.canRead()) "r" else "-" +
                       if (file.canWrite()) "w" else "-" +
                       if (file.canExecute()) "x" else "-"
            "$type$perms $type$perms $type$perms ${file.name}"
        }
    }

    private fun changeDirectory(args: List<String>): String {
        if (args.isEmpty()) {
            currentDirectory = File("/")
            return ""
        }

        val newDir = if (args[0].startsWith("/")) {
            File(args[0])
        } else {
            File(currentDirectory, args[0])
        }

        return if (newDir.exists() && newDir.isDirectory) {
            currentDirectory = newDir.canonicalFile
            ""
        } else {
            "cd: ${args[0]}: No such file or directory"
        }
    }

    private fun createDirectory(args: List<String>): String {
        if (args.isEmpty()) return "mkdir: missing operand"
        
        val dir = File(currentDirectory, args[0])
        return if (dir.mkdirs()) {
            ""
        } else {
            "mkdir: cannot create directory '${args[0]}': Permission denied"
        }
    }

    private fun readFile(args: List<String>): String {
        if (args.isEmpty()) return "cat: missing operand"
        
        val file = File(currentDirectory, args[0])
        return if (file.exists() && file.isFile) {
            try {
                file.readText()
            } catch (e: Exception) {
                "cat: ${args[0]}: Permission denied"
            }
        } else {
            "cat: ${args[0]}: No such file or directory"
        }
    }

    private fun executeSystemCommand(command: String): String {
        return try {
            val process = Runtime.getRuntime().exec(command)
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = reader.readText()
            process.waitFor()
            output.ifEmpty { "Command executed successfully" }
        } catch (e: Exception) {
            "Command not found: $command"
        }
    }
}
