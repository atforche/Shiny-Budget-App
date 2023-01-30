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
        
        # Entire row
        column(12,
               
           # Ui components for the monthly summary UI
           monthly_summary_ui(ns("monthly_summary"))   
           
        ), # column
        
      style="padding-top:10px"),
      
      # Second Row
      fluidRow(
        
        # First half of row
        column(6,
           # Ui components for the budget graph UI
           budget_graph_ui(ns("budget_graph"))
        ), # column
        
        # Second half of row
        column(6,
           # Ui components for the spending graph UI
          spending_graph_ui(ns("spending_graph"))       
        ), # column
        
      style="padding-top:10px") # fluidRow
    ) # conditionalPanel
  ) #tagList
}

