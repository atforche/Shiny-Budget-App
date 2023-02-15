# Server functionality for the Debt History module
debt_history_server <- function(id, select_range)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      # Populate the balance history text label
      output$debt_history_label <- renderText({
        "Debt History"
      })
      
      # Reactive variable to store the first date that we care about
      first_date <- reactive({
        get_earliest_date_in_range(select_range())
      })
      
      # Reactive variable to store all the balances across the months in the given range
      balances <- reactive({
        balances <- get_account_balance_table() %>%
          filter(Date >= first_date())
      })
      
      # Reactive variable to store all the debt balances across the months in the given range
      debt_balances <- reactive({
        debts <- balances() %>%
          filter(Category == "Loan")
      })
      
      # Reactive variable to store all the debt names that appear over the date range
      all_debt_names <- reactive({
        unique(debt_balances()$Name)
      })
      
      # Reactive variable to store all the total debt balance across the months in the given range
      total_debt_balances <- reactive({
        balances <- debt_balances() %>%
          group_by(Date) %>%
          summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
          rename("Debt.Balance" = "Balance")
      })
      
      # Reactive variable to store all the cash balances across the months in the given range
      cash_balances <- reactive({
        cash <- balances() %>%
          filter(Category %in% c("Spending", "Reserve", "Safety Net", "Savings")) %>%
          group_by(Date) %>%
          summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
          rename("Cash.Balance" = "Balance")
      })
      
      # Reactive variable to store all the total asset balances across the months in the given range
      total_asset_balances <- reactive({
        assets <- balances() %>%
          filter(Category  != "Loan") %>%
          group_by(Date) %>%
          summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
          rename("Asset.Balance" = "Balance")
      })
      
      # Update the select input with all the debt names across the date range
      observeEvent(all_debt_names(),
                   updateSelectInput(session, "select_debt", "Select Debt to View", c("All", all_debt_names(), "Net Cash vs. Debts", "Net Assets vs. Debts")))
    
      # Reactive variable to store the data that should appear in the graph
      graph_values <- reactive({
        
        # Require that the select debt input has a valid value
        req(input$select_debt)
        
        if (input$select_debt == "All")
        {
          balances <- total_debt_balances()
        }
        else if (input$select_debt == "Net Cash vs. Debts")
        {
          balances <- total_debt_balances() %>%
            left_join(cash_balances(), by="Date") %>%
            mutate(Difference = Cash.Balance - Debt.Balance)
          print(balances)
        }
        else if (input$select_debt == "Net Assets vs. Debts")
        {
          balances <- total_debt_balances() %>%
            left_join(total_asset_balances(), by="Date") %>%
            mutate(Difference = Asset.Balance - Debt.Balance)
          print(balances)
        }
        else
        {
          balances <- debt_balances() %>%
            filter(Name == input$select_debt) %>%
            group_by(Date) %>%
            summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
            rename("Spending.Balance" = "Balance")
        }
        names(balances)[ncol(balances)] <- "Value"
        return(balances)
      })

      # Populate the debt history graph with the plot
      output$debt_history_graph <- renderPlotly({
        ggplotly(
          ggplot(graph_values(), aes(Date, Value,
                                     text=paste0("Date: ", Date,
                                                 "<br>", input$select_balance, ": ", label_dollar()(Value))))
          + geom_line(aes(group=1))
          + geom_hline(yintercept=0, linewidth=0.1)
          + scale_y_continuous(expand = c(0, 0), limits = c(min(0, min(graph_values()$Value) * 1.10), max(0, max(graph_values()$Value) * 1.10)), labels=label_dollar())
          + theme(legend.position = "none",
                  axis.title.y = element_blank()),
          tooltip="text") %>%
          layout(xaxis = list(fixedrange = TRUE),
                 yaxis = list(fixedrange = TRUE),
                 hovermode="x unified")
      })
    }
  )
}