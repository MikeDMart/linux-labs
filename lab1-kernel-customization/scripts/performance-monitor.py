#!/usr/bin/env python3
"""
Real-time Performance Monitoring System
Monitors CPU, Memory, Disk, and Network usage
"""

import psutil
import time
import sys
import os
from datetime import datetime
from collections import deque

class PerformanceMonitor:
    def __init__(self, interval=1, history_size=60):
        self.interval = interval
        self.history_size = history_size
        
        # History buffers
        self.cpu_history = deque(maxlen=history_size)
        self.mem_history = deque(maxlen=history_size)
        self.disk_history = deque(maxlen=history_size)
        self.net_history = deque(maxlen=history_size)
        
        # Network counters
        self.last_net_io = psutil.net_io_counters()
        self.last_time = time.time()
    
    def clear_screen(self):
        """Clear terminal screen"""
        os.system('clear' if os.name == 'posix' else 'cls')
    
    def get_cpu_info(self):
        """Get CPU usage information"""
        cpu_percent = psutil.cpu_percent(interval=0.1)
        cpu_freq = psutil.cpu_freq()
        cpu_count = psutil.cpu_count()
        
        self.cpu_history.append(cpu_percent)
        
        return {
            'percent': cpu_percent,
            'freq': cpu_freq.current if cpu_freq else 0,
            'count': cpu_count,
            'per_cpu': psutil.cpu_percent(interval=0.1, percpu=True)
        }
    
    def get_memory_info(self):
        """Get memory usage information"""
        mem = psutil.virtual_memory()
        swap = psutil.swap_memory()
        
        self.mem_history.append(mem.percent)
        
        return {
            'total': mem.total,
            'available': mem.available,
            'used': mem.used,
            'percent': mem.percent,
            'swap_total': swap.total,
            'swap_used': swap.used,
            'swap_percent': swap.percent
        }
    
    def get_disk_info(self):
        """Get disk usage information"""
        disk_info = []
        
        for partition in psutil.disk_partitions():
            try:
                usage = psutil.disk_usage(partition.mountpoint)
                disk_info.append({
                    'device': partition.device,
                    'mountpoint': partition.mountpoint,
                    'fstype': partition.fstype,
                    'total': usage.total,
                    'used': usage.used,
                    'free': usage.free,
                    'percent': usage.percent
                })
            except PermissionError:
                continue
        
        return disk_info
    
    def get_network_info(self):
        """Get network usage information"""
        current_net_io = psutil.net_io_counters()
        current_time = time.time()
        
        time_delta = current_time - self.last_time
        
        bytes_sent_per_sec = (current_net_io.bytes_sent - self.last_net_io.bytes_sent) / time_delta
        bytes_recv_per_sec = (current_net_io.bytes_recv - self.last_net_io.bytes_recv) / time_delta
        
        self.last_net_io = current_net_io
        self.last_time = current_time
        
        self.net_history.append((bytes_sent_per_sec, bytes_recv_per_sec))
        
        return {
            'bytes_sent_per_sec': bytes_sent_per_sec,
            'bytes_recv_per_sec': bytes_recv_per_sec,
            'packets_sent': current_net_io.packets_sent,
            'packets_recv': current_net_io.packets_recv
        }
    
    def get_top_processes(self, n=10):
        """Get top N processes by CPU usage"""
        processes = []
        
        for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']):
            try:
                processes.append(proc.info)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        
        # Sort by CPU usage
        processes.sort(key=lambda x: x['cpu_percent'], reverse=True)
        return processes[:n]
    
    def format_bytes(self, bytes_val):
        """Format bytes to human readable format"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if bytes_val < 1024.0:
                return f"{bytes_val:.2f} {unit}"
            bytes_val /= 1024.0
        return f"{bytes_val:.2f} PB"
    
    def create_bar(self, percent, width=50):
        """Create a visual bar representation"""
        filled = int(width * percent / 100)
        bar = '█' * filled + '░' * (width - filled)
        return f"[{bar}] {percent:.1f}%"
    
    def display_dashboard(self):
        """Display the monitoring dashboard"""
        while True:
            try:
                self.clear_screen()
                
                # Header
                print("=" * 100)
                print(f"SYSTEM PERFORMANCE MONITOR - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                print(f"Hostname: {os.uname().nodename} | Uptime: {self.format_uptime()}")
                print("=" * 100)
                print()
                
                # CPU Information
                cpu_info = self.get_cpu_info()
                print("CPU USAGE")
                print(self.create_bar(cpu_info['percent']))
                print(f"Frequency: {cpu_info['freq']:.2f} MHz | Cores: {cpu_info['count']}")
                print("Per-Core: ", end="")
                for i, percent in enumerate(cpu_info['per_cpu']):
                    print(f"CPU{i}:{percent:5.1f}% ", end="")
                print("\n")
                
                # Memory Information
                mem_info = self.get_memory_info()
                print("MEMORY USAGE")
                print(self.create_bar(mem_info['percent']))
                print(f"Total: {self.format_bytes(mem_info['total'])} | " + 
                      f"Used: {self.format_bytes(mem_info['used'])} | " +
                      f"Available: {self.format_bytes(mem_info['available'])}")
                if mem_info['swap_total'] > 0:
                    print(f"Swap: {self.format_bytes(mem_info['swap_used'])} / " +
                          f"{self.format_bytes(mem_info['swap_total'])} " +
                          f"({mem_info['swap_percent']:.1f}%)")
                print()
                
                # Disk Information
                print("DISK USAGE")
                disk_info = self.get_disk_info()
                for disk in disk_info[:3]:  # Show top 3 partitions
                    print(f"{disk['mountpoint']:20} " +
                          f"{self.create_bar(disk['percent'], width=30)} " +
                          f"{self.format_bytes(disk['used'])} / {self.format_bytes(disk['total'])}")
                print()
                
                # Network Information
                net_info = self.get_network_info()
                print("NETWORK USAGE")
                print(f"↑ Upload:   {self.format_bytes(net_info['bytes_sent_per_sec'])}/s")
                print(f"↓ Download: {self.format_bytes(net_info['bytes_recv_per_sec'])}/s")
                print()
                
                # Top Processes
                print("TOP PROCESSES BY CPU")
                print(f"{'PID':<8} {'NAME':<25} {'CPU%':<8} {'MEM%':<8}")
                print("-" * 50)
                for proc in self.get_top_processes(5):
                    print(f"{proc['pid']:<8} {proc['name']:<25} " +
                          f"{proc['cpu_percent']:<8.1f} {proc['memory_percent']:<8.1f}")
                
                print()
                print("Press Ctrl+C to exit")
                
                time.sleep(self.interval)
                
            except KeyboardInterrupt:
                print("\nMonitoring stopped.")
                sys.exit(0)
            except Exception as e:
                print(f"Error: {e}")
                time.sleep(self.interval)
    
    def format_uptime(self):
        """Format system uptime"""
        uptime_seconds = time.time() - psutil.boot_time()
        days = int(uptime_seconds // 86400)
        hours = int((uptime_seconds % 86400) // 3600)
        minutes = int((uptime_seconds % 3600) // 60)
        return f"{days}d {hours}h {minutes}m"

if __name__ == "__main__":
    monitor = PerformanceMonitor(interval=1)
    monitor.display_dashboard()
