library(shiny)
library(dplyr)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(readr)

source("functions/customValueBox_fn.R")
variety_data <- readr::read_csv("files/variety_data.csv")

