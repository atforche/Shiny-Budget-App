# Define server logic for application that visualizes current budget trends and summaries
function(input, output, session) {
  
  # Load all the necessary data from the Excel workbook
  load_data()
  
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
