# Define UI for application that visualizes current budget trends and summaries
fluidPage(
  
  # Enable toaster messages
  useToastr(),
  
  # Enable arbitrary JS
  shinyjs::useShinyjs(),
  
  # HTML head tags
  tags$head(
    
    # HTML style tags
    tags$style(
    
      # Reduce the bottom margin for plotly plots
      HTML('.plotly { margin-bottom: -15px; }'),
      
      # Set up CSS classes for each text color needed
      HTML('.red { color:red; }'),
      HTML('.orange { color:orange; }'),
      HTML('.green { color:green; }'),
      
      # Allow popovers to cover the entire parent container (which is set
      # to the HTML body in the Bootstrap settings)
      HTML('.popover { max-width: 100%; }')
    
      ) # Style Tags
  
  ), # Head tags
  
  # Top row of application
  fluidRow(
    
    # Main Column
    column(9,
           
       # Application title
       titlePanel(
         "Noodle and Bean Budgets"
       )
           
    ), # column
    
    # Second column
    column(
      2,
      
      div(
        
        # Last updated display
        htmlOutput("last_updated"),
        
        style = "padding-top:15px"
        
      ) # div
      
    ), # column
    
    # Third column
    column(
      1,
      
      div(
        
        # Refresh button
        actionButton("refresh_button", "Refresh Data"),
        
        style = "padding-top:10px"
        
      ) # div
      
    ) # column
    
  ), # Fluid row
    
  # Select whether to view summaries or trends
  selectInput("trend_or_summary", "Select View", c("Summary", "Trends")),
  
  # Create the UI for the summary pane (if the user has selected it)
  summary_ui("summary"),
  
  # Create the UI for the trends pane (if the user has selected it)
  trends_ui("trends")
)
  