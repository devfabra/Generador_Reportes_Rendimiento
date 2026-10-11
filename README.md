# Generador de Reportes de Rendimiento en Bash - Debian 13

> **Proyecto de Aula:** Generador de Reportes de Rendimiento
> **Curso:** Sistemas Operativos
> **Docente:** Andres Felipe Gutierrez Rivera
> **Universidad:** Fundación Universitaria Compensar

Script automatizado desarrollado en Bash para la recolección, estructuración y exportación de métricas del sistema operativo (CPU, RAM y procesos activos) hacia archivos CSV, utilizando herramientas nativas de Unix/Linux como `top`, `vmstat`, `free`, `ps` y filtrado avanzado con `awk`.

---

## Tabla de Contenidos
- [Acerca del Proyecto](#acerca-del-proyecto)
- [Características Principales](#características-principales)
- [Prerrequisitos y Dependencias](#prerrequisitos-y-dependencias)
- [Instalación](#instalación)
- [Modo de Uso](#modo-de-uso)
- [Estructura del Repositorio](#estructura-del-repositorio)
- [Diseño Técnico y Arquitectura](#diseño-técnico-y-arquitectura)
- [Resultados Esperados](#resultados-esperados)
- [Autores](#autores)

---

## Acerca del Proyecto
Este proyecto surge como una herramienta práctica para la asignatura de **Sistemas Operativos**. Su objetivo principal es monitorear el comportamiento del kernel y la asignación de recursos hardware en tiempo real. Permite automatizar la toma de muestras de rendimiento para su posterior análisis cuantitativo en hojas de cálculo (Excel, Google Sheets, Python/Pandas, etc.).

---

## Características Principales
* **Monitoreo Multicomponente:** Captura simultáneamente estadísticas de carga del CPU (usuario, sistema, inactivo), consumo de memoria RAM (usada/libre en MB) y el proceso con mayor demanda de recursos.
* **Portabilidad Lingüística:** Configurado con localización estándar (`LC_ALL=C`) para evitar fallos de sintaxis en comandos del sistema independientemente del idioma del sistema operativo.
* **Estructura CSV Limpia:** Exporta los datos con marcas de tiempo (`Timestamp`) separados por comas y delimitados por comillas para asegurar la integridad de las cadenas de texto.
* **Parámetros Dinámicos:** Permite configurar de forma personalizada el intervalo de tiempo entre muestras y el número total de iteraciones al ejecutar el script.

---

## Prerrequisitos y Dependencias
Para ejecutar este script de manera correcta, necesitas:
* Un entorno operativo basado en **Linux** o sistemas tipo UNIX con intérprete **Bash** instalado.
* Las siguientes utilidades del sistema (generalmente vienen preinstaladas en la mayoría de distribuciones):
  * `vmstat` (Virtual Memory Statistics)
  * `free` (Monitoreo de memoria)
  * `ps` (Estado de procesos)
  * `awk` (Procesamiento de texto y tabulación)

---

## Instalación
1. Clona este repositorio en tu máquina local:
   ```bash
   git clone [https://github.com/tu-usuario/tu-repositorio.git](https://github.com/tu-usuario/tu-repositorio.git)
   cd tu-repositorio
   ```

## Modo de Uso

1. **Otorga permisos de ejecución** al script principal (asegúrate de estar en la raíz del proyecto):
```bash
chmod +x src/generador_reportes.sh
```

Se puede ejecutar el script de dos maneras:

2. **Con valores predeterminados**
Toma una muestra de cada 5 segundos, realizando un total de 12 iteraciones (equivalente a 1 minuto de monitoreo):
```bash
./src/generador_reportes.sh
```

3. Con parametros personalizados
Puedes especificar tu propio intervalo en segundos y la cantidad de muestras:
```bash
# Sintaxis: ./generador_reportes.sh [intervalo_sengundos] [total_iteraciones]
# Ejemplo: tomar una muestra cada 2 segundos, durante 30 iteraciones (1 minuto)
./generador_reportes.sh 2 30
```

## Estructura del Repositorio
```text
Generador_Reportes_Rendimiento/
├── reports/                  # Carpeta de salida para los reportes CSV
│   └── (archivos generados automáticamente)
├── src/                      # Carpeta de código fuente
|   └── generador_reportes.sh # Script principal en Bash
├── LICENSE
├── README.md                # Documentación del proyecto
```

## Diseño Técnico y Arquitectura

El script opera mediante un bucle iterativo controlado en Bash, estructurado en las siguientes fases lógicas por cada muestra:

1. **Marca Temporal (`date`):** Captura el momento exacto de la ejecución para garantizar la trazabilidad temporal en el análisis.
2. **Estadísticas del Núcleo - CPU (`vmstat`):** Ejecuta una consulta al kernel omitiendo la media de inicio (`tail -1`) y aislando mediante `awk` los porcentajes de uso de usuario (`us`), sistema (`sy`) e inactivo (`id`).
3. **Gestión de Memoria RAM (`free`):** Consulta el estado de la memoria en megabytes (`-m`), aplicando un respaldo lógico condicional para extraer dinámicamente los recursos usados y libres.
4. **Proceso Crítico de Mayor Consumo (`ps`):** Realiza una instantánea (`snapshot`) de la tabla de procesos ordenándolos descendentemente por uso de CPU (`--sort=-%cpu`), aislando el comando líder.
5. **Estadísticas Globales de Tareas (`top`):** Ejecuta `top` en modo lote (`-b -n 1`) para extraer métricas globales del kernel, como el total de tareas y las ejecuciones activas.
6. **Persistencia Automatizada (`reports/`):** Almacena de forma estructurada cada registro separado por comas utilizando redirección de texto (`>>`) en un archivo `.csv` con marca de tiempo única dentro del directorio de reportes.

## Resultados Esperados

Al finalizar la ejecución, el script genera automáticamente un archivo `.csv` ubicado en la carpeta `reports/` (en la raíz del proyecto) con la siguiente estructura de columnas:

```csv
Timestamp,CPU_Usr,CPU_Sys,CPU_Idle,RAM_Used_MB,RAM_Free_MB,Top_Process_PS,Tasks_Total,Tasks_Running
"2026-10-10 18:00:00",4,2,94,4120,3812,"code (12.5%)",312,2
"2026-10-10 18:00:02",2,1,97,4125,3807,"bash (2.1%)",310,1
```

---

### Autores

Integrantes del grupo:
* Miguel Rodriguez
* Sebastian Fabra
* Said Sepulveda
* Julian Rodriguez

Proyecto desarrollado para la asignatura de **Sistemas Operativos**:
* **Sebastian Felipe Fabra Petro** - *Implementación de scripts y lógica en Bash*
* **Miguel Rodriguez, Said Sepulveda, Julian Rodriguez** - *Documentación, pruebas y validación en Linux*
