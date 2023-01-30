# Set the working directory
setwd("C:\\Users\\atfor\\OneDrive\\Desktop\\Budget_Shiny_App")

# Global imports for the application
library(data.table)
library(ggplot2)
library(lubridate)
library(openxlsx)
library(plotly)
library(scales)
library(shiny)
library(shinyBS)
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