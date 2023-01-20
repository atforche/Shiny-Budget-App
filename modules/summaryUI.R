# Gets the UI elements for the summary module
summary_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Conditional UI elements that only appear if viewing Summaries
    conditionalPanel(

      # Only display these UI elements if the user has selected Summary
      condition = "output.is_summary_visible",

      # Set the namespace for this panel
      ns = ns,
      
      # Select which month to view, values will be populated by the summary server
      selectInput(ns("select_month"), "Select Month", ""),
      
      # First Row
      fluidRow(
        
        # First half of row
        column(6,
               
           # Ui components for the budget graph UI
           budget_graph_ui(ns("budget_graph"))
           
        ) # column
      ) # fluidRow
    ) # conditionalPanel
  ) #tagList
}

