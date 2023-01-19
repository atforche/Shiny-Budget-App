#' Gets the current month selected through the UI as a Date
#'
#' @param select_month current month selected in the select_month input
#'
#' @return the first day of the current month as a Date
get_current_month_as_date <- function(select_month)
{
  return(ymd(str_interp("${select_month[1:4]}/${select_month[5:6]}/01")))
}

#' Gets the current progress through the month as a decimal
#'
#' @param select_month current month selected in the select_month input
#'
#' @return a decimal representing the current progress through the month
get_progress_through_month <- function(select_month) 
{
  # Get the applications current month and the real life date
  month <- get_current_month_as_date(select_month)
  current_date <- as.Date(now())

  total_days <- days_in_month(month)
  days_elapsed <- max(as.double(difftime(current_date, month, units="days")), 0)
  return(min(1, days_elapsed / total_days))
}

#' Determines the color a budget should be displayed as in the UI based on the
#' current spending and progress through the month 
#'
#' @param remaining remaining amount for the budget this month
#' @param budget_amount total amount budgeted for a budget
#' @param select_month current month selected in the select_month input
#'
#' @return the CSS class that should be used for the budget test
get_ui_color_for_budget <- function(remaining, budget_amount, select_month)
{
  if (remaining < 0)
  {
    return("red")
  }
  
  progress_through_month <- get_progress_through_month(select_month)
  if (remaining < budget_amount - (budget_amount * progress_through_month))
  {
    return("yellow")
  }
  return("green")
}


#' Performs cleanup on the plot names for the budget plots
#'
#' @param budget_name The raw budget name from the budget table
#'
#' @return The cleaned plot name as a string
clean_budget_plot_name <- function(budget_name)
{
  cleaned_budget_name <- gsub(" ", "", budget_name)
  return(paste("budget", cleaned_budget_name, sep="_"))
}