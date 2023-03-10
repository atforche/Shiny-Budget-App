# Server functionality for the Trends module
trends_server <- function(id, trends_or_summary)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      # Reactive output variable to determine whether the Summary UI should be visible
      output$is_trends_visible <- reactive({
        trends_or_summary() == "Trends"
      })
      outputOptions(output, "is_trends_visible", suspendWhenHidden = FALSE)
      
      # Invoke the cash flow server logic
      cash_flow_server("cash_flow", reactive(input$select_range))
      
      # Invoke the budget spending server logic
      budget_spending_server("budget_spending", reactive(input$select_range))
      
      # Invoke the balance history server logic
      balance_history_server("balance_history", reactive(input$select_range))
      
      # Invoke the debt history server logic
      debt_history_server("debt_history", reactive(input$select_range))
    }
  )
}