# Define server logic for application that visualizes current budget trends and summaries
function(input, output, session) {
  
  # Load all the necessary data from the Excel workbook
  load_data()

  # Load server logic for the summary module
  summary_server("summary", reactive(input$trend_or_summary))
  
  # Load server logic for the trends module
  trends_server("trends", reactive(input$trend_or_summary))
}
