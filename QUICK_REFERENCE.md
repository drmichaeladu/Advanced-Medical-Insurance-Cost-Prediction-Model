# Quick Reference Guide

## 🚀 Getting Started (5 Minutes)

### 1. Clone and Setup
```bash
git clone https://github.com/drmichaeladu/Advanced-Medical-Insurance-Cost-Prediction-Model.git
cd Advanced-Medical-Insurance-Cost-Prediction-Model
```

### 2. Quick Start with Docker (Recommended)
```bash
docker-compose up -d
# Access: http://localhost:3838
```

### 3. Or Start with R
```bash
Rscript start_app.R
```

## 📂 Project Structure (Quick Overview)

```
├── app.R                  # Main application (start here)
├── config.R               # All settings and configuration
├── R/                     # Core functionality modules
├── utils/                 # Helper utilities (logging, validation)
├── models/                # Pre-trained ML models
└── Documentation files    # README, CONTRIBUTING, etc.
```

## 🔍 Common Tasks

### Check System Health
```bash
Rscript health_check.R
```

### Run Tests
```bash
Rscript tests/test_application.R
```

### View Logs
```bash
tail -f logs/predictions.log
tail -f logs/errors.log
```

### Update Configuration
Edit `config.R` - all settings in one place:
- Model paths
- Input ranges
- Logging settings

## 🔧 Key Files and Their Purpose

| File | Purpose | When to Edit |
|------|---------|--------------|
| `config.R` | Configuration | Change settings, paths, ranges |
| `app.R` | Main application | Modify UI or server logic |
| `R/model_loader.R` | Model loading | Change model loading logic |
| `R/prediction.R` | Predictions | Modify prediction logic |
| `utils/validators.R` | Validation | Change input validation rules |
| `utils/logger.R` | Logging | Customize logging behavior |
| `version.R` | Version info | Update version metadata |

## 📊 Feature Overview

### Available Models
1. **Linear Regression** - Fast, interpretable baseline
2. **Random Forest** - Handles non-linear relationships
3. **XGBoost** - Highest accuracy

### Application Tabs
1. **Home** - Overview and information
2. **Predict Costs** - Make predictions
3. **Model Comparison** - Compare model performance
4. **SHAP Visualizations** - Understand predictions
5. **About** - Project details

## ⚙️ Configuration Quick Reference

### Input Ranges (config.R)
```R
CONFIG$ranges$age       # Default: 18-64
CONFIG$ranges$bmi       # Default: 15-55
CONFIG$ranges$children  # Default: 0-5
```

### Categorical Values
```R
CONFIG$levels$sex       # "male", "female"
CONFIG$levels$smoker    # "yes", "no"
CONFIG$levels$region    # 4 US regions
```

### Logging
```R
CONFIG$logging$enabled  # TRUE/FALSE
CONFIG$logging$dir      # "logs"
```

## 🐛 Troubleshooting Quick Fixes

### Models Won't Load
```bash
# Check model files exist
ls -la models/
# Run health check
Rscript health_check.R
```

### Application Won't Start
```bash
# Check R packages
Rscript -e "source('health_check.R'); health_check()"
# Install missing packages
Rscript start_app.R
```

### Predictions Fail
```bash
# Check error logs
cat logs/errors.log | tail -20
# Verify input ranges in config.R
```

### Docker Issues
```bash
# Check container status
docker-compose ps
# View logs
docker-compose logs -f
# Restart
docker-compose restart
```

## 📈 Making Changes

### Adding a New Model
1. Train model and save to `models/`
2. Update `CONFIG$models` in `config.R`
3. Add loading logic in `R/model_loader.R`
4. Update UI in `app.R` to include new model
5. Test thoroughly

### Changing Validation Rules
1. Edit `utils/validators.R`
2. Update ranges in `config.R`
3. Test with edge cases
4. Update documentation if needed

### Adding New Features
1. Create new module in `R/` or `utils/`
2. Source in `app.R`
3. Add tests in `tests/`
4. Update documentation
5. Update version in `version.R`

## 🔐 Security Checklist

- [ ] Change default ports if needed
- [ ] Set up SSL/TLS for production
- [ ] Configure firewall rules
- [ ] Restrict log file access
- [ ] Use environment variables for secrets
- [ ] Keep packages updated
- [ ] Monitor logs regularly

## 📞 Quick Help

### Need Help?
- 📖 Read: `README.md` for detailed guide
- 🚀 Deploy: See `DEPLOYMENT.md`
- 🔧 Maintain: Check `MAINTENANCE.md`
- 🤝 Contribute: Read `CONTRIBUTING.md`
- 📊 Overview: View `SUMMARY.md`

### Contact
- **Email**: mikekay262@gmail.com
- **LinkedIn**: [Dr. Michael Adu](https://www.linkedin.com/in/drmichael-adu)
- **Issues**: [GitHub Issues](https://github.com/drmichaeladu/Advanced-Medical-Insurance-Cost-Prediction-Model/issues)

## ⚡ Quick Commands Reference

```bash
# Development
Rscript start_app.R              # Start app
Rscript health_check.R           # Check health
Rscript tests/test_application.R # Run tests

# Docker
docker-compose up -d             # Start
docker-compose logs -f           # View logs
docker-compose down              # Stop
docker-compose restart           # Restart

# Git
git status                       # Check status
git add .                        # Stage changes
git commit -m "message"          # Commit
git push                         # Push changes

# Logs
tail -f logs/predictions.log     # Watch predictions
tail -f logs/errors.log          # Watch errors
cat logs/*.log | grep ERROR      # Find errors
```

## 📋 Pre-Deployment Checklist

- [ ] Run health check: `Rscript health_check.R`
- [ ] Run tests: `Rscript tests/test_application.R`
- [ ] Update version in `version.R`
- [ ] Review and clean logs
- [ ] Test all features manually
- [ ] Backup current models
- [ ] Update documentation
- [ ] Review configuration settings
- [ ] Check security settings
- [ ] Plan rollback procedure

## 🎯 Performance Tips

1. **Model Loading**: Models load once at startup (not per request)
2. **Logging**: Disable logging in production if causing performance issues
3. **Docker**: Use production docker-compose config for resource limits
4. **Monitoring**: Use health checks sparingly (they consume resources)
5. **Logs**: Implement log rotation to prevent disk space issues

## 📚 Documentation Map

| Document | Read When... |
|----------|-------------|
| `README.md` | Setting up project first time |
| `QUICK_REFERENCE.md` | Need quick answers (this file) |
| `CONTRIBUTING.md` | Want to contribute code |
| `DEPLOYMENT.md` | Deploying to production |
| `MAINTENANCE.md` | Managing production system |
| `SUMMARY.md` | Understanding architecture changes |

## 🎓 Learning Path

1. **Day 1**: Read README, run health check, start app locally
2. **Day 2**: Explore code structure, read module files
3. **Day 3**: Make small config changes, test
4. **Day 4**: Deploy with Docker locally
5. **Day 5**: Deploy to cloud/production

## ✅ Daily Operations Checklist

### Morning
- [ ] Check application status
- [ ] Review overnight logs
- [ ] Verify model availability

### Weekly
- [ ] Archive old logs
- [ ] Review error patterns
- [ ] Check disk space
- [ ] Update packages

### Monthly
- [ ] Review model performance
- [ ] Update documentation
- [ ] Security updates
- [ ] Backup models

---

**Remember**: When in doubt, check `README.md` or run `health_check.R`!

**Version**: 2.0.0 | **Last Updated**: 2024-01-01
