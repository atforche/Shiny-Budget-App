# Gets the UI elements for the budget visualization graph module
budget_graph_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Output for the budgets section label
    span(textOutput(ns("budget_label")), style="font-weight:bold;font-size:x-large"),
    
    # Dynamic uiOutput to store individual graphs for each budget
    uiOutput(ns("budgets"))
  )
}