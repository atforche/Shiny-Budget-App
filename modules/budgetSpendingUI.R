# Gets the UI elements for the budget spending module
budget_spending_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Output for the budget spending label
    span(textOutput(ns("budget_spending_label")), style="font-weight:bold;font-size:x-large"),
    
    # Select which budget to view spending for (populated by server)
    selectInput(ns("select_budget"), "Select Budget to View", ""),
    
    # Plotly output to display the budget spending graph
    plotlyOutput(ns("budget_spending_graph"))

  ) #tagList
  
}

