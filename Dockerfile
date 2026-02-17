# Base image with R
FROM rocker/shiny:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'shinyWidgets', 'ggplot2', 'randomForest', 'xgboost', 'caret', 'DALEX', 'DALEXtra', 'plotly', 'dplyr'), repos='https://cloud.r-project.org/', dependencies=TRUE)"

# Create application directory
RUN mkdir -p /srv/shiny-server/insurance-predictor

# Set working directory
WORKDIR /srv/shiny-server/insurance-predictor

# Copy application files
COPY app.R /srv/shiny-server/insurance-predictor/
COPY config.R /srv/shiny-server/insurance-predictor/
COPY version.R /srv/shiny-server/insurance-predictor/
COPY R/ /srv/shiny-server/insurance-predictor/R/
COPY utils/ /srv/shiny-server/insurance-predictor/utils/
COPY models/ /srv/shiny-server/insurance-predictor/models/
COPY insurance.csv /srv/shiny-server/insurance-predictor/

# Create logs directory
RUN mkdir -p /srv/shiny-server/insurance-predictor/logs

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server/insurance-predictor

# Expose port
EXPOSE 3838

# Run application
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/insurance-predictor/app.R', host='0.0.0.0', port=3838)"]
