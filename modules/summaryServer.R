# Server functionality for the Summary module
summary_server <- function(id, trends_or_summary)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      # Create the namespace for the server module
      ns <- session$ns
      
      # Reactive output variable to determine whether the Summary UI should be visible
      output$is_summary_visible <- reactive({
        trends_or_summary() == "Summary"
      })
      outputOptions(output, "is_summary_visible", suspendWhenHidden = FALSE)
      
      # Reactive variable that stores a list of the available months
      available_months <- reactive({
        all_sheets <- get_worksheet_names()
        all_sheets[is_data_sheet(all_sheets)]
      })

      # Update the UI with the list of available months
      observeEvent(trends_or_summary(),
                   {
                     if (trends_or_summary() == "Summary")
                     {
                       updateSelectInput(session, "select_month", "Select Month", available_months())
                     }
                   })
      
      # Invoke the budget graph server logic
      budget_graph_server("budget_graph", reactive(input$select_month))
      
      # Invoke the spending graph server logic
      spending_graph_server("spending_graph", reactive(input$select_month))
    }
  )
}