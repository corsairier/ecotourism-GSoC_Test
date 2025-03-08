install.packages("sf", dependencies = TRUE)
install.packages("rnaturalearth", dependencies = TRUE)
install.packages("galah", dependencies = TRUE)
install.packages("ggspatial")


library(galah)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(ggspatial)

galah_config(email = "dgoel2099@gmail.com")

# Get Platypus occurrences
platypus_taxon <- search_taxa("Ornithorhynchus anatinus")

platypus_data <- galah_call() |>
  galah_identify(platypus_taxon) |>
  galah_filter(year == 2024) |>
  galah_select("decimalLatitude", "decimalLongitude") |>
  atlas_occurrences()

platypus_sf <- platypus_data %>%
  filter(!is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

ggplot() +
  borders("world", regions = "Australia", fill = "gray90", colour = "black") +
  geom_sf(data = platypus_sf, aes(geometry = geometry), color = "blue", alpha = 0.5) +
  ggtitle("Platypus Sightings in Australia (2024)") +
  theme_minimal() +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "tr", which_north = "true")
