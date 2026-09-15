param(
    [string]$Location = ""
)

try {
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
} catch {}

$encodedLocation = if ($Location) { [uri]::EscapeDataString($Location) } else { "" }
$url = "https://wttr.in/$encodedLocation`?format=j1&lang=es"

try {
    $data = Invoke-RestMethod -Uri $url -UserAgent "curl" -TimeoutSec 15 -ErrorAction Stop
} catch {
    Write-Output "Error: no se pudo obtener el tiempo. Comprueba la conexión a Internet o el nombre de la ciudad ('$Location')."
    Write-Output "Detalle: $($_.Exception.Message)"
    exit 1
}

if (-not $data.current_condition) {
    Write-Output "Error: respuesta inesperada de wttr.in. Prueba con otra ciudad o sin argumento."
    exit 1
}

$area = $data.nearest_area[0]
$areaName = $area.areaName[0].value
$region = $area.region[0].value
$country = $area.country[0].value
$locLabel = @($areaName, $region, $country) | Where-Object { $_ } | Select-Object -Unique
$locLabelStr = [string]::Join(", ", $locLabel)

$cur = $data.current_condition[0]
$tempC = $cur.temp_C
$feelsLike = $cur.FeelsLikeC
$desc = if ($cur.lang_es -and $cur.lang_es[0].value) { $cur.lang_es[0].value } else { $cur.weatherDesc[0].value }
$windKmph = $cur.windspeedKmph
$windDir = $cur.winddir16Point
$humidity = $cur.humidity
$precip = $cur.precipMM
$uv = $cur.uvIndex

Write-Output "Tiempo en $locLabelStr"
Write-Output "Ahora: $desc, $tempC C (sensacion $feelsLike C), viento $windKmph km/h $windDir, humedad $humidity%, precip $precip mm, UV $uv"
Write-Output ""
Write-Output "Pronostico:"

foreach ($day in $data.weather) {
    $date = $day.date
    $maxT = $day.maxtempC
    $minT = $day.mintempC
    $hourly = $day.hourly
    $midIndex = [Math]::Min(4, $hourly.Count - 1)
    $midHour = $hourly[$midIndex]
    $dayDesc = if ($midHour.lang_es -and $midHour.lang_es[0].value) { $midHour.lang_es[0].value } else { $midHour.weatherDesc[0].value }
    $rainChance = ($hourly | ForEach-Object { [int]$_.chanceofrain } | Measure-Object -Maximum).Maximum

    Write-Output "  $date : $dayDesc, min $minT C / max $maxT C, prob. lluvia $rainChance%"
}
