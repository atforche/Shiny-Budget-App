# Gets the UI elements for the cash flow module
cash_flow_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Output for the cash flow label
    span(textOutput(ns("cash_flow_label")), style="font-weight:bold;font-size:x-large"),
    
    # Select which metric to view
    selectInput(ns("cash_flow_type"), "Select Metric to View", 
                c("Net Income", "Additional Savings", "Change In Reserve Balance", "Change In Savings Balance")),
    
    # Plotly output to display the cash flow graph
    plotlyOutput(ns("cash_flow_graph"))
    
  ) #tagList
  
}

