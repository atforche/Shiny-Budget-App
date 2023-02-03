# Gets the UI elements for the summary module
monthly_summary_ui <- function(id)
{
  # Define the namespace for this module
  ns <- NS(id)
  
  tagList(
    
    # Output for the budgets section label
    span(textOutput(ns("monthly_summary_label")), style="font-weight:bold;font-size:x-large"),
    
    # First Row
    fluidRow(
      
      # First column
      column(4,
           
         # Div to give the text some padding
         div(style="padding: 15px;",
             
             # Output for the income column label
             span(textOutput(ns("income_label")), style="font-weight:bold;font-size:large"),
             
             # Div to give the text some more padding
             div(style="padding:10px;font-size:large;",
                 
                 # Output for the total income display
                 htmlOutput(ns("total_income")),
                 
                 # Output for the total expenses display
                 htmlOutput(ns("total_expenses")),
                 
                 # Output for the net income display
                 htmlOutput(ns("net_income")),
                 
                 # Output for the additional savings display
                 htmlOutput(ns("additional_savings")),
                 
                 # Popover to explain what Additional Savings are
                 bsPopover(ns("additional_savings"),
                        "Additional Savings",
                        paste("Additional savings refers to the money that we save on fixed monthly budgets plus any income we had over what we had budgeted.",
                              "This extra money can be treated as free savings and can be transferred into a savings account at the end of the month.",
                              "Running budgets do not count toward this number since any savings on those budgets automatically get rolled into the Reseve account and carried forward into next month"),
                        placement="bottom"),
                 
                 # Output for the change in reserve display
                 htmlOutput(ns("change_in_reserve"))
                 
             ) # div
             
          ) # div
         
       ), # column
      
      # Second column
      column(4,
             
             # Div to give the text some padding
             div(style="padding: 15px;",
                 
                 # Output for the asset column label
                 span(textOutput(ns("asset_label")), style="font-weight:bold;font-size:large"),
                 
                 # Div to give the text some more padding
                 div(style="padding:10px;font-size:large;",
                     
                     # Output for the total asset label
                     htmlOutput(ns("total_assets")),
                     
                     # Div to give text some more padding
                     div(style="padding-left:20px;font-size:large",
                         
                         # Output for the retirement assets display
                         htmlOutput(ns("retirement_assets")),
                         
                         # Output for the total cash display
                         htmlOutput(ns("total_cash")),
                         
                         # Div to give text some more padding
                         div(style="padding-left:20px;font-size:large",
                             
                             # Output for the spending cash display
                             htmlOutput(ns("spending_cash")),
                             
                             # Output for the reserve cash display
                             htmlOutput(ns("reserve_cash")),
                             
                             # Output for the safety net cash display
                             htmlOutput(ns("safety_net_cash")),
                             
                             # Output for the savings cash display
                             htmlOutput(ns("savings_cash"))
                             
                         ) # div
                         
                     ) # div
                     
                 ) # div
                 
             ) # div
             
      ), # column
      
      # Third column
      column(4,
             
             # Div to give the text some padding
             div(style="padding: 15px;",
                 
                 # Output for the debt column label
                 span(textOutput(ns("debt_label")), style="font-weight:bold;font-size:large"),
                 
                 # Div to give the text some more padding
                 div(style="padding:10px;font-size:large;",
                     
                     # Output for the total debt display
                     htmlOutput(ns("total_debt")),
                     
                     # Div to give text some more padding
                     div(style="padding-left:20px;font-size:large",
                     
                       # Output to display the current balance on each debt
                       uiOutput(ns("debts"))
                     
                     ), # div
                     
                     # Output to display the net cash vs debts display
                     htmlOutput(ns("net_cash_debts")),
                     
                     # Output to display the net assets vs debts display
                     htmlOutput(ns("net_assets_debts"))
                     
                 ), # div
                 
             ) # div
             
      ) # column
      
    )
    
  ) #tagList
}

