#!/usr/bin/env python3
"""
Superuser Terminal GUI
A graphical interface for managing Android superuser access and system operations.
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox, filedialog
import subprocess
import threading
import os
import sys
import time
import json
from datetime import datetime
from pathlib import Path

class SuperuserGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Enhanced Superuser Terminal v1.0")
        self.root.geometry("1200x800")
        self.root.configure(bg='#2b2b2b')
        
        # Status variables
        self.is_root = tk.BooleanVar()
        self.device_connected = tk.BooleanVar()
        self.operation_running = tk.BooleanVar()
        
        # Process reference for running operations
        self.current_process = None
        
        # Setup GUI components
        self.setup_styles()
        self.create_menu()
        self.create_main_interface()
        self.create_status_bar()
        
        # Initialize status
        self.check_initial_status()
        
    def setup_styles(self):
        """Configure custom styles for the GUI"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configure colors
        style.configure('Title.TLabel', 
                       background='#2b2b2b', 
                       foreground='#00ff00',
                       font=('Helvetica', 16, 'bold'))
        
        style.configure('Status.TLabel',
                       background='#2b2b2b',
                       foreground='#ffffff',
                       font=('Helvetica', 10))
        
        style.configure('Action.TButton',
                       background='#4a4a4a',
                       foreground='#ffffff',
                       font=('Helvetica', 10, 'bold'))
        
        style.map('Action.TButton',
                 background=[('active', '#5a5a5a')])
    
    def create_menu(self):
        """Create application menu bar"""
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Save Logs", command=self.save_logs)
        file_menu.add_command(label="Export Report", command=self.export_report)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        
        # Tools menu
        tools_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Tools", menu=tools_menu)
        tools_menu.add_command(label="ADB Shell", command=self.launch_adb_shell)
        tools_menu.add_command(label="Device Info", command=self.show_device_info)
        tools_menu.add_command(label="Backup Manager", command=self.open_backup_manager)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="Documentation", command=self.show_help)
        help_menu.add_command(label="About", command=self.show_about)
    
    def create_main_interface(self):
        """Create the main GUI interface"""
        # Main container
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Title
        title_label = ttk.Label(main_frame, 
                               text="🔐 Enhanced Superuser Terminal", 
                               style='Title.TLabel')
        title_label.pack(pady=(0, 20))
        
        # Create notebook for tabs
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True)
        
        # Create tabs
        self.create_system_tab()
        self.create_permissions_tab()
        self.create_android_tab()
        self.create_logs_tab()
        self.create_advanced_tab()
    
    def create_system_tab(self):
        """Create system information and control tab"""
        system_frame = ttk.Frame(self.notebook)
        self.notebook.add(system_frame, text="System")
        
        # System status section
        status_frame = ttk.LabelFrame(system_frame, text="System Status", padding=10)
        status_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Status indicators
        status_grid = ttk.Frame(status_frame)
        status_grid.pack(fill=tk.X)
        
        # Root status
        self.root_status_label = ttk.Label(status_grid, text="Root Access: Unknown", 
                                          style='Status.TLabel')
        self.root_status_label.grid(row=0, column=0, sticky=tk.W, padx=(0, 20))
        
        # Device status
        self.device_status_label = ttk.Label(status_grid, text="Device: Disconnected", 
                                            style='Status.TLabel')
        self.device_status_label.grid(row=0, column=1, sticky=tk.W)
        
        # System info display
        info_frame = ttk.LabelFrame(system_frame, text="System Information", padding=10)
        info_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        self.system_info_text = scrolledtext.ScrolledText(info_frame, 
                                                         height=10, 
                                                         bg='#1e1e1e', 
                                                         fg='#00ff00',
                                                         font=('Courier', 10))
        self.system_info_text.pack(fill=tk.BOTH, expand=True)
        
        # Control buttons
        button_frame = ttk.Frame(system_frame)
        button_frame.pack(fill=tk.X)
        
        ttk.Button(button_frame, text="🔍 System Check", 
                  command=self.run_system_check, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(button_frame, text="🔄 Refresh Status", 
                  command=self.refresh_status, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(button_frame, text="🛡️ Security Audit", 
                  command=self.run_security_audit, style='Action.TButton').pack(side=tk.LEFT)
    
    def create_permissions_tab(self):
        """Create permissions management tab"""
        perms_frame = ttk.Frame(self.notebook)
        self.notebook.add(perms_frame, text="Permissions")
        
        # Su binary status
        su_frame = ttk.LabelFrame(perms_frame, text="Su Binary Status", padding=10)
        su_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        # Su paths tree
        self.su_tree = ttk.Treeview(su_frame, columns=('Status', 'Permissions', 'Owner'), height=10)
        self.su_tree.heading('#0', text='Path')
        self.su_tree.heading('Status', text='Status')
        self.su_tree.heading('Permissions', text='Permissions')
        self.su_tree.heading('Owner', text='Owner')
        
        # Scrollbar for tree
        tree_scroll = ttk.Scrollbar(su_frame, orient=tk.VERTICAL, command=self.su_tree.yview)
        self.su_tree.configure(yscrollcommand=tree_scroll.set)
        
        self.su_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        tree_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Permission control buttons
        perm_button_frame = ttk.Frame(perms_frame)
        perm_button_frame.pack(fill=tk.X)
        
        ttk.Button(perm_button_frame, text="🔧 Fix Permissions", 
                  command=self.fix_permissions, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(perm_button_frame, text="✅ Check Access", 
                  command=self.check_accessibility, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(perm_button_frame, text="💾 Create Backup", 
                  command=self.create_backup, style='Action.TButton').pack(side=tk.LEFT)
    
    def create_android_tab(self):
        """Create Android device management tab"""
        android_frame = ttk.Frame(self.notebook)
        self.notebook.add(android_frame, text="Android")
        
        # Device info section
        device_frame = ttk.LabelFrame(android_frame, text="Device Information", padding=10)
        device_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.device_info_text = scrolledtext.ScrolledText(device_frame, 
                                                         height=8, 
                                                         bg='#1e1e1e', 
                                                         fg='#00ffff',
                                                         font=('Courier', 9))
        self.device_info_text.pack(fill=tk.BOTH, expand=True)
        
        # ADB controls
        adb_frame = ttk.LabelFrame(android_frame, text="ADB Controls", padding=10)
        adb_frame.pack(fill=tk.X, pady=(0, 10))
        
        adb_button_frame = ttk.Frame(adb_frame)
        adb_button_frame.pack(fill=tk.X)
        
        ttk.Button(adb_button_frame, text="📱 Device Info", 
                  command=self.get_android_info, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(adb_button_frame, text="🖥️ ADB Shell", 
                  command=self.launch_adb_shell, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(adb_button_frame, text="🔄 Restart ADB", 
                  command=self.restart_adb, style='Action.TButton').pack(side=tk.LEFT)
        
        # Terminal emulator
        terminal_frame = ttk.LabelFrame(android_frame, text="Terminal Output", padding=10)
        terminal_frame.pack(fill=tk.BOTH, expand=True)
        
        self.terminal_text = scrolledtext.ScrolledText(terminal_frame, 
                                                      height=12, 
                                                      bg='#000000', 
                                                      fg='#00ff00',
                                                      font=('Courier', 10))
        self.terminal_text.pack(fill=tk.BOTH, expand=True)
    
    def create_logs_tab(self):
        """Create logs and monitoring tab"""
        logs_frame = ttk.Frame(self.notebook)
        self.notebook.add(logs_frame, text="Logs")
        
        # Log controls
        log_control_frame = ttk.Frame(logs_frame)
        log_control_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Button(log_control_frame, text="🔄 Refresh Logs", 
                  command=self.refresh_logs, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(log_control_frame, text="🗑️ Clear Logs", 
                  command=self.clear_logs, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(log_control_frame, text="💾 Save Logs", 
                  command=self.save_logs, style='Action.TButton').pack(side=tk.LEFT)
        
        # Log level filter
        ttk.Label(log_control_frame, text="Level:").pack(side=tk.LEFT, padx=(20, 5))
        self.log_level_var = tk.StringVar(value="ALL")
        log_level_combo = ttk.Combobox(log_control_frame, textvariable=self.log_level_var,
                                      values=["ALL", "INFO", "WARN", "ERROR"], width=8)
        log_level_combo.pack(side=tk.LEFT)
        log_level_combo.bind('<<ComboboxSelected>>', self.filter_logs)
        
        # Log display
        self.log_text = scrolledtext.ScrolledText(logs_frame, 
                                                 height=25, 
                                                 bg='#1a1a1a', 
                                                 fg='#ffffff',
                                                 font=('Courier', 9))
        self.log_text.pack(fill=tk.BOTH, expand=True)
        
        # Configure log text tags for colors
        self.log_text.tag_configure("INFO", foreground="#00ff00")
        self.log_text.tag_configure("WARN", foreground="#ffff00")
        self.log_text.tag_configure("ERROR", foreground="#ff0000")
    
    def create_advanced_tab(self):
        """Create advanced tools and settings tab"""
        advanced_frame = ttk.Frame(self.notebook)
        self.notebook.add(advanced_frame, text="Advanced")
        
        # Performance monitoring
        perf_frame = ttk.LabelFrame(advanced_frame, text="Performance Monitor", padding=10)
        perf_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Performance metrics
        perf_grid = ttk.Frame(perf_frame)
        perf_grid.pack(fill=tk.X)
        
        ttk.Label(perf_grid, text="CPU Usage:").grid(row=0, column=0, sticky=tk.W)
        self.cpu_label = ttk.Label(perf_grid, text="0%")
        self.cpu_label.grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        ttk.Label(perf_grid, text="Memory:").grid(row=1, column=0, sticky=tk.W)
        self.memory_label = ttk.Label(perf_grid, text="0 MB")
        self.memory_label.grid(row=1, column=1, sticky=tk.W, padx=(10, 0))
        
        # Advanced tools
        tools_frame = ttk.LabelFrame(advanced_frame, text="Advanced Tools", padding=10)
        tools_frame.pack(fill=tk.X, pady=(0, 10))
        
        tools_button_frame = ttk.Frame(tools_frame)
        tools_button_frame.pack(fill=tk.X)
        
        ttk.Button(tools_button_frame, text="🔬 Dependency Check", 
                  command=self.check_dependencies, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(tools_button_frame, text="⚡ Performance Test", 
                  command=self.run_performance_test, style='Action.TButton').pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(tools_button_frame, text="🛠️ Interactive Mode", 
                  command=self.launch_interactive_mode, style='Action.TButton').pack(side=tk.LEFT)
        
        # Settings
        settings_frame = ttk.LabelFrame(advanced_frame, text="Settings", padding=10)
        settings_frame.pack(fill=tk.BOTH, expand=True)
        
        # Auto-refresh option
        self.auto_refresh_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(settings_frame, text="Auto-refresh status", 
                       variable=self.auto_refresh_var).pack(anchor=tk.W)
        
        # Verbose logging option
        self.verbose_logging_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(settings_frame, text="Verbose logging", 
                       variable=self.verbose_logging_var).pack(anchor=tk.W)
        
        # Dark mode option
        self.dark_mode_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(settings_frame, text="Dark mode", 
                       variable=self.dark_mode_var,
                       command=self.toggle_theme).pack(anchor=tk.W)
    
    def create_status_bar(self):
        """Create status bar at bottom"""
        self.status_bar = ttk.Frame(self.root)
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Progress bar
        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(self.status_bar, 
                                           variable=self.progress_var,
                                           mode='determinate')
        self.progress_bar.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(5, 10))
        
        # Status text
        self.status_text = tk.StringVar(value="Ready")
        status_label = ttk.Label(self.status_bar, textvariable=self.status_text)
        status_label.pack(side=tk.RIGHT, padx=(0, 5))
    
    # Core functionality methods
    def execute_script_command(self, command, callback=None):
        """Execute superuser script command in background thread"""
        def run_command():
            try:
                self.operation_running.set(True)
                self.update_status(f"Executing: {command}")
                
                script_path = os.path.join(os.path.dirname(__file__), "Superuser_main")
                if not os.path.exists(script_path):
                    raise FileNotFoundError("Superuser_main script not found")
                
                cmd = ["sudo", script_path, command]
                process = subprocess.Popen(cmd, 
                                         stdout=subprocess.PIPE, 
                                         stderr=subprocess.STDOUT,
                                         universal_newlines=True,
                                         bufsize=1)
                
                self.current_process = process
                output = []
                
                for line in iter(process.stdout.readline, ''):
                    if line:
                        output.append(line.strip())
                        self.root.after(0, lambda l=line: self.append_log(l.strip()))
                
                process.wait()
                self.current_process = None
                
                if callback:
                    self.root.after(0, lambda: callback('\n'.join(output)))
                
            except Exception as e:
                error_msg = f"Error executing command: {str(e)}"
                self.root.after(0, lambda: self.append_log(error_msg, "ERROR"))
                messagebox.showerror("Error", error_msg)
            finally:
                self.operation_running.set(False)
                self.root.after(0, lambda: self.update_status("Ready"))
        
        threading.Thread(target=run_command, daemon=True).start()
    
    def update_status(self, message):
        """Update status bar message"""
        self.status_text.set(message)
        
    def append_log(self, message, level="INFO"):
        """Append message to log display"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        formatted_msg = f"[{timestamp}] [{level}] {message}\n"
        
        self.log_text.insert(tk.END, formatted_msg, level)
        self.log_text.see(tk.END)
        
        # Also update terminal if it's a command output
        if hasattr(self, 'terminal_text'):
            self.terminal_text.insert(tk.END, message + '\n')
            self.terminal_text.see(tk.END)
    
    # Event handlers
    def run_system_check(self):
        """Run comprehensive system check"""
        def update_system_info(output):
            self.system_info_text.delete('1.0', tk.END)
            self.system_info_text.insert('1.0', output)
        
        self.execute_script_command("check", update_system_info)
    
    def fix_permissions(self):
        """Fix su binary permissions"""
        if messagebox.askyesno("Confirm", "Fix su binary permissions? This requires root access."):
            self.execute_script_command("check")  # This includes permission fix
    
    def create_backup(self):
        """Create backup of critical files"""
        if messagebox.askyesno("Confirm", "Create backup of critical su binaries?"):
            self.execute_script_command("backup")
    
    def get_android_info(self):
        """Get Android device information"""
        def update_device_info(output):
            self.device_info_text.delete('1.0', tk.END)
            self.device_info_text.insert('1.0', output)
        
        self.execute_script_command("android-user", update_device_info)
    
    def launch_adb_shell(self):
        """Launch ADB shell in external terminal"""
        try:
            subprocess.Popen(["gnome-terminal", "--", "adb", "shell"])
        except FileNotFoundError:
            try:
                subprocess.Popen(["xterm", "-e", "adb", "shell"])
            except FileNotFoundError:
                messagebox.showerror("Error", "No suitable terminal emulator found")
    
    def launch_interactive_mode(self):
        """Launch interactive mode in external terminal"""
        try:
            script_path = os.path.join(os.path.dirname(__file__), "Superuser_main")
            subprocess.Popen(["gnome-terminal", "--", "sudo", script_path, "interactive"])
        except FileNotFoundError:
            messagebox.showerror("Error", "Terminal or script not found")
    
    # Placeholder methods for menu actions
    def save_logs(self):
        """Save logs to file"""
        log_file = filedialog.asksaveasfilename(defaultextension=".log", 
                                                 filetypes=[("Log files", "*.log"), ("All files", "*.*")])
        if log_file:
            try:
                with open(log_file, 'w') as f:
                    f.write(self.log_text.get('1.0', tk.END))
                messagebox.showinfo("Logs Saved", f"Logs saved to {log_file}")
            except Exception as e:
                messagebox.showerror("Error", f"Could not save logs: {str(e)}")
    
    def export_report(self):
        """Export system report as JSON"""
        report_file = filedialog.asksaveasfilename(defaultextension=".json", 
                                                    filetypes=[("JSON files", "*.json"), ("All files", "*.*")])
        if report_file:
            try:
                # Collect system information
                report_data = {
                    "root_access": self.is_root.get(),
                    "device_connected": self.device_connected.get(),
                    "system_info": self.system_info_text.get('1.0', tk.END).strip().split('\n'),
                    "logs": self.log_text.get('1.0', tk.END).strip().split('\n')
                }
                
                with open(report_file, 'w') as f:
                    json.dump(report_data, f, indent=4)
                messagebox.showinfo("Report Exported", f"Report exported to {report_file}")
            except Exception as e:
                messagebox.showerror("Error", f"Could not export report: {str(e)}")
    
    def show_device_info(self):
        """Show detailed device information in a message box"""
        device_info = self.device_info_text.get('1.0', tk.END).strip()
        if device_info:
            messagebox.showinfo("Device Information", device_info)
        else:
            messagebox.showinfo("Device Information", "No device information available")
    
    def show_help(self):
        """Show help documentation"""
        help_file = os.path.join(os.path.dirname(__file__), "docs", "user_guide.pdf")
        if os.path.exists(help_file):
            subprocess.Popen(["xdg-open", help_file])
        else:
            messagebox.showerror("Error", "Help documentation not found")
    
    def show_about(self):
        """Show about information"""
        messagebox.showinfo("About", "Enhanced Superuser Terminal v1.0\n\n"
                                      "A graphical interface for managing Android superuser access and system operations.\n\n"
                                      "Developed by Your Name")
    
    def refresh_status(self):
        """Refresh system and device status"""
        self.update_status("Refreshing status...")
        self.execute_script_command("check", self.update_status_labels)
    
    def update_status_labels(self, output):
        """Update status labels based on script output"""
        lines = output.strip().split('\n')
        for line in lines:
            if "Root access" in line:
                status = line.split(': ')[1]
                self.is_root.set(status == "Granted")
                self.root_status_label.config(text=f"Root Access: {status}", 
                                             foreground="#00ff00" if status == "Granted" else "#ff0000")
            elif "Device" in line:
                status = line.split(': ')[1]
                self.device_connected.set(status == "Connected")
                self.device_status_label.config(text=f"Device: {status}", 
                                               foreground="#00ff00" if status == "Connected" else "#ff0000")
    
    def check_initial_status(self):
        """Check initial status of the device and root access"""
        self.update_status("Checking initial status...")
        self.execute_script_command("check", self.update_status_labels)
        self.refresh_logs()
    
    def refresh_logs(self):
        """Refresh logs display"""
        try:
            with open(os.path.join(os.path.dirname(__file__), "superuser.log"), 'r') as f:
                logs = f.readlines()
            
            self.log_text.delete('1.0', tk.END)
            for log in logs:
                level = "INFO"
                if "ERROR" in log:
                    level = "ERROR"
                elif "WARN" in log:
                    level = "WARN"
                
                self.log_text.insert(tk.END, log.strip(), level)
            
            self.log_text.see(tk.END)
        except Exception as e:
            messagebox.showerror("Error", f"Could not refresh logs: {str(e)}")
    
    def clear_logs(self):
        """Clear logs display"""
        if messagebox.askyesno("Confirm", "Clear all logs?"):
            self.log_text.delete('1.0', tk.END)
            with open(os.path.join(os.path.dirname(__file__), "superuser.log"), 'w') as f:
                f.write("")
            messagebox.showinfo("Logs Cleared", "All logs have been cleared")
    
    def check_dependencies(self):
        """Check and install required dependencies"""
        self.update_status("Checking dependencies...")
        missing_deps = []
        
        # List of required commands
        required_commands = ["bash", "curl", "grep", "awk", "sed", "find", "xargs", "mkdir", "rm", "touch", "chmod", "chown"]
        
        for cmd in required_commands:
            if not self.command_exists(cmd):
                missing_deps.append(cmd)
        
        if missing_deps:
            self.update_status(f"Missing dependencies: {', '.join(missing_deps)}")
            if messagebox.askyesno("Install Dependencies", 
                                   f"The following dependencies are missing:\n{', '.join(missing_deps)}\n\n"
                                   "Install now?"):
                for dep in missing_deps:
                    self.install_dependency(dep)
                self.update_status("Dependencies installed")
            else:
                self.update_status("Dependency check canceled")
        else:
            self.update_status("All dependencies are satisfied")
    
    def command_exists(self, cmd):
        """Check if a command exists on the system"""
        return subprocess.call(f"command -v {cmd}", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE) == 0
    
    def install_dependency(self, dep):
        """Install a missing dependency using the package manager"""
        try:
            if sys.platform.startswith('linux'):
                if subprocess.call(f"sudo apt-get install -y {dep}", shell=True) == 0:
                    self.append_log(f"✓ {dep} installed successfully")
                else:
                    self.append_log(f"✗ Failed to install {dep}", "ERROR")
            else:
                self.append_log("Automatic dependency installation is not supported on this platform", "WARN")
        except Exception as e:
            self.append_log(f"Error installing {dep}: {str(e)}", "ERROR")
    
    def run_performance_test(self):
        """Run performance test and show results"""
        self.update_status("Running performance test...")
        def show_results(output):
            self.append_log("Performance test completed. Results:")
            self.append_log(output)
        
        self.execute_script_command("performance-test", show_results)
    
    def toggle_theme(self):
        """Toggle between light and dark theme"""
        if self.dark_mode_var.get():
            # Set dark theme colors
            bg_color = '#2b2b2b'
            fg_color = '#ffffff'
            self.root.configure(bg=bg_color)
            for widget in self.root.winfo_children():
                widget.configure(bg=bg_color, fg=fg_color)
            
            self.append_log("Dark mode enabled")
        else:
            # Set light theme colors
            bg_color = '#ffffff'
            fg_color = '#000000'
            self.root.configure(bg=bg_color)
            for widget in self.root.winfo_children():
                widget.configure(bg=bg_color, fg=fg_color)
            
            self.append_log("Dark mode disabled")
        
        # Reconfigure styles
        self.setup_styles()

def main():
    """Main application entry point"""
    root = tk.Tk()
    app = SuperuserGUI(root)
    
    # Start auto-refresh if enabled
    def auto_refresh():
        if app.auto_refresh_var.get():
            app.refresh_status()
        root.after(30000, auto_refresh)  # Refresh every 30 seconds
    
    root.after(1000, auto_refresh)
    root.mainloop()

if __name__ == "__main__":
    main()