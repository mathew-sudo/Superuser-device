package com.superuser.terminal

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import java.text.SimpleDateFormat
import java.util.*

class CommandHistoryAdapter(
    private val onCommandClick: (TerminalCommand) -> Unit
) : RecyclerView.Adapter<CommandHistoryAdapter.CommandViewHolder>() {
    
    private val commands = mutableListOf<TerminalCommand>()
    
    class CommandViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val commandText: TextView = itemView.findViewById(R.id.commandText)
        val timestampText: TextView = itemView.findViewById(R.id.timestampText)
    }
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CommandViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_terminal_command, parent, false)
        return CommandViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: CommandViewHolder, position: Int) {
        val command = commands[position]
        
        holder.commandText.text = command.command
        
        // Format timestamp
        val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        holder.timestampText.text = timeFormat.format(Date(command.timestamp))
        
        // Set colors based on command type
        val context = holder.itemView.context
        val textColor = when (command.type) {
            TerminalCommand.Type.USER -> ContextCompat.getColor(context, android.R.color.holo_green_light)
            TerminalCommand.Type.OUTPUT -> ContextCompat.getColor(context, android.R.color.white)
            TerminalCommand.Type.ERROR -> ContextCompat.getColor(context, android.R.color.holo_red_light)
            TerminalCommand.Type.SYSTEM -> ContextCompat.getColor(context, android.R.color.holo_blue_light)
        }
        
        holder.commandText.setTextColor(textColor)
        
        // Set font family to monospace
        holder.commandText.typeface = android.graphics.Typeface.MONOSPACE
        
        // Click listener for user commands
        if (command.type == TerminalCommand.Type.USER) {
            holder.itemView.setOnClickListener {
                onCommandClick(command)
            }
            holder.itemView.background = ContextCompat.getDrawable(context, R.drawable.selectable_background)
        } else {
            holder.itemView.setOnClickListener(null)
            holder.itemView.background = null
        }
    }
    
    override fun getItemCount(): Int = commands.size
    
    fun addCommand(command: TerminalCommand) {
        commands.add(command)
        notifyItemInserted(commands.size - 1)
    }
    
    fun clearCommands() {
        commands.clear()
        notifyDataSetChanged()
    }
}
