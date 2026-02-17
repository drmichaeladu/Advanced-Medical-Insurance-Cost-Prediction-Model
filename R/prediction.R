# Prediction functions with error handling and validation

#' Make prediction using specified model
#' @param input_data Input data frame with user inputs
#' @param models List containing all loaded models
#' @param model_type Type of model to use
#' @return Predicted cost value
predict_cost <- function(input_data, models, model_type = "xgboost") {
  tryCatch({
    # Validate input data first
    validation_result <- validate_input_data(input_data)
    if (!validation_result$valid) {
      stop(paste("Input validation failed:", paste(validation_result$messages, collapse = "; ")))
    }
    
    # Check if requested model is available
    model_key <- switch(model_type,
                       "xgboost" = "xgboost",
                       "random_forest" = "random_forest",
                       "linear_model" = "linear",
                       "dummy" = "dummy",
                       stop(paste("Invalid model type:", model_type)))
    
    if (is.null(models[[model_key]])) {
      stop(paste("Model not available:", model_type))
    }
    
    # Get feature names for XGBoost if available
    train_columns <- NULL
    if (model_type == "xgboost" && !is.null(models$xgboost$feature_names)) {
      train_columns <- models$xgboost$feature_names
    }
    
    # Preprocess input data based on model type
    preprocessed_data <- preprocess_data(input_data, model_type, train_columns)
    
    # Make prediction based on model type
    prediction <- NULL
    if (model_type == "xgboost") {
      prediction <- predict(models$xgboost, as.matrix(preprocessed_data))
    } else if (model_type == "random_forest") {
      prediction <- predict(models$random_forest, preprocessed_data)
    } else if (model_type == "linear_model") {
      prediction <- predict(models$linear, preprocessed_data)
    } else if (model_type == "dummy") {
      prediction <- predict(models$dummy, newdata = preprocessed_data)
    }
    
    # Validate prediction output
    if (is.null(prediction) || is.na(prediction) || !is.numeric(prediction)) {
      stop("Invalid prediction output from model")
    }
    
    # Ensure prediction is positive
    if (prediction < 0) {
      warning(sprintf("Negative prediction (%.2f) adjusted to 0", prediction))
      prediction <- 0
    }
    
    # Log the prediction
    log_prediction(input_data, prediction, model_type)
    
    return(prediction)
  }, error = function(e) {
    log_error(e$message, sprintf("Making prediction with %s model", model_type))
    stop(paste("Prediction error:", e$message))
  })
}

#' Batch prediction for multiple inputs
#' @param input_data_list List of input data frames
#' @param models List containing all loaded models
#' @param model_type Type of model to use
#' @return Vector of predicted costs
predict_batch <- function(input_data_list, models, model_type = "xgboost") {
  predictions <- sapply(input_data_list, function(input_data) {
    tryCatch({
      predict_cost(input_data, models, model_type)
    }, error = function(e) {
      log_error(e$message, "Batch prediction")
      return(NA)
    })
  })
  
  return(predictions)
}

#' Get model performance metrics (if training data available)
#' @param models List containing all loaded models
#' @return Data frame with model comparison metrics
get_model_metrics <- function(models) {
  tryCatch({
    if (is.null(models$train_data)) {
      warning("Training data not available for metrics calculation")
      return(NULL)
    }
    
    train_data <- models$train_data
    actual_values <- train_data$charges
    
    metrics <- data.frame(
      Model = character(),
      RMSE = numeric(),
      MAE = numeric(),
      R_Squared = numeric(),
      stringsAsFactors = FALSE
    )
    
    # Calculate metrics for each model
    model_types <- c("linear_model", "random_forest", "xgboost")
    model_names <- c("Linear Regression", "Random Forest", "XGBoost")
    
    for (i in seq_along(model_types)) {
      model_type <- model_types[i]
      model_name <- model_names[i]
      
      model_key <- switch(model_type,
                         "linear_model" = "linear",
                         "random_forest" = "random_forest",
                         "xgboost" = "xgboost")
      
      if (!is.null(models[[model_key]])) {
        # Make predictions on training data
        predictions <- sapply(1:nrow(train_data), function(row_idx) {
          input_row <- train_data[row_idx, ]
          tryCatch({
            # Remove charges column for prediction
            input_row$charges <- NULL
            predict_cost(input_row, models, model_type)
          }, error = function(e) {
            return(NA)
          })
        })
        
        # Calculate metrics
        valid_idx <- !is.na(predictions)
        if (sum(valid_idx) > 0) {
          rmse <- sqrt(mean((predictions[valid_idx] - actual_values[valid_idx])^2))
          mae <- mean(abs(predictions[valid_idx] - actual_values[valid_idx]))
          
          # R-squared
          ss_res <- sum((actual_values[valid_idx] - predictions[valid_idx])^2)
          ss_tot <- sum((actual_values[valid_idx] - mean(actual_values[valid_idx]))^2)
          r_squared <- 1 - (ss_res / ss_tot)
          
          metrics <- rbind(metrics, data.frame(
            Model = model_name,
            RMSE = rmse,
            MAE = mae,
            R_Squared = r_squared,
            stringsAsFactors = FALSE
          ))
        }
      }
    }
    
    return(metrics)
  }, error = function(e) {
    log_error(e$message, "Calculating model metrics")
    warning(paste("Failed to calculate metrics:", e$message))
    return(NULL)
  })
}
