#!/usr/bin/env python3
"""
Enhanced Hardware Diagnostic Tool
Comprehensive system health monitoring with alerting
"""

import psutil
import platform
import subprocess
import json
from datetime import datetime
import socket
import time
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import print as rprint

console = Console()

class EnhancedHardwareDiagnostic:
    def __init__(self):
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'hostname': platform.node(),
            'system_info': {},
            'tests': {},
            'alerts': [],
            'overall_status': 'HEALTHY'
        }

    def get_system_info(self):
        """Gather comprehensive system information"""
        print("🖥️  Gathering system information...")

        system_info = {
            'platform': platform.system(),
            'platform_version': platform.version(),
            'architecture': platform.architecture()[0],
            'processor': platform.processor(),
            'hostname': socket.gethostname(),
            'ip_address': socket.gethostbyname(socket.gethostname()),
            'boot_time': datetime.fromtimestamp(psutil.boot_time()).strftime("%Y-%m-%d %H:%M:%S")
        }

        self.results['system_info'] = system_info

    def check_cpu(self):
        """Comprehensive CPU diagnostic"""
        console.print("🔍 [bold blue]Checking CPU...[/bold blue]")

        try:
            cpu_info = {
                'physical_cores': psutil.cpu_count(logical=False),
                'logical_cores': psutil.cpu_count(logical=True),
                'usage_percent': psutil.cpu_percent(interval=1),
                'per_cpu_usage': psutil.cpu_percent(interval=1, percpu=True),
                'load_average': psutil.getloadavg() if hasattr(psutil, 'getloadavg') else 'N/A'
            }

            # CPU frequency information
            if psutil.cpu_freq():
                cpu_freq = psutil.cpu_freq()
                cpu_info['max_frequency'] = f"{cpu_freq.max:.2f} MHz"
                cpu_info['current_frequency'] = f"{cpu_freq.current:.2f} MHz"
                cpu_info['min_frequency'] = f"{cpu_freq.min:.2f} MHz"
            else:
                cpu_info['max_frequency'] = 'N/A'
                cpu_info['current_frequency'] = 'N/A'
                cpu_info['min_frequency'] = 'N/A'

            # Check for high CPU usage
            issues = []
            warnings = []

            if cpu_info['usage_percent'] > 90:
                issues.append(f"CRITICAL: CPU usage at {cpu_info['usage_percent']}%")
                self.results['overall_status'] = 'CRITICAL'
            elif cpu_info['usage_percent'] > 80:
                issues.append(f"High CPU usage: {cpu_info['usage_percent']}%")
                if self.results['overall_status'] == 'HEALTHY':
                    self.results['overall_status'] = 'WARNING'

            # Check CPU temperatures (Linux)
            try:
                temps = psutil.sensors_temperatures()
                if temps:
                    cpu_temps = []
                    for name, entries in temps.items():
                        if 'core' in name.lower() or 'cpu' in name.lower():
                            for entry in entries:
                                cpu_temps.append(entry.current)

                    if cpu_temps:
                        cpu_info['temperature'] = {
                            'max': max(cpu_temps),
                            'min': min(cpu_temps),
                            'average': sum(cpu_temps) / len(cpu_temps)
                        }

                        if max(cpu_temps) > 85:
                            issues.append(f"CRITICAL: High CPU temperature: {max(cpu_temps)}°C")
                            self.results['overall_status'] = 'CRITICAL'
                        elif max(cpu_temps) > 75:
                            warnings.append(f"High CPU temperature: {max(cpu_temps)}°C")
                            if self.results['overall_status'] == 'HEALTHY':
                                self.results['overall_status'] = 'WARNING'
                else:
                    cpu_info['temperature'] = 'N/A'
            except Exception as e:
                cpu_info['temperature'] = f"N/A ({str(e)})"

            # Check load average (Unix-like systems)
            if hasattr(psutil, 'getloadavg'):
                load_avg = psutil.getloadavg()
                cpu_info['load_average'] = load_avg
                # If load average is higher than number of cores, it might indicate issues
                if load_avg[0] > cpu_info['logical_cores']:
                    warnings.append(f"High load average: {load_avg[0]:.2f}")

            self.results['tests']['cpu'] = {
                'status': 'FAIL' if issues else 'WARNING' if warnings else 'PASS',
                'info': cpu_info,
                'issues': issues,
                'warnings': warnings
            }

            # Add to global alerts
            self.results['alerts'].extend(issues)
            self.results['alerts'].extend(warnings)

        except Exception as e:
            self.results['tests']['cpu'] = {
                'status': 'ERROR',
                'error': str(e)
            }

    def check_memory(self):
        """Comprehensive memory diagnostic"""
        console.print("💾 [bold blue]Checking Memory...[/bold blue]")

        try:
            mem = psutil.virtual_memory()
            swap = psutil.swap_memory()

            mem_info = {
                'total_gb': round(mem.total / (1024**3), 2),
                'available_gb': round(mem.available / (1024**3), 2),
                'used_gb': round(mem.used / (1024**3), 2),
                'percent_used': mem.percent,
                'swap_total_gb': round(swap.total / (1024**3), 2),
                'swap_used_gb': round(swap.used / (1024**3), 2),
                'swap_percent': swap.percent
            }

            issues = []
            warnings = []

            # Memory usage checks
            if mem.percent > 95:
                issues.append(f"CRITICAL: Memory usage at {mem.percent}%")
                self.results['overall_status'] = 'CRITICAL'
            elif mem.percent > 85:
                issues.append(f"High memory usage: {mem.percent}%")
                if self.results['overall_status'] == 'HEALTHY':
                    self.results['overall_status'] = 'WARNING'
            elif mem.percent > 75:
                warnings.append(f"Elevated memory usage: {mem.percent}%")

            # Swap usage checks
            if swap.percent > 80:
                issues.append(f"High swap usage: {swap.percent}% - Possible memory pressure")
                if self.results['overall_status'] == 'HEALTHY':
                    self.results['overall_status'] = 'WARNING'
            elif swap.percent > 50:
                warnings.append(f"Elevated swap usage: {swap.percent}%")

            self.results['tests']['memory'] = {
                'status': 'FAIL' if issues else 'WARNING' if warnings else 'PASS',
                'info': mem_info,
                'issues': issues,
                'warnings': warnings
            }

            self.results['alerts'].extend(issues)
            self.results['alerts'].extend(warnings)

        except Exception as e:
            self.results['tests']['memory'] = {
                'status': 'ERROR',
                'error': str(e)
            }

    def check_disk(self):
        """Comprehensive disk diagnostic"""
        console.print("💽 [bold blue]Checking Disk...[/bold blue]")

        try:
            disk_info = []
            issues = []
            warnings = []

            for partition in psutil.disk_partitions():
                try:
                    usage = psutil.disk_usage(partition.mountpoint)

                    part_info = {
                        'device': partition.device,
                        'mountpoint': partition.mountpoint,
                        'fstype': partition.fstype,
                        'total_gb': round(usage.total / (1024**3), 2),
                        'used_gb': round(usage.used / (1024**3), 2),
                        'free_gb': round(usage.free / (1024**3), 2),
                        'percent_used': usage.percent
                    }

                    disk_info.append(part_info)

                    # Disk usage checks
                    if usage.percent > 95:
                        issues.append(f"CRITICAL: Disk {partition.mountpoint} at {usage.percent}% capacity")
                        self.results['overall_status'] = 'CRITICAL'
                    elif usage.percent > 90:
                        issues.append(f"High disk usage on {partition.mountpoint}: {usage.percent}%")
                        if self.results['overall_status'] == 'HEALTHY':
                            self.results['overall_status'] = 'WARNING'
                    elif usage.percent > 85:
                        warnings.append(f"Elevated disk usage on {partition.mountpoint}: {usage.percent}%")

                except PermissionError:
                    # Skip partitions we can't access
                    continue

            # Disk I/O statistics
            disk_io = psutil.disk_io_counters()
            if disk_io:
                disk_info.append({
                    'io_stats': {
                        'read_count': disk_io.read_count,
                        'write_count': disk_io.write_count,
                        'read_bytes_gb': round(disk_io.read_bytes / (1024**3), 2),
                        'write_bytes_gb': round(disk_io.write_bytes / (1024**3), 2)
                    }
                })

            self.results['tests']['disk'] = {
                'status': 'FAIL' if issues else 'WARNING' if warnings else 'PASS',
                'info': disk_info,
                'issues': issues,
                'warnings': warnings
            }

            self.results['alerts'].extend(issues)
            self.results['alerts'].extend(warnings)

        except Exception as e:
            self.results['tests']['disk'] = {
                'status': 'ERROR',
                'error': str(e)
            }

    def check_network(self):
        """Basic network connectivity check"""
        console.print("🌐 [bold blue]Checking Network...[/bold blue]")

        try:
            network_info = {}
            issues = []
            warnings = []

            # Network interfaces
            net_io = psutil.net_io_counters()
            network_info['bytes_sent_mb'] = round(net_io.bytes_sent / (1024**2), 2)
            network_info['bytes_recv_mb'] = round(net_io.bytes_recv / (1024**2), 2)

            # Network connections
            connections = psutil.net_connections()
            network_info['total_connections'] = len(connections)

            # Basic connectivity test
            try:
                # Try to resolve google.com to check DNS
                socket.gethostbyname('google.com')
                network_info['dns_resolution'] = 'WORKING'
            except:
                network_info['dns_resolution'] = 'FAILED'
                issues.append("DNS resolution failed")

            self.results['tests']['network'] = {
                'status': 'FAIL' if issues else 'WARNING' if warnings else 'PASS',
                'info': network_info,
                'issues': issues,
                'warnings': warnings
            }

            self.results['alerts'].extend(issues)
            self.results['alerts'].extend(warnings)

        except Exception as e:
            self.results['tests']['network'] = {
                'status': 'ERROR',
                'error': str(e)
            }

    def display_results(self):
        """Display comprehensive results in rich format"""
        # Overall status panel
        status_color = {
            'HEALTHY': 'green',
            'WARNING': 'yellow',
            'CRITICAL': 'red'
        }.get(self.results['overall_status'], 'white')

        console.print(Panel(
            f"🏥 [bold]Overall System Health:[/bold] [{status_color}]{self.results['overall_status']}[/{status_color}]\n"
            f"🖥️  Hostname: {self.results['hostname']}\n"
            f"📅 Timestamp: {self.results['timestamp']}\n"
            f"🔔 Alerts: {len(self.results['alerts'])}",
            title="System Diagnostic Report",
            border_style=status_color
        ))

        # System information
        sys_info = self.results['system_info']
        console.print(Panel(
            f"💻 Platform: {sys_info['platform']} {sys_info['platform_version']}\n"
            f"🏗️  Architecture: {sys_info['architecture']}\n"
            f"⚡ Processor: {sys_info['processor']}\n"
            f"🔌 Boot Time: {sys_info['boot_time']}\n"
            f"📍 IP Address: {sys_info['ip_address']}",
            title="System Information",
            border_style="blue"
        ))

        # Detailed test results
        for test_name, test_result in self.results['tests'].items():
            if test_result['status'] == 'ERROR':
                console.print(Panel(
                    f"❌ {test_name.upper()}: ERROR - {test_result['error']}",
                    border_style="red"
                ))
                continue

            status_color = {
                'PASS': 'green',
                'WARNING': 'yellow',
                'FAIL': 'red'
            }.get(test_result['status'], 'white')

            # Create table for each test
            table = Table(title=f"{test_name.upper()} Diagnostic", show_header=True)
            table.add_column("Metric", style="cyan")
            table.add_column("Value", style="white")

            if test_name == 'cpu':
                info = test_result['info']
                table.add_row("Physical Cores", str(info['physical_cores']))
                table.add_row("Logical Cores", str(info['logical_cores']))
                table.add_row("Usage", f"{info['usage_percent']}%")
                table.add_row("Current Frequency", info['current_frequency'])
                if 'temperature' in info and info['temperature'] != 'N/A':
                    table.add_row("Max Temperature", f"{info['temperature']['max']}°C")

            elif test_name == 'memory':
                info = test_result['info']
                table.add_row("Total Memory", f"{info['total_gb']} GB")
                table.add_row("Used Memory", f"{info['used_gb']} GB ({info['percent_used']}%)")
                table.add_row("Available Memory", f"{info['available_gb']} GB")
                table.add_row("Swap Usage", f"{info['swap_percent']}%")

            elif test_name == 'disk':
                for disk in test_result['info']:
                    if 'device' in disk:
                        table.add_row(
                            f"Disk {disk['mountpoint']}",
                            f"{disk['used_gb']}/{disk['total_gb']} GB ({disk['percent_used']}%)")

            elif test_name == 'network':
                info = test_result['info']
                table.add_row("DNS Resolution", info['dns_resolution'])
                table.add_row("Data Sent", f"{info['bytes_sent_mb']} MB")
                table.add_row("Data Received", f"{info['bytes_recv_mb']} MB")

            console.print(Panel(
                table,
                title=f"{test_name.upper()} - [{status_color}]{test_result['status']}[/{status_color}]",
                border_style=status_color
            ))

            # Show issues and warnings
            if test_result['issues']:
                console.print(Panel(
                    "\n".join([f"❌ {issue}" for issue in test_result['issues']]),
                    title="Critical Issues",
                    border_style="red"
                ))

            if test_result['warnings']:
                console.print(Panel(
                    "\n".join([f"⚠️  {warning}" for warning in test_result['warnings']]),
                    title="Warnings",
                    border_style="yellow"
                ))

        # Summary of alerts
        if self.results['alerts']:
            console.print(Panel(
                "\n".join([f"• {alert}" for alert in self.results['alerts']]),
                title="📋 Summary of Alerts",
                border_style="red" if self.results['overall_status'] == 'CRITICAL' else "yellow"
            ))

    def run_all_checks(self):
        """Run all diagnostic checks"""
        self.get_system_info()
        self.check_cpu()
        self.check_memory()
        self.check_disk()
        self.check_network()
        self.display_results()

        # Save results to file
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"system_diagnostic_{timestamp}.json"
        with open(filename, 'w') as f:
            json.dump(self.results, f, indent=2)

        console.print(f"\n💾 [bold green]Report saved to: {filename}[/bold green]")

def main():
    """Main function"""
    console.print("🚀 [bold blue]Starting Enhanced Hardware Diagnostic...[/bold blue]\n")

    diagnostic = EnhancedHardwareDiagnostic()
    diagnostic.run_all_checks()

if __name__ == "__main__":
    main()
