# Gets the UI elements for the debt history module
debt_history_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Output for the debt history label
    span(textOutput(ns("debt_history_label")), style="font-weight:bold;font-size:x-large"),
    
    # Select which debt to view, choices will be populated by server
    selectInput(ns("select_debt"), "Select Debt to View", c()),
    
    # Plotly output to display the debt history graph
    plotlyOutput(ns("debt_history_graph"))
    
  ) #tagList
  
}

