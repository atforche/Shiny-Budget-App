# Define server logic for application that visualizes current budget trends and summaries
function(input, output, session) {
  
  # Load all the necessary data from the Excel workbook or the local caches
  if (need_to_update_workbook())
  {
    load_data()
    # Cache the newly loaded workbook so it's available in the future
    saveRDS(get_last_updated_date(FALSE), local_date_cache)
    save(loaded_workbook, loaded_transaction_table, loaded_account_balance_table, loaded_income_table, loaded_budget_table, file=local_data_cache)
  }
  else
  {
    load(local_data_cache, globalenv())
    toastr_success("No new changes. Loaded stored workbook")
  }
  
  # Populate the last updated text display
  output$last_updated <- renderText({
    paste(HTML("<span style='margin:30px'>Last Updated:", get_last_updated_date(), "</span>"))
  })
  
  # Event observer to handle refreshing the data, loads the new workbook and refreshes the page
  observeEvent(input$refresh_button,
               {
                 load_data()
                 shinyjs::refresh()
               })

  # Load server logic for the summary module
  summary_server("summary", reactive(input$trend_or_summary))
  
  # Load server logic for the trends module
  trends_server("trends", reactive(input$trend_or_summary))
  
}
