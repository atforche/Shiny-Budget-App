# Gets the UI elements for the summary module
summaryUI <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    # Conditional UI elements that only appear if viewing Summaries
    conditionalPanel(

      # Only display these UI elements if
      condition = 'true',#"input['trend_or_summary'] == 'Summary'",

      # Set the namespace for this panel
      ns = ns,

       # Select which month to view, values will be populated by the server
      selectInput(ns("select_month"), "Select Month", ""),
      
      # Ui components for the budget graph UI
      budgetGraphUI(ns("budget_graph"))
    ) # conditionalPanel
  )
}

