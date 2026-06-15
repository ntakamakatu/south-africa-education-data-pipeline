#===============================================================================
# SCRIPT: 03_static_spatial_map.R
# PURPOSE: Spatial cleaning and static GIS mapping of school 
#          distribution across South Africa using simple features (sf).
# AUTHOR: Ntaka Makatu
#===============================================================================

# 1. Load Required Libraries ---------------------------------------------------
library(tidyverse)
library(sf)
library(rnaturalearth)
library(readxl)

# 2. Ingest and Clean Geospatial Records ----------------------------------------
# Assumes National master registry matches repository path rules
national_data_path <- "data/National.xlsx"

if (!file.exists(national_data_path)) {
  stop("Master database registry missing from data/ workspace directory.")
}

schools_data <- read_xlsx(national_data_path, guess_max = Inf)
names(schools_data) <- trimws(names(schools_data)) 

schools_clean <- schools_data %>%
  mutate(
    GIS_Long   = as.numeric(GIS_Long),
    GIS_Lat    = as.numeric(GIS_Lat),
    Clean_Prov = toupper(trimws(Province))
  ) %>%
  filter(!is.na(GIS_Long) & !is.na(GIS_Lat)) %>%
  
  # Methodological Correction: Resolve known administrative coordinate inversion
  # flips across specific provincial master sheets (e.g., Eastern Cape/Northern Cape)
  mutate(
    Temp_Long = ifelse(Clean_Prov %in% c("EC", "EASTERN CAPE", "NC", "NORTHERN CAPE"), GIS_Lat, GIS_Long),
    Temp_Lat  = ifelse(Clean_Prov %in% c("EC", "EASTERN CAPE", "NC", "NORTHERN CAPE"), GIS_Long, GIS_Lat)
  ) %>%
  mutate(
    GIS_Long = abs(Temp_Long),
    GIS_Lat  = -abs(Temp_Lat)
  ) %>%
  # Truncate outliers falling outside South Africa's geographic bounding box
  filter(GIS_Long > 16 & GIS_Long < 34.5 & GIS_Lat < -21 & GIS_Lat > -35)

# 3. Generate National Base Map Geometry ---------------------------------------
sa_boundary <- rnaturalearth::ne_countries(
  scale = "medium", 
  country = "South Africa", 
  returnclass = "sf"
)

# 4. Build Static Representation Plot -------------------------------------------
national_spatial_plot <- ggplot() +
  # Render national boundary polygon topology
  geom_sf(data = sa_boundary, fill = "#F8F9FA", color = "#CED4DA", size = 0.4) +
  
  # Map school geographic points layered by sector typography
  geom_point(
    data = schools_clean, 
    aes(x = GIS_Long, y = GIS_Lat, color = Sector, alpha = Sector, size = Sector)
  ) +
  
  # Geographic framing window tightly bound to borders
  coord_sf(xlim = c(16, 33.5), ylim = c(-35, -21.5)) +
  
  # Balanced color scale matching education infrastructure briefs
  scale_color_manual(values = c("PUBLIC" = "#2B8CBE", "INDEPENDENT" = "#E34A33")) +
  scale_size_manual(values = c("PUBLIC" = 0.3, "INDEPENDENT" = 0.4)) +       
  scale_alpha_manual(values = c("PUBLIC" = 0.15, "INDEPENDENT" = 0.6)) +     
  
  labs(
    title = "Spatial Distribution of Institutional Educational Infrastructure",
    subtitle = paste("Geocoded Active Operational Sectors | Total N =", format(nrow(schools_clean), big.mark=",")),
    x = "Longitude", y = "Latitude",
    color = "Sector Assignment"
  ) +
  guides(
    size = FALSE,
    alpha = FALSE,
    color = guide_legend(override.aes = list(size = 3, alpha = 1))
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    panel.background = element_rect(fill = "#E0F2FE", color = NA), # Soft canvas oceanic background tint
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 9, color = "grey30"),
    legend.title = element_text(size = 9, face = "bold"),
    legend.text = element_text(size = 8)
  )

# 5. Export Infrastructure Map -------------------------------------------------
if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures", recursive = TRUE)
}

ggsave(
  filename = "outputs/figures/South_Africa_Schools_Map.png", 
  plot = national_spatial_plot,
  width = 10, 
  height = 8, 
  dpi = 300
)

message("Static GIS map visualization successfully generated and saved.")
