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
#' @param budget_name name of the budget
#' @param select_month current month selected in the select_month input
#'
#' @return the CSS class that should be used for the budget test
get_ui_color_for_budget <- function(remaining, budget_amount, budget_name, select_month)
{
  output_color <- ""
  progress_through_month <- get_progress_through_month(select_month)
  if (remaining < 0)
  {
    output_color <- "red"
  }
  else if (remaining < budget_amount - (budget_amount * progress_through_month))
  {
    output_color <- "orange"
  }
  else
  {
    output_color <- "green"
  }
  return(output_color)
}

#' Performs cleanup on the plot names for any dynamic plots
#'
#' @param name The raw name for the table
#'
#' @return The cleaned plot name as a string
clean_plot_name <- function(name)
{
  cleaned_name <- gsub(" ", "", name)
  return(paste("dynamic", cleaned_name, sep="_"))
}

#' Predicate that determines if a given date falls within the given month and year
#'
#' @param date Date to check
#' @param month_year Date object with the month and year to validate against
#'
#' @return True if the date falls within the month and year, false otherwise
is_date_in_month <- function(date, month_year)
{
  return(month(date) == month(month_year) & year(date) == year(month_year))
}

#' Gets the earliest date that occurs in a given date range
#'
#' @param select_range the Date range the user has selected in the UI
#'
#' @return the earliest date that belongs to the selected date range
get_earliest_date_in_range <- function(select_range)
{
  # If the selected range is All Time, just return the origin date
  if (select_range == "All Time")
  {
    return(.Date(0))
  }
  
  date <- as.Date(now())
  if (select_range == "Past Six Months")
  {
    date <- date %m-% months(6)
  }
  else if (select_range == "Past Year")
  {
    date <- date %m-% months(12) 
  }
  
  # Get the first date of that month
  floor_date(date, 'month')
}
