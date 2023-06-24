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
  if (select_month == "")
  {
    return(1)
  }
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
#' @param budget_type type of the budget
#' @param select_month current month selected in the select_month input
#'
#' @return the CSS class that should be used for the budget test
get_ui_color_for_budget <- function(remaining, budget_amount, budget_type, select_month)
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
  return(get_ui_color_for_savings_budget(remaining, output_color, budget_type))
}

#' For a savings budget, we want the remaining amount to be negative. So invert
#' the UI colors if the budget is a savings budget
#'
#' @param output_color the output color determined by get_ui_color_for_budget
#' @param budget_type type of the budget
#'
#' @return the UI color for a budget, inverting the color if it's a savings budget
get_ui_color_for_savings_budget <- function(remaining, output_color, budget_type)
{
  if (budget_type != "Saving" || output_color == "orange")
  {
    return(output_color)
  }
  if (output_color == "red" || remaining == 0)
  {
    return("green")
  }
  return("red")
}

#' Calculates the monthly remaining budget balance for a given budget
#'
#' @param budget_type type of the budget
#' @param budget_amount budgeted amount for the particular budget
#' @param total_debits total amount of debits applied to that budget
#' @param total_credits total amount of credits applied to that budget
#'
#' @return the monthly remaining amount for this budget
calculate_monthly_remaining_budget_balance <- function(budget_type, budget_amount, total_debits, total_credits)
{
  if (budget_type != "Saving")
  {
    return(budget_amount - total_debits)
  }
  return(budget_amount + total_debits - total_credits)
}

#' Determines if the total budget spending for the month has exceeded the budget
#'
#' @param budget_type type of the budget
#' @param budget_amount budgeted amount for the particular budget
#' @param total_debits total amount of debits applied to that budget
#' @param total_credits total amount of credits applied to that budget
#'
#' @return whether the monthly spending has exceeded the budget amount
has_spending_exceeded_budget <- function(budget_type, budget_amount, total_debits, total_credits)
{
  if (budget_type != "Saving")
  {
    return(total_debits > budget_amount)
  }
  return(total_credits > (budget_amount + total_debits))
}

#' Calculates the total amount of spending toward the budget
#'
#' @param budget_type type of the budget
#' @param total_debits total amount of debits applied to that budget
#' @param total_credits total amount of credits applied to that budget
#'
#' @return the total spending toward the budget
calculate_spending_toward_budget <- function(budget_type, total_debits, total_credits)
{
  if (budget_type != "Saving")
  {
    return(total_debits)
  }
  return(total_credits - total_debits)
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
