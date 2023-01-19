# Server functionality for the Summary module
summaryServer <- function(id, stringsAsFactors, trends_or_summary)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      # Create the namespace for the server module
      ns <- session$ns
      
      # Reactive variable that stores a list of the available months
      available_months <- reactive({
        all_sheets <- get_worksheet_names()
        all_sheets[is_data_sheet(all_sheets)]
      })

      # Update the UI with the list of available months
      observeEvent(trends_or_summary(),
                   {
                     print(trends_or_summary())
                     if (trends_or_summary() == "Summary")
                     {
                       updateSelectInput(session, "select_month", "Select Month", available_months())
                     }
                   })
      
      # Invoke the budget graph server logic
      budgetGraphServer("budget_graph", FALSE, reactive(input$select_month))
    }
  )
}