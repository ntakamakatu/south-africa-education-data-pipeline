#===============================================================================
# SCRIPT: 04_interactive_leaflet_map.R
# PURPOSE: Builds an interactive Leaflet map canvas for regional spatial audits
#          of educational centers across target provinces.
# AUTHOR: Ntaka Makatu
#===============================================================================

# 1. Load Required Libraries ---------------------------------------------------
library(tidyverse)
library(readxl)
library(leaflet) 

# 2. Load and Clean Geospatial Records ----------------------------------------
national_data_path <- "data/National.xlsx"

if (!file.exists(national_data_path)) {
  stop("Master database registry missing from data/ workspace directory.")
}

schools_data <- read_xlsx(national_data_path, guess_max = Inf)
names(schools_data) <- trimws(names(schools_data))

# Subset target provinces for regional cluster visibility analysis
target_provinces <- c("WC", "GT", "KZN", "LP")

schools_clean <- schools_data %>%
  filter(toupper(trimws(Province)) %in% target_provinces) %>%
  
  mutate(
    GIS_Long = as.numeric(GIS_Long),
    GIS_Lat  = as.numeric(GIS_Lat)
  ) %>%
  filter(!is.na(GIS_Long) & !is.na(GIS_Lat)) %>%
  
  # Standardize sign orientation boundaries across markers
  mutate(
    GIS_Long = abs(GIS_Long),
    GIS_Lat  = -abs(GIS_Lat)
  ) %>%
  filter(GIS_Long > 16 & GIS_Long < 34.5 & GIS_Lat < -21 & GIS_Lat > -35)

# 3. Map Aesthetic Configurations ----------------------------------------------
sector_colors <- colorFactor(
  palette = c("#E34A33", "#2B8CBE"), 
  domain = schools_clean$Sector
)

# 4. Assemble Interactive Leaflet Canvas ---------------------------------------
interactive_map <- leaflet(data = schools_clean) %>%
  # Add OpenStreetMap base tiles
  addTiles() %>% 
  
  # Center camera framework coordinates over general South African topography
  setView(lng = 25.0, lat = -29.0, zoom = 6) %>%
  
  # Add school location markers
  addCircleMarkers(
    lng = ~GIS_Long, 
    lat = ~GIS_Lat,
    
    # Render dimension sizes dynamically based on organizational framework scaling
    radius = ~ifelse(Sector == "INDEPENDENT", 4, 2), 
    color = ~sector_colors(Sector),
    stroke = FALSE,             
    fillOpacity = ~ifelse(Sector == "INDEPENDENT", 0.8, 0.4),
    
    # Setup interactive HTML contextual text window popups for point audits
    popup = ~paste0(
      "<strong>School Name:</strong> ", Official_Institution_Name, "<br>",
      "<strong>Sector Classification:</strong> ", Sector, "<br>",
      "<strong>Province:</strong> ", Province
    )
  ) %>%
  
  # Anchor institutional color code mapping legend panel
  addLegend(
    position = "bottomright",
    pal = sector_colors,
    values = ~Sector,
    title = "Institution Sector",
    opacity = 0.8
  )

# 5. Display Rendered Map Widget ----------------------------------------------
# Executing this prints the map directly into the RStudio Viewer pane
print(interactive_map)

# Optional Extension for Reviewers: 
# To save this interactive map as a standalone shareable HTML file, 
# uncomment the two lines below:
# if(!dir.exists("outputs/interactive")) dir.create("outputs/interactive", recursive = TRUE)
# htmlwidgets::saveWidget(interactive_map, file = "outputs/interactive/schools_map.html")
