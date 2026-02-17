# Health Check Script for Production Monitoring
# This script verifies that all required components are available and functional

#' Perform health check on the application
#' @return List with status and details
health_check <- function() {
  results <- list(
    timestamp = Sys.time(),
    overall_status = "healthy",
    checks = list()
  )
  
  # Check 1: Configuration file
  tryCatch({
    source("config.R", local = TRUE)
    results$checks$config <- list(status = "OK", message = "Configuration loaded")
  }, error = function(e) {
    results$checks$config <- list(status = "ERROR", message = e$message)
    results$overall_status <- "unhealthy"
  })
  
  # Check 2: Utility modules
  utils_status <- c()
  for (util_file in c("utils/logger.R", "utils/validators.R")) {
    tryCatch({
      source(util_file, local = TRUE)
      utils_status <- c(utils_status, "OK")
    }, error = function(e) {
      utils_status <- c(utils_status, "ERROR")
      results$overall_status <- "unhealthy"
    })
  }
  results$checks$utilities <- list(
    status = if (all(utils_status == "OK")) "OK" else "ERROR",
    message = sprintf("Utility modules: %s", paste(utils_status, collapse = ", "))
  )
  
  # Check 3: Core R modules
  r_modules_status <- c()
  for (r_file in c("R/model_loader.R", "R/preprocessing.R", "R/prediction.R", "R/explainability.R")) {
    tryCatch({
      source(r_file, local = TRUE)
      r_modules_status <- c(r_modules_status, "OK")
    }, error = function(e) {
      r_modules_status <- c(r_modules_status, "ERROR")
      results$overall_status <- "unhealthy"
    })
  }
  results$checks$core_modules <- list(
    status = if (all(r_modules_status == "OK")) "OK" else "ERROR",
    message = sprintf("Core modules: %s", paste(r_modules_status, collapse = ", "))
  )
  
  # Check 4: Model files
  model_files <- c(
    "models/linear_model.RData",
    "models/random_forest_model.RData",
    "models/xgboost_model.RData",
    "models/dummy_model.rds",
    "models/train_data.RData"
  )
  
  missing_models <- c()
  for (model_file in model_files) {
    if (!file.exists(model_file)) {
      missing_models <- c(missing_models, basename(model_file))
    }
  }
  
  if (length(missing_models) == 0) {
    results$checks$model_files <- list(status = "OK", message = "All model files present")
  } else {
    results$checks$model_files <- list(
      status = "WARNING",
      message = sprintf("Missing models: %s", paste(missing_models, collapse = ", "))
    )
    if (results$overall_status == "healthy") {
      results$overall_status <- "degraded"
    }
  }
  
  # Check 5: Required R packages
  required_packages <- c(
    "shiny", "shinydashboard", "shinyWidgets", "ggplot2",
    "randomForest", "xgboost", "caret", "DALEX", "DALEXtra",
    "plotly", "dplyr"
  )
  
  missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
  
  if (length(missing_packages) == 0) {
    results$checks$packages <- list(status = "OK", message = "All packages installed")
  } else {
    results$checks$packages <- list(
      status = "ERROR",
      message = sprintf("Missing packages: %s", paste(missing_packages, collapse = ", "))
    )
    results$overall_status <- "unhealthy"
  }
  
  # Check 6: Log directory
  if (dir.exists("logs")) {
    results$checks$logs <- list(status = "OK", message = "Log directory exists")
  } else {
    results$checks$logs <- list(
      status = "WARNING",
      message = "Log directory missing (will be created on startup)"
    )
  }
  
  # Check 7: Dataset
  if (file.exists("insurance.csv")) {
    results$checks$dataset <- list(status = "OK", message = "Dataset available")
  } else {
    results$checks$dataset <- list(
      status = "WARNING",
      message = "insurance.csv not found"
    )
  }
  
  return(results)
}

#' Print health check results
#' @param results Health check results from health_check()
print_health_check <- function(results) {
  cat("\n")
  cat(strrep("=", 70), "\n")
  cat("Health Check Report\n")
  cat(strrep("=", 70), "\n")
  cat(sprintf("Timestamp: %s\n", results$timestamp))
  cat(sprintf("Overall Status: %s\n", toupper(results$overall_status)))
  cat(strrep("=", 70), "\n\n")
  
  for (check_name in names(results$checks)) {
    check <- results$checks[[check_name]]
    status_symbol <- switch(check$status,
                           "OK" = "✓",
                           "WARNING" = "⚠",
                           "ERROR" = "✗",
                           "?")
    
    cat(sprintf("%s %s: %s\n", status_symbol, toupper(check_name), check$message))
  }
  
  cat("\n")
  cat(strrep("=", 70), "\n")
  
  if (results$overall_status == "healthy") {
    cat("All systems operational. Application ready to run.\n")
  } else if (results$overall_status == "degraded") {
    cat("Application is functional but some features may be limited.\n")
  } else {
    cat("Critical issues detected. Please resolve errors before running.\n")
  }
  
  cat(strrep("=", 70), "\n\n")
}

# Run health check if script is executed directly
if (!interactive()) {
  results <- health_check()
  print_health_check(results)
  
  # Exit with appropriate code
  if (results$overall_status == "unhealthy") {
    quit(status = 1)
  } else {
    quit(status = 0)
  }
}
