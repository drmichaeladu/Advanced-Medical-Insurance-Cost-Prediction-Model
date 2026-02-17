# Model loading utilities with robust error handling

#' Safely load an RData model file
#' @param model_path Path to the RData file
#' @param expected_object Expected object name in the file
#' @return The loaded model object or NULL on failure
safe_load_rdata <- function(model_path, expected_object = NULL) {
  tryCatch({
    if (!file.exists(model_path)) {
      stop(sprintf("Model file not found: %s", model_path))
    }
    
    # Load the RData file into a temporary environment
    temp_env <- new.env()
    load(model_path, envir = temp_env)
    
    # If expected object is specified, try to extract it
    if (!is.null(expected_object)) {
      if (exists(expected_object, envir = temp_env)) {
        return(get(expected_object, envir = temp_env))
      } else {
        # If expected object not found, try to get the first object
        objects <- ls(temp_env)
        if (length(objects) > 0) {
          warning(sprintf("Expected object '%s' not found. Using '%s' instead.", 
                         expected_object, objects[1]))
          return(get(objects[1], envir = temp_env))
        } else {
          stop(sprintf("No objects found in %s", model_path))
        }
      }
    } else {
      # Return the first object if no expected object specified
      objects <- ls(temp_env)
      if (length(objects) > 0) {
        return(get(objects[1], envir = temp_env))
      } else {
        stop(sprintf("No objects found in %s", model_path))
      }
    }
  }, error = function(e) {
    log_error(e$message, sprintf("Loading model from %s", model_path))
    return(NULL)
  })
}

#' Safely load an RDS model file
#' @param model_path Path to the RDS file
#' @return The loaded model object or NULL on failure
safe_load_rds <- function(model_path) {
  tryCatch({
    if (!file.exists(model_path)) {
      stop(sprintf("Model file not found: %s", model_path))
    }
    
    model <- readRDS(model_path)
    return(model)
  }, error = function(e) {
    log_error(e$message, sprintf("Loading RDS model from %s", model_path))
    return(NULL)
  })
}

#' Load training data
#' @return Training data frame or NULL on failure
load_train_data <- function() {
  train_data_path <- get_model_path("train_data")
  
  tryCatch({
    if (!file.exists(train_data_path)) {
      stop(sprintf("Training data file not found: %s", train_data_path))
    }
    
    temp_env <- new.env()
    load(train_data_path, envir = temp_env)
    
    if (exists("train_data", envir = temp_env)) {
      return(get("train_data", envir = temp_env))
    } else {
      stop("train_data object not found in file")
    }
  }, error = function(e) {
    log_error(e$message, "Loading training data")
    return(NULL)
  })
}

#' Load all models required for the application
#' @return List with models and their status
load_all_models <- function() {
  models <- list()
  loaded_models <- c()
  
  # Load linear model
  linear_path <- get_model_path("linear")
  models$linear <- safe_load_rdata(linear_path, "lm_model")
  if (!is.null(models$linear)) {
    loaded_models <- c(loaded_models, "linear")
  } else {
    warning("Failed to load linear model")
  }
  
  # Load random forest model
  rf_path <- get_model_path("random_forest")
  models$random_forest <- safe_load_rdata(rf_path, "rf_optimized")
  if (!is.null(models$random_forest)) {
    loaded_models <- c(loaded_models, "random_forest")
  } else {
    warning("Failed to load random forest model")
  }
  
  # Load XGBoost model
  xgb_path <- get_model_path("xgboost")
  models$xgboost <- safe_load_rdata(xgb_path, "xgb_best")
  if (!is.null(models$xgboost)) {
    loaded_models <- c(loaded_models, "xgboost")
  } else {
    warning("Failed to load XGBoost model")
  }
  
  # Load dummy model
  dummy_path <- get_model_path("dummy")
  models$dummy <- safe_load_rds(dummy_path)
  if (!is.null(models$dummy)) {
    loaded_models <- c(loaded_models, "dummy")
  } else {
    warning("Failed to load dummy model")
  }
  
  # Load training data
  models$train_data <- load_train_data()
  if (!is.null(models$train_data)) {
    loaded_models <- c(loaded_models, "train_data")
  } else {
    warning("Failed to load training data")
  }
  
  # Check if at least one model loaded successfully
  if (length(loaded_models) == 0) {
    stop("No models could be loaded. Please check the models directory.")
  }
  
  # Log successful startup
  log_startup(loaded_models)
  
  return(list(
    models = models,
    loaded = loaded_models,
    success = length(loaded_models) > 0
  ))
}
