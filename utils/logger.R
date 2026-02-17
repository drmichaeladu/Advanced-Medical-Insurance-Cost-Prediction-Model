# Logging utilities for production monitoring

#' Initialize logging directory
#' @return TRUE if successful, FALSE otherwise
init_logging <- function() {
  tryCatch({
    if (CONFIG$logging$enabled) {
      if (!dir.exists(CONFIG$logging$dir)) {
        dir.create(CONFIG$logging$dir, recursive = TRUE)
      }
    }
    return(TRUE)
  }, error = function(e) {
    warning(paste("Failed to initialize logging:", e$message))
    return(FALSE)
  })
}

#' Log a prediction event
#' @param input_data User input data frame
#' @param prediction Predicted value
#' @param model_type Model used for prediction
log_prediction <- function(input_data, prediction, model_type) {
  if (!CONFIG$logging$enabled) return(NULL)
  
  tryCatch({
    log_file <- file.path(CONFIG$logging$dir, CONFIG$logging$prediction_log)
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    
    log_entry <- sprintf(
      "%s | Model: %s | Prediction: $%.2f | Age: %d | BMI: %.1f | Smoker: %s | Region: %s",
      timestamp, model_type, prediction, 
      input_data$age, input_data$bmi, input_data$smoker, input_data$region
    )
    
    write(log_entry, file = log_file, append = TRUE)
  }, error = function(e) {
    warning(paste("Failed to log prediction:", e$message))
  })
}

#' Log an error event
#' @param error_message Error message
#' @param context Context where error occurred
log_error <- function(error_message, context = "Unknown") {
  if (!CONFIG$logging$enabled) return(NULL)
  
  tryCatch({
    log_file <- file.path(CONFIG$logging$dir, CONFIG$logging$error_log)
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    
    log_entry <- sprintf(
      "%s | Context: %s | Error: %s",
      timestamp, context, error_message
    )
    
    write(log_entry, file = log_file, append = TRUE)
  }, error = function(e) {
    warning(paste("Failed to log error:", e$message))
  })
}

#' Log application startup
#' @param models_loaded List of successfully loaded models
log_startup <- function(models_loaded) {
  if (!CONFIG$logging$enabled) return(NULL)
  
  tryCatch({
    log_file <- file.path(CONFIG$logging$dir, CONFIG$logging$prediction_log)
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    
    log_entry <- sprintf(
      "%s | Application started | Models loaded: %s",
      timestamp, paste(models_loaded, collapse = ", ")
    )
    
    write(log_entry, file = log_file, append = TRUE)
  }, error = function(e) {
    warning(paste("Failed to log startup:", e$message))
  })
}
