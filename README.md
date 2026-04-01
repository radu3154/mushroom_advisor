# Mushroom Advisor

A cozy app that tells you if it's worth going out to forage for mushrooms based on current weather conditions.

## Quick Start

```bash
cd mushroom_advisor
bin/setup
bin/rails server
```

Visit **http://localhost:3000** and pick a mushroom!

## Weather Data

The app works in **demo mode** out of the box. For real weather data:

1. Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Set it before starting the server:

```bash
export OPEN_WEATHER_API_KEY=your_key_here
bin/rails server
```

## How It Works

Select a species (Morel, Boletus, or Chanterelle) and the app scores current conditions on a 0–100 scale based on four factors:

| Factor      | Max Points | What it checks                        |
|-------------|-----------|---------------------------------------|
| Season      | 20        | Is it the right time of year?         |
| Temperature | 30        | Is the temp in the ideal range?       |
| Rainfall    | 30        | Has there been enough recent rain?    |
| Timing      | 20        | How many days since the last rain?    |

You'll get a score, a label (EXCELLENT → SKIP), the best time to go, and habitat tips.

## Customization

### Change your location

Edit `LOCATIONS` in `app/controllers/mushrooms_controller.rb` with your lat/lon.

### Add more species

Add entries to the `CATALOG` hash in `app/models/species.rb`.
