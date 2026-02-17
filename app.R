# Medical Insurance Cost Prediction - Modular Shiny Application
# Author: Dr. Michael Adu
# Production-ready version with proper error handling and logging

# Function to ensure required libraries are installed
check_and_install <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
}

# List of required libraries
required_packages <- c(
  "shiny", "shinydashboard", "shinyWidgets", "ggplot2",
  "randomForest", "xgboost", "caret", "DALEX", "DALEXtra", "plotly", "dplyr"
)

# Check and install missing libraries
check_and_install(required_packages)

# Load libraries
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(ggplot2)
library(randomForest)
library(xgboost)
library(caret)
library(DALEX)
library(DALEXtra)
library(plotly)
library(dplyr)

# Source modular components
source("config.R")
source("utils/logger.R")
source("utils/validators.R")
source("R/model_loader.R")
source("R/preprocessing.R")
source("R/prediction.R")
source("R/explainability.R")

# Initialize logging
init_logging()

# Load all models with error handling
cat("Loading models...\n")
model_load_result <- load_all_models()

if (!model_load_result$success) {
  stop("Failed to load required models. Please check the models directory.")
}

# Extract loaded models
app_models <- model_load_result$models
loaded_model_names <- model_load_result$loaded

cat(sprintf("Successfully loaded models: %s\n", paste(loaded_model_names, collapse = ", ")))

# Create explainer for SHAP visualizations (if XGBoost and training data available)
xgb_explainer <- NULL
if (!is.null(app_models$xgboost) && !is.null(app_models$train_data)) {
  cat("Creating XGBoost explainer for SHAP visualizations...\n")
  xgb_explainer <- create_xgb_explainer(app_models$xgboost, app_models$train_data)
}

# Calculate model metrics for comparison
cat("Calculating model performance metrics...\n")
model_metrics <- get_model_metrics(app_models)

# UI Section
ui <- dashboardPage(
  dashboardHeader(title = CONFIG$app$title),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Predict Costs", tabName = "predict", icon = icon("calculator")),
      menuItem("Model Comparison", tabName = "comparison", icon = icon("chart-bar")),
      menuItem("SHAP Visualizations", tabName = "shap", icon = icon("chart-area")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "home",
        fluidRow(
          box(
            title = paste("Welcome to the", CONFIG$app$title, "App"),
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            p("This app predicts medical costs using advanced machine learning models."),
            p("Explore features like model performance comparison, batch predictions, and explainable AI insights using SHAP visualizations."),
            p(sprintf("Author: %s", CONFIG$app$author)),
            p(sprintf("Email: %s", CONFIG$app$email)),
            p("LinkedIn: ", a(CONFIG$app$author, href = CONFIG$app$linkedin)),
            hr(),
            h4("Available Models:"),
            tags$ul(
              if (!is.null(app_models$linear)) tags$li("Linear Regression"),
              if (!is.null(app_models$random_forest)) tags$li("Random Forest"),
              if (!is.null(app_models$xgboost)) tags$li("XGBoost"),
              if (!is.null(app_models$dummy)) tags$li("Dummy Model (Baseline)")
            )
          )
        )
      ),
      tabItem(
        tabName = "predict",
        fluidRow(
          box(
            title = "Input Patient Details",
            width = 6,
            status = "info",
            numericInput("age", "Age:", 
                        value = 30, 
                        min = CONFIG$ranges$age[1], 
                        max = CONFIG$ranges$age[2], 
                        step = 1),
            selectInput("sex", "Sex:", choices = CONFIG$levels$sex),
            numericInput("bmi", "BMI:", 
                        value = 25, 
                        min = CONFIG$ranges$bmi[1], 
                        max = CONFIG$ranges$bmi[2], 
                        step = 0.1),
            numericInput("children", "Number of Children:", 
                        value = 0, 
                        min = CONFIG$ranges$children[1], 
                        max = CONFIG$ranges$children[2], 
                        step = 1),
            selectInput("smoker", "Smoker:", choices = CONFIG$levels$smoker),
            selectInput("region", "Region:", choices = CONFIG$levels$region),
            pickerInput("model_choice", "Select Model:", 
                       choices = c(
                         if (!is.null(app_models$linear)) "Linear Regression",
                         if (!is.null(app_models$random_forest)) "Random Forest",
                         if (!is.null(app_models$xgboost)) "XGBoost"
                       ), 
                       selected = if (!is.null(app_models$xgboost)) "XGBoost" else NULL),
            actionButton("predict", "Predict", class = "btn-primary")
          ),
          box(
            title = "Prediction Results",
            width = 6,
            status = "success",
            solidHeader = TRUE,
            htmlOutput("prediction")
          )
        )
      ),
      tabItem(
        tabName = "comparison",
        fluidRow(
          box(
            title = "Model Performance Comparison",
            width = 12,
            status = "warning",
            plotlyOutput("modelComparisonPlot", height = "500px")
          )
        )
      ),
      tabItem(
        tabName = "shap",
        fluidRow(
          box(
            title = "SHAP Visualizations",
            width = 12,
            status = "info",
            selectInput("shap_type", "Select Visualization Type:", 
                       choices = c("Feature Importance", "Individual Explanation")),
            conditionalPanel(
              condition = "input.shap_type == 'Individual Explanation'",
              p("Note: Individual explanation will use the most recent prediction inputs.")
            ),
            plotOutput("shapPlot", height = "500px")
          )
        )
      ),
      tabItem(
        tabName = "about",
        fluidRow(
          box(
            title = "About the Project",
            width = 12,
            status = "info",
            solidHeader = TRUE,
            p("This project demonstrates the use of machine learning models to predict medical costs."),
            p("Features advanced regression techniques like Linear Regression, Random Forest, and XGBoost."),
            p("Explainability tools ensure the predictions are interpretable and actionable."),
            hr(),
            h4("Technical Features:"),
            tags$ul(
              tags$li("Modular code architecture for maintainability"),
              tags$li("Comprehensive error handling and validation"),
              tags$li("Production-ready logging system"),
              tags$li("SHAP-based model explainability"),
              tags$li("Interactive model comparison visualizations")
            ),
            hr(),
            p(sprintf("Contact: %s", CONFIG$app$author)),
            p(sprintf("Email: %s", CONFIG$app$email)),
            p("LinkedIn: ", a(CONFIG$app$author, href = CONFIG$app$linkedin))
          )
        )
      )
    )
  )
)

# Server Section
server <- function(input, output, session) {
  # Reactive value to store last prediction input for SHAP
  last_input <- reactiveVal(NULL)
  
  # Predict function
  predict_cost_output <- reactive({
    req(input$predict)
    
    # Create user data frame
    user_data <- data.frame(
      age = input$age,
      sex = input$sex,
      bmi = input$bmi,
      children = input$children,
      smoker = input$smoker,
      region = input$region,
      stringsAsFactors = FALSE
    )
    
    # Store for SHAP visualization
    last_input(user_data)
    
    # Map model choice to model_type
    model_type <- switch(input$model_choice,
                        "Linear Regression" = "linear_model",
                        "Random Forest" = "random_forest",
                        "XGBoost" = "xgboost",
                        stop("Invalid model selection"))
    
    # Make prediction with error handling
    tryCatch({
      prediction <- predict_cost(user_data, app_models, model_type)
      return(list(success = TRUE, value = prediction, error = NULL))
    }, error = function(e) {
      return(list(success = FALSE, value = NULL, error = e$message))
    })
  })
  
  # Render prediction
  output$prediction <- renderUI({
    result <- predict_cost_output()
    
    if (result$success) {
      tagList(
        h3(sprintf("Predicted Medical Cost: $%s", format(round(result$value, 2), big.mark = ","))),
        p(sprintf("Model used: %s", input$model_choice)),
        p(class = "text-muted", sprintf("Prediction made at: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
      )
    } else {
      tagList(
        h3("Prediction Error", class = "text-danger"),
        p(result$error, class = "text-danger")
      )
    }
  })
  
  # Model comparison plot
  output$modelComparisonPlot <- renderPlotly({
    if (!is.null(model_metrics)) {
      plot_model_comparison(model_metrics)
    } else {
      # Return empty plot with message
      plotly::plot_ly() %>%
        plotly::layout(
          title = "Model metrics unavailable",
          annotations = list(
            text = "Training data not available for comparison",
            xref = "paper",
            yref = "paper",
            x = 0.5,
            y = 0.5,
            showarrow = FALSE
          )
        )
    }
  })
  
  # SHAP visualization
  output$shapPlot <- renderPlot({
    if (is.null(xgb_explainer)) {
      plot.new()
      text(0.5, 0.5, "SHAP visualizations unavailable\n(XGBoost model or training data not loaded)", 
           cex = 1.5, col = "red")
      return(NULL)
    }
    
    if (input$shap_type == "Feature Importance") {
      plot_feature_importance(xgb_explainer)
    } else if (input$shap_type == "Individual Explanation") {
      current_input <- last_input()
      if (is.null(current_input)) {
        plot.new()
        text(0.5, 0.5, "Make a prediction first to see individual explanation", 
             cex = 1.2, col = "blue")
        return(NULL)
      }
      plot_individual_explanation(xgb_explainer, current_input)
    }
  })
}

# Run the app
shinyApp(ui = ui, server = server)
