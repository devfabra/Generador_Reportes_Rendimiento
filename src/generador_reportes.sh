#!/bin/bash

# ==============================================================================
# Script: Generador de reportes de rendimiento (Usando vmstat, free, ps y top)
# Descripción: Recopila métricas de CPU, RAM, tareas (top) y procesos (ps) a CSV.
# Uso: ./generador_reportes.sh [intervalo_segundos] [total_iteraciones]
# ==============================================================================

# Forzar idioma inglés para estandarizar las salidas de los comandos
export LC_ALL=C

REPORTS_DIR="../reports"
mkdir -p "$REPORTS_DIR"

# Nombre del archivo CSV de salida con marca de tiempo
OUTPUT_FILE="$REPORTS_DIR/reporte_rendimiento_$(date +%Y%m%d_%H%M%S).csv"

# Parámetros configurables (por defecto: 5 segundos, 12 iteraciones = 1 minuto)
INTERVALO=${1:-5}
ITERACIONES=${2:-12}

echo "=================================================="
echo " Iniciar Recopilación de Métricas"
echo "=================================================="
echo " Intervalo: ${INTERVALO}s | Muestras: ${ITERACIONES}"
echo " Archivo de salida: $OUTPUT_FILE"
echo "--------------------------------------------------"

# Escribir la cabecera del archivo CSV incluyendo métricas de ps y top
echo "Timestamp,CPU_Usr,CPU_Sys,CPU_Idle,RAM_Used_MB,RAM_Free_MB,Top_Process_PS,Tasks_Total,Tasks_Running" > "$OUTPUT_FILE"

# Todo lo que este dentro de este for se ejecuta una vez por muestra
for ((i=1; i<=ITERACIONES; i++)); do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 1. Recopilar métricas de CPU usando vmstat
    VMSTAT_OUT=$(vmstat 1 2 | tail -1)
    CPU_USR=$(echo "$VMSTAT_OUT" | awk '{print $13}')
    CPU_SYS=$(echo "$VMSTAT_OUT" | awk '{print $14}')
    CPU_IDLE=$(echo "$VMSTAT_OUT" | awk '{print $15}')
    
    # 2. Recopilar métricas de memoria RAM usando free
    RAM_INFO=$(free -m | awk '/Mem:/ {print $3, $4}')
    if [ -z "$RAM_INFO" ]; then
        RAM_INFO=$(free -m | awk 'NR==2 {print $3, $2-$3}')
    fi
    RAM_USED=$(echo "$RAM_INFO" | awk '{print $1}')
    RAM_FREE=$(echo "$RAM_INFO" | awk '{print $2}')

    # 3. Identificar el proceso líder con ps
    TOP_PROC_PS=$(ps -eo comm,%cpu --sort=-%cpu | head -n 2 | tail -n 1 | awk '{print $1 " (" $2 "%)"}')

    # 4. Obtener estadísticas globales de procesos con top (en modo batch -b)
    # top -b -n 1 toma una sola "foto" no interactiva del sistema
    TOP_OUTPUT=$(top -b -n 1)
    
    # Extraer el total de tareas y las tareas en ejecución desde la cabecera de top
    TASKS_TOTAL=$(echo "$TOP_OUTPUT" | grep "Tasks:" | awk '{print $2}')
    TASKS_RUNNING=$(echo "$TOP_OUTPUT" | grep "Tasks:" | awk '{print $4}')

    # Escribir la línea formateada en el CSV
    echo "\"$TIMESTAMP\",$CPU_USR,$CPU_SYS,$CPU_IDLE,$RAM_USED,$RAM_FREE,\"$TOP_PROC_PS\",$TASKS_TOTAL,$TASKS_RUNNING" >> "$OUTPUT_FILE"

    echo "[$i/$ITERACIONES] Datos registrados a las $TIMESTAMP"
    
    # Esperar el intervalo especificado (excepto en la última iteración)
    if [ "$i" -lt "$ITERACIONES" ]; then
        sleep "$INTERVALO"
    fi
done

echo "--------------------------------------------------"
echo "¡Proceso finalizado! Reporte guardado en: $OUTPUT_FILE"
echo "=================================================="
