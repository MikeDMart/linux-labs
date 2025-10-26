# 🚀 IT Support Lab 2.0 - Sistema Completo de Gestión de Soporte Técnico

<div align="center">

![Status](https://img.shields.io/badge/status-production%20ready-brightgreen?style=for-the-badge)
![Python](https://img.shields.io/badge/python-3.10+-blue?style=for-the-badge&logo=python)
![PostgreSQL](https://img.shields.io/badge/postgresql-14+-316192?style=for-the-badge&logo=postgresql)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

**Sistema empresarial de tickets con diagnóstico de hardware en tiempo real**

[🎯 Características](#-características-principales) • [⚡ Inicio Rápido](#-inicio-rápido) • [📖 Documentación](#-documentación) • [🔧 Arquitectura](#-arquitectura)

</div>

---

## 📋 Tabla de Contenidos

- [Acerca del Proyecto](#-acerca-del-proyecto)
- [Características Principales](#-características-principales)
- [Stack Tecnológico](#-stack-tecnológico)
- [Prerequisitos](#-prerequisitos)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Arquitectura](#-arquitectura)
- [Base de Datos](#-base-de-datos)
- [API y Comandos](#-api-y-comandos)
- [Casos de Uso](#-casos-de-uso)
- [Troubleshooting](#-troubleshooting)
- [Roadmap](#-roadmap)
- [Contribución](#-contribución)

---

## 🎯 Acerca del Proyecto

IT Support Lab 2.0 es un **sistema integral de gestión de soporte técnico** diseñado para entornos empresariales modernos. Combina un robusto sistema de ticketing con herramientas avanzadas de diagnóstico de hardware, todo presentado con una interfaz CLI de última generación.

### ¿Por qué este proyecto?

- ✅ **Gestión Eficiente**: Maneja tickets de soporte de forma organizada y profesional
- ✅ **Diagnóstico Proactivo**: Detecta problemas de hardware antes de que se conviertan en críticos
- ✅ **Trazabilidad Completa**: Cada ticket tiene un historial completo desde creación hasta resolución
- ✅ **Base de Conocimiento**: Aprende de tickets anteriores para resolver problemas más rápido
- ✅ **Enterprise-Ready**: Preparado para escalar en organizaciones de cualquier tamaño

---

## 🌟 Características Principales

### 🎫 Sistema de Tickets Avanzado

```
✓ Creación y gestión de tickets con categorización automática
✓ Sistema de prioridades (Low, Medium, High, Critical)
✓ Asignación inteligente a técnicos
✓ Seguimiento de SLA (Service Level Agreement)
✓ Comentarios internos y externos
✓ Cálculo automático de tiempo de resolución
✓ Estados configurables (Open, In Progress, Pending, Resolved, Closed)
```

### 🔬 Diagnóstico de Hardware en Tiempo Real

```
✓ Monitoreo de CPU (uso, temperatura, frecuencia)
✓ Análisis de memoria RAM y SWAP
✓ Estado de discos y almacenamiento
✓ Verificación de conectividad de red
✓ Alertas automáticas por umbrales
✓ Reportes JSON exportables
✓ Dashboard visual con Rich
```

### 📊 Reportes y Estadísticas

```
✓ Estadísticas en tiempo real de tickets
✓ Distribución por categoría, prioridad y estado
✓ Métricas de rendimiento del equipo
✓ Exportación de reportes de hardware
✓ Visualización con tablas y paneles coloridos
```

### 📚 Base de Conocimiento

```
✓ Artículos de soluciones comunes
✓ Búsqueda por keywords
✓ Contador de utilidad de artículos
✓ Categorización inteligente
```

---

## 🛠️ Stack Tecnológico

<div align="center">

| Componente | Tecnología | Versión | Propósito |
|------------|-----------|---------|-----------|
| **Backend** | Python | 3.10+ | Lógica de negocio |
| **Base de Datos** | PostgreSQL | 14+ | Persistencia de datos |
| **CLI Framework** | Rich | 12.0+ | Interfaz visual avanzada |
| **DB Adapter** | psycopg2 | 2.9+ | Conexión PostgreSQL |
| **System Monitor** | psutil | 5.9+ | Métricas del sistema |
| **Argument Parser** | argparse | Built-in | CLI arguments |

</div>

---

## ⚙️ Prerequisitos

### Requisitos del Sistema

```bash
- Ubuntu 22.04 LTS (o superior)
- Python 3.10+
- PostgreSQL 14+
- 2GB RAM mínimo
- 1GB espacio en disco
- Permisos sudo para instalación
```

### Conocimientos Recomendados

- ✓ Básicos de Linux/Terminal
- ✓ SQL fundamentals
- ✓ Python básico (para modificaciones)
- ✓ Conceptos de IT Support

---

## 📥 Instalación

### Instalación Automática (Recomendada)

```bash
# Clonar o descargar el proyecto
git clone https://github.com/tu-usuario/it-support-lab.git
cd it-support-lab

# Ejecutar script de instalación
chmod +x install.sh
./install.sh

# El script instalará automáticamente:
# - PostgreSQL
# - Python dependencies
# - Configuración de base de datos
# - Datos de ejemplo
```

### Instalación Manual (Paso a Paso)

#### 1️⃣ Crear Estructura de Directorios

```bash
mkdir -p it-support-lab/{database,ticket_system,diagnostic_tools,inventory,knowledge_base,runbooks,docs}
cd it-support-lab
```

#### 2️⃣ Instalar PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### 3️⃣ Configurar Base de Datos

```bash
# Crear base de datos y usuario
sudo -u postgres psql -c "CREATE DATABASE it_support;"
sudo -u postgres psql -c "CREATE USER itsupport_user WITH PASSWORD '12345678';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE it_support TO itsupport_user;"

# Ejecutar esquema
psql -h localhost -U itsupport_user -d it_support -f database/it_support_simple.sql
```

#### 4️⃣ Instalar Dependencias Python

```bash
cd ticket_system
pip3 install -r requirements.txt
```

#### 5️⃣ Verificar Instalación

```bash
# Test de conexión a BD
psql -h localhost -U itsupport_user -d it_support -c "SELECT current_database();"

# Test del sistema de tickets
python3 ticket_manager.py stats

# Test de diagnóstico
cd ../diagnostic_tools
python3 hardware_diagnostic.py
```

---

## 🚀 Uso

### Sistema de Tickets

#### Crear un Ticket

```bash
cd ticket_system

# Sintaxis básica
python3 ticket_manager.py create \
  "Título del problema" \
  "Descripción detallada" \
  <categoria> \
  <prioridad> \
  <id_usuario>

# Ejemplo real
python3 ticket_manager.py create \
  "Monitor no enciende" \
  "El monitor principal no muestra imagen después del último apagón" \
  hardware \
  high \
  3
```

**Categorías disponibles:** `hardware`, `software`, `network`, `account`, `other`  
**Prioridades disponibles:** `low`, `medium`, `high`, `critical`

#### Listar Tickets

```bash
# Todos los tickets
python3 ticket_manager.py list

# Filtrar por estado
python3 ticket_manager.py list --status open

# Filtrar por prioridad
python3 ticket_manager.py list --priority critical

# Limitar resultados
python3 ticket_manager.py list --limit 5
```

#### Ver Detalles de un Ticket

```bash
python3 ticket_manager.py get <ticket_id>

# Ejemplo
python3 ticket_manager.py get 1
```

#### Asignar Ticket a Técnico

```bash
python3 ticket_manager.py assign <ticket_id> <technician_id>

# Ejemplo
python3 ticket_manager.py assign 1 2
```

#### Ver Estadísticas

```bash
python3 ticket_manager.py stats
```

### Diagnóstico de Hardware

```bash
cd diagnostic_tools

# Ejecutar diagnóstico completo
python3 hardware_diagnostic.py

# Los resultados se guardan automáticamente en:
# system_diagnostic_YYYYMMDD_HHMMSS.json
```

### Salida del Diagnóstico

```
🚀 Starting Enhanced Hardware Diagnostic...

🖥️  Gathering system information...
🔍 Checking CPU...
💾 Checking Memory...
💽 Checking Disk...
🌐 Checking Network...

╭────────────────── System Diagnostic Report ──────────────────╮
│ 🏥 Overall System Health: HEALTHY                            │
│ 🖥️  Hostname: servidor-produccion                            │
│ 📅 Timestamp: 2025-10-26T11:26:42.983829                    │
│ 🔔 Alerts: 0                                                 │
╰──────────────────────────────────────────────────────────────╯

💾 Report saved to: system_diagnostic_20251026_112645.json
```

---

## 🏗️ Arquitectura

```
it-support-lab/
│
├── database/                      # Base de datos
│   ├── it_support_simple.sql     # Esquema completo
│   └── migrations/                # Migraciones futuras
│
├── ticket_system/                 # Sistema de tickets
│   ├── ticket_manager.py         # CLI principal
│   ├── requirements.txt          # Dependencias
│   └── models/                   # Modelos de datos (futuro)
│
├── diagnostic_tools/              # Herramientas de diagnóstico
│   ├── hardware_diagnostic.py    # Diagnóstico de hardware
│   └── system_diagnostic_*.json  # Reportes generados
│
├── inventory/                     # Gestión de inventario (futuro)
│   └── asset_manager.py
│
├── knowledge_base/                # Base de conocimiento (futuro)
│   └── kb_search.py
│
├── runbooks/                      # Procedimientos automatizados
│   └── common_tasks.py
│
└── docs/                          # Documentación
    ├── README.md                  # Este archivo
    ├── API.md                     # Documentación API
    └── DEPLOYMENT.md              # Guía de despliegue
```

### Diagrama de Flujo

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Usuario   │────▶│   Ticket     │────▶│  PostgreSQL │
│   (CLI)     │     │   Manager    │     │  Database   │
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

## 💾 Base de Datos

### Esquema ER

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

### Tablas Principales

#### 🧑‍💼 users
Gestión de usuarios del sistema

```sql
- id: Identificador único
- username: Nombre de usuario
- email: Correo electrónico
- full_name: Nombre completo
- department: Departamento
- role: admin | technician | user
- is_active: Estado de la cuenta
```

#### 🎫 tickets
Tickets de soporte

```sql
- id: Identificador único
- ticket_number: TKT-YYYYMMDD-XXXX
- title: Título del problema
- description: Descripción detallada
- category: hardware | software | network | account | other
- priority: low | medium | high | critical
- status: open | in_progress | pending | resolved | closed
- requester_id: FK a users
- assigned_to: FK a users (técnico)
- created_at: Timestamp de creación
- updated_at: Última actualización
- closed_at: Timestamp de cierre
- resolution_time: Tiempo de resolución en minutos
```

#### 💬 ticket_comments
Comentarios y seguimiento

```sql
- id: Identificador único
- ticket_id: FK a tickets
- user_id: FK a users
- comment: Texto del comentario
- is_internal: Comentario interno/externo
- created_at: Timestamp
```

#### 💻 hardware_inventory
Inventario de equipos

```sql
- id: Identificador único
- asset_tag: Etiqueta del activo
- type: desktop | laptop | server | printer | monitor | network_device
- manufacturer: Fabricante
- model: Modelo
- serial_number: Número de serie
- assigned_to: FK a users
- status: active | in_repair | retired | lost | disposed
```

#### 📚 knowledge_base
Base de conocimiento

```sql
- id: Identificador único
- title: Título del artículo
- category: Categoría
- problem_description: Descripción del problema
- solution: Solución paso a paso
- keywords: Array de palabras clave
- author_id: FK a users
- views: Contador de visitas
- helpful_count: Contador de utilidad
```

---

## 📡 API y Comandos

### Comandos CLI Completos

#### Ticket Manager

```bash
# Help general
python3 ticket_manager.py --help

# Crear ticket
python3 ticket_manager.py create TITLE DESCRIPTION CATEGORY PRIORITY REQUESTER_ID

# Listar tickets
python3 ticket_manager.py list [--status STATUS] [--priority PRIORITY] [--limit N]

# Ver detalles
python3 ticket_manager.py get TICKET_ID

# Asignar ticket
python3 ticket_manager.py assign TICKET_ID TECHNICIAN_ID

# Estadísticas
python3 ticket_manager.py stats
```

#### Hardware Diagnostic

```bash
# Diagnóstico completo
python3 hardware_diagnostic.py

# Los reportes se generan automáticamente en formato JSON
```

### Ejemplos de Uso Avanzado

#### Crear Múltiples Tickets (Batch)

```bash
#!/bin/bash
# batch_create_tickets.sh

tickets=(
  "Impresora offline:La impresora del piso 3 no responde:hardware:high:4"
  "Password reset:Usuario olvidó su contraseña:account:medium:5"
  "Red lenta:Conexión intermitente en toda la oficina:network:critical:3"
)

for ticket in "${tickets[@]}"; do
  IFS=':' read -r title desc category priority user <<< "$ticket"
  python3 ticket_manager.py create "$title" "$desc" "$category" "$priority" "$user"
done
```

#### Monitoreo Continuo

```bash
#!/bin/bash
# continuous_monitor.sh

while true; do
  echo "=== Sistema de Monitoreo $(date) ==="
  python3 hardware_diagnostic.py
  sleep 3600  # Cada hora
done
```

---

## 🎯 Casos de Uso

### Caso 1: Ticket de Hardware con Diagnóstico

```bash
# 1. Usuario reporta problema
python3 ticket_manager.py create \
  "Computadora muy lenta" \
  "La computadora tarda mucho en abrir programas" \
  hardware \
  high \
  4

# Output: ✅ Ticket Created! TKT-20251026-1234

# 2. Técnico ejecuta diagnóstico
cd ../diagnostic_tools
python3 hardware_diagnostic.py

# Output: Sistema detecta 92% uso de RAM

# 3. Técnico asigna el ticket a sí mismo
cd ../ticket_system
python3 ticket_manager.py assign 5 2

# 4. Técnico revisa detalles y agrega solución
python3 ticket_manager.py get 5
```

### Caso 2: Monitoreo Proactivo

```bash
# Script de monitoreo programado (cron)
# Ejecuta diagnóstico cada 6 horas y crea ticket si detecta problemas

#!/bin/bash
REPORT=$(python3 diagnostic_tools/hardware_diagnostic.py)

if echo "$REPORT" | grep -q "CRITICAL"; then
  python3 ticket_system/ticket_manager.py create \
    "Sistema crítico detectado" \
    "El monitoreo automático detectó un problema crítico. Ver reporte adjunto." \
    hardware \
    critical \
    1
fi
```

### Caso 3: Dashboard de Soporte

```bash
# Ver estado actual del departamento
python3 ticket_manager.py stats
python3 ticket_manager.py list --status open --priority critical
```

---

## 🔧 Troubleshooting

### Problemas Comunes

#### ❌ Error: "Could not connect to server"

```bash
# Verificar que PostgreSQL está corriendo
sudo systemctl status postgresql

# Si no está corriendo, iniciar
sudo systemctl start postgresql

# Verificar puerto
sudo netstat -plnt | grep 5432
```

#### ❌ Error: "Permission denied for database"

```bash
# Re-asignar permisos
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE it_support TO itsupport_user;"

# Verificar permisos
psql -h localhost -U itsupport_user -d it_support -c "\l"
```

#### ❌ Error: "Module 'psycopg2' not found"

```bash
# Reinstalar dependencias
pip3 install --upgrade -r ticket_system/requirements.txt

# Verificar instalación
python3 -c "import psycopg2; print('OK')"
```

#### ❌ Error: "Ticket number already exists"

```bash
# El generador de números usa timestamp + random
# Si ejecutas muy rápido dos comandos, puede repetir

# Solución: Esperar 1 segundo entre comandos
# O regenerar con:
python3 ticket_manager.py create ... # (mismo comando)
```

#### ⚠️ Advertencia: "High CPU temperature"

```bash
# Esto es una alerta, no un error
# Verificar ventiladores y limpieza del sistema

# Ver temperatura actual
sensors  # (requiere lm-sensors)
```

### Logs y Debugging

```bash
# Habilitar modo verbose en Python
PYTHONVERBOSE=1 python3 ticket_manager.py stats

# Ver logs de PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-14-main.log

# Verificar conexiones activas
psql -h localhost -U itsupport_user -d it_support \
  -c "SELECT * FROM pg_stat_activity WHERE datname='it_support';"
```

---

## 🗺️ Roadmap

### ✅ Completado (v1.0)

- [x] Sistema de tickets básico
- [x] Diagnóstico de hardware
- [x] Base de datos PostgreSQL
- [x] CLI con Rich
- [x] Sistema de estadísticas
- [x] Base de conocimiento

### 🚧 En Desarrollo (v1.5)

- [ ] API REST con FastAPI
- [ ] Dashboard web
- [ ] Notificaciones por email
- [ ] Integración con Slack/Teams
- [ ] Búsqueda avanzada en KB
- [ ] Reportes PDF

### 🔮 Futuro (v2.0)

- [ ] Machine Learning para categorización automática
- [ ] Chatbot de soporte
- [ ] Aplicación móvil
- [ ] Integración con sistemas de monitoreo (Nagios, Zabbix)
- [ ] Multi-tenant support
- [ ] Gamificación para técnicos

---

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Este proyecto está abierto a mejoras.

### Cómo Contribuir

1. **Fork** el repositorio
2. Crea una **rama** para tu feature (`git checkout -b feature/amazing-feature`)
3. **Commit** tus cambios (`git commit -m 'Add amazing feature'`)
4. **Push** a la rama (`git push origin feature/amazing-feature`)
5. Abre un **Pull Request**

### Guías de Estilo

- Python: PEP 8
- SQL: Usar snake_case para tablas y columnas
- Commits: Usar [Conventional Commits](https://www.conventionalcommits.org/)
- Documentación: Español claro y técnico

### Reportar Bugs

Usa el [Issue Tracker](https://github.com/tu-usuario/it-support-lab/issues) con:

- Descripción clara del problema
- Pasos para reproducir
- Comportamiento esperado vs actual
- Screenshots si aplica
- Versión del sistema y Python

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver archivo `LICENSE` para más detalles.

```
MIT License

Copyright (c) 2025 IT Support Lab

Permission is hereby granted, free of charge, to any person obtaining a copy...
```

---

## 👥 Autores

- **Tu Nombre** - *Desarrollo Inicial* - [@tu-usuario](https://github.com/tu-usuario)

Ver también la lista de [contribuidores](https://github.com/tu-usuario/it-support-lab/contributors) que participaron en este proyecto.

---

## 🙏 Agradecimientos

- PostgreSQL por su robusta base de datos
- psutil por las métricas del sistema
- Rich por hacer el CLI hermoso
- La comunidad de Python por herramientas increíbles
- Todos los que usan este sistema y reportan bugs

---

## 📞 Soporte

¿Necesitas ayuda?

- 📧 Email: support@itsupportlab.com
- 💬 Discord: [IT Support Lab Community](https://discord.gg/itsupportlab)
- 📖 Wiki: [Documentación Completa](https://github.com/tu-usuario/it-support-lab/wiki)
- 🐛 Bugs: [Issue Tracker](https://github.com/tu-usuario/it-support-lab/issues)

---

## 📊 Estadísticas del Proyecto

![GitHub stars](https://img.shields.io/github/stars/tu-usuario/it-support-lab?style=social)
![GitHub forks](https://img.shields.io/github/forks/tu-usuario/it-support-lab?style=social)
![GitHub issues](https://img.shields.io/github/issues/tu-usuario/it-support-lab)
![GitHub pull requests](https://img.shields.io/github/issues-pr/tu-usuario/it-support-lab)

---

<div align="center">

**[⬆ Volver arriba](#-it-support-lab-20---sistema-completo-de-gestión-de-soporte-técnico)**

Hecho con ❤️ y ☕ por el equipo de IT Support Lab

</div>
