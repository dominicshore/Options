library(data.table)
library(dplyr)
require(purrr)



while( TRUE ) {
  # Initialising the schduling
  start_time <- as.POSIXct( paste0( as.character( Sys.Date()), " 10:20:00" ))
  end_time <- as.POSIXct( paste0( as.character( Sys.Date()), " 16:20:00" ))
  current_time <- Sys.time()
  
  if ( current_time >= start_time & current_time <= end_time ) {
  options_scraping_script()
  Sys.sleep(60*15)
  
  } else {
  break() 
  }
}

# The loop which will run the program every 20 minutes (ASX data update frequency)
  # while( (current_time >= start_time & current_time <= end_time & difftime( current_time, last_update ) >= 20) == TRUE )  {}
  # last_upate <- Sys.time()

options_scraping_script <- function() {
  # Path to previously saved options data from CSV file
  path <- 'C:/Users/Dos/Documents/R/Options/Options/OptionsTable.csv'
  
  # Function to read in previous options_table
  prev_table <- as.data.frame( fread( path, drop = "V1" ))
  
  # Need to coerce some character formatting into date/time  before calling rbind function on row 18
  prev_table$expiry <- as.Date( prev_table$expiry, format = "%Y-%m-%d" )
  prev_table$retrieved <- as.POSIXct( strptime( prev_table$retrieved, "%Y-%m-%d %H:%M:%S" ))
  
  # Reading the list of all options currently tradable from the ASX
  ASXListed <- read.csv("http://www.asx.com.au/data/ASXCLDerivativesMasterList.csv", stringsAsFactors = FALSE)
  unique_stocks <- unique( ASXListed$Underlying )
  
  # Removing options series that does not cover individual stocks
  unique_stocks <- unique_stocks[ -grep( pattern="[[:digit:]]", x=unique_stocks )]
  unique_stocks <- unique_stocks[ -grep( pattern="XJO", x=unique_stocks )]
  
  # Using map_ function from the purrr package because it is quicker than base-r's control flow options
  new_table <- map_df( unique_stocks, getOptionChainAsx )
  
  # Binding current and previous dataframes
  options_table <- rbind( prev_table, new_table )
  
  write.csv( options_table, file = 'OptionsTable.csv' )
}
