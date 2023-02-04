# Server functionality for the budget spending module
budget_spending_server <- function(id, select_range)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      
      # Reactive variable to store the first date that we care about
      first_date <- reactive({
        get_earliest_date_in_range(select_range())
      })
      
      # Reactive variable to store all the budget names that appear over the date range
      all_budget_names <- reactive({
        budget_table <- get_budget_table() %>%
          filter(Date >= first_date(),
                 Name != "Savings")
        unique(budget_table$Name)
      })
      
      # Reactive variable to store the budget data to be included in the graph
      budget_spending <- reactive({
        
        # Get the budget data
        budget_table <- get_budget_table() %>%
          filter(Date >= first_date(),
                 Name != "Savings") %>%
          mutate(Month = floor_date(Date, 'month'))
        
        # If the user hasn't selected "All", then filter to the given budget type
        if (input$select_budget != "All")
        {
          budget_table <- budget_table %>% 
            filter(Name == input$select_budget)
        }
        
        budget_table <- budget_table %>%
          group_by(Month) %>%
          summarize(Spending = sum(Total.Spent),
                    Budget = sum(Amount))
      })
      
      # Reactive variable to store the average budget spending to be displayed on the graph
      average_budget_spending <- reactive({
        
        # Calculate the average budget spending for every month except the current month
        average_spending <- budget_spending() %>%
          filter(!is_date_in_month(Month, as.Date(now())))
        average <- mean(average_spending$Spending)
      })
      
      # Populate the budget spending text label
      output$budget_spending_label <- renderText({
        "Budget Spending by Month"
      })
      
      # Update the select budget drop down with the correct budget names
      observeEvent(all_budget_names(),
                   updateSelectInput(session, "select_budget", "Select Budget to View", c("All", all_budget_names())))
      
      # Populate the budget_spending graph with the plot
      output$budget_spending_graph <- renderPlotly({
        ggplotly(
          ggplot(budget_spending(), aes(Month, Spending, 
                                        text=paste0("<span style='font-size:medium'>",
                                                    "<b>Month:</b> ", Month,
                                                    "<br><b>Total Spending:</b> ", label_dollar()(Spending),
                                                    "<br><b>Total Budgeted:</b> ", label_dollar()(Budget),
                                                    "<br><b>Difference:</b> <span style='color:", ifelse(Spending <= Budget,"green","red"), "'>", label_dollar()(Spending - Budget), "</span>",
                                                    "<br>",
                                                    "<br><b>Average Spending:</b> ", label_dollar()(average_budget_spending()),
                                                    "<br><b>Difference From Average:</b> <span style='color:", ifelse(Spending <= average_budget_spending(),"green","red"), "'>", label_dollar()(Spending - average_budget_spending()), "</span>",
                                                    "</span>"),
                                        fill=ifelse(Spending <= Budget, "positive", "negative")))
          + geom_col()
          + geom_hline(yintercept=average_budget_spending())
          + scale_y_continuous(labels=label_dollar())
          + scale_fill_manual(values=c("positive"="green2", "negative"="red2"))
          + theme(legend.position = "none",
                  axis.title.y = element_blank()),
          tooltip="text") %>%
          style(hoverlabel = list(bgcolor="white")) %>%
          layout(xaxis = list(fixedrange = TRUE), 
                 yaxis = list(fixedrange = TRUE),
                 hovermode="x")
      })
      
    }
  )
}