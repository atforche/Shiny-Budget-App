# Server functionality for the Spending Graph module
monthly_summary_server <- function(id, select_month)
{
  # Instantiate the server logic for this module
  moduleServer(
    id,
    function(input, output, session)
    {
      # Create the namespace for the server module
      ns <- session$ns
      
      # Reactive variable to store the months total income
      total_income <- reactive({
        income_table <- get_income_table() %>%
          filter(is_date_in_month(Date, get_current_month_as_date(select_month())))
        sum(income_table$Amount)
      })
      
      # Reactive variable to store the months total expenses
      total_expenses <- reactive({
        transaction_table <- get_transaction_table() %>%
          filter(is_date_in_month(Date, get_current_month_as_date(select_month())),
                 Category != 'Savings')
        sum(transaction_table$Amount)
      })
      
      # Reactive variable to store the months net income
      net_income <- reactive({
        total_income() - total_expenses()
      })
      
      # Reactive variable to store the months additional savings
      additional_savings <- reactive({
      
        budget_table <- get_budget_table() %>%
          filter(is_date_in_month(Date, get_current_month_as_date(select_month())))
        income_table <- get_income_table() %>%
          filter(is_date_in_month(Date, get_current_month_as_date(select_month())))
        
        # Get how much we saved on fixed monthly budgets
        non_running_budget_table <- budget_table %>%
          filter(Type == 'Fixed') %>%
          mutate(Monthly.Savings = Amount - Total.Spent)
        
        # Get how much income we had compared to what we had budgeted
        total_budgeted_income <- sum(budget_table$Amount)
        total_actual_income <- sum(income_table$Amount)
        
        sum(non_running_budget_table$Monthly.Savings) + (total_actual_income - total_budgeted_income)
      })
      
      # Reactive variable to store the most recent set of each account balance
      balances <- reactive({
        
        # Require that a month has been selected
        req(select_month())
        
        current_month_start <- get_current_month_as_date(select_month())
        current_month_end <- (current_month_start %m+% months(1)) - 1
        account_balances <- get_account_balance_table()
        
        # Find the last Monday that occurred, either from the end of the month
        # or the current date if we're in the month
        most_recent_monday <- floor_date(min(as.Date(now()), current_month_end), "week", 1)
        
        # If there's no balances entered for the most recent Monday, then search another Monday
        while (sum(account_balances$Date == most_recent_monday) == 0)
        {
          most_recent_monday <- most_recent_monday - 7 
        }
        
        # Find the set of balances that 
        account_balances <- account_balances %>%
          filter(Date == most_recent_monday)
      })
      
      # Reactive variable to store the most recent amount of retirement assets for this month
      retirement_assets <- reactive({
        req(balances())
        account_balances <- balances() %>% filter(Category == "Retirement")
        sum(account_balances$Balance)
      })
      
      # Reactive variable to store the most recent amount of spending cash for this month
      spending_cash <- reactive({
        account_balances <- balances() %>% filter(Category == "Spending")
        sum(account_balances$Balance)
      })
      
      # Reactive variable to store the most recent amount of reserve cash for this month
      reserve_cash <- reactive({
        account_balances <- balances() %>% filter(Category == "Reserve")
        sum(account_balances$Balance)
      })
      
      # Reactive variable to store the expected amount of reserve cash at for this month
      expected_reserve_cash <- reactive({
        base_reserve_balance <- 5000
        budget_table <- get_budget_table() %>%
          filter(is_date_in_month(Date, get_current_month_as_date(select_month())),
                 Type == "Rolling")
        
        base_reserve_balance + sum(budget_table$Remaining.Budget)
      })
      
      # Reactive variable to store the most recent amount of safety net cash for this month
      safety_net_cash <- reactive({
        account_balances <- balances() %>% filter(Category == "Safety Net")
        sum(account_balances$Balance)
      })
      
      # Reactive variable to store the most recent amount of savings cash for this month
      savings_cash <- reactive({
        account_balances <- balances() %>% filter(Category == "Savings")
        sum(account_balances$Balance)
      })
      
      # Reactive variable to store the total amount of cash for this month
      total_cash <- reactive({
        spending_cash() + reserve_cash() + safety_net_cash() + savings_cash()
      })
      
      # Reactive variable to store the total sum of assets and cash
      total_assets <- reactive({
        retirement_assets() + total_cash()
      })
      
      # Reactive variable to store the total sum of debts
      total_debt <- reactive({
        account_balances <- balances() %>% filter(Category == "Loan")
        sum(account_balances$Balance)
      })
      
      # Populate the monthly summary text label
      output$monthly_summary_label <- renderText({
        "Monthly Summary"
      })
      
      # Populate the income text label
      output$income_label <- renderText({
        "Income Overview"
      })
      
      # Populate the total income display
      output$total_income <- renderText({
        HTML(str_interp("Total Income: ${label_dollar()(total_income())}"))
      })
      
      # Populate the total expenses display
      output$total_expenses <- renderText({
        HTML(str_interp("Total Expenses: ${label_dollar()(total_expenses())}"))
      })
      
      # Populate the net income display
      output$net_income <- renderText({
        HTML(str_interp("Net Income: <span class=\"${ifelse(net_income() < 0, 'red', 'green')}\">${label_dollar()(net_income())}</span>"))
      })
      
      # Populate the additional savings display
      output$additional_savings <- renderText({
        HTML(str_interp("Additional Savings: <span class=\"${ifelse(additional_savings() < 0, 'red', 'green')}\">${label_dollar()(additional_savings())}</span>"))
      })
      
      # Populate the asset text label
      output$asset_label <- renderText({
        "Assets"
      })
      
      # Populate the total assets display
      output$total_assets <- renderText({
        HTML(str_interp("<b>Total Assets: ${label_dollar()(total_assets())}</b>"))
      })
      
      # Populate the retirement assets display
      output$retirement_assets <- renderText({
        HTML(str_interp("Retirement Balance: ${label_dollar()(retirement_assets())}"))
      })
      
      # Populate the total cash display
      output$total_cash <- renderText({
        HTML(str_interp("<b>Total Cash: ${label_dollar()(total_cash())}</b>"))
      })
      
      # Populate the spending cash display
      output$spending_cash <- renderText({
        spending_threshold <- 5000
        HTML(str_interp("Spending Balance: <span ${ifelse(spending_cash() < spending_threshold, 'class=\"red\"', '')}>${label_dollar()(spending_cash())}</span>"))
      })
      
      # Populate the reserve cash display
      output$reserve_cash <- renderText({
        reserve_threshold <- 5000
        HTML(str_interp("Reserve Balance: <span ${ifelse(reserve_cash() < reserve_threshold, 'class=\"red\"', '')}>${label_dollar()(reserve_cash())} (${label_dollar()(expected_reserve_cash())})</span>"))
      })
      
      # Populate the safety net cash display
      output$safety_net_cash <- renderText({
        safety_net_threshold <- 30000
        HTML(str_interp("Safety Net Balance: <span ${ifelse(safety_net_cash() < safety_net_threshold, 'class=\"red\"', '')}>${label_dollar()(safety_net_cash())}</span>"))
      })
      
      # Populate the savings cash display
      output$savings_cash <- renderText({
        HTML(str_interp("Savings Balance: ${label_dollar()(savings_cash())}"))
      })
      
      # Populate the debt label
      output$debt_label <- renderText({
        "Debts"
      })
      
      # Populate the total debt display
      output$total_debt <- renderText({
        HTML(str_interp("<b>Total Debt: ${label_dollar()(total_debt())}</b>"))
      })
      
      # Generate and populate each of the individual debts
      observeEvent(select_month(),
                   {
                     # Grab the balances for the currently selected month
                     balance_table <- balances() %>%
                       filter(Category == "Loan")
                     
                     # Populate the uiOutput with each of the debt graphs
                     output$debts <- renderUI({
                       
                       # Create a HTML output for each debt for the current month
                       output_list <- lapply(unique(balance_table$Name), function(balance_name)
                       {
                         # Calculate the different summary values
                         balance <- balance_table$Balance[balance_table$Name == balance_name][1]

                         # Remove any existing popovers then create a new plotOutput with a popover
                         plot_name <- clean_plot_name(balance_name)
                         print(plot_name)
                         htmlOutput(ns(plot_name))
                       })
                       
                       # Necessary for plots to display properly
                       do.call(tagList, output_list)
                     }) #renderUI
                     
                     # After the HTML outputs are created, populate them with each debt
                     for (balance in unique(balance_table$Name))
                     {
                       # Need a local context to prevent multithreaded variable thrashing
                       local({
                         local_balance_copy <- balance
                         plot_name <- clean_plot_name(local_balance_copy)
                         print(plot_name)
                         balance <- balance_table %>% filter(Name == local_balance_copy)
                         output[[plot_name]] <- renderText({
                            HTML(str_interp("${local_balance_copy}: ${label_dollar()(balance$Balance)}"))
                         })
                        }) 
                     }
                   }
      ) #observeEvent
      
      # Populate the net cash vs debt display
      output$net_cash_debts <- renderText({
        HTML(str_interp("<b>Net Cash Vs. Debt: <span ${ifelse(total_cash() - total_debt() < 0, 'class=\"red\"', '')}>${label_dollar()(total_cash() - total_debt())}</span></b>"))
      })
      
      # Populate the net assets vs debt display
      output$net_assets_debts <- renderText({
        HTML(str_interp("<b>Net Assets Vs. Debt: <span ${ifelse(total_assets() - total_debt() < 0, 'class=\"red\"', '')}>${label_dollar()(total_assets() - total_debt())}</span></b>"))
      })
      
    }
  )
}