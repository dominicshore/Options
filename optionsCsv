library(data.table)
library(dplyr)
require(purrr)
s <- Sys.time()
#Get previously saved options data from CSV file
path <- 'C:/Users/Dos/Documents/R/Options/Options/OptionsTable.csv'

prev_table <- fread(path, drop = "V1")
prev_table <- prev_table %>% 
                    mutate(
                          symbol        = symbol,
                          retrieved     = Sys.time(),
                          open.interest = suppressWarnings(as.integer(gsub(",", "", open.interest))),
                          premium       = suppressWarnings(as.numeric(premium)),
                          bid           = suppressWarnings(as.numeric(bid)),
                          ask           = suppressWarnings(as.numeric(ask)),
                          volume        = suppressWarnings(as.integer(gsub(",", "", volume))),
                          expiry        = as.Date(expiry, format = "%d/%m/%Y")
                          )

ASXListed <- read.csv("http://www.asx.com.au/data/ASXCLDerivativesMasterList.csv", stringsAsFactors = FALSE)
UniqueStocks <- unique(ASXListed$Underlying)
UniqueStocks <- UniqueStocks[-grep(pattern="[[:digit:]]", x=UniqueStocks)]
UniqueStocks <- UniqueStocks[-grep(pattern="XJO", x=UniqueStocks)]


new_table <- map_df(UniqueStocks, getOptionChainAsx)

Options_table <- rbind(prev_table, new_table)

write.csv(Options_table, file = 'OptionsTable.csv')

e <- Sys.time()
tt <- e-s
tt
