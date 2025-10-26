🛠️ IT Support Management System
📋 Descripción
Sistema completo de gestión de soporte técnico con Python y PostgreSQL que permite gestionar tickets, diagnosticar hardware y generar reportes en tiempo real.

🚀 Características Principales
✅ Gestión completa de tickets con categorías y prioridades

✅ Diagnóstico automático de hardware integrado

✅ Base de datos PostgreSQL optimizada para soporte técnico

✅ Interfaz visual profesional con librería Rich

✅ Reportes y estadísticas en tiempo real

✅ Sistema de asignación a técnicos especializados

✅ Generación automática de números de ticket únicos

🛠️ Stack Tecnológico
Python 3.10+ - Lógica de negocio y automatización

PostgreSQL - Base de datos robusta y escalable

psutil - Diagnóstico avanzado de hardware

Rich - Interfaz de consola visualmente atractiva

psycopg2 - Conector PostgreSQL para Python

📦 Estructura del Proyecto
text
it-support-lab/
├── ticket_system/
│   ├── ticket_manager.py      # Sistema principal de gestión
│   ├── requirements.txt       # Dependencias del proyecto
│   └── database/
│       └── it_support.sql     # Esquema de base de datos
├── docs/
│   └── user_manual.md         # Documentación técnica
└── scripts/
    └── setup.py              # Scripts de instalación
⚙️ Instalación y Configuración
1. Configurar PostgreSQL
bash
# Acceder a PostgreSQL y crear la base de datos
sudo -u postgres psql -f database/it_support.sql

# O ejecutar manualmente:
sudo -u postgres psql
CREATE DATABASE it_support;
\c it_support;
\i database/it_support.sql
2. Instalar Dependencias
bash
# Navegar al directorio del proyecto
cd ticket_system

# Instalar requerimientos
pip install -r requirements.txt

# Dependencias principales:
# psutil==5.9.0
# rich==13.0.0
# psycopg2-binary==2.9.5
3. Configurar Conexión a BD
python
# En ticket_manager.py, configurar conexión:
DATABASE_CONFIG = {
    'host': 'localhost',
    'database': 'it_support',
    'user': 'postgres',
    'password': 'tu_password'
}
🎯 Uso del Sistema
Comandos Principales
bash
# Crear nuevo ticket
python3 ticket_manager.py create "Título" "Descripción" categoria prioridad id_solicitante

# Listar todos los tickets
python3 ticket_manager.py list

# Ver estadísticas
python3 ticket_manager.py stats

# Asignar ticket a técnico
python3 ticket_manager.py assign <ticket_id> <technician_id>

# Ver detalles de ticket
python3 ticket_manager.py get <ticket_id>

# Diagnosticar hardware
python3 ticket_manager.py diagnose
Ejemplos de Uso
bash
# Crear ticket crítico de hardware
python3 ticket_manager.py create "Monitor no funciona" "El monitor no enciende" hardware critical 1

# Crear ticket de software
python3 ticket_manager.py create "Software lento" "La PC va muy lenta" software medium 2

# Asignar ticket al técnico
python3 ticket_manager.py assign 1 2

# Generar reporte de estadísticas
python3 ticket_manager.py stats
📊 Categorías y Prioridades Soportadas
🎯 Categorías
hardware - Problemas de componentes físicos

software - Issues de aplicaciones y SO

network - Problemas de conectividad

security - Incidencias de seguridad

🚨 Niveles de Prioridad
critical - Crítico (resolución inmediata)

high - Alto (máximo 4 horas)

medium - Medio (24 horas)

low - Bajo (48-72 horas)

🔧 Funciones de Diagnóstico
El sistema incluye diagnóstico automático de:

✅ Uso de CPU y memoria

✅ Estado del disco duro

✅ Temperatura del sistema

✅ Procesos críticos

✅ Conectividad de red

📈 Reportes y Métricas
Estadísticas Generadas
Total de tickets por estado

Distribución por prioridad

Métricas por categoría

Tiempos promedio de resolución

Carga de trabajo por técnico

Ejemplo de Salida Estadística
text
📊 Total Tickets: 15
📈 By Status: {'open': 5, 'in_progress': 3, 'resolved': 7}
🚨 By Priority: {'critical': 2, 'high': 4, 'medium': 6, 'low': 3}
📁 By Category: {'hardware': 6, 'software': 5, 'network': 4}
🎨 Interfaz Visual
Características de la UI
Tablas formateadas con colores y bordes

Paneles informativos para detalles

Iconos y emojis para mejor legibilidad

Colores por prioridad (rojo=crítico, amarillo=medio)

Progress bars para métricas

🔒 Seguridad y Validación
Validación de entrada de datos

Prevención de SQL injection

Manejo seguro de contraseñas

Logs de auditoría de operaciones

📋 Próximas Características
API REST para integraciones

Panel web administrativo

Notificaciones por email

App móvil para técnicos

Sistema de knowledge base

Reportes PDF automáticos

🆘 Soporte y Troubleshooting
Problemas Comunes
bash
# Error de conexión a BD
Verificar: servicio PostgreSQL ejecutándose

# Módulos no encontrados
pip install --upgrade -r requirements.txt

# Permisos insuficientes
sudo systemctl start postgresql
📞 Soporte Técnico
Para issues y soporte técnico del sistema, crear un ticket en:
python3 ticket_manager.py create "Soporte Sistema" "Descripción del problema" software high 1

¿Listo para optimizar tu flujo de soporte técnico? 🚀

bash
# ¡Iniciar el sistema ahora!
cd ticket_system && python3 ticket_manager.py
