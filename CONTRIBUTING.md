# Contributing to Advanced Medical Insurance Cost Prediction Model

Thank you for your interest in contributing to this project! This document provides guidelines for contributions.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/Advanced-Medical-Insurance-Cost-Prediction-Model.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly
6. Commit your changes: `git commit -m "Add: your feature description"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## 📋 Code Style Guidelines

### R Code Style
- Follow the [Tidyverse Style Guide](https://style.tidyverse.org/)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and single-purpose
- Maximum line length: 100 characters

### File Organization
- Place model-related functions in `R/` directory
- Place utility functions in `utils/` directory
- Place tests in `tests/` directory
- Update `config.R` for any new configuration options

### Function Documentation
Use Roxygen-style comments for all functions:
```R
#' Brief description of function
#' @param param1 Description of parameter 1
#' @param param2 Description of parameter 2
#' @return Description of return value
#' @examples
#' example_function(param1 = "value", param2 = 10)
function_name <- function(param1, param2) {
  # Implementation
}
```

## 🧪 Testing

Before submitting a Pull Request:

1. **Test your code:**
   ```R
   source("tests/test_application.R")
   ```

2. **Test the application:**
   ```R
   shiny::runApp("app.R")
   ```

3. **Verify all features work:**
   - Test predictions with all models
   - Verify SHAP visualizations
   - Check model comparison charts
   - Test input validation
   - Check error handling

## 📝 Commit Messages

Use clear and descriptive commit messages:

- `Add:` for new features
- `Fix:` for bug fixes
- `Update:` for changes to existing features
- `Refactor:` for code restructuring
- `Docs:` for documentation changes
- `Test:` for test additions or changes

Examples:
```
Add: SHAP waterfall plot for individual predictions
Fix: XGBoost preprocessing handling missing features
Update: Model comparison visualization colors
Docs: Add usage examples to README
```

## 🔍 Pull Request Guidelines

### Before Submitting
- [ ] Code follows the style guidelines
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No debugging code or console.log statements
- [ ] New functions have documentation
- [ ] Configuration changes are documented

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe how you tested your changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

## 🐛 Reporting Bugs

When reporting bugs, please include:

1. **Description:** Clear description of the bug
2. **Steps to Reproduce:** Detailed steps
3. **Expected Behavior:** What should happen
4. **Actual Behavior:** What actually happens
5. **Environment:**
   - R version
   - Package versions
   - Operating system
6. **Screenshots:** If applicable
7. **Error Messages:** Full error messages or logs

## 💡 Feature Requests

When requesting features:

1. **Use Case:** Describe the problem you're trying to solve
2. **Proposed Solution:** Your suggested approach
3. **Alternatives:** Other solutions you've considered
4. **Additional Context:** Any other relevant information

## 🔒 Security

If you discover a security vulnerability:

1. **Do NOT** open a public issue
2. Email the maintainer directly: mikekay262@gmail.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## 📚 Development Setup

### Required Tools
- R >= 4.0.0
- RStudio (recommended)
- Git

### Installation
```bash
# Clone repository
git clone https://github.com/drmichaeladu/Advanced-Medical-Insurance-Cost-Prediction-Model.git
cd Advanced-Medical-Insurance-Cost-Prediction-Model

# Install dependencies in R
Rscript -e "install.packages(c('shiny', 'shinydashboard', 'shinyWidgets', 'ggplot2', 'randomForest', 'xgboost', 'caret', 'DALEX', 'DALEXtra', 'plotly', 'dplyr'), dependencies = TRUE)"
```

## 🎯 Areas for Contribution

We welcome contributions in these areas:

### High Priority
- [ ] Add unit tests for all functions
- [ ] Implement batch prediction from CSV
- [ ] Add model performance monitoring dashboard
- [ ] Create Docker container for deployment
- [ ] Add CI/CD pipeline

### Medium Priority
- [ ] Add more visualization options
- [ ] Implement model versioning system
- [ ] Add data upload functionality
- [ ] Create API endpoint for predictions
- [ ] Add internationalization (i18n)

### Documentation
- [ ] Add more usage examples
- [ ] Create video tutorial
- [ ] Add troubleshooting guide
- [ ] Document deployment options
- [ ] Add API documentation

## 📞 Questions?

If you have questions:

1. Check existing issues and discussions
2. Read the README.md thoroughly
3. Contact the maintainer: mikekay262@gmail.com
4. LinkedIn: [Dr. Michael Adu](https://www.linkedin.com/in/drmichael-adu)

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## 🙏 Thank You!

Your contributions make this project better for everyone. We appreciate your time and effort!
