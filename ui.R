# Define UI for application that visualizes current budget trends and summaries
fluidPage(
  
    # Reduce the bottom margin for plotly plots
    tags$head(
      tags$style(
        HTML(
        '.plotly { margin-bottom: -15px; }'
        ),
        HTML(
          '.red{ color:red; }'
        ),
        HTML(
          '.yellow{ color:yellow; }'
        ),
        HTML(
          '.green{ color:green; }'
        ),
        HTML(
          '.popover{ max-width: 100%; }'
        )
      )
    ),

    # Application title
    titlePanel("Noodle and Bean Budgets"),

    # Select whether to view summaries or trends
    selectInput("trend_or_summary", "Select View", c("Summary", "Trends")),
    
    # First Row
    fluidRow(
      # First half of row
      column(6,
             
        # Create the UI for the summary pane (if necessary)     
        summaryUI("summary"),
        
        # Condition UI elements that only appear if viewing Trends
        conditionalPanel(
          condition = "input.trend_or_summary == 'Trends'",
          
          # Select what months to view trends over
          
        ) # conditionalPanel
      ) # column
    ) # fluidRow
)
