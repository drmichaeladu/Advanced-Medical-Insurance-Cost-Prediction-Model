# Data preprocessing functions for different models

#' Preprocess data for XGBoost model
#' @param data Input data frame
#' @param train_columns Feature names from training (optional)
#' @return Preprocessed data frame
preprocess_data_xgb <- function(data, train_columns = NULL) {
  tryCatch({
    # Create a copy to avoid modifying original
    processed_data <- data
    
    # Encode 'smoker' as binary
    processed_data$smoker.yes <- ifelse(processed_data$smoker == "yes", 1, 0)
    
    # Create derived features
    processed_data$smoker_bmi <- ifelse(processed_data$smoker == "yes", processed_data$bmi, 0)
    processed_data$age_squared <- processed_data$age^2
    
    # One-hot encode 'region' (excluding 'northeast' as baseline)
    region_levels <- c("northwest", "southeast", "southwest")
    for (region in region_levels) {
      col_name <- paste0("region.", region)
      processed_data[[col_name]] <- ifelse(processed_data$region == region, 1, 0)
    }
    
    # Remove original categorical columns
    processed_data$region <- NULL
    processed_data$smoker <- NULL
    
    # Handle 'sex' column (binary encoding for male)
    if ("sex" %in% colnames(processed_data)) {
      processed_data$sex.male <- ifelse(processed_data$sex == "male", 1, 0)
      processed_data$sex <- NULL
    }
    
    # Ensure all required features are included if train_columns provided
    if (!is.null(train_columns)) {
      # Add missing columns with default values of 0
      missing_cols <- setdiff(train_columns, colnames(processed_data))
      if (length(missing_cols) > 0) {
        for (col in missing_cols) {
          processed_data[[col]] <- 0
        }
      }
      
      # Remove extra columns not present in train_columns
      # Exclude 'charges' if present (target variable)
      train_cols_no_charges <- train_columns[train_columns != "charges"]
      processed_data <- processed_data[, intersect(colnames(processed_data), train_cols_no_charges), drop = FALSE]
      
      # Reorder columns to match train_columns
      processed_data <- processed_data[, train_cols_no_charges, drop = FALSE]
    }
    
    # Ensure all columns are numeric
    processed_data <- as.data.frame(lapply(processed_data, as.numeric))
    
    # Remove the target variable 'charges' if present
    if ("charges" %in% colnames(processed_data)) {
      processed_data$charges <- NULL
    }
    
    return(processed_data)
  }, error = function(e) {
    log_error(e$message, "Preprocessing data for XGBoost")
    stop(paste("Error in XGBoost preprocessing:", e$message))
  })
}

#' Preprocess data for Random Forest model
#' @param data Input data frame
#' @return Preprocessed data frame
preprocess_data_rf <- function(data) {
  tryCatch({
    # Create a copy to avoid modifying original
    processed_data <- data
    
    # Add derived features
    processed_data$smoker_bmi <- ifelse(processed_data$smoker == "yes", processed_data$bmi, 0)
    processed_data$age_squared <- processed_data$age^2
    
    # Ensure categorical variables are factors with consistent levels
    processed_data$smoker <- factor(processed_data$smoker, levels = CONFIG$levels$smoker)
    processed_data$sex <- factor(processed_data$sex, levels = CONFIG$levels$sex)
    processed_data$region <- factor(processed_data$region, levels = CONFIG$levels$region)
    
    return(processed_data)
  }, error = function(e) {
    log_error(e$message, "Preprocessing data for Random Forest")
    stop(paste("Error in Random Forest preprocessing:", e$message))
  })
}

#' Preprocess data for Linear Model
#' @param data Input data frame
#' @return Preprocessed data frame
preprocess_data_lm <- function(data) {
  tryCatch({
    # Create a copy to avoid modifying original
    processed_data <- data
    
    # Add derived features
    processed_data$smoker_bmi <- ifelse(processed_data$smoker == "yes", processed_data$bmi, 0)
    processed_data$age_squared <- processed_data$age^2
    
    # Ensure categorical variables are factors
    processed_data$smoker <- factor(processed_data$smoker, levels = CONFIG$levels$smoker)
    processed_data$sex <- factor(processed_data$sex, levels = CONFIG$levels$sex)
    processed_data$region <- factor(processed_data$region, levels = CONFIG$levels$region)
    
    return(processed_data)
  }, error = function(e) {
    log_error(e$message, "Preprocessing data for Linear Model")
    stop(paste("Error in Linear Model preprocessing:", e$message))
  })
}

#' Preprocess data based on model type
#' @param data Input data frame
#' @param model_type Type of model ("xgboost", "random_forest", "linear_model")
#' @param train_columns Feature names from training (for XGBoost)
#' @return Preprocessed data frame
preprocess_data <- function(data, model_type, train_columns = NULL) {
  if (model_type == "xgboost") {
    return(preprocess_data_xgb(data, train_columns))
  } else if (model_type == "random_forest") {
    return(preprocess_data_rf(data))
  } else if (model_type == "linear_model") {
    return(preprocess_data_lm(data))
  } else if (model_type == "dummy") {
    # Dummy model uses same preprocessing as XGBoost
    return(preprocess_data_xgb(data, train_columns))
  } else {
    stop(paste("Unknown model type:", model_type))
  }
}
