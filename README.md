# Monitor de Red con Bash, Nmap y Tshark

Este proyecto contiene un script de Bash (`monitor.sh`) diseñado para realizar un análisis básico de seguridad y tráfico en tu red local. Es ideal para una auditoría rápida o para aprendizaje sobre monitorización de redes.

## Funcionalidades

1.  **Descubrimiento de Hosts**: Identifica dispositivos activos en la red local (`192.168.1.0/24` por defecto).
2.  **Escaneo de Puertos**: Busca puertos abiertos comunes (21, 22, 80, 443, etc.) en los dispositivos encontrados.
3.  **Captura de Tráfico**: Captura paquetes durante 30 segundos utilizando `tshark` (Wireshark CLI).
4.  **Detección de Anomalías**:
    *   Identifica los "Top Talkers" (IPs que envían más tráfico).
    *   Detecta posibles escaneos de puertos (basado en el volumen de paquetes SYN).

## Requisitos

Este script está diseñado para ejecutarse en entornos Linux (o **WSL** en Windows).

Dependencias necesarias:
*   **Nmap**: Para escaneo de red.
*   **Tshark** (Wireshark): Para captura y análisis de paquetes.

### Instalación de Dependencias

En Ubuntu / Debian / WSL:

```bash
sudo apt update
sudo apt install nmap tshark
```

> **Nota para usuarios de Wireshark/Tshark**: Durante la instalación se te preguntará si los usuarios no-root pueden capturar tráfico. Si seleccionas "Sí", asegúrate de añadir tu usuario al grupo `wireshark`. Si no, necesitarás ejecutar el script con `sudo`.

## Uso

1.  Dale permisos de ejecución al script:
    ```bash
    chmod +x monitor.sh
    ```

2.  Ejecuta el script (se requieren privilegios de root para el escaneo y captura):
    ```bash
    sudo ./monitor.sh
    ```

3.  **Configuración**:
    *   Puedes editar `monitor.sh` para cambiar la interfaz de red (por defecto `eth0`) o el rango de subred (`SUBNET`).

## Resultados

El script mostrará el progreso en la terminal y generará un archivo de reporte con la fecha y hora:
`network_report_AAAAMMDD_HHMMSS.txt`

Este archivo incluirá la lista de hosts, puertos abiertos y el análisis de tráfico.
