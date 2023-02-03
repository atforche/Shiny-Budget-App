# Define UI for application that visualizes current budget trends and summaries
fluidPage(
  
    tags$head(
      tags$style(
        # Reduce the bottom margin for plotly plots
        HTML(
        '.plotly { margin-bottom: -15px; }'
        ),
        # Set up CSS classes for each text color needed
        HTML(
          '.red{ color:red; }'
        ),
        HTML(
          '.orange{ color:orange; }'
        ),
        HTML(
          '.green{ color:green; }'
        ),
        # Allow popovers to cover the entire parent container (which is set
        # to the HTML body in the Bootstrap settings)
        HTML(
          '.popover{ max-width: 100%; }'
        )
      )
    ),

    # Application title
    titlePanel("Noodle and Bean Budgets"),

    # Select whether to view summaries or trends
    selectInput("trend_or_summary", "Select View", c("Summary", "Trends")),
    
    # Create the UI for the summary pane (if the user has selected it)     
    summary_ui("summary"),
    
    # Create the UI for the trends pane (if the user has selected it)
    trends_ui("trends")
)
