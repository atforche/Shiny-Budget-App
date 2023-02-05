# Gets the UI elements for the balance history module
balance_history_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Output for the cash flow label
    span(textOutput(ns("balance_history_label")), style="font-weight:bold;font-size:x-large"),
    
    # Select which balance to view
    selectInput(ns("select_balance"), "Select Balance to View", 
                c("Total Assets", "Retirement Balance", "Total Cash", "Spending Balance", "Reserve Balance", "Safety Net Balance", "Savings Balance")),
    
    # Plotly output to display the balance history graph
    plotlyOutput(ns("balance_history_graph"))
    
  ) #tagList
  
}

