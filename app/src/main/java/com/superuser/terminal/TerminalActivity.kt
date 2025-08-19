package com.superuser.terminal

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.Menu
import android.view.MenuItem
import android.view.inputmethod.EditorInfo
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import com.superuser.terminal.databinding.ActivityTerminalBinding
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class TerminalActivity : AppCompatActivity() {
    private lateinit var binding: ActivityTerminalBinding
    private lateinit var terminalEngine: TerminalEngine
    private lateinit var commandHistoryAdapter: CommandHistoryAdapter
    private val commandHistory = mutableListOf<TerminalCommand>()
    private var historyIndex = -1
    private var currentDirectory = "/data"
    private val handler = Handler(Looper.getMainLooper())
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTerminalBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupTerminal()
        setupUI()
        showWelcomeMessage()
        checkSystemStatus()
    }
    
    private fun setupTerminal() {
        terminalEngine = TerminalEngine(this)
        
        // Setup command history RecyclerView
        commandHistoryAdapter = CommandHistoryAdapter { command ->
            binding.commandInput.setText(command.command)
            binding.commandInput.setSelection(command.command.length)
        }
        
        binding.commandHistoryRecyclerView.apply {
            layoutManager = LinearLayoutManager(this@TerminalActivity).apply {
                stackFromEnd = true
            }
            adapter = commandHistoryAdapter
        }
        
        // Setup command input
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
        
        // Setup execute button
        binding.executeButton.setOnClickListener {
            executeCommand()
        }
        
        // Setup quick action buttons
        binding.quickCheckButton.setOnClickListener {
            executeCommandInternal("su-check")
        }
        
        binding.quickFixButton.setOnClickListener {
            executeCommandInternal("su-fix")
        }
        
        binding.quickStatusButton.setOnClickListener {
            executeCommandInternal("status")
        }
        
        binding.quickHelpButton.setOnClickListener {
            executeCommandInternal("help")
        }
        
        // Focus on input
        binding.commandInput.requestFocus()
    }
    
    private fun setupUI() {
        supportActionBar?.title = "Enhanced Terminal"
        
        // Update time display
        updateTimeDisplay()
        
        // Setup swipe refresh
        binding.swipeRefresh.setOnRefreshListener {
            refreshTerminal()
        }
        
        // Update status indicators
        updateStatusIndicators()
    }
    
    private fun showWelcomeMessage() {
        val welcomeText = """
╔══════════════════════════════════════════════════╗
║     Enhanced Superuser Terminal v1.1-enhanced    ║
║              Advanced Android Terminal           ║
╚══════════════════════════════════════════════════╝

Welcome to the Enhanced Superuser Terminal!
• Type 'help' for available commands
• Use arrow keys to navigate command history
• Tab for auto-completion
• Swipe down to refresh

Current Directory: $currentDirectory
System Time: ${SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())}

"""
        addTerminalOutput(welcomeText, TerminalCommand.Type.SYSTEM)
        addPrompt()
    }
    
    private fun executeCommand() {
        val command = binding.commandInput.text.toString().trim()
        if (command.isBlank()) {
            addPrompt()
            return
        }
        
        // Add to history
        val terminalCommand = TerminalCommand(
            command = command,
            timestamp = System.currentTimeMillis(),
            directory = currentDirectory,
            type = TerminalCommand.Type.USER
        )
        
        commandHistory.add(terminalCommand)
        commandHistoryAdapter.addCommand(terminalCommand)
        historyIndex = commandHistory.size
        
        // Clear input
        binding.commandInput.text.clear()
        
        // Add command to output
        addTerminalOutput("${getPrompt()}$command", TerminalCommand.Type.USER)
        
        // Handle special commands
        when (command.lowercase()) {
            "clear" -> {
                clearTerminal()
                return
            }
            "exit" -> {
                finish()
                return
            }
        }
        
        executeCommandInternal(command)
    }
    
    private fun executeCommandInternal(command: String) {
        lifecycleScope.launch {
            try {
                binding.progressBar.visibility = android.view.View.VISIBLE
                
                val result = withContext(Dispatchers.IO) {
                    terminalEngine.executeCommand(command, currentDirectory)
                }
                
                // Update current directory if cd command
                if (command.startsWith("cd ") && result.exitCode == 0) {
                    val newDir = command.substringAfter("cd ").trim()
                    currentDirectory = if (newDir.startsWith("/")) {
                        newDir
                    } else {
                        "$currentDirectory/$newDir"
                    }
                    updateStatusIndicators()
                }
                
                // Add output
                if (result.output.isNotEmpty()) {
                    addTerminalOutput(result.output, TerminalCommand.Type.OUTPUT)
                }
                
                if (result.error.isNotEmpty()) {
                    addTerminalOutput(result.error, TerminalCommand.Type.ERROR)
                }
                
                // Add execution info
                val executionInfo = "Command completed in ${result.executionTime}ms (Exit code: ${result.exitCode})"
                addTerminalOutput(executionInfo, TerminalCommand.Type.SYSTEM)
                
            } catch (e: Exception) {
                addTerminalOutput("Error executing command: ${e.message}", TerminalCommand.Type.ERROR)
            } finally {
                binding.progressBar.visibility = android.view.View.GONE
                addPrompt()
                scrollToBottom()
            }
        }
    }
    
    private fun addTerminalOutput(text: String, type: TerminalCommand.Type) {
        val command = TerminalCommand(
            command = text,
            timestamp = System.currentTimeMillis(),
            directory = currentDirectory,
            type = type
        )
        commandHistoryAdapter.addCommand(command)
    }
    
    private fun addPrompt() {
        val prompt = getPrompt()
        binding.promptText.text = prompt
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
        commandHistoryAdapter.clearCommands()
        showWelcomeMessage()
    }
    
    private fun scrollToBottom() {
        handler.post {
            binding.commandHistoryRecyclerView.scrollToPosition(commandHistoryAdapter.itemCount - 1)
        }
    }
    
    private fun navigateHistory(direction: Int) {
        if (commandHistory.isEmpty()) return
        
        historyIndex += direction
        historyIndex = historyIndex.coerceIn(0, commandHistory.size)
        
        binding.commandInput.setText(
            if (historyIndex < commandHistory.size) {
                commandHistory[historyIndex].command
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
            val suggestionText = "Suggestions: ${suggestions.joinToString(", ")}"
            addTerminalOutput(suggestionText, TerminalCommand.Type.SYSTEM)
            addTerminalOutput("${getPrompt()}$currentInput", TerminalCommand.Type.USER)
            scrollToBottom()
        }
    }
    
    private fun getAutoCompleteSuggestions(input: String): List<String> {
        val commands = listOf(
            "help", "clear", "exit", "status", "ls", "cd", "pwd", "mkdir", "cat", "rm",
            "su-check", "su-fix", "su-backup", "su-setup", "su-health", "su-network",
            "su-security", "su-optimize", "su-full", "df", "free", "ps", "top", "uname",
            "date", "whoami", "id", "ping", "netstat", "ifconfig", "mount", "chmod",
            "chown", "cp", "mv", "grep", "find", "which", "echo", "env", "history"
        )
        
        return commands.filter { it.startsWith(input) }.take(10)
    }
    
    private fun updateTimeDisplay() {
        lifecycleScope.launch {
            while (true) {
                val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
                binding.timeDisplay.text = timeFormat.format(Date())
                kotlinx.coroutines.delay(60000) // Update every minute
            }
        }
    }
    
    private fun updateStatusIndicators() {
        lifecycleScope.launch {
            val rootStatus = withContext(Dispatchers.IO) {
                RootUtils.isDeviceRooted()
            }
            
            binding.statusIndicator.text = if (rootStatus) "●" else "○"
            binding.statusIndicator.setTextColor(
                if (rootStatus) getColor(android.R.color.holo_green_light) 
                else getColor(android.R.color.holo_red_light)
            )
            
            binding.statusText.text = "Enhanced Terminal v1.1 | Dir: ${currentDirectory.substringAfterLast("/")}"
        }
    }
    
    private fun refreshTerminal() {
        lifecycleScope.launch {
            updateStatusIndicators()
            
            // Check system status
            val systemStatus = withContext(Dispatchers.IO) {
                terminalEngine.getSystemStatus()
            }
            
            addTerminalOutput("System Status Refreshed:", TerminalCommand.Type.SYSTEM)
            addTerminalOutput(systemStatus, TerminalCommand.Type.OUTPUT)
            addPrompt()
            
            binding.swipeRefresh.isRefreshing = false
        }
    }
    
    private fun checkSystemStatus() {
        lifecycleScope.launch {
            val isRooted = withContext(Dispatchers.IO) {
                RootUtils.isDeviceRooted()
            }
            
            if (isRooted) {
                addTerminalOutput("✓ Root access detected", TerminalCommand.Type.SYSTEM)
            } else {
                addTerminalOutput("⚠ Root access not available - some features may be limited", TerminalCommand.Type.ERROR)
            }
            
            // Initialize terminal engine
            val initResult = withContext(Dispatchers.IO) {
                terminalEngine.initialize()
            }
            
            if (initResult) {
                addTerminalOutput("✓ Terminal engine initialized", TerminalCommand.Type.SYSTEM)
            } else {
                addTerminalOutput("⚠ Terminal engine initialization failed", TerminalCommand.Type.ERROR)
            }
            
            addPrompt()
        }
    }
    
    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.terminal_menu, menu)
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
            R.id.action_settings -> {
                startActivity(Intent(this, SettingsActivity::class.java))
                true
            }
            R.id.action_help -> {
                executeCommandInternal("help")
                true
            }
            R.id.action_export_history -> {
                exportCommandHistory()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
    
    private fun exportCommandHistory() {
        lifecycleScope.launch {
            try {
                val exportData = withContext(Dispatchers.IO) {
                    terminalEngine.exportHistory(commandHistory)
                }
                
                if (exportData != null) {
                    Toast.makeText(this@TerminalActivity, "History exported to: $exportData", Toast.LENGTH_LONG).show()
                } else {
                    Toast.makeText(this@TerminalActivity, "Failed to export history", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                Toast.makeText(this@TerminalActivity, "Export error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        terminalEngine.cleanup()
    }
}
