# 🚀 IT Support Center - Complete Technical Support Management System

<div align="center">

![Status](https://img.shields.io/badge/status-production%20ready-brightgreen?style=for-the-badge)
![Python](https://img.shields.io/badge/python-3.10+-blue?style=for-the-badge&logo=python)
![PostgreSQL](https://img.shields.io/badge/postgresql-14+-316192?style=for-the-badge&logo=postgresql)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

**Enterprise ticketing system with real-time hardware diagnostics**

[🎯 Features](#-key-features) • [⚡ Quick Start](#-quick-start) • [📖 Documentation](#-documentation) • [🔧 Architecture](#-architecture)

</div>

---

## 📋 Table of Contents

- [About The Project](#-about-the-project)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Usage](#-usage)
- [Architecture](#-architecture)
- [Database](#-database)
- [API & Commands](#-api--commands)
- [Use Cases](#-use-cases)
- [Troubleshooting](#-troubleshooting)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)

---

## 🎯 About The Project

IT Support Lab 2.0 is a **comprehensive technical support management system** designed for modern enterprise environments. It combines a robust ticketing system with advanced hardware diagnostic tools, all presented through a cutting-edge CLI interface.

### Why This Project?

- ✅ **Efficient Management**: Handle support tickets in an organized and professional manner
- ✅ **Proactive Diagnostics**: Detect hardware issues before they become critical
- ✅ **Complete Traceability**: Every ticket has a full history from creation to resolution
- ✅ **Knowledge Base**: Learn from previous tickets to solve problems faster
- ✅ **Enterprise-Ready**: Prepared to scale in organizations of any size

---

## 🌟 Key Features

### 🎫 Advanced Ticketing System

```
✓ Ticket creation and management with automatic categorization
✓ Priority system (Low, Medium, High, Critical)
✓ Intelligent technician assignment
✓ SLA (Service Level Agreement) tracking
✓ Internal and external comments
✓ Automatic resolution time calculation
✓ Configurable states (Open, In Progress, Pending, Resolved, Closed)
```

### 🔬 Real-Time Hardware Diagnostics

```
✓ CPU monitoring (usage, temperature, frequency)
✓ RAM and SWAP analysis
✓ Disk and storage status
✓ Network connectivity verification
✓ Automatic threshold alerts
✓ Exportable JSON reports
✓ Visual dashboard with Rich
```

### 📊 Reports and Statistics

```
✓ Real-time ticket statistics
✓ Distribution by category, priority, and status
✓ Team performance metrics
✓ Hardware report exports
✓ Visualization with colored tables and panels
```

### 📚 Knowledge Base

```
✓ Common solution articles
✓ Keyword search
✓ Article usefulness counter
✓ Intelligent categorization
```

---

## 🛠️ Tech Stack

<div align="center">

| Component | Technology | Version | Purpose |
|------------|-----------|---------|-----------|
| **Backend** | Python | 3.10+ | Business logic |
| **Database** | PostgreSQL | 14+ | Data persistence |
| **CLI Framework** | Rich | 12.0+ | Advanced visual interface |
| **DB Adapter** | psycopg2 | 2.9+ | PostgreSQL connection |
| **System Monitor** | psutil | 5.9+ | System metrics |
| **Argument Parser** | argparse | Built-in | CLI arguments |

</div>

---

## ⚙️ Prerequisites

### System Requirements

```bash
- Ubuntu 22.04 LTS (or higher)
- Python 3.10+
- PostgreSQL 14+
- 2GB RAM minimum
- 1GB disk space
- Sudo permissions for installation
```

### Recommended Knowledge

- ✓ Basic Linux/Terminal skills
- ✓ SQL fundamentals
- ✓ Basic Python (for modifications)
- ✓ IT Support concepts

---

## 📥 Installation

### Automatic Installation (Recommended)

```bash
# Clone or download the project
git clone https://github.com/your-username/it-support-lab.git
cd it-support-lab

# Run installation script
chmod +x install.sh
./install.sh

# The script will automatically install:
# - PostgreSQL
# - Python dependencies
# - Database configuration
# - Sample data
```

### Manual Installation (Step by Step)

#### 1️⃣ Create Directory Structure

```bash
mkdir -p it-support-lab/{database,ticket_system,diagnostic_tools,inventory,knowledge_base,runbooks,docs}
cd it-support-lab
```

#### 2️⃣ Install PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### 3️⃣ Configure Database

```bash
# Create database and user
sudo -u postgres psql -c "CREATE DATABASE it_support;"
sudo -u postgres psql -c "CREATE USER itsupport_user WITH PASSWORD '12345678';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE it_support TO itsupport_user;"

# Execute schema
psql -h localhost -U itsupport_user -d it_support -f database/it_support_simple.sql
```

#### 4️⃣ Install Python Dependencies

```bash
cd ticket_system
pip3 install -r requirements.txt
```

#### 5️⃣ Verify Installation

```bash
# Test database connection
psql -h localhost -U itsupport_user -d it_support -c "SELECT current_database();"

# Test ticket system
python3 ticket_manager.py stats

# Test diagnostics
cd ../diagnostic_tools
python3 hardware_diagnostic.py
```

---

## 🚀 Usage

### Ticket System

#### Create a Ticket

```bash
cd ticket_system

# Basic syntax
python3 ticket_manager.py create \
  "Problem title" \
  "Detailed description" \
  <category> \
  <priority> \
  <user_id>

# Real example
python3 ticket_manager.py create \
  "Monitor not turning on" \
  "Main monitor shows no image after the last power outage" \
  hardware \
  high \
  3
```

**Available categories:** `hardware`, `software`, `network`, `account`, `other`  
**Available priorities:** `low`, `medium`, `high`, `critical`

#### List Tickets

```bash
# All tickets
python3 ticket_manager.py list

# Filter by status
python3 ticket_manager.py list --status open

# Filter by priority
python3 ticket_manager.py list --priority critical

# Limit results
python3 ticket_manager.py list --limit 5
```

#### View Ticket Details

```bash
python3 ticket_manager.py get <ticket_id>

# Example
python3 ticket_manager.py get 1
```

#### Assign Ticket to Technician

```bash
python3 ticket_manager.py assign <ticket_id> <technician_id>

# Example
python3 ticket_manager.py assign 1 2
```

#### View Statistics

```bash
python3 ticket_manager.py stats
```

### Hardware Diagnostics

```bash
cd diagnostic_tools

# Run complete diagnostic
python3 hardware_diagnostic.py

# Results are automatically saved to:
# system_diagnostic_YYYYMMDD_HHMMSS.json
```

### Diagnostic Output

```
🚀 Starting Enhanced Hardware Diagnostic...

🖥️  Gathering system information...
🔍 Checking CPU...
💾 Checking Memory...
💽 Checking Disk...
🌐 Checking Network...

╭────────────────── System Diagnostic Report ──────────────────╮
│ 🏥 Overall System Health: HEALTHY                            │
│ 🖥️  Hostname: production-server                              │
│ 📅 Timestamp: 2025-10-26T11:26:42.983829                    │
│ 🔔 Alerts: 0                                                 │
╰──────────────────────────────────────────────────────────────╯

💾 Report saved to: system_diagnostic_20251026_112645.json
```

---

## 🏗️ Architecture

```
it-support-lab/
│
├── database/                      # Database
│   ├── it_support_simple.sql     # Complete schema
│   └── migrations/                # Future migrations
│
├── ticket_system/                 # Ticketing system
│   ├── ticket_manager.py         # Main CLI
│   ├── requirements.txt          # Dependencies
│   └── models/                   # Data models (future)
│
├── diagnostic_tools/              # Diagnostic tools
│   ├── hardware_diagnostic.py    # Hardware diagnostics
│   └── system_diagnostic_*.json  # Generated reports
│
├── inventory/                     # Inventory management (future)
│   └── asset_manager.py
│
├── knowledge_base/                # Knowledge base (future)
│   └── kb_search.py
│
├── runbooks/                      # Automated procedures
│   └── common_tasks.py
│
└── docs/                          # Documentation
    ├── README.md                  # This file
    ├── API.md                     # API documentation
    └── DEPLOYMENT.md              # Deployment guide
```

### Flow Diagram

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│    User     │────▶│   Ticket     │────▶│  PostgreSQL │
│    (CLI)    │     │   Manager    │     │  Database   │
└─────────────┘     └──────────────┘     └─────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │  Hardware    │
                    │  Diagnostic  │
                    └──────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │ JSON Report  │
                    └──────────────┘
```

---

## 💾 Database

### ER Schema

```
┌─────────────┐       ┌─────────────┐       ┌──────────────────┐
│   users     │       │   tickets   │       │ ticket_comments  │
├─────────────┤       ├─────────────┤       ├──────────────────┤
│ id (PK)     │──┐    │ id (PK)     │──┐    │ id (PK)          │
│ username    │  │    │ ticket_num  │  │    │ ticket_id (FK)   │
│ email       │  └───▶│ requester_id│  └───▶│ user_id (FK)     │
│ full_name   │       │ assigned_to │       │ comment          │
│ department  │       │ title       │       │ is_internal      │
│ role        │       │ description │       │ created_at       │
└─────────────┘       │ category    │       └──────────────────┘
                      │ priority    │
                      │ status      │
                      └─────────────┘
```

### Main Tables

#### 🧑‍💼 users
System user management

```sql
- id: Unique identifier
- username: Username
- email: Email address
- full_name: Full name
- department: Department
- role: admin | technician | user
- is_active: Account status
```

#### 🎫 tickets
Support tickets

```sql
- id: Unique identifier
- ticket_number: TKT-YYYYMMDD-XXXX
- title: Problem title
- description: Detailed description
- category: hardware | software | network | account | other
- priority: low | medium | high | critical
- status: open | in_progress | pending | resolved | closed
- requester_id: FK to users
- assigned_to: FK to users (technician)
- created_at: Creation timestamp
- updated_at: Last update
- closed_at: Closure timestamp
- resolution_time: Resolution time in minutes
```

#### 💬 ticket_comments
Comments and tracking

```sql
- id: Unique identifier
- ticket_id: FK to tickets
- user_id: FK to users
- comment: Comment text
- is_internal: Internal/external comment
- created_at: Timestamp
```

#### 💻 hardware_inventory
Equipment inventory

```sql
- id: Unique identifier
- asset_tag: Asset tag
- type: desktop | laptop | server | printer | monitor | network_device
- manufacturer: Manufacturer
- model: Model
- serial_number: Serial number
- assigned_to: FK to users
- status: active | in_repair | retired | lost | disposed
```

#### 📚 knowledge_base
Knowledge base

```sql
- id: Unique identifier
- title: Article title
- category: Category
- problem_description: Problem description
- solution: Step-by-step solution
- keywords: Array of keywords
- author_id: FK to users
- views: View counter
- helpful_count: Usefulness counter
```

---

## 📡 API & Commands

### Complete CLI Commands

#### Ticket Manager

```bash
# General help
python3 ticket_manager.py --help

# Create ticket
python3 ticket_manager.py create TITLE DESCRIPTION CATEGORY PRIORITY REQUESTER_ID

# List tickets
python3 ticket_manager.py list [--status STATUS] [--priority PRIORITY] [--limit N]

# View details
python3 ticket_manager.py get TICKET_ID

# Assign ticket
python3 ticket_manager.py assign TICKET_ID TECHNICIAN_ID

# Statistics
python3 ticket_manager.py stats
```

#### Hardware Diagnostic

```bash
# Complete diagnostic
python3 hardware_diagnostic.py

# Reports are automatically generated in JSON format
```

### Advanced Usage Examples

#### Create Multiple Tickets (Batch)

```bash
#!/bin/bash
# batch_create_tickets.sh

tickets=(
  "Printer offline:3rd floor printer not responding:hardware:high:4"
  "Password reset:User forgot password:account:medium:5"
  "Slow network:Intermittent connection throughout office:network:critical:3"
)

for ticket in "${tickets[@]}"; do
  IFS=':' read -r title desc category priority user <<< "$ticket"
  python3 ticket_manager.py create "$title" "$desc" "$category" "$priority" "$user"
done
```

#### Continuous Monitoring

```bash
#!/bin/bash
# continuous_monitor.sh

while true; do
  echo "=== Monitoring System $(date) ==="
  python3 hardware_diagnostic.py
  sleep 3600  # Every hour
done
```

---

## 🎯 Use Cases

### Case 1: Hardware Ticket with Diagnostics

```bash
# 1. User reports problem
python3 ticket_manager.py create \
  "Computer very slow" \
  "Computer takes a long time to open programs" \
  hardware \
  high \
  4

# Output: ✅ Ticket Created! TKT-20251026-1234

# 2. Technician runs diagnostic
cd ../diagnostic_tools
python3 hardware_diagnostic.py

# Output: System detects 92% RAM usage

# 3. Technician assigns ticket to themselves
cd ../ticket_system
python3 ticket_manager.py assign 5 2

# 4. Technician reviews details and adds solution
python3 ticket_manager.py get 5
```

### Case 2: Proactive Monitoring

```bash
# Scheduled monitoring script (cron)
# Runs diagnostic every 6 hours and creates ticket if problems detected

#!/bin/bash
REPORT=$(python3 diagnostic_tools/hardware_diagnostic.py)

if echo "$REPORT" | grep -q "CRITICAL"; then
  python3 ticket_system/ticket_manager.py create \
    "Critical system detected" \
    "Automatic monitoring detected a critical problem. See attached report." \
    hardware \
    critical \
    1
fi
```

### Case 3: Support Dashboard

```bash
# View current department status
python3 ticket_manager.py stats
python3 ticket_manager.py list --status open --priority critical
```

---

## 🔧 Troubleshooting

### Common Issues

#### ❌ Error: "Could not connect to server"

```bash
# Verify PostgreSQL is running
sudo systemctl status postgresql

# If not running, start it
sudo systemctl start postgresql

# Check port
sudo netstat -plnt | grep 5432
```

#### ❌ Error: "Permission denied for database"

```bash
# Re-assign permissions
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE it_support TO itsupport_user;"

# Verify permissions
psql -h localhost -U itsupport_user -d it_support -c "\l"
```

#### ❌ Error: "Module 'psycopg2' not found"

```bash
# Reinstall dependencies
pip3 install --upgrade -r ticket_system/requirements.txt

# Verify installation
python3 -c "import psycopg2; print('OK')"
```

#### ❌ Error: "Ticket number already exists"

```bash
# The number generator uses timestamp + random
# If you execute two commands very quickly, it may repeat

# Solution: Wait 1 second between commands
# Or regenerate with:
python3 ticket_manager.py create ... # (same command)
```

#### ⚠️ Warning: "High CPU temperature"

```bash
# This is an alert, not an error
# Check fans and system cleanliness

# View current temperature
sensors  # (requires lm-sensors)
```

### Logs and Debugging

```bash
# Enable verbose mode in Python
PYTHONVERBOSE=1 python3 ticket_manager.py stats

# View PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-14-main.log

# Check active connections
psql -h localhost -U itsupport_user -d it_support \
  -c "SELECT * FROM pg_stat_activity WHERE datname='it_support';"
```

---

## 🗺️ Roadmap

### ✅ Completed (v1.0)

- [x] Basic ticketing system
- [x] Hardware diagnostics
- [x] PostgreSQL database
- [x] CLI with Rich
- [x] Statistics system
- [x] Knowledge base

### 🚧 In Development (v1.5)

- [ ] REST API with FastAPI
- [ ] Web dashboard
- [ ] Email notifications
- [ ] Slack/Teams integration
- [ ] Advanced KB search
- [ ] PDF reports

### 🔮 Future (v2.0)

- [ ] Machine Learning for automatic categorization
- [ ] Support chatbot
- [ ] Mobile application
- [ ] Integration with monitoring systems (Nagios, Zabbix)
- [ ] Multi-tenant support
- [ ] Gamification for technicians

---

## 🤝 Contributing

Contributions are welcome! This project is open to improvements.

### How to Contribute

1. **Fork** the repository
2. Create a **branch** for your feature (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. Open a **Pull Request**

### Style Guidelines

- Python: PEP 8
- SQL: Use snake_case for tables and columns
- Commits: Use [Conventional Commits](https://www.conventionalcommits.org/)
- Documentation: Clear and technical English

### Report Bugs

Use the [Issue Tracker](https://github.com/your-username/it-support-lab/issues) with:

- Clear problem description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- System and Python version

---

## 📄 License

This project is licensed under the MIT License. See `LICENSE` file for details.

```
MIT License

Copyright (c) 2025 IT Support Lab

Permission is hereby granted, free of charge, to any person obtaining a copy...
```

---

## 👥 Authors

- **Your Name** - *Initial Development* - [@your-username](https://github.com/your-username)

See also the list of [contributors](https://github.com/your-username/it-support-lab/contributors) who participated in this project.

---

## 🙏 Acknowledgments

- PostgreSQL for its robust database
- psutil for system metrics
- Rich for making CLI beautiful
- Python community for incredible tools
- Everyone who uses this system and reports bugs

---

## 📞 Support

Need help?

- 📧 Email: support@itsupportlab.com
- 💬 Discord: [IT Support Lab Community](https://discord.gg/itsupportlab)
- 📖 Wiki: [Complete Documentation](https://github.com/your-username/it-support-lab/wiki)
- 🐛 Bugs: [Issue Tracker](https://github.com/your-username/it-support-lab/issues)

---

## 📊 Project Statistics

![GitHub stars](https://img.shields.io/github/stars/your-username/it-support-lab?style=social)
![GitHub forks](https://img.shields.io/github/forks/your-username/it-support-lab?style=social)
![GitHub issues](https://img.shields.io/github/issues/your-username/it-support-lab)
![GitHub pull requests](https://img.shields.io/github/issues-pr/your-username/it-support-lab)

---

<div align="center">

**[⬆ Back to top](#-it-support-lab-20---complete-technical-support-management-system)**

Made with ❤️ and ☕ by the IT Support Lab team

</div>
