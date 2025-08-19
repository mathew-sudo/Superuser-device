package com.superuser.terminal

import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

object RootUtils {
    
    fun isDeviceRooted(): Boolean {
        return checkRootMethod1() || checkRootMethod2() || checkRootMethod3()
    }
    
    private fun checkRootMethod1(): Boolean {
        val buildTags = android.os.Build.TAGS
        return buildTags != null && buildTags.contains("test-keys")
    }
    
    private fun checkRootMethod2(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )
        
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }
    
    private fun checkRootMethod3(): Boolean {
        var process: Process? = null
        return try {
            process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = reader.readLine()
            output != null && output.lowercase().contains("uid=0")
        } catch (e: Exception) {
            false
        } finally {
            process?.destroy()
        }
    }
    
    fun executeRootCommand(command: String): Pair<Boolean, String> {
        var process: Process? = null
        return try {
            process = Runtime.getRuntime().exec(arrayOf("su", "-c", command))
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
            Pair(exitCode == 0, output.toString().trim())
        } catch (e: Exception) {
            Pair(false, "Exception: ${e.message}")
        } finally {
            process?.destroy()
        }
    }
    
    fun checkSuBinary(): String {
        val suPaths = arrayOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/su/bin/su"
        )
        
        val results = StringBuilder()
        var workingCount = 0
        
        for (path in suPaths) {
            val file = File(path)
            if (file.exists()) {
                val perms = try {
                    val process = Runtime.getRuntime().exec(arrayOf("stat", "-c", "%a", path))
                    val reader = BufferedReader(InputStreamReader(process.inputStream))
                    reader.readLine() ?: "unknown"
                } catch (e: Exception) {
                    "unknown"
                }
                
                val isExecutable = file.canExecute()
                val status = if (perms == "6755" && isExecutable) {
                    workingCount++
                    "✓ OK"
                } else {
                    "✗ BAD"
                }
                
                results.appendLine("$status $path (perms: $perms, executable: $isExecutable)")
            }
        }
        
        results.appendLine("\nWorking su binaries: $workingCount")
        return results.toString()
    }
}
