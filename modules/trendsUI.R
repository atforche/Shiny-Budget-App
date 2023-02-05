# Gets the UI elements for the trends module
trends_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Conditional UI elements that only appear if viewing Summaries
    conditionalPanel(
      
      # Only display these UI elements if the user has not selected the summary view
      condition = "output.is_trends_visible",
      
      # Set the namespace for this panel
      ns = ns,
      
      # Select which range of months to view
      selectInput(ns("select_range"), "Select Date Range", 
                  c("Past Six Months", "Past Year", "All Time")),
      
      # First Row
      fluidRow(
        
        # First half of row
        column(6,
               
          # UI components for the cash flow graph
          cash_flow_ui(ns("cash_flow"))
               
        ), # column
        
        # Second half or row
        column(6,
         
          # UI components for the budget spending graph
          budget_spending_ui(ns("budget_spending"))
                     
        ),
        
        style="padding-top:10px"),
      
      # Second Row
      fluidRow(
        
        # First half of row
        column(6,
               
               # UI components for the balance history graph
               balance_history_ui(ns("balance_history"))
               
        ), # column
        
        style="padding-top:10px")
      
    ) # conditionalPanel
    
  ) #tagList
  
}

