# Explainability utilities for SHAP visualizations

#' Create DALEX explainer for XGBoost model
#' @param xgb_model XGBoost model object
#' @param train_data Training data frame
#' @return DALEX explainer object or NULL on failure
create_xgb_explainer <- function(xgb_model, train_data) {
  tryCatch({
    if (is.null(xgb_model) || is.null(train_data)) {
      warning("Model or training data not available for explainer")
      return(NULL)
    }
    
    # Prepare target variable
    y_target <- train_data$charges
    
    # Exclude the target variable for model input
    train_data_features <- train_data
    train_data_features$charges <- NULL
    
    # Convert categorical variables to dummy/one-hot encoding
    train_data_numeric <- model.matrix(~ . - 1, data = train_data_features)
    train_data_numeric <- as.matrix(train_data_numeric)
    
    # Verify dimensions
    if (nrow(train_data_numeric) != length(y_target)) {
      warning("Mismatch between feature matrix rows and target variable length.")
      return(NULL)
    }
    
    # Create XGBoost explainer
    explainer <- DALEX::explain_xgboost(
      model = xgb_model,
      data = train_data_numeric,
      y = y_target,
      label = "XGBoost"
    )
    
    return(explainer)
  }, error = function(e) {
    log_error(e$message, "Creating XGBoost explainer")
    warning(paste("Failed to create explainer:", e$message))
    return(NULL)
  })
}

#' Generate feature importance plot
#' @param explainer DALEX explainer object
#' @return ggplot object or NULL on failure
plot_feature_importance <- function(explainer) {
  tryCatch({
    if (is.null(explainer)) {
      warning("Explainer not available")
      return(NULL)
    }
    
    # Calculate variable importance
    vi <- DALEX::model_parts(explainer)
    
    # Create plot
    p <- plot(vi) +
      ggplot2::ggtitle("Feature Importance") +
      ggplot2::theme_minimal()
    
    return(p)
  }, error = function(e) {
    log_error(e$message, "Plotting feature importance")
    warning(paste("Failed to create feature importance plot:", e$message))
    return(NULL)
  })
}

#' Generate individual explanation plot
#' @param explainer DALEX explainer object
#' @param new_observation Data frame with single observation to explain
#' @return ggplot object or NULL on failure
plot_individual_explanation <- function(explainer, new_observation) {
  tryCatch({
    if (is.null(explainer)) {
      warning("Explainer not available")
      return(NULL)
    }
    
    if (is.null(new_observation) || nrow(new_observation) == 0) {
      warning("No observation provided for explanation")
      return(NULL)
    }
    
    # Prepare the observation
    obs <- new_observation
    obs$charges <- NULL  # Remove target if present
    
    # Create break-down explanation
    bd <- DALEX::predict_parts(explainer, new_observation = obs)
    
    # Create plot
    p <- plot(bd) +
      ggplot2::ggtitle("Individual Prediction Explanation") +
      ggplot2::theme_minimal()
    
    return(p)
  }, error = function(e) {
    log_error(e$message, "Plotting individual explanation")
    warning(paste("Failed to create individual explanation plot:", e$message))
    return(NULL)
  })
}

#' Generate model performance comparison plot
#' @param metrics Data frame with model metrics (from get_model_metrics)
#' @return plotly object or NULL on failure
plot_model_comparison <- function(metrics) {
  tryCatch({
    if (is.null(metrics) || nrow(metrics) == 0) {
      warning("No metrics available for comparison")
      return(NULL)
    }
    
    # Create interactive plotly chart
    p <- plotly::plot_ly(
      data = metrics,
      x = ~Model,
      y = ~RMSE,
      type = "bar",
      name = "RMSE",
      marker = list(color = "#1f77b4")
    ) %>%
      plotly::add_trace(
        y = ~MAE,
        name = "MAE",
        marker = list(color = "#ff7f0e")
      ) %>%
      plotly::layout(
        title = "Model Performance Comparison",
        xaxis = list(title = "Model"),
        yaxis = list(title = "Error Metric"),
        barmode = "group",
        legend = list(x = 0.8, y = 1)
      )
    
    return(p)
  }, error = function(e) {
    log_error(e$message, "Plotting model comparison")
    warning(paste("Failed to create model comparison plot:", e$message))
    return(NULL)
  })
}

#' Generate R-squared comparison plot
#' @param metrics Data frame with model metrics
#' @return plotly object or NULL on failure
plot_r_squared_comparison <- function(metrics) {
  tryCatch({
    if (is.null(metrics) || nrow(metrics) == 0) {
      warning("No metrics available for R-squared comparison")
      return(NULL)
    }
    
    # Create bar plot for R-squared
    p <- plotly::plot_ly(
      data = metrics,
      x = ~Model,
      y = ~R_Squared,
      type = "bar",
      marker = list(color = "#2ca02c")
    ) %>%
      plotly::layout(
        title = "R-Squared Comparison",
        xaxis = list(title = "Model"),
        yaxis = list(title = "R-Squared", range = c(0, 1))
      )
    
    return(p)
  }, error = function(e) {
    log_error(e$message, "Plotting R-squared comparison")
    warning(paste("Failed to create R-squared comparison plot:", e$message))
    return(NULL)
  })
}
