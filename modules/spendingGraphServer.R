# Server functionality for the Spending Graph module
spending_graph_server <- function(id, select_month)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      
      # Populate the Budgets text label
      output$spending_label <- renderText({
        "Spending"
      })
      
      # Update the UI when the selected month has changed
      observeEvent(select_month(),
         {
           # Grab the budgets for the currently selected month
           budget_table <- get_budget_table() %>%
             filter(Date == get_current_month_as_date(select_month()))
           
           updateSelectInput(session, "select_budget", "Select Budget", c("All", budget_table$Name))
         })
      
      # Populate the spending graph
      output$spending_graph <- renderPlotly({
        
        # Require that select_month have a valid value
        req(select_month())
        
        # Determine the date range we're plotting along
        start_month <- get_current_month_as_date(select_month())
        start_previous_month <- get_current_month_as_date(select_month()) %m-% months(1)
        end_month <- (start_month %m+% months(1)) - 1
        date_range <- seq(start_month, end_month, by="day")

        # Grab the transactions for the needed months
        transaction_table <- get_transaction_table() %>%
          filter(is_date_in_month(Date, start_month),
                 Category != "Savings")
        previous_transactions <- get_transaction_table() %>%
          filter(is_date_in_month(Date, start_previous_month),
                 Category != "Savings")
                
        # If the user selected a budget, only show that budget
        if (input$select_budget != "All") 
        {
          browser()
          transaction_table <- transaction_table %>%
            filter(Category == input$select_budget)
          previous_transactions <- previous_transactions %>%
            filter(Category == input$select_budget)
        }
        
        # Calculate the running totals
        transaction_table <- transaction_table %>%
          arrange(Date) %>%
          group_by(Date) %>%
          summarize(Amount = sum(Amount)) %>%
          mutate(Running.Total = cumsum(Amount))
        previous_transactions <- previous_transactions %>%
          mutate(Date = Date %m+% months(1)) %>%
          arrange(Date) %>%
          group_by(Date) %>%
          summarize(Amount = sum(Amount)) %>%
          mutate(Previous.Total = cumsum(Amount))
        
        # Fill in any missing dates
        for(date in date_range)
        {
          if (!(.Date(date) %in% transaction_table$Date))
          {
            transaction_table <- transaction_table %>% add_row(Date=.Date(date), Amount=NA, Running.Total=NA)
          }
          if (!(.Date(date) %in% previous_transactions$Date))
          {
            previous_transactions <- previous_transactions %>% add_row(Date=.Date(date), Amount=NA, Previous.Total=NA)
          }
        }
        
        # Ensure the first date has a value for the fill below
        if (is.na(transaction_table$Running.Total[transaction_table$Date == start_month]))
        {
          transaction_table$Running.Total[transaction_table$Date == start_month] <- 0
        }
        if (is.na(previous_transactions$Previous.Total[previous_transactions$Date == start_month]))
        {
          previous_transactions$Previous.Total[previous_transactions$Date == start_month] <- 0
        }
        
        # Sort and fill in any missing values with the previous days amount
        transaction_table <- transaction_table %>%
          arrange(Date) %>%
          fill(Running.Total, .direction="down") %>%
          mutate(Total.Spent = label_dollar()(Running.Total))
        previous_transactions <- previous_transactions %>%
          arrange(Date) %>%
          fill(Previous.Total, .direction="down") %>%
          mutate(Previous.Spent = label_dollar()(Previous.Total)) %>%
          select(Date, Previous.Total, Previous.Spent)
        
        # Join the previous months spending onto the current months
        transaction_table <- transaction_table %>%
          left_join(previous_transactions, by="Date") %>%
          mutate(Difference = ifelse(Date > as.Date(now()), NA, Running.Total - Previous.Total),
                 Running.Total=ifelse(Date > as.Date(now()), NA, Running.Total))

        # Populate the spending graph
        ggplotly(
          ggplot(transaction_table) +
            geom_area(aes(Date, Running.Total, text=paste0("Date: ", Date, "<br>This month: ", Total.Spent), group=TRUE), 
                      stat="identity", color="green4", fill="green4", alpha=0.4) +
            geom_line(aes(Date, Previous.Total, 
                          text=paste0("Last month: ", Previous.Spent, "<br>Difference: <span style='color:", ifelse(Difference > 0, "red", "green"), "'>", label_dollar()(Difference),"</span>"), group=TRUE), 
                      stat="identity", color="red4") +
            scale_y_continuous(labels=label_dollar()) +
            theme(legend.position = "none",
                  axis.title.y = element_blank()),
          tooltip="text") %>%
          layout(xaxis = list(fixedrange = TRUE), 
                 yaxis = list(fixedrange = TRUE),
                 hovermode="x unified")
      })
    }
  )
}