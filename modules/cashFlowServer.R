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
        
        nets <- nets %>%
          mutate(Net.Income = Income - Expenses)
      })
      
      # Reactive variable to store the average net income across the months in the given range
      average_net_income <- reactive({
        
        # Calculate the average Net Income for every month except the current month
        average_nets <- net_income() %>%
          filter(!is_date_in_month(Month, as.Date(now())))
        average <- mean(average_nets$Net.Income)
      })
      
      # Populate the cash flow graph with the plot
      output$cash_flow_graph <- renderPlotly({
        ggplotly(
          ggplot(net_income(), aes(Month, Net.Income, 
                                   text=paste0("Month: ", Month, 
                                               "<br>Net Income: <span style='color:", ifelse(Net.Income > 0,"green","red"), "'>", label_dollar()(Net.Income), "</span>",
                                               "<br>Average: ", label_dollar()(average_net_income()),
                                               "<br>Difference: <span style='color:", ifelse(Net.Income > average_net_income(),"green","red"), "'>", label_dollar()(Net.Income - average_net_income()), "</span>"), 
                                   fill=ifelse(Net.Income > 0, "positive", "negative")))
          + geom_col()
          + geom_hline(yintercept=average_net_income())
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