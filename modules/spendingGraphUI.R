# Gets the UI elements for the summary module
spending_graph_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Output for the budgets section label
    span(textOutput(ns("spending_label")), style="font-weight:bold;font-size:x-large"),
    
    # Select which budget to view spending for, values will be populated by the summary server
    selectInput(ns("select_budget"), "Select Budget", ""),
    
    # Plot output to display spending graph
    plotlyOutput(ns("spending_graph"), height=375)
    
  ) #tagList
}

