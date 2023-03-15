# Set the working directory
setwd("C:\\Users\\atfor\\OneDrive\\Desktop\\Budget_Shiny_App")

# Expected locations for the Excel workbooks
master_workbook_location <- "C:\\Users\\atfor\\OneDrive\\Desktop\\Shared\\Monthly Budget Tracking.xlsm"
local_workbook_location <- "res\\data.xlsm"

# Paths to the local caches
local_date_cache <- "res\\last_modified.rds"
local_data_cache <- "res\\cached_data.RData"

# Imports for the application
library(data.table)
library(ggplot2)
library(lubridate)
library(openxlsx)
library(plotly)
library(scales)
library(shiny)
library(shinyBS)
library(shinyjs)
library(shinytoastr)
library(tidyverse)
source("loaders.R")
source("helpers.R")

# Monthly summary module
source("modules//monthlySummaryUI.R")
source("modules//monthlySummaryServer.R")

# Budget graph module
source("modules//budgetGraphUI.R")
source("modules//budgetGraphServer.R")

# Spending graph module
source("modules//spendingGraphUI.R")
source("modules//spendingGraphServer.R")

# Summary UI module
source("modules//summaryUI.R")
source("modules//summaryServer.R")

# Cash Flow module
source("modules//cashFlowUI.R")
source("modules//cashFlowServer.R")

# Budget Spending module
source("modules//budgetSpendingUI.R")
source("modules//budgetSpendingServer.R")

# Balance History module
source("modules//balanceHistoryUI.R")
source("modules//balanceHistoryServer.R")

# Debt History module
source("modules//debtHistoryUI.R")
source("modules//debtHistoryServer.R")

# Trends UI module
source("modules//trendsUI.R")
source("modules//trendsServer.R")