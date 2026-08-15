#!/usr/bin/env python3
import json
import sys
import urllib.request
from datetime import datetime

# Solid filled monochrome weather icons
WEATHER_CODES = {
    # Clear / Sunny
    "113": "",   # Solid Sun
    # Cloudy variations
    "116": "",   # Solid Partly Cloudy
    "119": "",   # Solid Cloud
    "122": "",   # Solid Overcast
    # Fog / Mist
    "143": "",   # Solid Mist
    "248": "",   # Solid Fog
    "260": "",   # Solid Freezing Fog
    # Drizzle / Light Rain
    "176": "🌦",   # Solid Light Rain
    "263": "🌦",   # Solid Drizzle
    "266": "🌦",   # Solid Light Drizzle
    "293": "🌦",   # Solid Light Rain
    "296": "",   # Solid Rain
    # Moderate / Heavy Rain
    "299": "",   # Solid Rain
    "302": "",   # Solid Rain
    "305": "",   # Solid Heavy Rain
    "308": "",   # Solid Heavy Rain
    "353": "🌦",   # Solid Rain Shower
    "356": "",   # Heavy Rain Shower
    "359": "",   # Torrential Rain
    # Thunderstorm
    "200": "",   # Solid Lightning
    "386": "",   # Solid Rain with Thunder
    "389": "",   # Heavy Thunderstorm
    "392": "",   # Snow Thunderstorm
    "395": "",   # Heavy Snow Thunderstorm
    # Sleet / Freezing Rain
    "182": "",   # Solid Sleet
    "185": "",   # Solid Freezing Drizzle
    "281": "",   # Freezing Drizzle
    "284": "",   # Heavy Freezing Drizzle
    "311": "",   # Freezing Rain
    "314": "",   # Heavy Freezing Rain
    "317": "",   # Light Sleet
    "320": "",   # Heavy Sleet
    "362": "",   # Sleet Showers
    "365": "",   # Heavy Sleet Showers
    # Snow
    "179": "",   # Solid Snow
    "227": "",   # Blowing Snow
    "230": "",   # Blizzard
    "323": "",   # Light Snow
    "326": "",   # Light Snow
    "329": "",   # Moderate Snow
    "332": "",   # Moderate Snow
    "335": "",   # Heavy Snow
    "338": "",   # Heavy Snow
    "368": "",   # Snow Showers
    "371": "",   # Heavy Snow Showers
    "374": "",   # Ice Pellets
    "377": "",   # Heavy Ice Pellets
}

location = "Indore"
if len(sys.argv) > 1 and sys.argv[1].strip():
    location = sys.argv[1].strip()

url = f"https://wttr.in/{location}?format=j1"

try:
    req = urllib.request.Request(url, headers={"User-Agent": "curl/7.68.0"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read().decode())

    curr = data["current_condition"][0]
    temp_c = curr.get("temp_C", "?")
    feels_like = curr.get("FeelsLikeC", "?")
    code = curr.get("weatherCode", "113")
    desc = curr.get("weatherDesc", [{}])[0].get("value", "").strip() or "Clear"
    humidity = curr.get("humidity", "?")
    wind_km = curr.get("windspeedKmph", "?")
    wind_dir = curr.get("winddir16Point", "")
    uv = curr.get("uvIndex", "0")

    icon = WEATHER_CODES.get(code, "")

    lines = [
        f"<b>{icon}     {location} Weather Report</b>",
        "─────────────────────────────────",
        f"<b>Current:</b> {desc}, <b>{temp_c}°C</b> (Feels like {feels_like}°C)",
        f"󰖎 Humidity: {humidity}%   |   󰖝 Wind: {wind_km} km/h {wind_dir}   |   󰖙 UV: {uv}",
        "",
        "<b>Hourly Forecast:</b>"
    ]

    # Full 24-hour forecast for today (8 steps x 3 hours = 24 hours)
    today_weather = data.get("weather", [{}])[0]
    hourly = today_weather.get("hourly", [])
    for h in hourly:
        t_raw = int(h.get("time", "0"))
        time_str = f"{t_raw // 100:02d}:00"
        h_code = h.get("weatherCode", "113")
        h_icon = WEATHER_CODES.get(h_code, "")
        h_temp = h.get("tempC", "?")
        h_rain = h.get("chanceofrain", "0")
        lines.append(f"  {time_str}     {h_icon}     {h_temp}°C     (Rain {h_rain}%)")

    lines.append("")
    lines.append("<b>3-Day Forecast:</b>")
    for day in data.get("weather", [])[:3]:
        date_raw = day.get("date", "")
        try:
            dt = datetime.strptime(date_raw, "%Y-%m-%d")
            date_str = dt.strftime("%a %d %b")
        except Exception:
            date_str = date_raw

        max_t = day.get("maxtempC", "?")
        min_t = day.get("mintempC", "?")
        d_hourly = day.get("hourly", [{}])
        mid_code = d_hourly[len(d_hourly)//2].get("weatherCode", "113") if d_hourly else "113"
        d_icon = WEATHER_CODES.get(mid_code, "")
        
        lines.append(f"  {date_str}:     {d_icon}     {min_t}°C / {max_t}°C")

    tooltip = "\n".join(lines)

    output = {
        "text": f"{icon}     {temp_c}°C",
        "tooltip": tooltip,
        "class": "weather"
    }
    print(json.dumps(output))
except Exception as e:
    print(json.dumps({
        "text": "     --°C",
        "tooltip": f"Weather info unavailable ({e})",
        "class": "weather-error"
    }))
