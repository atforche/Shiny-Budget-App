# Gets the UI elements for the budget visualization graph module
budgetGraphUI <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    # Display a label for the budgets section
    span(textOutput(ns("budget_label")), style="font-weight:bold;font-size:large"),
    
    # View current progress towards budgets
    uiOutput(ns("budgets"))
  )
}