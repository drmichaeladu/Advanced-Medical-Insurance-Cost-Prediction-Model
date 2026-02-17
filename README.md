"# Advanced Medical Insurance Cost Prediction Model

A production-ready R Shiny application for predicting medical insurance costs using advanced machine learning models including Linear Regression, Random Forest, and XGBoost. The application features model explainability through SHAP visualizations and comprehensive performance comparisons.

## 🚀 Features

- **Multiple ML Models**: Linear Regression, Random Forest, and XGBoost models
- **Interactive Web Interface**: User-friendly Shiny dashboard for predictions
- **Model Explainability**: SHAP visualizations for understanding predictions
- **Performance Comparison**: Interactive charts comparing model metrics
- **Production-Ready**: 
  - Modular code architecture
  - Comprehensive error handling
  - Input validation
  - Logging system for monitoring
  - Configuration management

## 📋 Requirements

- R >= 4.0.0
- Required R packages:
  - shiny
  - shinydashboard
  - shinyWidgets
  - ggplot2
  - randomForest
  - xgboost
  - caret
  - DALEX
  - DALEXtra
  - plotly
  - dplyr

## 🛠️ Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/drmichaeladu/Advanced-Medical-Insurance-Cost-Prediction-Model.git
   cd Advanced-Medical-Insurance-Cost-Prediction-Model
   ```

2. **Install required R packages:**
   ```R
   # Install required packages
   required_packages <- c(
     "shiny", "shinydashboard", "shinyWidgets", "ggplot2",
     "randomForest", "xgboost", "caret", "DALEX", "DALEXtra", 
     "plotly", "dplyr"
   )
   
   install.packages(required_packages, dependencies = TRUE)
   ```

3. **Verify models are in place:**
   - Ensure the `models/` directory contains:
     - `linear_model.RData`
     - `random_forest_model.RData`
     - `xgboost_model.RData`
     - `dummy_model.rds`
     - `train_data.RData`

## 🏃 Running the Application

### Option 1: Production Version (Recommended)
Run the modular, production-ready version:
```R
shiny::runApp("app_modular.R")
```

### Option 2: Original Version
Run the original single-file version:
```R
shiny::runApp("app.R")
```

### Access the Application
Once running, open your web browser and navigate to:
```
http://localhost:8080
```

## 📁 Project Structure

```
.
├── app.R                           # Original single-file Shiny app
├── app_modular.R                   # Production-ready modular version
├── config.R                        # Centralized configuration
├── R/                              # Core R modules
│   ├── model_loader.R              # Model loading with error handling
│   ├── preprocessing.R             # Data preprocessing functions
│   ├── prediction.R                # Prediction logic
│   └── explainability.R            # SHAP visualization functions
├── utils/                          # Utility modules
│   ├── logger.R                    # Logging functionality
│   └── validators.R                # Input validation
├── models/                         # Trained ML models
│   ├── linear_model.RData
│   ├── random_forest_model.RData
│   ├── xgboost_model.RData
│   ├── dummy_model.rds
│   └── train_data.RData
├── logs/                           # Application logs (created at runtime)
├── insurance.csv                   # Training dataset
└── README.md                       # This file
```

## 💡 Usage

1. **Home Tab**: Overview of the application and available models
2. **Predict Costs Tab**: 
   - Enter patient details (age, sex, BMI, children, smoker status, region)
   - Select a model (Linear Regression, Random Forest, or XGBoost)
   - Click "Predict" to get cost estimation
3. **Model Comparison Tab**: View interactive performance metrics (RMSE, MAE, R²)
4. **SHAP Visualizations Tab**: 
   - Feature Importance: See which features impact predictions most
   - Individual Explanation: Understand specific prediction breakdown
5. **About Tab**: Project information and technical details

## 🔧 Configuration

Edit `config.R` to customize:
- Model paths
- Input validation ranges
- Logging settings
- Application metadata

Example:
```R
CONFIG <- list(
  ranges = list(
    age = c(18, 64),
    bmi = c(15, 55),
    children = c(0, 5)
  ),
  logging = list(
    enabled = TRUE,
    dir = "logs"
  )
)
```

## 📊 Model Information

- **Linear Regression**: Fast baseline model with interpretable coefficients
- **Random Forest**: Ensemble method handling non-linear relationships
- **XGBoost**: Gradient boosting for highest accuracy

Performance metrics are calculated on training data and displayed in the Model Comparison tab.

## 🔒 Production Features

### Error Handling
- Comprehensive try-catch blocks
- User-friendly error messages
- Graceful degradation when models unavailable

### Input Validation
- Range checking for numeric inputs
- Categorical value validation
- Server-side validation before prediction

### Logging
- Prediction events logged with timestamps
- Error tracking for debugging
- Startup logging for monitoring

### Monitoring
All logs are stored in the `logs/` directory:
- `predictions.log`: User predictions and model usage
- `errors.log`: Error events for debugging

## 🧪 Testing

To validate the application:
```R
# Source the test file (if exists)
source("tests/test_prediction.R")

# Or manually test predictions
source("config.R")
source("utils/validators.R")
source("R/model_loader.R")
source("R/preprocessing.R")
source("R/prediction.R")

# Load models
models <- load_all_models()

# Test prediction
test_data <- data.frame(
  age = 30, sex = "male", bmi = 25, 
  children = 2, smoker = "no", region = "northeast"
)
result <- predict_cost(test_data, models$models, "xgboost")
print(result)
```

## 📝 Deployment

### Deploy with Docker (Recommended for Production)
The easiest way to deploy the application:

```bash
# Build and run with Docker Compose
docker-compose up -d

# Access the application at http://localhost:3838

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

Or build manually:
```bash
# Build the Docker image
docker build -t insurance-predictor .

# Run the container
docker run -d -p 3838:3838 --name insurance-app insurance-predictor

# Access at http://localhost:3838
```

### Deploy to Shinyapps.io
```R
library(rsconnect)
rsconnect::deployApp(appName = "insurance-cost-predictor")
```

### Deploy to Heroku
The repository includes `Procfile` and `runtime.txt` for Heroku deployment:
```bash
heroku create your-app-name
git push heroku main
```

### Health Check Endpoint
Before deployment, run the health check script:
```R
source("health_check.R")
results <- health_check()
print_health_check(results)
```

## 👤 Author

**Dr. Michael Adu**
- Email: mikekay262@gmail.com
- LinkedIn: [Dr. Michael Adu](https://www.linkedin.com/in/drmichael-adu)

## 📄 License

This project is for educational and research purposes. Not intended for commercial use or diagnostic purposes.

## ⚠️ Disclaimer

This model is developed for learning and research purposes only. Predictions should not be used for actual medical or insurance decision-making without proper validation and regulatory approval.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📚 References

- Dataset: Medical Cost Personal Dataset (Kaggle)
- SHAP: Lundberg & Lee (2017) - "A Unified Approach to Interpreting Model Predictions"
- XGBoost: Chen & Guestrin (2016) - "XGBoost: A Scalable Tree Boosting System"" 
