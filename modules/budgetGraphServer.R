# Server functionality for the budget visualization graph module
budgetGraphServer <- function(id, stringsAsFactors, select_month)
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
      
      # Populate the Budgets output with enough plot outputs to store a plot for each budget
      observeEvent(select_month(),
                   {
                     # Populate the uiOutput with each of the budget graphs
                     output$budgets <- renderUI({
                       budget_table <- get_budget_table() %>%
                         filter(Date == get_current_month_as_date(select_month()))
                       # Create a plot output for each budget in the current month
                       plot_output_list <- lapply(unique(budget_table$Name), function(budget_name)
                       {
                         amount <- budget_table$Amount[budget_table$Name == budget_name][1]
                         total_spent <- budget_table$Total.Spent[budget_table$Name == budget_name][1]
                         monthly_remaining <- amount - total_spent
                         total_remaining <- budget_table$Remaining.Budget[budget_table$Name == budget_name][1]
                         plot_name <- clean_budget_plot_name(budget_name)
                         popify(plotOutput(ns(plot_name), height=25), budget_name,
                                HTML(str_interp(paste('Amount: ${label_dollar()(amount)}<br>',
                                                      'Total Spent: ${label_dollar()(total_spent)}<br>',
                                                      'Monthly Remaining: <span class="${get_ui_color_for_budget(monthly_remaining, amount, select_month())}">${label_dollar()(monthly_remaining)}</span><br>',
                                                      'Total Remaining: <span class="${get_ui_color_for_budget(total_remaining, amount, select_month())}">${label_dollar()(total_remaining)}</span>', sep=""))),
                                placement="right",
                                options=list(container="body"))
                       })
                       
                       # Necessary for plots to display properly
                       do.call(tagList, plot_output_list)
                     })
                     
                     # Grab the budgets for the currently selected month
                     budget_table <- get_budget_table() %>%
                       filter(Date == get_current_month_as_date(select_month()))
                     
                     # For each budget this month, create a plot that tracks the current progress
                     for (budget in unique(budget_table$Name))
                     {
                       local({
                         local_budget <- budget # need to store a local copy of this variable, otherwise bad things happen
                         plot_name <- clean_budget_plot_name(local_budget) # create the dynamic name of the plot
                         budget_data <- budget_table %>% filter(Name == local_budget)
                         output[[plot_name]] <- renderPlot({
                           ggplot(budget_data,
                                  aes(
                                    # if we spent more than the budget, cap the bar at the budgeted amount so it displays properly
                                    ifelse(any(budget_data$Total.Spent > budget_data$Amount), budget_data$Amount, budget_data$Total.Spent),
                                    str_pad(budget_data$Name, 20, side="right"),
                                    fill=budget_data$Name)) +
                             scale_fill_manual("legend", values = c(get_ui_color_for_budget(budget_data$Remaining.Budget[1], budget_data$Amount[1], select_month()))) +
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
                   }
      )
    }
  )
}