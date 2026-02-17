# Configuration file for Medical Insurance Cost Prediction App
# Centralized configuration to avoid hard-coded values

CONFIG <- list(
  # Model paths
  models = list(
    dir = "models",
    linear = "linear_model.RData",
    random_forest = "random_forest_model.RData",
    xgboost = "xgboost_model.RData",
    dummy = "dummy_model.rds",
    train_data = "train_data.RData"
  ),
  
  # Feature ranges for validation
  ranges = list(
    age = c(18, 64),
    bmi = c(15, 55),
    children = c(0, 5)
  ),
  
  # Categorical levels
  levels = list(
    sex = c("male", "female"),
    smoker = c("yes", "no"),
    region = c("northeast", "northwest", "southeast", "southwest")
  ),
  
  # Logging configuration
  logging = list(
    enabled = TRUE,
    dir = "logs",
    prediction_log = "predictions.log",
    error_log = "errors.log"
  ),
  
  # App metadata
  app = list(
    title = "Medical Insurance Cost Prediction",
    author = "Dr. Michael Adu",
    email = "mikekay262@gmail.com",
    linkedin = "https://www.linkedin.com/in/drmichael-adu"
  )
)

# Helper function to build full model path
get_model_path <- function(model_name) {
  file.path(CONFIG$models$dir, CONFIG$models[[model_name]])
}
