# Server functionality for the Balance History module
balance_history_server <- function(id, select_range)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      # Populate the balance history text label
      output$balance_history_label <- renderText({
        "Balance History"
      })
      
      # Reactive variable to store the first date that we care about
      first_date <- reactive({
        get_earliest_date_in_range(select_range())
      })
      
      # Reactive variable to store all the balances across the months in the given range
      balances <- reactive({
        account_balances <- get_account_balance_table() %>%
          filter(Date >= first_date())
      })
      
      # Reactive variable to store the retirement asset balances across the months in the given range
      retirement_balances <- reactive({
        retirement <- balances() %>%  
          filter(Category == "Retirement") %>%
          group_by(Date) %>%
          summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
          rename("Retirement.Balance" = "Balance")
      })
      
      # Reactive variable to store the spending cash balances across the months in the given range
      spending_balances <- reactive({
        spending <- balances() %>%
          filter(Category == "Spending") %>%
          group_by(Date) %>%
          summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
          rename("Spending.Balance" = "Balance")
      })
      
      # Reactive variable to store the reserve cash balances across the months in the given range
      reserve_balances <- reactive({
        reserve <- balances() %>%
          filter(Category == "Reserve") %>%
          group_by(Date) %>%
          summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
          rename("Reserve.Balance" = "Balance")
      })
      
      # Reactive variable to store the safety net balances across the months in the given range
      safety_net_balances <- reactive({
        safety_net <- balances() %>%
          filter(Category == "Safety Net") %>%
          group_by(Date) %>%
          summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
          rename("Safety.Net.Balance" = "Balance")
      })
      
      # Reactive variable to store the savings balances across the months in the given range
      savings_balances <- reactive({
        savings <- balances() %>%
          filter(Category == "Savings") %>%
          group_by(Date) %>%
          summarize(Balance = sum(Balance, na.rm=TRUE)) %>%
          rename("Savings.Balance" = "Balance")
      })
      
      # Reactive variable to store the total cash balances across the months in the given range
      total_cash_balances <- reactive({
        cash_balances <- spending_balances() %>%
          left_join(reserve_balances(), by="Date") %>%
          left_join(safety_net_balances(), by="Date") %>%
          left_join(savings_balances(), by="Date") %>%
          mutate(Total.Cash.Balance = Spending.Balance + Reserve.Balance + Safety.Net.Balance + Savings.Balance)
      })
      
      # Reactive variable to store the total asset balances across the months in the given range
      total_asset_balances <- reactive({
        asset_balances <- total_cash_balances() %>%
          left_join(retirement_balances(), by="Date") %>%
          mutate(Total.Asset.Balance = Total.Cash.Balance + Retirement.Balance)
      })
      
      # Reactive variable to store the data that should appear in the graph
      graph_values <- reactive({
        if (input$select_balance == "Total Assets")
        {
          balances <- total_asset_balances()
        }
        else if (input$select_balance == "Retirement Balance")
        {
          balances <- retirement_balances()
        }
        else if (input$select_balance == "Total Cash")
        {
          balances <- total_cash_balances()
        }
        else if (input$select_balance == "Spending Balance")
        {
          balances <- spending_balances()
        }
        else if (input$select_balance == "Reserve Balance")
        {
          balances <- reserve_balances()
        }
        else if (input$select_balance == "Safety Net Balance")
        {
          balances <- safety_net_balances()
        }
        else if (input$select_balance == "Savings Balance")
        {
          balances <- savings_balances()
        }
        names(balances)[ncol(balances)] <- "Value"
        return(balances)
      })
      
      # Populate the balance history graph with the plot
      output$balance_history_graph <- renderPlotly({
        ggplotly(
          ggplot(graph_values(), aes(Date, Value,
                                     text=paste0("Date: ", Date,
                                                 "<br>", input$select_balance, ": ", label_dollar()(Value))))
          + geom_line(aes(group=1))
          + scale_y_continuous(expand = c(0, 0), limits = c(0, max(graph_values()$Value) * 1.10), labels=label_dollar())
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