# Global variable to cache the Excel workbook
loaded_workbook <- NULL

#' Checks to see if an updated version of the Excel workbook is available to grab
#'
#' @return True if an updated version of the workbook is available, false otherwise
need_to_update_workbook <- function()
{
  # Check to see if the master workbook path is reachable
  if (!file.exists(master_workbook_location))
  {
    return(FALSE)
  }
  
  # Now check to see if both the caches are intact
  if (!file.exists(local_date_cache) || !file.exists(local_data_cache))
  {
    return(TRUE)
  }
  
  # Compare our last modified date
  last_modified_date <- as_datetime(readRDS(file=local_date_cache))
  if (last_modified_date == force_tz(file.info(master_workbook_location)$mtime, "UTC"))
  {
    return(FALSE)
  }
  return(TRUE)
}

#' Attempts to grab the most recent version of the budget workbook
#'
#' Tries to copy the master budget workbook from the specified location into the
#' local application directory. If an error occurs, an error will not be thrown.
#' Instead, the error message will be returned.
#'
#' @return the error message that occurs when updating the workbook, or a blank string
update_workbook <- function()
{
  # Temporary file names used by the copying process
  existing_temp_name <- "res/old.xlsm"
  new_temp_name <- "res/new.xlsm"

  # Copy the master workbook to the res directory
  if (!file.copy(master_workbook_location, new_temp_name, overwrite=TRUE))
  {
    if (!dir.exists("res/shared"))
    {
      return("Unable to access shared folder.")
    }
    if (!file.exists(master_workbook_location))
    {
      return("Unable to access shared workbook.")
    }
    return("Unable to copy master file.")
  }

  # Rename the existing workbook to a temp name
  if (!file.rename(local_workbook_location, existing_temp_name))
  {
    return("Unable to rename existing file.") 
  }

  # Rename the new workbook to the name the application expects
  if (!file.rename(new_temp_name, local_workbook_location))
  {
    return("Unable to rename new file.")
  }

  # Delete the now obsolete old workbook
  if (!file.remove(existing_temp_name))
  {
    return("Unable to delete old file.")
  }

  return("")
}

#' Gets the date and time of the most recent update to the data
#'
#' @return the date time of the last data update
get_last_updated_date <- function(local_workbook = TRUE)
{
  if (local_workbook)
  {
    return(toString(file.info(local_workbook_location)$mtime))
  }
  return(toString(file.info(master_workbook_location)$mtime))
}

#' Load an Excel workbook
#'
#' Loads the Excel workbook found at the end of the file path and caches the 
#' workbook for further use
#' @param filename the file path pointing to the Excel file
#'
#' @return None
load_excel_workbook <- function(filename)
{
  loaded_workbook <<- loadWorkbook(filename)
}

#' Gets the current Excel workbook
#'
#' The Excel workbook must first be loaded by load_excel_workbook. 
#' If no workbook is loaded, an error is thrown
#' @return the current Excel workbook
get_workbook <- function()
{
  if (!is.null(loaded_workbook))
  {
    return(loaded_workbook)
  }
  stop("No workbook is currently loaded.")
}

# Global variable to cache the transaction table
loaded_transaction_table <- NULL

#' Loads the table with all transactions
#'
#' Caches the table for future use. 
#' Requires that the workbook has already been loaded.
#' @return None
load_transaction_table <- function()
{
  loaded_transaction_table <<- NULL
  for (sheet_name in get_worksheet_names())
  {
    if (is_data_sheet(sheet_name))
    {
      table_name <- paste("_", gsub("-", "_", sheet_name), "\\Transactions", sep="")
      transaction_table <- load_excel_table(table_name, sheet_name)
      
      # Populate or concatenate the new transactions onto the existing transactions
      if (nrow(transaction_table) == 0)
      {
        next
      }
      if (is.null(loaded_transaction_table))
      {
        loaded_transaction_table <<- transaction_table
      }
      else
      {
        loaded_transaction_table <<- rbindlist(list(loaded_transaction_table, transaction_table))
      }
    }
  }
}

#' Gets the loaded transaction table
#'
#' The transaction table must first be loaded by load_transaction_table.
#' If the table is not loaded, an error is thrown
#' @return the table of transactions
get_transaction_table <- function()
{
  if (!is.null(loaded_transaction_table))
  {
    return(loaded_transaction_table)
  }
  stop("Transaction table is not loaded")
}

# Global variable to cache the account balance table
loaded_account_balance_table <- NULL

#' Loads the table with each recorded account balance
#'
#' Caches the table for future use. 
#' Requires that the workbook has already been loaded.
#' @return None
load_account_balance_table <- function()
{
  loaded_account_balance_table <<- NULL
  for (sheet_name in get_worksheet_names())
  {
    if (is_data_sheet(sheet_name))
    {
      column_names <- c("First.Monday", "Second.Monday", "Third.Monday", "Fourth.Monday", "Fifth.Monday")
      table_name <- paste("_", gsub("-", "_", sheet_name), "\\Balances", sep="")
      balance_table <- load_excel_table(table_name, sheet_name)
      
      # Pivot the balances from wide to long
      balance_table <- balance_table %>% 
        pivot_longer(
          cols = any_of(column_names),
          names_to = "Date",
          values_to = "Balance"
        ) %>% 
        filter(!is.na(Balance))
      
      # Replace the column names with their respective dates
      monday_dates <- get_mondays_in_month(sheet_name[1:4], sheet_name[6:7])
      for (index in 1:length(monday_dates))
      {
        balance_table$Date <- replace(balance_table$Date, 
                                 balance_table$Date == column_names[index],
                                 as.character(monday_dates[index]))  
      }
      balance_table <- balance_table %>% mutate(Date = as.Date(Date)) %>% 
        select(Date, everything())
      
      # Populate or concatenate the new balances onto the existing balances
      if (nrow(balance_table) == 0)
      {
        next
      }
      if (is.null(loaded_account_balance_table))
      {
        loaded_account_balance_table <<- balance_table
      }
      else
      {
        loaded_account_balance_table <<- rbindlist(list(loaded_account_balance_table, balance_table))
      }
    }
  }
}

#' Gets the loaded account balance table
#'
#' The account balance table must first be loaded by load_account_balance_table. 
#' If the table is not loaded, an error is thrown
#' @return the table of account balances
get_account_balance_table <- function()
{
  if (!is.null(loaded_account_balance_table))
  {
    return(loaded_account_balance_table)
  }
  stop("Account balance table is not loaded")
}

# Global variable to cache the income table
loaded_income_table <- NULL

#' Loads the table with each income transaction
#'
#' Caches the table for future use. 
#' Requires that the workbook has already been loaded.
#' @return None
load_income_table <- function()
{
  loaded_income_table <<- NULL
  for (sheet_name in get_worksheet_names())
  {
    if (is_data_sheet(sheet_name))
    {
      table_name <- paste("_", gsub("-", "_", sheet_name), "\\Actual_Income", sep="")
      income_table <- load_excel_table(table_name, sheet_name) %>%
        select(Date, Net.Income)
      
      # Populate or concatenate the new transactions onto the existing transactions
      if (nrow(income_table) == 0)
      {
        next
      }
      if (is.null(loaded_income_table))
      {
        loaded_income_table <<- income_table
      }
      else
      {
        loaded_income_table <<- rbindlist(list(loaded_income_table, income_table))
      }
    }
  }
}

#' Gets the loaded income table
#'
#' The income table must first be loaded by load_income_table. 
#' If the table is not loaded, an error is thrown
#' @return the table of income transactions
get_income_table <- function()
{
  if (!is.null(loaded_income_table))
  {
    return(loaded_income_table)
  }
  stop("Income table is not loaded")
}

# Global variable to cache the budget table
loaded_budget_table <- NULL

#' Loads the table with each monthly budget balance
#'
#' Caches the table for future use. 
#' Requires that the workbook has already been loaded.
#' @return None
load_budget_table <- function()
{
  loaded_budget_table <<- NULL
  for (sheet_name in get_worksheet_names())
  {
    if (is_data_sheet(sheet_name))
    {
      table_name <- paste("_", gsub("-", "_", sheet_name), "\\Budgets", sep="")
      budget_table <- load_excel_table(table_name, sheet_name) %>% 
        mutate(Date = ymd(str_interp("${sheet_name[1:4]}/${sheet_name[6:7]}/01"))) %>%
        select(Date, everything())
      
      # Populate or concatenate the new transactions onto the existing transactions
      if (nrow(budget_table) == 0)
      {
        next
      }
      if (is.null(loaded_budget_table))
      {
        loaded_budget_table <<- budget_table
      }
      else
      {
        loaded_budget_table <<- rbindlist(list(loaded_budget_table, budget_table))
      }
    }
  }
}

#' Gets the budget table
#'
#' The budget table must first be loaded by load_budget_table. 
#' If the table is not loaded, an error is thrown
#' @return the table of budgets
get_budget_table <- function()
{
  if (!is.null(loaded_budget_table))
  {
    return(loaded_budget_table)
  }
  stop("Budget table is not loaded")
}

#' Loads a named Excel table as a data.table
#'
#' Throw an error if no table by that name appears
#' @param table_name name of the Excel table to load 
#' @param sheet_name name of the worksheet the table is found on
#'
#' @return the data in the Excel table as a data.table
load_excel_table <- function(table_name, sheet_name)
{
  tables <- getTables(get_workbook(), sheet=sheet_name)
  if (table_name %in% tables)
  {
    table_range <- names(tables[tables == table_name])
    table_range_refs <- strsplit(table_range, ":")[[1]]
    table_rows <- gsub("[^0-9.]", "", table_range_refs)
    table_cols <- convertFromExcelRef(table_range_refs)
    
    excel_table <- as.data.table(read.xlsx(get_workbook(), 
                                     sheet_name, 
                                     detectDates=TRUE,
                                     rows=table_rows[1]:table_rows[2], 
                                     cols=table_cols[1]:table_cols[2])) %>%
      filter(!is.na(.[[1]]))
    return(excel_table)
  }
  stop(str_interp("Specified table \"${table_name}\" not found on sheet \"${sheet_name}\""))
}

#' Gets a list of dates that represent every Monday in a month
#'
#' @param year an integer representing the year
#' @param month an integer representing the month
#'
#' @return a list of dates corresponding to every Monday in the month
get_mondays_in_month <- function(year, month)
{
  start_date <- ymd(str_interp("${year}/${month}/01"))
  end_date <- (start_date %m+% months(1)) - days(1)
  date_range <- seq(start_date, end_date, "days")
  
  return(date_range[wday(date_range, label=TRUE) == "Mon"]) 
}

#' Determines if the given sheet name corresponds to a sheet with data in it
#'
#' @param sheetname Name of a sheet
#'
#' @return True if the sheet has data, false otherwise
is_data_sheet <- function(sheetname)
{
  regex <- "[[:digit:]]{4}-[[:digit:]]{2}"
  return(grepl(regex, sheetname))
}

#' Get worksheet names
#'
#' Requires that the excel workbook has already been loaded
#' @return a list of strings containing the names of each worksheet in the Excel workbook
get_worksheet_names <- function()
{
  return(names(get_workbook()))
}

#' Loads all the data and tables from the Excel workbook
#'
#' @return None
load_data <- function()
{
  update_error <- update_workbook()
  if (update_error != "")
  {
    toastr_error(update_error)
  }

  load_excel_workbook(local_workbook_location)
  
  load_transaction_table()
  load_account_balance_table()
  load_income_table()
  load_budget_table()
}
