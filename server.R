# Define server logic for application that visualizes current budget trends and summaries
function(input, output, session) {
  
  # Reactive values storing info about data updates
  update_data <- reactiveValues(
    last_updated = get_last_updated_date()
  )
  
  # Load all the necessary data from the Excel workbook
  load_data()
  update_data$last_updated <- get_last_updated_date()
  
  # Populate the last updated text display
  output$last_updated <- renderText({
    paste(HTML("<span style='margin:30px'>Last Updated:", update_data$last_updated, "</span>"))
  })
  
  # Event observer to handle refreshing the data
  observeEvent(input$refresh_button,
               {
                 print("Reloading")
                 load_data()
                 update_data$last_updated <- get_last_updated_date()
                 shinyjs::refresh()
                 print("Done")
               })

  # Load server logic for the summary module
  summary_server("summary", reactive(input$trend_or_summary))
  
  # Load server logic for the trends module
  trends_server("trends", reactive(input$trend_or_summary))
}
