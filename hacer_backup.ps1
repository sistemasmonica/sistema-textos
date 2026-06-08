# =====================================================
# RESPALDO LOCAL - Sistema Textos Escolares 2026
# Descarga todos los datos de Supabase y los guarda
# en la carpeta base_datos_local
# =====================================================

$SUPA_URL = "https://pqluiqsvfeddmxpuxyhm.supabase.co"
$SUPA_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxbHVpcXN2ZmVkZG14cHV4eWhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA1MTI4MDYsImV4cCI6MjA5NjA4ODgwNn0.cdWKlECRLxms1y8a3sSHr1i5rsif9B94mDrvigHNm2A"

$TABLAS = @(
    @{nombre="txe_registros";      descripcion="Facturas y compras"},
    @{nombre="txe_banco";          descripcion="Movimientos bancarios"},
    @{nombre="txe_conciliaciones"; descripcion="Conciliaciones"},
    @{nombre="txe_movinventario";  descripcion="Movimientos de inventario"},
    @{nombre="txe_guias";          descripcion="Guias de retiro"},
    @{nombre="txe_colegios";       descripcion="Colegios"},
    @{nombre="txe_coldata";        descripcion="Datos de colegios"},
    @{nombre="txe_config";         descripcion="Configuracion"}
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backupDir = Join-Path $scriptDir "base_datos_local"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$fechaArchivo = Get-Date -Format "yyyy-MM-dd"
$horaArchivo  = Get-Date -Format "HH-mm-ss"
$fechaLegible = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  RESPALDO LOCAL - Sistema Textos Escolares" -ForegroundColor Cyan
Write-Host "  Fecha: $fechaLegible" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "apikey"        = $SUPA_KEY
    "Authorization" = "Bearer $SUPA_KEY"
    "Content-Type"  = "application/json"
}

$todosLosDatos = @{}
$resumen = @()
$totalRegistros = 0

foreach ($tabla in $TABLAS) {
    $nombre = $tabla.nombre
    $desc   = $tabla.descripcion
    Write-Host "  Descargando $desc..." -NoNewline

    try {
        $url = "$SUPA_URL/rest/v1/$nombre`?select=*"
        $respuesta = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -ErrorAction Stop

        $cantidad = if ($respuesta -is [Array]) { $respuesta.Count } else { if ($null -eq $respuesta) { 0 } else { 1 } }
        $todosLosDatos[$nombre] = $respuesta
        $resumen += [PSCustomObject]@{
            Tabla       = $nombre
            Descripcion = $desc
            Filas       = $cantidad
            Estado      = "OK"
        }
        $totalRegistros += $cantidad
        Write-Host " OK ($cantidad filas)" -ForegroundColor Green
    }
    catch {
        $msg = $_.Exception.Message
        Write-Host " ERROR" -ForegroundColor Red
        $resumen += [PSCustomObject]@{
            Tabla       = $nombre
            Descripcion = $desc
            Filas       = 0
            Estado      = "ERROR: $msg"
        }
    }
}

Write-Host ""

if ($totalRegistros -eq 0) {
    Write-Host "  ATENCION: Las tablas en la nube estan vacias." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Esto significa que tus datos estan guardados en el" -ForegroundColor White
    Write-Host "  navegador pero aun no se han subido a la nube." -ForegroundColor White
    Write-Host ""
    Write-Host "  PASO A SEGUIR:" -ForegroundColor Cyan
    Write-Host "  1. Abre la app en tu navegador" -ForegroundColor White
    Write-Host "  2. Haz clic en el boton  Backup  (arriba a la derecha)" -ForegroundColor White
    Write-Host "  3. Mueve el archivo JSON descargado a esta carpeta:" -ForegroundColor White
    Write-Host "     $backupDir" -ForegroundColor Yellow
    Write-Host "  4. Vuelve a ejecutar este script para respaldar desde la nube" -ForegroundColor White
    Write-Host ""
} else {
    # Guardar JSON con fecha y hora
    $archivoFecha   = Join-Path $backupDir "backup_$fechaArchivo`_$horaArchivo.json"
    $archivoActual  = Join-Path $backupDir "backup_ACTUAL.json"

    $paquete = @{
        version        = "2.0"
        fecha_respaldo = $fechaLegible
        sistema        = "Sistema Textos Escolares 2026"
        datos          = $todosLosDatos
    }

    Write-Host "  Guardando archivos de respaldo..." -NoNewline
    $json = $paquete | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText($archivoFecha,  $json, [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($archivoActual, $json, [System.Text.Encoding]::UTF8)
    Write-Host " OK" -ForegroundColor Green

    # Guardar log
    $logPath = Join-Path $backupDir "historial.csv"
    if (-not (Test-Path $logPath)) {
        "Fecha,Archivo,Tablas OK,Total Filas" | Out-File -FilePath $logPath -Encoding UTF8
    }
    "$fechaLegible,$archivoFecha,$($resumen | Where-Object {$_.Estado -eq 'OK'} | Measure-Object | Select-Object -ExpandProperty Count),$totalRegistros" |
        Add-Content -Path $logPath -Encoding UTF8

    Write-Host ""
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "  RESUMEN" -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Cyan
    $resumen | Format-Table Tabla, Descripcion, Filas, Estado -AutoSize
    Write-Host ""
    Write-Host "  Archivos guardados en:" -ForegroundColor White
    Write-Host "  $backupDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  - backup_ACTUAL.json         (siempre el mas reciente)" -ForegroundColor White
    Write-Host "  - backup_$fechaArchivo`_$horaArchivo.json  (copia con fecha)" -ForegroundColor White
    Write-Host ""
    Write-Host "  RESPALDO EXITOSO!" -ForegroundColor Green
}

Write-Host ""
Read-Host "  Presiona ENTER para cerrar"
