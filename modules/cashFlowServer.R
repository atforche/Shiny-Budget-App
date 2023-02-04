# Server functionality for the Cash Flow module
cash_flow_server <- function(id, select_range)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      # Populate the cash flow text label
      output$cash_flow_label <- renderText({
        first_date()
        "Cash Flow by Month"
      })
      
      # Reactive variable to store the first date that we care about
      first_date <- reactive({
        
        # If the selected range is All Time, just return the origin date
        if (select_range() == "All Time")
        {
          return(.Date(0))
        }
        
        date <- as.Date(now())
        if (select_range() == "Past Six Months")
        {
          date <- date %m-% months(6)
        }
        else if (select_range() == "Past Year")
        {
          date <- date %m-% months(12) 
        }
        
        # Get the first date of that month
        floor_date(date, 'month')
      })
      
      # Reactive variable to store the net income across the months in the given range
      net_income <- reactive({
        
        # Get our transactions over the date range and summarize our spending by month
        transactions <- get_transaction_table() %>%
          filter(Date >= first_date(),
                 Category != 'Savings') %>%
          mutate(Month = floor_date(Date, 'month')) %>%
          group_by(Month) %>%
          summarize(Expenses = sum(Amount, na.rm=TRUE))
        transactions[is.na(transactions)] <- 0
          
        # Get our income over the date range and summarize our income by month 
        income <- get_income_table() %>%
          filter(Date >= first_date()) %>%
          mutate(Month = floor_date(Date, 'month')) %>%
          group_by(Month) %>%
          summarize(Income = sum(Amount, na.rm=TRUE))
        income[is.na(income)] <- 0
        
        # Join the two tables together
        nets <- transactions %>% 
          left_join(income, by="Month")
        nets[is.na(nets)] <- 0
        
        # Calculate the net income
        nets <- nets %>%
          mutate(Value = Income - Expenses)
      })
      
      # Reactive variable to store the average net income across the months in the given range
      average_net_income <- reactive({
        
        # Calculate the average Net Income for every month except the current month
        average_nets <- net_income() %>%
          filter(!is_date_in_month(Month, as.Date(now())))
        average <- mean(average_nets$Value)
      })
      
      # Reactive variable to store the actual savings across multiple months in a given range
      actual_savings <- reactive({
        
        # Get the transactions over the date range
        transaction_table <- get_transaction_table() %>%
          filter(Date >= first_date(),
                 Category == "Savings") %>%
          mutate(Month = floor_date(Date, 'month')) %>%
          group_by(Month) %>%
          summarize(Value = sum(Amount))
      })
      
      # Reactive variable to store the average actual savings across the months in the given range
      average_actual_savings <- reactive({
        
        # Calculate the average actual savings for every month except the current month
        average_savings <- actual_savings() %>%
          filter(!is_date_in_month(Month, as.Date(now())))
        average <- mean(average_savings$Value)
      })
      
      # Reactive variable to store the change in reserve balance across the months in the given range
      change_in_reserve_balance <- reactive({
        budget_table <- get_budget_table() %>%
          filter(Date >= first_date(),
                 Type == "Rolling") %>%
          mutate(Month = floor_date(Date, 'month'),
                 Monthly.Change = Amount - Total.Spent) %>%
          group_by(Month) %>%
          summarize(Value = sum(Monthly.Change))
      })
      
      # Reactive variable to store the average change in reserve balance across the months in the given range
      average_change_in_reserve_balance <- reactive({
        
        # Calculate the average change in reserve balance for every month except the current month
        average_change <- change_in_reserve_balance() %>%
          filter(!is_date_in_month(Month, as.Date(now())))
        average <- mean(average_change$Value)
      })
      
      # Reactive variable to store the graph data that should appear based on the users selection
      graph_values <- reactive({
        if (input$cash_flow_type == "Net Income")
        {
          return(net_income())
        }
        else if (input$cash_flow_type == "Actual Savings")
        {
          return(actual_savings())
        }
        else if (input$cash_flow_type == "Change In Reserve Balance")
        {
          return(change_in_reserve_balance())
        }
      })
      
      # Reactive variable to store the average value that should appear based on the user's selection
      average_value <- reactive({
        if (input$cash_flow_type == "Net Income")
        {
          return(average_net_income())
        }
        else if (input$cash_flow_type == "Actual Savings")
        {
          return(average_actual_savings())
        }
        else if (input$cash_flow_type == "Change In Reserve Balance")
        {
          return(average_change_in_reserve_balance())
        }
      })
      
      # Populate the cash flow graph with the plot
      output$cash_flow_graph <- renderPlotly({
        ggplotly(
          ggplot(graph_values(), aes(Month, Value, 
                                   text=paste0("Month: ", Month, 
                                               "<br>", input$cash_flow_type, ": <span style='color:", ifelse(Value > 0,"green","red"), "'>", label_dollar()(Value), "</span>",
                                               "<br>Average: ", label_dollar()(average_value()),
                                               "<br>Difference: <span style='color:", ifelse(Value > average_value(),"green","red"), "'>", label_dollar()(Value - average_value()), "</span>"), 
                                   fill=ifelse(Value > 0, "positive", "negative")))
          + geom_col()
          + geom_hline(yintercept=average_value())
          + scale_y_continuous(labels=label_dollar())
          + scale_fill_manual(values=c("positive"="green2", "negative"="red2"))
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