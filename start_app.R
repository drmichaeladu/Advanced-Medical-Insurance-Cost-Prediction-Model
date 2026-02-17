#!/usr/bin/env Rscript
# Startup script for Medical Insurance Cost Prediction Application

cat("\n")
cat("========================================================\n")
cat("  Medical Insurance Cost Prediction Application\n")
cat("  Starting application...\n")
cat("========================================================\n\n")

# Check if required packages are installed
required_packages <- c(
  "shiny", "shinydashboard", "shinyWidgets", "ggplot2",
  "randomForest", "xgboost", "caret", "DALEX", "DALEXtra", 
  "plotly", "dplyr"
)

cat("Checking required packages...\n")
missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]

if (length(missing_packages) > 0) {
  cat("Missing packages found:", paste(missing_packages, collapse = ", "), "\n")
  cat("Installing missing packages...\n")
  install.packages(missing_packages, dependencies = TRUE, repos = "https://cloud.r-project.org")
  cat("Packages installed successfully!\n\n")
} else {
  cat("All required packages are installed.\n\n")
}

# Load version information
if (file.exists("version.R")) {
  source("version.R")
  print_version_info()
  cat("\n")
}

# Start the application
cat("Starting Shiny application...\n")
cat("Application will open in your default web browser.\n")
cat("To stop the application, press Ctrl+C or close this terminal.\n\n")

library(shiny)
runApp("app.R", launch.browser = TRUE)
