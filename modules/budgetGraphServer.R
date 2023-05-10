# Server functionality for the budget visualization graph module
budget_graph_server <- function(id, select_month)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      # Create the namespace for the server module
      ns <- session$ns
      
      # Populate the Budgets text label
      output$budget_label <- renderText({
        "Budgets"
      })
      
      # Store whether the budget graphs have already been populated
      graphs_populated <- FALSE
      
      # Populate the Budgets output with enough plot outputs to store a plot for each budget
      observeEvent(select_month(),
                   {
                     # Grab the budgets for the currently selected month
                     budget_table <- get_budget_table() %>%
                       filter(Date == get_current_month_as_date(select_month()))
                     
                     # Populate the uiOutput with each of the budget graphs
                     output$budgets <- renderUI({
                       
                       # Create a plot output with popover for each budget in the current month
                       plot_output_list <- lapply(unique(budget_table$Name), function(budget_name)
                       {
                         # Calculate the different summary values
                         amount <- budget_table$Amount[budget_table$Name == budget_name][1]
                         total_debits <- budget_table$Total.Debits[budget_table$Name == budget_name][1]
                         total_credits <- budget_table$Total.Credits[budget_table$Name == budget_name][1]
                         monthly_remaining <- amount - total_debits
                         total_remaining <- budget_table$Remaining.Budget[budget_table$Name == budget_name][1]
                         
                         # Remove any existing popovers then create a new plotOutput with a popover
                         plot_name <- clean_plot_name(budget_name)
                         if (graphs_populated)
                         {
                           removePopover(session, ns(plot_name))
                         }
                         popify(plotOutput(ns(plot_name), height=25), 
                                budget_name,
                                HTML(str_interp(paste('Amount: ${label_dollar()(amount)}<br>',
                                                      'Total Debits: ${label_dollar()(total_debits)}<br>',
                                                      'Total Credits: ${label_dollar()(total_credits)}<br>',
                                                      'Monthly Remaining: <span class="${get_ui_color_for_budget(monthly_remaining, amount, budget_name, select_month())}">${label_dollar()(monthly_remaining)}</span><br>',
                                                      'Total Remaining: <span class="${get_ui_color_for_budget(total_remaining, amount, budget_name, select_month())}">${label_dollar()(total_remaining)}</span>', sep=""))),
                                placement="right",
                                options=list(container="body"))
                       })
                       
                       # Necessary for plots to display properly
                       do.call(tagList, plot_output_list)
                     }) #renderUI
                     
                     # After the plotOutputs are created, populate them with plots
                     for (budget in unique(budget_table$Name))
                     {
                       # Need a local context to prevent multithreaded variable thrashing
                       local({
                         local_budget_copy <- budget
                         plot_name <- clean_plot_name(local_budget_copy)
                         budget_data <- budget_table %>% filter(Name == local_budget_copy) %>% mutate(Monthly.Remaining = Amount - Total.Debits)
                         output[[plot_name]] <- renderPlot({
                           ggplot(budget_data,
                                  aes(
                                    # if we spent more than the budget, cap the bar at the budgeted amount so it displays properly
                                    ifelse(any(budget_data$Total.Debits > budget_data$Amount), budget_data$Amount, budget_data$Total.Debits),
                                    str_pad(budget_data$Name, 20, side="right"),
                                    fill=budget_data$Name)) +
                             scale_fill_manual("legend", values = c(get_ui_color_for_budget(min(budget_data$Remaining.Budget[1], budget_data$Monthly.Remaining[1]), budget_data$Amount[1], budget_data$Name[1], select_month()))) +
                             xlim(0, budget_data$Amount[1]) +
                             geom_bar(stat="identity") +
                             geom_vline(xintercept = budget_data$Amount[1] * get_progress_through_month(select_month())) + # place a horizontal line at our approximate progress through the month
                             theme(legend.position = "none",
                                   axis.title.x = element_blank(),
                                   axis.title.y = element_blank(),
                                   axis.text.x = element_blank(),
                                   axis.text.y = element_text(family="mono", size=14, face="bold"),
                                   axis.ticks.x = element_blank(),
                                   axis.ticks.y = element_blank())
                         })
                       })
                     }
                     
                     # Mark the initial graph populate as complete
                     graphs_populated <- TRUE
                   }
      )
    }
  )
}