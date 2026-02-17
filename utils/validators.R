# Input validation utilities for production safety

#' Validate age input
#' @param age Numeric age value
#' @return List with valid (TRUE/FALSE) and message
validate_age <- function(age) {
  if (is.na(age) || is.null(age)) {
    return(list(valid = FALSE, message = "Age cannot be empty"))
  }
  
  if (!is.numeric(age)) {
    return(list(valid = FALSE, message = "Age must be a number"))
  }
  
  min_age <- CONFIG$ranges$age[1]
  max_age <- CONFIG$ranges$age[2]
  
  if (age < min_age || age > max_age) {
    return(list(
      valid = FALSE, 
      message = sprintf("Age must be between %d and %d", min_age, max_age)
    ))
  }
  
  return(list(valid = TRUE, message = ""))
}

#' Validate BMI input
#' @param bmi Numeric BMI value
#' @return List with valid (TRUE/FALSE) and message
validate_bmi <- function(bmi) {
  if (is.na(bmi) || is.null(bmi)) {
    return(list(valid = FALSE, message = "BMI cannot be empty"))
  }
  
  if (!is.numeric(bmi)) {
    return(list(valid = FALSE, message = "BMI must be a number"))
  }
  
  min_bmi <- CONFIG$ranges$bmi[1]
  max_bmi <- CONFIG$ranges$bmi[2]
  
  if (bmi < min_bmi || bmi > max_bmi) {
    return(list(
      valid = FALSE, 
      message = sprintf("BMI must be between %d and %d", min_bmi, max_bmi)
    ))
  }
  
  return(list(valid = TRUE, message = ""))
}

#' Validate children input
#' @param children Numeric children count
#' @return List with valid (TRUE/FALSE) and message
validate_children <- function(children) {
  if (is.na(children) || is.null(children)) {
    return(list(valid = FALSE, message = "Number of children cannot be empty"))
  }
  
  if (!is.numeric(children)) {
    return(list(valid = FALSE, message = "Number of children must be a number"))
  }
  
  min_children <- CONFIG$ranges$children[1]
  max_children <- CONFIG$ranges$children[2]
  
  if (children < min_children || children > max_children) {
    return(list(
      valid = FALSE, 
      message = sprintf("Number of children must be between %d and %d", min_children, max_children)
    ))
  }
  
  return(list(valid = TRUE, message = ""))
}

#' Validate categorical input
#' @param value Input value
#' @param allowed_values Vector of allowed values
#' @param field_name Name of the field for error messages
#' @return List with valid (TRUE/FALSE) and message
validate_categorical <- function(value, allowed_values, field_name) {
  if (is.na(value) || is.null(value) || value == "") {
    return(list(valid = FALSE, message = sprintf("%s cannot be empty", field_name)))
  }
  
  if (!(value %in% allowed_values)) {
    return(list(
      valid = FALSE, 
      message = sprintf("%s must be one of: %s", field_name, paste(allowed_values, collapse = ", "))
    ))
  }
  
  return(list(valid = TRUE, message = ""))
}

#' Validate all user inputs
#' @param input_data Data frame with user inputs
#' @return List with valid (TRUE/FALSE) and messages vector
validate_input_data <- function(input_data) {
  messages <- c()
  
  # Validate age
  age_result <- validate_age(input_data$age)
  if (!age_result$valid) {
    messages <- c(messages, age_result$message)
  }
  
  # Validate BMI
  bmi_result <- validate_bmi(input_data$bmi)
  if (!bmi_result$valid) {
    messages <- c(messages, bmi_result$message)
  }
  
  # Validate children
  children_result <- validate_children(input_data$children)
  if (!children_result$valid) {
    messages <- c(messages, children_result$message)
  }
  
  # Validate sex
  sex_result <- validate_categorical(input_data$sex, CONFIG$levels$sex, "Sex")
  if (!sex_result$valid) {
    messages <- c(messages, sex_result$message)
  }
  
  # Validate smoker
  smoker_result <- validate_categorical(input_data$smoker, CONFIG$levels$smoker, "Smoker")
  if (!smoker_result$valid) {
    messages <- c(messages, smoker_result$message)
  }
  
  # Validate region
  region_result <- validate_categorical(input_data$region, CONFIG$levels$region, "Region")
  if (!region_result$valid) {
    messages <- c(messages, region_result$message)
  }
  
  if (length(messages) > 0) {
    return(list(valid = FALSE, messages = messages))
  }
  
  return(list(valid = TRUE, messages = c()))
}
