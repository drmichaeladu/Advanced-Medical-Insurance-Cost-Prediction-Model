# Version Metadata for Medical Insurance Cost Prediction Application
# This file tracks versions of models and the application

VERSION <- list(
  # Application version
  app = list(
    version = "2.0.0",
    release_date = "2024-01-01",
    description = "Production-ready modular version with error handling, logging, and validation"
  ),
  
  # Model versions
  models = list(
    linear = list(
      version = "1.0",
      trained_date = "2023-12-01",
      algorithm = "Linear Regression with polynomial features",
      features = c("age", "age_squared", "sex", "bmi", "children", "smoker", "region", "smoker_bmi"),
      performance = list(
        rmse = 5408.644,
        r_squared = 0.8537
      )
    ),
    
    random_forest = list(
      version = "1.0",
      trained_date = "2023-12-01",
      algorithm = "Random Forest (optimized)",
      features = c("age", "age_squared", "sex", "bmi", "children", "smoker", "region", "smoker_bmi"),
      hyperparameters = list(
        ntree = 500,
        mtry = "optimized"
      )
    ),
    
    xgboost = list(
      version = "1.0",
      trained_date = "2023-12-01",
      algorithm = "XGBoost (Bayesian optimized)",
      features = c("age", "age_squared", "sex.male", "bmi", "children", "smoker.yes", 
                   "region.northwest", "region.southeast", "region.southwest", "smoker_bmi"),
      hyperparameters = list(
        max_depth = "optimized",
        eta = "optimized",
        nrounds = "optimized"
      )
    )
  ),
  
  # Dataset version
  dataset = list(
    source = "Medical Cost Personal Dataset (Kaggle)",
    version = "1.0",
    rows = 1338,
    features = 7,
    target = "charges"
  ),
  
  # Change log
  changelog = list(
    "2.0.0" = list(
      date = "2024-01-01",
      changes = c(
        "Modularized codebase into separate files",
        "Added comprehensive error handling",
        "Implemented input validation",
        "Added logging system for monitoring",
        "Created configuration management",
        "Implemented SHAP visualizations",
        "Added model comparison features",
        "Updated documentation"
      )
    ),
    "1.0.0" = list(
      date = "2023-12-01",
      changes = c(
        "Initial release",
        "Basic Shiny application",
        "Three ML models (Linear, RF, XGBoost)",
        "Simple prediction interface"
      )
    )
  )
)

#' Get application version string
#' @return Character string with version
get_app_version <- function() {
  return(VERSION$app$version)
}

#' Get model version information
#' @param model_name Name of the model ("linear", "random_forest", "xgboost")
#' @return List with model version details
get_model_version <- function(model_name) {
  if (model_name %in% names(VERSION$models)) {
    return(VERSION$models[[model_name]])
  } else {
    warning(sprintf("Model '%s' not found in version metadata", model_name))
    return(NULL)
  }
}

#' Print version information
print_version_info <- function() {
  cat(strrep("=", 70), "\n")
  cat("Medical Insurance Cost Prediction Application\n")
  cat(strrep("=", 70), "\n")
  cat(sprintf("Version: %s\n", VERSION$app$version))
  cat(sprintf("Release Date: %s\n", VERSION$app$release_date))
  cat(sprintf("Description: %s\n", VERSION$app$description))
  cat("\nAvailable Models:\n")
  for (model_name in names(VERSION$models)) {
    model_info <- VERSION$models[[model_name]]
    cat(sprintf("  - %s (v%s): %s\n", model_name, model_info$version, model_info$algorithm))
  }
  cat(strrep("=", 70), "\n")
}
