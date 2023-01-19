# Define server logic for application that visualizes current budget trends and summaries
function(input, output, session) {
  
  # Load all the necessary data from the Excel workbook
  load_data()

  # Load server logic for the summary module
  summaryServer("summary", FALSE, reactive(input$trend_or_summary))
}
