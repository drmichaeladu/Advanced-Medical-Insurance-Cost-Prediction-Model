# Project Cleanup and Maintenance Guide

This guide helps maintain the project in a clean, production-ready state.

## 🧹 Initial Cleanup (Recommended)

The following files are duplicates and can be safely removed if the `models/` directory contains all model files:

### Duplicate Model Files (Remove if in models/ directory)
```bash
# Check if models exist in models/ directory first
ls -la models/

# If all files are present in models/, remove duplicates:
rm -f dummy_model.rds
rm -f linear_model.RData
rm -f random_forest_model.RData
rm -f train_data.RData
rm -f xgboost_model.RData
```

### Development Files (Optional Cleanup)
These files are useful for development but not needed in production:

```bash
# Original RMarkdown analysis (keep for reference)
# - Advanced Medical Insurance Cost Prediction Model II.Rmd
# - Advanced-Medical-Insurance-Cost-Prediction-Model-II.html
# - Advanced-Medical-Insurance-Cost-Prediction-Model-II.pdf

# R Project file (useful for RStudio users)
# - Advanced Medical Insurance Cost Prediction Model II.Rproj
```

## 📁 Recommended Directory Structure

```
.
├── app.R                           # Main application (modular version)
├── config.R                        # Configuration
├── version.R                       # Version metadata
├── start_app.R                     # Startup script
├── health_check.R                  # Health monitoring
├── R/                              # Core modules
│   ├── model_loader.R
│   ├── preprocessing.R
│   ├── prediction.R
│   └── explainability.R
├── utils/                          # Utilities
│   ├── logger.R
│   └── validators.R
├── models/                         # ML models (required)
│   ├── linear_model.RData
│   ├── random_forest_model.RData
│   ├── xgboost_model.RData
│   ├── dummy_model.rds
│   └── train_data.RData
├── tests/                          # Test scripts
│   └── test_application.R
├── logs/                           # Runtime logs (auto-created)
├── insurance.csv                   # Training dataset
├── Dockerfile                      # Docker configuration
├── docker-compose.yml              # Docker Compose config
├── README.md                       # Documentation
├── CONTRIBUTING.md                 # Contribution guide
├── .gitignore                      # Git ignore rules
└── .dockerignore                   # Docker ignore rules
```

## 🔧 Regular Maintenance Tasks

### Daily/Weekly
- Monitor logs in `logs/` directory
- Check disk space for log files
- Review error logs for patterns

### Monthly
- Update R packages: `update.packages(ask = FALSE)`
- Review and archive old logs
- Check for security updates
- Verify model performance metrics

### Quarterly
- Review and update model versions
- Re-train models if needed
- Update documentation
- Review and close old issues

## 📊 Log Management

### Log Rotation (Recommended)
Implement log rotation to prevent disk space issues:

```bash
# Linux/Mac: Add to cron
0 0 * * 0 cd /path/to/app && find logs/ -name "*.log" -mtime +30 -delete

# Or use logrotate (create /etc/logrotate.d/insurance-app)
/path/to/app/logs/*.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
}
```

### Manual Log Cleanup
```bash
# View log sizes
du -sh logs/*

# Archive old logs
tar -czf logs_archive_$(date +%Y%m%d).tar.gz logs/*.log
mv logs_archive_*.tar.gz ~/archives/

# Clean logs older than 30 days
find logs/ -name "*.log" -mtime +30 -delete
```

## 🔄 Model Updates

### When to Update Models
- Significant new data available
- Model performance degradation
- Feature changes required
- Scheduled quarterly reviews

### Model Update Process
1. Train new model with updated data
2. Save with version suffix: `xgboost_model_v2.RData`
3. Update `version.R` with new version info
4. Update `config.R` to point to new model
5. Test thoroughly before deployment
6. Keep old model as backup for 1 quarter

### Version Naming Convention
```
model_name_vX.Y.RData

X = Major version (breaking changes)
Y = Minor version (improvements)

Examples:
- xgboost_model_v1.0.RData (initial)
- xgboost_model_v1.1.RData (performance improvement)
- xgboost_model_v2.0.RData (feature changes)
```

## 🐛 Debugging Production Issues

### Check Health Status
```R
source("health_check.R")
results <- health_check()
print_health_check(results)
```

### Review Recent Errors
```R
# Read last 50 error log entries
errors <- tail(readLines("logs/errors.log"), 50)
cat(errors, sep="\n")
```

### Review Recent Predictions
```R
# Read last 100 prediction logs
predictions <- tail(readLines("logs/predictions.log"), 100)
cat(predictions, sep="\n")
```

### Common Issues and Solutions

**Issue: Models fail to load**
- Check model file paths in `config.R`
- Verify model files exist in `models/` directory
- Check file permissions

**Issue: Predictions fail**
- Check input validation in logs
- Verify preprocessing functions
- Check model compatibility with input format

**Issue: Application crashes**
- Review error logs
- Check memory usage: `htop` or `top`
- Verify package versions
- Check disk space

**Issue: Slow performance**
- Monitor with: `source("health_check.R")`
- Check log file sizes
- Review model loading time
- Consider caching strategies

## 🔐 Security Best Practices

### File Permissions
```bash
# Set appropriate permissions
chmod 644 app.R config.R version.R
chmod 755 start_app.R health_check.R
chmod 700 logs/
chmod 600 logs/*.log
```

### Environment Variables
For production deployments, use environment variables for sensitive data:

```R
# .Renviron file (add to .gitignore)
DB_PASSWORD=your_password
API_KEY=your_api_key
```

### Regular Security Updates
```bash
# Update R packages
R -e "update.packages(ask = FALSE)"

# Update system packages (Ubuntu/Debian)
sudo apt-get update && sudo apt-get upgrade

# Check for security vulnerabilities
R -e "remotes::install_github('r-lib/pak'); pak::pkg_deps_explain('shiny')"
```

## 📈 Performance Monitoring

### Application Metrics to Track
- Average prediction response time
- Number of predictions per day
- Error rate (errors / total requests)
- Memory usage
- Model accuracy over time

### Setting up Basic Monitoring
```R
# Add to app.R or create monitoring script
monitor_performance <- function() {
  logs <- readLines("logs/predictions.log")
  
  # Count predictions per day
  dates <- as.Date(substr(logs, 1, 10))
  daily_counts <- table(dates)
  
  cat("Daily Prediction Counts:\n")
  print(daily_counts)
  
  # Error rate
  errors <- readLines("logs/errors.log")
  error_rate <- length(errors) / length(logs)
  cat(sprintf("\nError Rate: %.2f%%\n", error_rate * 100))
}
```

## 🚀 Deployment Checklist

Before deploying to production:

- [ ] Run health check: `source("health_check.R")`
- [ ] Run tests: `source("tests/test_application.R")`
- [ ] Verify all models load correctly
- [ ] Check configuration settings
- [ ] Review and clean logs
- [ ] Update version.R if needed
- [ ] Test all UI features manually
- [ ] Backup current production models
- [ ] Update documentation
- [ ] Set up monitoring
- [ ] Configure log rotation
- [ ] Set appropriate file permissions
- [ ] Test rollback procedure

## 🔙 Rollback Procedure

If issues occur after deployment:

1. **Immediate Rollback**
   ```bash
   # Restore previous version from git
   git checkout previous_tag
   
   # Or restore previous Docker image
   docker pull insurance-predictor:previous-version
   docker-compose up -d
   ```

2. **Restore Previous Models**
   ```bash
   cp models_backup/*.RData models/
   ```

3. **Verify Rollback**
   ```R
   source("health_check.R")
   results <- health_check()
   print_health_check(results)
   ```

4. **Notify Stakeholders**
   - Document the issue
   - Notify users if affected
   - Create incident report

## 📞 Support and Troubleshooting

For issues not covered in this guide:

1. Check existing GitHub issues
2. Review application logs
3. Run health check script
4. Contact maintainer: mikekay262@gmail.com

## 📚 Additional Resources

- [Shiny Production Guide](https://shiny.rstudio.com/articles/deployment.html)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [R Package Management](https://rstudio.github.io/renv/)
- [Log Management](https://www.loggly.com/ultimate-guide/r-logging-basics/)
