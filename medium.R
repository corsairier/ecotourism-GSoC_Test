library(GSODR)
library(galah)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(ggspatial)
library(densityClust)
library(MASS) 

# Configure Galah for platypus data retrieval
galah_config(email = "dgoel2099@gmail.com")

# Get platypus occurrences
platypus_taxon <- search_taxa("Ornithorhynchus anatinus")

platypus_data <- galah_call() |>
  galah_identify(platypus_taxon) |>
  galah_filter(year == 2024) |>
  galah_select("decimalLatitude", "decimalLongitude") |>
  atlas_occurrences()

# Convert to spatial format (SF object)
platypus_sf <- platypus_data %>%
  filter(!is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

# Define center point as the coords of Victoria and search radius as 300km
center_point <- st_sfc(st_point(c(143.3906, -36.9848)), crs = 4326)
search_radius_km <- 300  # 300km limit
search_area <- st_buffer(center_point, dist = search_radius_km * 1000)  # Convert km to meters

# Keep only platypus sightings inside the 300km radius
platypus_in_radius <- platypus_sf[st_intersects(platypus_sf, search_area, sparse = FALSE),]

# Extract coordinates for KDE
plat_coords <- st_coordinates(platypus_in_radius)

# Perform KDE (adjust bandwidth if needed)
density_est <- kde2d(plat_coords[,1], plat_coords[,2], n = 100)

# Find highest-density area (max value in KDE grid)
max_idx <- which(density_est$z == max(density_est$z), arr.ind = TRUE)
densest_point <- c(density_est$x[max_idx[1]], density_est$y[max_idx[2]])

# Convert densest point to an sf object
densest_sf <- st_sf(geometry = st_sfc(st_point(densest_point), crs = 4326))

# Get weather stations within 300km of (-36.9848, 143.3906)
tbar_stations <- nearest_stations(LAT = -36.9848, LON = 143.3906, distance = search_radius_km)

# Convert to sf object
stations_sf <- tbar_stations %>%
  filter(!is.na(LAT) & !is.na(LON)) %>%
  st_as_sf(coords = c("LON", "LAT"), crs = 4326)

# Find the closest weather station to the densest platypus area
stations_sf$distance <- st_distance(stations_sf, densest_sf)
nearest_station <- stations_sf[which.min(stations_sf$distance),]

print(nearest_station)

# Plot results
ggplot() +
  borders("world", regions = "Australia", fill = "gray90", colour = "black") +
  geom_sf(data = platypus_sf, aes(geometry = geometry), color = "blue", alpha = 0.3, size = 0.5) +  # All platypus sightings
  geom_sf(data = platypus_in_radius, aes(geometry = geometry), color = "darkblue", alpha = 0.5, size = 0.5) +  # Platypus in 300km radius
  geom_sf(data = densest_sf, color = "purple", size = 3) +  # Most dense platypus area
  geom_sf(data = stations_sf, aes(geometry = geometry), color = "red", size = 0.5) +  # All stations
  geom_sf(data = nearest_station, color = "green", size = 2) +  # Nearest station to densest area
  geom_sf(data = search_area, fill = NA, color = "black", linetype = "dashed") +  # Search radius
  ggtitle("Platypus Density & Closest Weather Station (Limited to 300km)") +
  theme_minimal() +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "tr", which_north = "true")

# Extract station ID of the nearest weather station
nearest_station_id <- nearest_station$STNID

# Get one year (2024) of daily weather data for the nearest station
weather_data <- get_GSOD(years = 2024, station = nearest_station_id)

# Select only precipitation (PRCP) and temperature (TEMP) columns
weather_filtered <- weather_data[, c("YEARMODA", "TEMP", "PRCP", "PRCP_ATTRIBUTES")]

# Print first few rows
print(weather_filtered)
