# Test Script for Medical Insurance Cost Prediction Application
# This script tests the modular components

# Source required files
source("config.R")
source("utils/logger.R")
source("utils/validators.R")
source("R/model_loader.R")
source("R/preprocessing.R")
source("R/prediction.R")
source("R/explainability.R")

cat("=" %R% 70, "\n")
cat("Testing Medical Insurance Cost Prediction Application\n")
cat("=" %R% 70, "\n\n")

# Test 1: Configuration
cat("Test 1: Configuration Loading\n")
cat("-" %R% 70, "\n")
cat("Model directory:", CONFIG$models$dir, "\n")
cat("Age range:", CONFIG$ranges$age[1], "to", CONFIG$ranges$age[2], "\n")
cat("Region levels:", paste(CONFIG$levels$region, collapse = ", "), "\n")
cat("✓ Configuration loaded successfully\n\n")

# Test 2: Logging initialization
cat("Test 2: Logging Initialization\n")
cat("-" %R% 70, "\n")
init_result <- init_logging()
if (init_result) {
  cat("✓ Logging initialized successfully\n")
  cat("Log directory:", CONFIG$logging$dir, "\n\n")
} else {
  cat("✗ Logging initialization failed\n\n")
}

# Test 3: Input Validation
cat("Test 3: Input Validation\n")
cat("-" %R% 70, "\n")

test_data_valid <- data.frame(
  age = 30,
  sex = "male",
  bmi = 25.5,
  children = 2,
  smoker = "no",
  region = "northeast"
)

valid_result <- validate_input_data(test_data_valid)
cat("Valid input test:")
if (valid_result$valid) {
  cat(" ✓ PASSED\n")
} else {
  cat(" ✗ FAILED:", paste(valid_result$messages, collapse = "; "), "\n")
}

test_data_invalid <- data.frame(
  age = 100,  # Out of range
  sex = "male",
  bmi = 25.5,
  children = 2,
  smoker = "no",
  region = "northeast"
)

invalid_result <- validate_input_data(test_data_invalid)
cat("Invalid input test:")
if (!invalid_result$valid) {
  cat(" ✓ PASSED (correctly rejected)\n")
  cat("  Error messages:", paste(invalid_result$messages, collapse = "; "), "\n")
} else {
  cat(" ✗ FAILED (should have rejected)\n")
}
cat("\n")

# Test 4: Model Loading
cat("Test 4: Model Loading\n")
cat("-" %R% 70, "\n")

tryCatch({
  model_result <- load_all_models()
  
  if (model_result$success) {
    cat("✓ Models loaded successfully\n")
    cat("Loaded models:", paste(model_result$loaded, collapse = ", "), "\n")
    
    # Store models for further tests
    test_models <- model_result$models
  } else {
    cat("✗ Model loading failed\n")
    test_models <- NULL
  }
}, error = function(e) {
  cat("✗ Model loading error:", e$message, "\n")
  test_models <- NULL
})
cat("\n")

# Test 5: Preprocessing
cat("Test 5: Data Preprocessing\n")
cat("-" %R% 70, "\n")

tryCatch({
  # Test XGBoost preprocessing
  xgb_data <- preprocess_data_xgb(test_data_valid)
  cat("✓ XGBoost preprocessing successful\n")
  cat("  Features:", ncol(xgb_data), "columns\n")
  
  # Test Random Forest preprocessing
  rf_data <- preprocess_data_rf(test_data_valid)
  cat("✓ Random Forest preprocessing successful\n")
  cat("  Features:", ncol(rf_data), "columns\n")
  
  # Test Linear Model preprocessing
  lm_data <- preprocess_data_lm(test_data_valid)
  cat("✓ Linear Model preprocessing successful\n")
  cat("  Features:", ncol(lm_data), "columns\n")
}, error = function(e) {
  cat("✗ Preprocessing error:", e$message, "\n")
})
cat("\n")

# Test 6: Prediction (if models loaded)
cat("Test 6: Prediction\n")
cat("-" %R% 70, "\n")

if (!is.null(test_models)) {
  # Test predictions with each model type
  model_types <- c("xgboost", "random_forest", "linear_model")
  
  for (model_type in model_types) {
    model_key <- switch(model_type,
                       "xgboost" = "xgboost",
                       "random_forest" = "random_forest",
                       "linear_model" = "linear")
    
    if (!is.null(test_models[[model_key]])) {
      tryCatch({
        prediction <- predict_cost(test_data_valid, test_models, model_type)
        cat(sprintf("✓ %s prediction: $%.2f\n", model_type, prediction))
      }, error = function(e) {
        cat(sprintf("✗ %s prediction failed: %s\n", model_type, e$message))
      })
    } else {
      cat(sprintf("- %s model not available\n", model_type))
    }
  }
} else {
  cat("✗ Cannot test predictions - models not loaded\n")
}
cat("\n")

# Test 7: Model Metrics
cat("Test 7: Model Performance Metrics\n")
cat("-" %R% 70, "\n")

if (!is.null(test_models)) {
  tryCatch({
    metrics <- get_model_metrics(test_models)
    
    if (!is.null(metrics) && nrow(metrics) > 0) {
      cat("✓ Model metrics calculated successfully\n")
      print(metrics)
    } else {
      cat("- No metrics available (training data may not be loaded)\n")
    }
  }, error = function(e) {
    cat("✗ Metrics calculation error:", e$message, "\n")
  })
} else {
  cat("✗ Cannot calculate metrics - models not loaded\n")
}
cat("\n")

# Test 8: Explainability
cat("Test 8: Explainability (SHAP)\n")
cat("-" %R% 70, "\n")

if (!is.null(test_models) && !is.null(test_models$xgboost) && !is.null(test_models$train_data)) {
  tryCatch({
    explainer <- create_xgb_explainer(test_models$xgboost, test_models$train_data)
    
    if (!is.null(explainer)) {
      cat("✓ XGBoost explainer created successfully\n")
    } else {
      cat("- XGBoost explainer could not be created\n")
    }
  }, error = function(e) {
    cat("✗ Explainer creation error:", e$message, "\n")
  })
} else {
  cat("- Cannot create explainer (XGBoost model or training data not available)\n")
}
cat("\n")

# Summary
cat("=" %R% 70, "\n")
cat("Test Summary\n")
cat("=" %R% 70, "\n")
cat("All core components have been tested.\n")
cat("To run the full application, use: shiny::runApp('app.R')\n")
cat("=" %R% 70, "\n")
