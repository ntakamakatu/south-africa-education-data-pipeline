#===============================================================================
# SCRIPT: 02_subject_correlation.R
# PURPOSE: Builds a pairwise curriculum correlation matrix and generates a 
#          high-resolution diagnostic heatmap.
# AUTHOR: Ntaka Makatu
#===============================================================================

# 1. Load Required Libraries ---------------------------------------------------
library(tidyverse)
library(readxl)

# 2. Ingest Cleared Master Data ------------------------------------------------
input_path <- "data_anonymized/Grade10_All_Terms_Clean.xlsx"

if (!file.exists(input_path)) {
  stop("Master data file not found. Please execute '01_data_cleaning_sams.R' first.")
}

grade10_data <- read_excel(input_path)

# 3. Data Transformation & Matrix Formulation ---------------------------------
# Isolate mark profiles, force numeric constraints, and polish label formatting
marks_data <- grade10_data %>%
  select(contains("Marks")) %>%
  mutate(across(everything(), as.numeric))

# Reformat column headers dynamically (e.g., "Physical_Sciences_Marks" -> "Physical Sciences")
colnames(marks_data) <- colnames(marks_data) %>%
  gsub("_Marks", "", .) %>%
  gsub("_", " ", .)

# Generate correlation matrix using pairwise observations to handle empty streams gracefully
cor_matrix <- cor(marks_data, use = "pairwise.complete.obs")

# Pivot matrix to long-form format required for ggplot2 rendering
cor_long <- as.data.frame(cor_matrix) %>%
  rownames_to_column(var = "Subject_A") %>%
  pivot_longer(
    cols = -Subject_A, 
    names_to = "Subject_B", 
    values_to = "Correlation"
  )

# 4. Construct Heatmap Visualization ------------------------------------------
curriculum_heatmap <- ggplot(cor_long, aes(x = Subject_A, y = Subject_B, fill = Correlation)) +
  geom_tile(color = "white", size = 0.2) +
  
  # Professional, diverging academic color palette
  scale_fill_gradient2(
    low = "#3B71CA",      # Blue for negative correlation bounds
    high = "#DC4C64",     # Red for strong positive performance co-movements
    mid = "white",        # Neutral white for zero correlation
    midpoint = 0, 
    limit = c(-1, 1), 
    name = "Correlation\nCoefficient",
    na.value = "grey92"   # Distinct styling for mutually exclusive subject streams
  ) +
  
  coord_fixed() +
  theme_minimal() + 
  theme(
    axis.text.x = element_text(angle = 45, vjust = 1, size = 9, hjust = 1),
    axis.text.y = element_text(size = 9),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold", size = 13, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 9, color = "grey40", margin = margin(b = 15)),
    legend.title = element_text(size = 9, face = "bold"),
    legend.text = element_text(size = 8)
  ) +
  labs(
    title = "Grade 10 Full Curriculum Performance Correlation Map",
    subtitle = "Grey segments isolate structurally separate elective tracks or stream vacancies"
  )

# 5. Export Output -------------------------------------------------------------
if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures", recursive = TRUE)
}

ggsave(
  filename = "outputs/figures/Grade10_Full_Curriculum_Heatmap.png", 
  plot = curriculum_heatmap,
  width = 10,       
  height = 9,      
  dpi = 300        
)

message("Curriculum correlation mapping successfully exported to outputs/figures/")
