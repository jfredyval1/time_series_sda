echo "=== ANÁLISIS DE TIPOS DE ARCHIVO Y CANTIDAD ==="
echo "Buscando DISPOSITIVOS USUARIOS 2025 y subcarpetas..."
find /media/disk1/DISPOSITIVOS_USUARIOS_2025 -type f | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr

echo -e "\n=== ARCHIVOS MÁS GRANDES (TOP 15) ==="
find /media/disk1/DISPOSITIVOS_USUARIOS_2025 -type f -exec du -h {} \; | sort -hr | head -15

echo -e "\n=== TAMAÑO DE SUBCARPETAS ==="
du -h --max-depth=2 /media/disk1/DISPOSITIVOS_USUARIOS_2025 | sort -hr
