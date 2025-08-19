package com.superuser.terminal

import android.content.Intent
import android.os.Bundle
import android.view.KeyEvent
import android.view.Menu
import android.view.MenuItem
import android.view.inputmethod.EditorInfo
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import com.superuser.terminal.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private lateinit var superuserIntegration: SuperuserIntegration
    private val terminalCommand = TerminalCommand()
    private val commandHistory = mutableListOf<String>()
    private var historyIndex = -1
    private var currentDirectory = "/data"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        superuserIntegration = SuperuserIntegration(this)
        setupTerminal()
        showWelcomeMessage()
        checkRootAndSetup()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_clear -> {
                clearTerminal()
                true
            }
            R.id.action_system_monitor -> {
                startActivity(Intent(this, SystemMonitorActivity::class.java))
                true
            }
            R.id.action_help -> {
                executeCommandInternal("help")
                true
            }
            R.id.action_settings -> {
                showSettingsDialog()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun setupTerminal() {
        binding.commandInput.setOnEditorActionListener { _, actionId, event ->
            if (actionId == EditorInfo.IME_ACTION_DONE || 
                (event?.keyCode == KeyEvent.KEYCODE_ENTER && event.action == KeyEvent.ACTION_DOWN)) {
                executeCommand()
                true
            } else {
                false
            }
        }

        binding.commandInput.setOnKeyListener { _, keyCode, event ->
            if (event.action == KeyEvent.ACTION_DOWN) {
                when (keyCode) {
                    KeyEvent.KEYCODE_DPAD_UP -> {
                        navigateHistory(-1)
                        true
                    }
                    KeyEvent.KEYCODE_DPAD_DOWN -> {
                        navigateHistory(1)
                        true
                    }
                    KeyEvent.KEYCODE_TAB -> {
                        autoComplete()
                        true
                    }
                    else -> false
                }
            } else {
                false
            }
        }

        // Focus on input
        binding.commandInput.requestFocus()
    }

    private fun showWelcomeMessage() {
        val welcomeMessage = """
╔══════════════════════════════════════════════════╗
║        Enhanced Superuser Terminal v1.1          ║
║              Android Integration                 ║
╚══════════════════════════════════════════════════╝

Welcome to the Enhanced Superuser Terminal!
Type 'help' for available commands
Type 'su-check' to run system diagnostics
Type 'status' for quick system status

"""
        binding.terminalOutput.text = welcomeMessage + getPrompt()
    }

    private fun checkRootAndSetup() {
        lifecycleScope.launch {
            val isRooted = withContext(Dispatchers.IO) {
                RootUtils.isDeviceRooted()
            }
            
            if (isRooted) {
                appendToTerminal("✓ Root access detected")
                
                // Try to install superuser script
                val installed = withContext(Dispatchers.IO) {
                    superuserIntegration.installSuperuserScript()
                }
                
                if (installed) {
                    appendToTerminal("✓ Superuser integration ready")
                } else {
                    appendToTerminal("⚠ Superuser script installation failed")
                }
            } else {
                appendToTerminal("⚠ Root access not available")
                appendToTerminal("Some features may be limited")
            }
            
            appendToTerminal(getPrompt())
            scrollToBottom()
        }
    }

    private fun executeCommand() {
        val command = binding.commandInput.text.toString().trim()
        if (command.isNotBlank()) {
            commandHistory.add(command)
            historyIndex = commandHistory.size
        }

        appendToTerminal("${getPrompt()}$command")
        binding.commandInput.text.clear()

        if (command == "clear") {
            clearTerminal()
            return
        }

        executeCommandInternal(command)
    }

    private fun executeCommandInternal(command: String) {
        lifecycleScope.launch {
            val output = withContext(Dispatchers.IO) {
                when {
                    command.startsWith("su-") || command in listOf("help", "status", "monitor", "benchmark") -> {
                        superuserIntegration.executeCommand(command)
                    }
                    command.startsWith("cd ") -> {
                        val path = command.substringAfter("cd ").trim()
                        changeDirectory(path)
                    }
                    else -> {
                        terminalCommand.executeCommand(command)
                    }
                }
            }

            if (output.isNotEmpty()) {
                appendToTerminal(output)
            }
            
            appendToTerminal(getPrompt())
            scrollToBottom()
        }
    }

    private fun changeDirectory(path: String): String {
        val newDir = if (path.startsWith("/")) {
            path
        } else {
            "$currentDirectory/$path"
        }
        
        return if (java.io.File(newDir).exists() && java.io.File(newDir).isDirectory) {
            currentDirectory = newDir
            ""
        } else {
            "cd: $path: No such file or directory"
        }
    }

    private fun getPrompt(): String {
        val user = if (RootUtils.isDeviceRooted()) "root" else "user"
        val shortDir = if (currentDirectory.length > 20) {
            "..." + currentDirectory.takeLast(17)
        } else {
            currentDirectory
        }
        return "[$user@android:$shortDir]# "
    }

    private fun clearTerminal() {
        binding.terminalOutput.text = getPrompt()
    }

    private fun appendToTerminal(text: String) {
        val currentText = binding.terminalOutput.text.toString()
        val newText = if (currentText.endsWith("# ")) {
            currentText.dropLast(getPrompt().length) + text + "\n"
        } else {
            "$currentText$text\n"
        }
        binding.terminalOutput.text = newText
    }

    private fun scrollToBottom() {
        binding.scrollView.post {
            binding.scrollView.fullScroll(android.view.View.FOCUS_DOWN)
        }
    }

    private fun navigateHistory(direction: Int) {
        if (commandHistory.isEmpty()) return

        historyIndex += direction
        historyIndex = historyIndex.coerceIn(0, commandHistory.size)

        binding.commandInput.setText(
            if (historyIndex < commandHistory.size) {
                commandHistory[historyIndex]
            } else {
                ""
            }
        )
        
        binding.commandInput.setSelection(binding.commandInput.text.length)
    }

    private fun autoComplete() {
        val currentInput = binding.commandInput.text.toString()
        val suggestions = getAutoCompleteSuggestions(currentInput)
        
        if (suggestions.size == 1) {
            binding.commandInput.setText(suggestions[0])
            binding.commandInput.setSelection(suggestions[0].length)
        } else if (suggestions.isNotEmpty()) {
            appendToTerminal("Suggestions: ${suggestions.joinToString(", ")}")
            appendToTerminal(getPrompt() + currentInput)
            scrollToBottom()
        }
    }

    private fun getAutoCompleteSuggestions(input: String): List<String> {
        val commands = listOf(
            "help", "clear", "status", "monitor", "benchmark",
            "su-check", "su-fix", "su-backup", "su-setup", "su-health",
            "su-network", "su-security", "su-optimize", "su-full",
            "ls", "cd", "pwd", "mkdir", "cat", "df", "free", "ps", "top",
            "uname", "date", "whoami", "id", "ping", "netstat", "ifconfig"
        )
        
        return commands.filter { it.startsWith(input) }
    }

    private fun showSettingsDialog() {
        // Implementation for settings dialog
        Toast.makeText(this, "Settings dialog - Coming soon!", Toast.LENGTH_SHORT).show()
    }
}
