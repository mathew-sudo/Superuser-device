#!/usr/bin/env python3
"""
Termux GUI Launcher for Enhanced Superuser Terminal
Optimized for Termux environment with auto-root capabilities
Version: 2.0 - Enhanced Edition
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import os
import threading
import json
import time
import queue
from pathlib import Path
from datetime import datetime

class TermuxSuperuserGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Enhanced Superuser Terminal - Termux Edition v2.0")
        self.root.geometry("1000x800")
        self.root.configure(bg='#2b2b2b')
        
        # Termux-specific paths
        self.termux_home = "/data/data/com.termux/files/home"
        self.script_path = os.path.join(self.termux_home, "Superuser_main")
        
        # Status variables
        self.is_root = tk.BooleanVar()
        self.is_termux = tk.BooleanVar()
        self.auto_refresh = tk.BooleanVar(value=True)
        
        # Command queue for threaded operations
        self.command_queue = queue.Queue()
        
        # Setup components
        self.setup_styles()
        self.setup_gui()
        self.setup_status_monitoring()
        self.check_termux_environment()
        
        # Start auto-refresh if enabled
        self.start_auto_refresh()
    
    def setup_styles(self):
        """Setup custom styles for enhanced UI"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configure enhanced styles
        style.configure('Title.TLabel',
                       background='#2b2b2b',
                       foreground='#00ff41',
                       font=('Helvetica', 16, 'bold'))
        
        style.configure('Status.TLabel',
                       background='#2b2b2b',
                       foreground='#ffffff',
                       font=('Helvetica', 10))
        
        style.configure('Success.TLabel',
                       background='#2b2b2b',
                       foreground='#00ff41',
                       font=('Helvetica', 10, 'bold'))
        
        style.configure('Error.TLabel',
                       background='#2b2b2b',
                       foreground='#ff4444',
                       font=('Helvetica', 10, 'bold'))
        
        style.configure('Action.TButton',
                       background='#4a4a4a',
                       foreground='#ffffff',
                       font=('Helvetica', 10, 'bold'),
                       borderwidth=2)
        
        style.map('Action.TButton',
                 background=[('active', '#5a5a5a'),
                           ('pressed', '#6a6a6a')])
    
    def setup_gui(self):
        """Setup the enhanced GUI interface"""
        # Main container
        main_frame = ttk.Frame(self.root, padding="15")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Title with enhanced styling
        title_frame = ttk.Frame(main_frame)
        title_frame.pack(fill=tk.X, pady=(0, 20))
        
        title_label = ttk.Label(title_frame, 
                               text="🔐 Enhanced Superuser Terminal - Termux Edition",
                               style='Title.TLabel')
        title_label.pack()
        
        version_label = ttk.Label(title_frame, 
                                 text="v2.0 - Enhanced Security & Features",
                                 style='Status.TLabel')
        version_label.pack()
        
        # Create notebook for organized tabs
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True)
        
        # Create enhanced tabs
        self.create_status_tab()
        self.create_actions_tab()
        self.create_terminal_tab()
        self.create_monitoring_tab()
        self.create_settings_tab()
    
    def create_status_tab(self):
        """Create enhanced status monitoring tab"""
        status_frame = ttk.Frame(self.notebook)
        self.notebook.add(status_frame, text="📊 Status")
        
        # System status section
        sys_status_frame = ttk.LabelFrame(status_frame, text="System Status", padding="10")
        sys_status_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Status grid with enhanced information
        status_grid = ttk.Frame(sys_status_frame)
        status_grid.pack(fill=tk.X)
        
        # Root status with icon
        self.root_status = ttk.Label(status_grid, text="🔐 Root Status: Checking...", 
                                    style='Status.TLabel')
        self.root_status.grid(row=0, column=0, sticky=tk.W, pady=2)
        
        # Termux status
        self.termux_status = ttk.Label(status_grid, text="📱 Termux: Checking...", 
                                     style='Status.TLabel')
        self.termux_status.grid(row=1, column=0, sticky=tk.W, pady=2)
        
        # Device info
        self.device_info = ttk.Label(status_grid, text="📲 Device: Unknown", 
                                   style='Status.TLabel')
        self.device_info.grid(row=2, column=0, sticky=tk.W, pady=2)
        
        # Permission status
        self.permission_status = ttk.Label(status_grid, text="🛡️ Permissions: Checking...", 
                                         style='Status.TLabel')
        self.permission_status.grid(row=3, column=0, sticky=tk.W, pady=2)
        
        # Detailed system information
        details_frame = ttk.LabelFrame(status_frame, text="System Details", padding="10")
        details_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        self.details_text = scrolledtext.ScrolledText(details_frame, 
                                                     height=12, 
                                                     bg='#1e1e1e', 
                                                     fg='#00ff41',
                                                     font=('Courier', 10),
                                                     wrap=tk.WORD)
        self.details_text.pack(fill=tk.BOTH, expand=True)
        
        # Control buttons
        control_frame = ttk.Frame(status_frame)
        control_frame.pack(fill=tk.X)
        
        ttk.Button(control_frame, text="🔄 Refresh Status", 
                  command=self.refresh_status, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(control_frame, text="📊 Detailed Check", 
                  command=self.detailed_system_check, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        # Auto-refresh checkbox
        ttk.Checkbutton(control_frame, text="Auto-refresh", 
                       variable=self.auto_refresh,
                       command=self.toggle_auto_refresh).pack(side=tk.RIGHT)
    
    def create_actions_tab(self):
        """Create enhanced actions tab"""
        actions_frame = ttk.Frame(self.notebook)
        self.notebook.add(actions_frame, text="⚡ Actions")
        
        # Primary actions
        primary_frame = ttk.LabelFrame(actions_frame, text="Primary Actions", padding="15")
        primary_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Action buttons with enhanced layout
        action_grid = ttk.Frame(primary_frame)
        action_grid.pack(fill=tk.X)
        
        ttk.Button(action_grid, text="🔐 Get Root Access", 
                  command=self.get_root_access, style='Action.TButton').grid(row=0, column=0, padx=5, pady=5, sticky=tk.W+tk.E)
        
        ttk.Button(action_grid, text="🔍 System Check", 
                  command=self.run_system_check, style='Action.TButton').grid(row=0, column=1, padx=5, pady=5, sticky=tk.W+tk.E)
        
        ttk.Button(action_grid, text="🛠️ Fix Permissions", 
                  command=self.fix_permissions, style='Action.TButton').grid(row=1, column=0, padx=5, pady=5, sticky=tk.W+tk.E)
        
        ttk.Button(action_grid, text="💾 Create Backup", 
                  command=self.create_backup, style='Action.TButton').grid(row=1, column=1, padx=5, pady=5, sticky=tk.W+tk.E)
        
        # Configure grid weights
        action_grid.columnconfigure(0, weight=1)
        action_grid.columnconfigure(1, weight=1)
        
        # Android tools section
        android_frame = ttk.LabelFrame(actions_frame, text="Android Tools", padding="15")
        android_frame.pack(fill=tk.X, pady=(0, 10))
        
        android_grid = ttk.Frame(android_frame)
        android_grid.pack(fill=tk.X)
        
        ttk.Button(android_grid, text="📱 Device Info", 
                  command=self.get_device_info, style='Action.TButton').grid(row=0, column=0, padx=5, pady=5, sticky=tk.W+tk.E)
        
        ttk.Button(android_grid, text="🖥️ ADB Shell", 
                  command=self.launch_adb_shell, style='Action.TButton').grid(row=0, column=1, padx=5, pady=5, sticky=tk.W+tk.E)
        
        ttk.Button(android_grid, text="📋 User Info", 
                  command=self.android_user_info, style='Action.TButton').grid(row=1, column=0, padx=5, pady=5, sticky=tk.W+tk.E)
        
        ttk.Button(android_grid, text="🔧 Tools Menu", 
                  command=self.launch_terminal_menu, style='Action.TButton').grid(row=1, column=1, padx=5, pady=5, sticky=tk.W+tk.E)
        
        android_grid.columnconfigure(0, weight=1)
        android_grid.columnconfigure(1, weight=1)
        
        # Progress indicator
        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(actions_frame, 
                                          variable=self.progress_var,
                                          mode='indeterminate')
        self.progress_bar.pack(fill=tk.X, pady=(10, 0))
    
    def create_terminal_tab(self):
        """Create enhanced terminal output tab"""
        terminal_frame = ttk.Frame(self.notebook)
        self.notebook.add(terminal_frame, text="💻 Terminal")
        
        # Terminal controls
        control_frame = ttk.Frame(terminal_frame)
        control_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Button(control_frame, text="🗑️ Clear", 
                  command=self.clear_output, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(control_frame, text="💾 Save Log", 
                  command=self.save_output, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(control_frame, text="📤 Export", 
                  command=self.export_output, style='Action.TButton').pack(side=tk.LEFT)
        
        # Enhanced output display
        output_frame = ttk.Frame(terminal_frame)
        output_frame.pack(fill=tk.BOTH, expand=True)
        
        self.output_text = scrolledtext.ScrolledText(output_frame, 
                                                   height=25, 
                                                   bg='#000000', 
                                                   fg='#00ff41',
                                                   font=('Courier', 11),
                                                   wrap=tk.WORD,
                                                   insertbackground='#00ff41')
        self.output_text.pack(fill=tk.BOTH, expand=True)
        
        # Configure text tags for colored output
        self.output_text.tag_configure("info", foreground="#00ff41")
        self.output_text.tag_configure("warn", foreground="#ffff00")
        self.output_text.tag_configure("error", foreground="#ff4444")
        self.output_text.tag_configure("success", foreground="#44ff44")
        self.output_text.tag_configure("timestamp", foreground="#888888")
        
        # Command input
        input_frame = ttk.Frame(terminal_frame)
        input_frame.pack(fill=tk.X, pady=(10, 0))
        
        ttk.Label(input_frame, text="Command:").pack(side=tk.LEFT)
        
        self.command_entry = ttk.Entry(input_frame, font=('Courier', 10))
        self.command_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(10, 10))
        self.command_entry.bind('<Return>', self.execute_custom_command)
        
        ttk.Button(input_frame, text="▶️ Execute", 
                  command=self.execute_custom_command, style='Action.TButton').pack(side=tk.RIGHT)
    
    def create_monitoring_tab(self):
        """Create system monitoring tab"""
        monitor_frame = ttk.Frame(self.notebook)
        self.notebook.add(monitor_frame, text="📈 Monitor")
        
        # Resource monitoring
        resource_frame = ttk.LabelFrame(monitor_frame, text="Resource Monitor", padding="10")
        resource_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Resource indicators
        self.cpu_label = ttk.Label(resource_frame, text="CPU: 0%", style='Status.TLabel')
        self.cpu_label.pack(anchor=tk.W)
        
        self.memory_label = ttk.Label(resource_frame, text="Memory: 0 MB", style='Status.TLabel')
        self.memory_label.pack(anchor=tk.W)
        
        self.storage_label = ttk.Label(resource_frame, text="Storage: 0 GB free", style='Status.TLabel')
        self.storage_label.pack(anchor=tk.W)
        
        # Log monitoring
        log_frame = ttk.LabelFrame(monitor_frame, text="Log Monitor", padding="10")
        log_frame.pack(fill=tk.BOTH, expand=True)
        
        self.log_text = scrolledtext.ScrolledText(log_frame, 
                                                height=15, 
                                                bg='#1a1a1a', 
                                                fg='#ffffff',
                                                font=('Courier', 9),
                                                wrap=tk.WORD)
        self.log_text.pack(fill=tk.BOTH, expand=True)
    
    def create_settings_tab(self):
        """Create enhanced settings tab"""
        settings_frame = ttk.Frame(self.notebook)
        self.notebook.add(settings_frame, text="⚙️ Settings")
        
        # Application settings
        app_frame = ttk.LabelFrame(settings_frame, text="Application Settings", padding="15")
        app_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Settings options
        self.verbose_mode = tk.BooleanVar(value=False)
        ttk.Checkbutton(app_frame, text="Verbose output mode",
                       variable=self.verbose_mode).pack(anchor=tk.W, pady=2)
        
        self.save_logs = tk.BooleanVar(value=True)
        ttk.Checkbutton(app_frame, text="Automatically save logs",
                       variable=self.save_logs).pack(anchor=tk.W, pady=2)
        
        self.notifications = tk.BooleanVar(value=True)
        ttk.Checkbutton(app_frame, text="Enable notifications",
                       variable=self.notifications).pack(anchor=tk.W, pady=2)
        
        # Termux-specific settings
        termux_frame = ttk.LabelFrame(settings_frame, text="Termux Settings", padding="15")
        termux_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Button(termux_frame, text="📁 Setup Storage Access",
                  command=self.setup_storage).pack(fill=tk.X, pady=2)
        
        ttk.Button(termux_frame, text="📦 Install Packages",
                  command=self.install_packages).pack(fill=tk.X, pady=2)
        
        ttk.Button(termux_frame, text="🔄 Update System",
                  command=self.update_system).pack(fill=tk.X, pady=2)
        
        # About section
        about_frame = ttk.LabelFrame(settings_frame, text="About", padding="15")
        about_frame.pack(fill=tk.BOTH, expand=True)
        
        about_text = """Enhanced Superuser Terminal for Termux
Version: 2.0 - Enhanced Edition

Features:
• Advanced security with input validation
• Real-time system monitoring
• Comprehensive device management
• GUI and terminal interfaces
• Automated backup and recovery

Developed for Android rooting and system administration."""
        
        ttk.Label(about_frame, text=about_text, 
                 justify=tk.LEFT, wraplength=400).pack(anchor=tk.W)
    
    def check_termux_environment(self):
        """Check Termux environment status with better error handling"""
        def check_status():
            try:
                # Check root status
                try:
                    result = subprocess.run(['id'], capture_output=True, text=True, timeout=5)
                    if 'uid=0(root)' in result.stdout:
                        self.root.after(0, lambda: self.root_status.config(
                            text="Root Status: ✅ Active", foreground='green'))
                        self.is_root.set(True)
                    else:
                        self.root.after(0, lambda: self.root_status.config(
                            text="Root Status: ❌ Not root", foreground='red'))
                        self.is_root.set(False)
                except (subprocess.TimeoutExpired, FileNotFoundError):
                    self.root.after(0, lambda: self.root_status.config(
                        text="Root Status: ❓ Unknown", foreground='orange'))
                
                # Check Termux status
                if os.path.exists("/data/data/com.termux"):
                    self.root.after(0, lambda: self.termux_status.config(
                        text="Termux: ✅ Environment detected", foreground='green'))
                    self.is_termux.set(True)
                else:
                    self.root.after(0, lambda: self.termux_status.config(
                        text="Termux: ❌ Not detected", foreground='red'))
                    self.is_termux.set(False)
                
                self.root.after(0, lambda: self.append_output("🔍 Environment check completed\n"))
                
            except Exception as e:
                self.root.after(0, lambda: self.append_output(f"❌ Environment check failed: {str(e)}\n"))
        
        threading.Thread(target=check_status, daemon=True).start()

    def run_command(self, command, show_output=True):
        """Run command with improved error handling"""
        def execute():
            try:
                if show_output:
                    self.root.after(0, lambda: self.append_output(f"$ {command}\n"))
                
                # Add timeout and better error handling
                process = subprocess.Popen(command, shell=True,
                                         stdout=subprocess.PIPE,
                                         stderr=subprocess.STDOUT,
                                         universal_newlines=True)
                
                # Read output with timeout
                try:
                    stdout, _ = process.communicate(timeout=30)
                    if show_output and stdout:
                        self.root.after(0, lambda: self.append_output(stdout))
                except subprocess.TimeoutExpired:
                    process.kill()
                    self.root.after(0, lambda: self.append_output("⚠️ Command timed out\n"))
                
                if show_output:
                    self.root.after(0, lambda: self.append_output(
                        f"Command completed (exit code: {process.returncode})\n\n"))
                
            except Exception as e:
                self.root.after(0, lambda: self.append_output(f"Error: {str(e)}\n"))
        
        threading.Thread(target=execute, daemon=True).start()

    def get_root_access(self):
        """Attempt to get root access with better error handling"""
        self.append_output("🔐 Attempting to get root access...\n")
        
        # Try different methods with validation
        commands = [
            ("tsu", "Termux SU"),
            ("su", "Standard su"),
            (f"bash {self.script_path}", "Superuser script")
        ]
        
        for cmd, description in commands:
            try:
                # Check if command exists
                check_cmd = cmd.split()[0]
                result = subprocess.run(f"command -v {check_cmd}", shell=True, 
                                      capture_output=True, timeout=5)
                if result.returncode == 0:
                    self.append_output(f"✅ Found: {description}\n")
                    if 'tsu' in cmd:
                        self.run_command("tsu -c 'id; whoami'")
                        return
                    elif 'su' in cmd and 'tsu' not in cmd:
                        self.run_command("su -c 'id; whoami'")
                        return
                    elif 'bash' in cmd:
                        self.run_command(cmd)
                        return
            except (subprocess.TimeoutExpired, Exception) as e:
                self.append_output(f"⚠️ Error checking {description}: {str(e)}\n")
        
        self.append_output("❌ No root access method found\n")
        messagebox.showwarning("Warning", "Root access not available")

    def run_system_check(self):
        """Run comprehensive system check"""
        if os.path.exists(self.script_path):
            self.run_command(f"bash {self.script_path} check")
        else:
            self.append_output("❌ Superuser script not found\n")
            messagebox.showerror("Error", f"Script not found: {self.script_path}")
    
    def fix_permissions(self):
        """Fix su permissions"""
        if messagebox.askyesno("Confirm", "Fix su binary permissions? This requires root access."):
            if os.path.exists(self.script_path):
                self.run_command(f"tsu -c 'bash {self.script_path} check'")
            else:
                self.append_output("❌ Superuser script not found\n")
    
    def android_tools(self):
        """Launch Android tools"""
        self.run_command(f"bash {self.script_path} android-user")
    
    def launch_terminal_menu(self):
        """Launch terminal tools menu"""
        menu_script = os.path.join(self.termux_home, "termux_tools_menu.sh")
        if os.path.exists(menu_script):
            subprocess.Popen(['bash', menu_script])
        else:
            self.append_output("❌ Tools menu not found\n")
    
    def open_settings(self):
        """Open settings dialog"""
        settings_window = tk.Toplevel(self.root)
        settings_window.title("Settings")
        settings_window.geometry("400x300")
        
        ttk.Label(settings_window, text="Termux Settings", 
                 font=('Sans', 12, 'bold')).pack(pady=10)
        
        # Auto-root option
        auto_root_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(settings_window, text="Auto-switch to root on startup",
                       variable=auto_root_var).pack(anchor=tk.W, padx=20)
        
        # GUI mode option
        gui_mode_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(settings_window, text="Enable GUI mode",
                       variable=gui_mode_var).pack(anchor=tk.W, padx=20)
        
        # Storage access
        def setup_storage():
            self.run_command("termux-setup-storage")
        
        ttk.Button(settings_window, text="Setup Storage Access",
                  command=setup_storage).pack(pady=10)
        
        # Install missing packages
        def install_packages():
            self.run_command("pkg update && pkg install -y python tkinter")
        
        ttk.Button(settings_window, text="Install Missing Packages",
                  command=install_packages).pack(pady=5)
    
    def setup_status_monitoring(self):
        """Setup enhanced status monitoring"""
        self.status_queue = queue.Queue()
        self.monitoring_active = True
        
        def monitor_loop():
            while self.monitoring_active:
                try:
                    # Update resource information
                    self.update_resource_info()
                    time.sleep(5)  # Update every 5 seconds
                except Exception as e:
                    self.append_output(f"Monitor error: {str(e)}\n", "error")
                    time.sleep(10)  # Wait longer on error
        
        threading.Thread(target=monitor_loop, daemon=True).start()
    
    def update_resource_info(self):
        """Update system resource information"""
        try:
            # CPU info (mock for now)
            cpu_percent = "N/A"
            
            # Memory info
            try:
                result = subprocess.run(['free', '-m'], capture_output=True, text=True)
                if result.returncode == 0:
                    lines = result.stdout.split('\n')
                    for line in lines:
                        if 'Mem:' in line:
                            parts = line.split()
                            total = parts[1]
                            used = parts[2]
                            memory_info = f"Memory: {used}/{total} MB"
                            break
                    else:
                        memory_info = "Memory: N/A"
                else:
                    memory_info = "Memory: N/A"
            except:
                memory_info = "Memory: N/A"
            
            # Storage info
            try:
                result = subprocess.run(['df', '-h', '/data'], capture_output=True, text=True)
                if result.returncode == 0:
                    lines = result.stdout.split('\n')
                    if len(lines) > 1:
                        parts = lines[1].split()
                        available = parts[3]
                        storage_info = f"Storage: {available} free"
                    else:
                        storage_info = "Storage: N/A"
                else:
                    storage_info = "Storage: N/A"
            except:
                storage_info = "Storage: N/A"
            
            # Update UI in main thread
            self.root.after(0, lambda: self.update_resource_labels(cpu_percent, memory_info, storage_info))
            
        except Exception as e:
            pass  # Silently fail for resource monitoring
    
    def update_resource_labels(self, cpu, memory, storage):
        """Update resource labels in main thread"""
        if hasattr(self, 'cpu_label'):
            self.cpu_label.config(text=f"CPU: {cpu}")
        if hasattr(self, 'memory_label'):
            self.memory_label.config(text=memory)
        if hasattr(self, 'storage_label'):
            self.storage_label.config(text=storage)
    
    def start_auto_refresh(self):
        """Start auto-refresh timer"""
        if self.auto_refresh.get():
            self.refresh_status()
            self.root.after(30000, self.start_auto_refresh)  # Refresh every 30 seconds
    
    def toggle_auto_refresh(self):
        """Toggle auto-refresh functionality"""
        if self.auto_refresh.get():
            self.start_auto_refresh()
    
    def execute_custom_command(self, event=None):
        """Execute custom command from entry"""
        command = self.command_entry.get().strip()
        if command:
            self.command_entry.delete(0, tk.END)
            self.run_command(command)
    
    def clear_output(self):
        """Clear terminal output"""
        if hasattr(self, 'output_text'):
            self.output_text.delete('1.0', tk.END)
    
    def save_output(self):
        """Save terminal output to file"""
        if hasattr(self, 'output_text'):
            content = self.output_text.get('1.0', tk.END)
            filename = f"termux_output_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            try:
                with open(os.path.join(self.termux_home, filename), 'w') as f:
                    f.write(content)
                messagebox.showinfo("Success", f"Output saved to {filename}")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to save: {str(e)}")
    
    def export_output(self):
        """Export output in JSON format"""
        if hasattr(self, 'output_text'):
            content = self.output_text.get('1.0', tk.END)
            export_data = {
                "timestamp": datetime.now().isoformat(),
                "version": "2.0",
                "environment": "termux",
                "output": content,
                "status": {
                    "root": self.is_root.get(),
                    "termux": self.is_termux.get()
                }
            }
            filename = f"termux_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            try:
                with open(os.path.join(self.termux_home, filename), 'w') as f:
                    json.dump(export_data, f, indent=2)
                messagebox.showinfo("Success", f"Data exported to {filename}")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to export: {str(e)}")
    
    def setup_storage(self):
        """Setup Termux storage access"""
        self.run_command("termux-setup-storage")
    
    def install_packages(self):
        """Install missing packages for Termux"""
        self.run_command("pkg update && pkg install -y python tkinter")
    
    def update_system(self):
        """Update Termux and installed packages"""
        self.run_command("pkg update && pkg upgrade -y")
    
    def detailed_system_check(self):
        """Run detailed system check"""
        if os.path.exists(self.script_path):
            self.run_command(f"bash {self.script_path} check detail")
        else:
            self.append_output("❌ Superuser script not found\n")
            messagebox.showerror("Error", f"Script not found: {self.script_path}")
    
    def get_device_info(self):
        """Get and display device information"""
        try:
            # Basic device info
            self.append_output("📱 Device Information:\n", "success")
            self.run_command("getprop | grep '^[\\[]' | awk -F'[][]' '{print $2\"=\"$(NF)}'", show_output=True)
            
            # Battery info
            self.append_output("\n🔋 Battery Status:\n", "success")
            self.run_command("dumpsys battery | grep -E 'Level|Status|Health|Temperature'", show_output=True)
            
            # Storage info
            self.append_output("\n💾 Storage Information:\n", "success")
            self.run_command("df -h /data", show_output=True)
        except Exception as e:
            self.append_output(f"Error retrieving device info: {str(e)}\n", "error")

    def launch_adb_shell(self):
        """Launch ADB shell interface"""
        try:
            if self.is_root.get():
                self.run_command("adb shell", show_output=True)
            else:
                self.append_output("❌ ADB shell requires root access\n", "error")
        except Exception as e:
            self.append_output(f"Error launching ADB shell: {str(e)}\n", "error")

    def android_user_info(self):
        """Display Android user information"""
        try:
            self.append_output("👤 Android User Information:\n", "success")
            self.run_command("id", show_output=True)
            self.run_command("pm list packages -f", show_output=True)
        except Exception as e:
            self.append_output(f"Error retrieving user info: {str(e)}\n", "error")

def main():
    """Enhanced main function with error handling"""
    try:
        # Check environment
        if not os.path.exists("/data/data/com.termux"):
            print("⚠️ Warning: Not running in Termux environment")
        
        # Create and run GUI
        root = tk.Tk()
        app = TermuxSuperuserGUI(root)
        
        # Handle cleanup on exit
        def on_closing():
            app.monitoring_active = False
            root.destroy()
        
        root.protocol("WM_DELETE_WINDOW", on_closing)
        root.mainloop()
        
    except KeyboardInterrupt:
        print("\n🔴 GUI terminated by user")
    except Exception as e:
        print(f"🔴 GUI error: {str(e)}")
    finally:
        print("👋 Termux GUI launcher terminated")

if __name__ == "__main__":
    main()
