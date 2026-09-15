---
name: clima
description: Consulta el tiempo actual y el pronostico de 3 dias via wttr.in. Sin argumento usa la ubicacion detectada por IP; acepta una ciudad (ej. /clima Barcelona). Usala para "que tiempo hace", "clima", "weather", "va a llover", "pronostico".
---

# Clima

Consulta el tiempo local usando wttr.in (sin API key). Todo el procesamiento del JSON ocurre en el script — nunca vuelques el JSON crudo al contexto.

## Uso

Ejecuta con la herramienta PowerShell:

```
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/clima/scripts/clima.ps1 "<ciudad opcional>"
```

- Si el usuario no menciona una ciudad, invoca el script **sin argumento** (usa geolocalizacion por IP de wttr.in).
- Si el usuario nombra una ciudad ("clima en Madrid", "/clima Tokyo"), pasala como argumento entre comillas.

## Presentar el resultado

- Muestra la salida del script tal cual, o resumela en 3-5 lineas si el usuario pidio algo muy breve.
- No repitas el comando ejecutado ni el JSON.

## Fallback

Si el script de PowerShell falla (ejecucion bloqueada, etc.), usa como alternativa:

```
curl.exe -s -H "User-Agent: curl" "https://wttr.in/<ciudad>?format=3"
```

## Notas

- Requiere conexion a Internet.
- wttr.in aplica limite de peticiones: no llames en bucle ni repetidamente en poco tiempo.
