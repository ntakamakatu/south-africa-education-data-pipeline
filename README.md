# Data & Spatial Analysis Pipelines: South African Education Data

## Project Overview
This repository showcases reproducible workflows for processing, cleaning, and visualizing administrative education data in South Africa. The codebase bridges the gap between raw, highly stratified institutional databases (such as South African School Administration and Management System schedules) and geographic information systems (GIS) to analyze the distribution of schools across provinces.

### Key Technical Competencies Demonstrated:
* **Data Wrangling & Pipeline Automation:** Cleaning inconsistent Excel structures, handling missing data slots (`NA` filtering), and executing cohort matching across term-level files using `tidyverse`.
* **Spatial Econometrics & GIS Mapping:** Correcting systemic coordinate anomalies, executing spatial boundaries via `sf`, and building interactive map geometries using `leaflet`.
* **Statistical Visualization:** Constructing pairwise correlation matrices and custom ggplot heatmaps to isolate programmatic and curriculum streaming differences.

## Data Availability & Privacy Notice
To comply with data privacy regulations (including POPIA) and institutional data sharing agreements, the raw administrative datasets (`National.xlsx`, individual school schedules) are omitted from this public repository. Methodologies can be reviewed directly within the `scripts/` directory.
