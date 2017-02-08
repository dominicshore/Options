require(dplyr)
require(plyer)
require(data.table)
require(jsonlite)
require(httr)
require(rvest)
require(XML)
require(plyr)


COLORDER = c("symbol", "type", "expiry", "strike", "premium", "bid", "ask", "volume", "open.interest", "retrieved")


# AUSTRALIAN OPTIONS --------------------------------------------------------------------------------------------------

# ASX is the Australian Securities Exchange.

URLASX = 'http://www.asx.com.au/asx/markets/optionPrices.do?by=underlyingCode&underlyingCode=%s&expiryDate=&optionType=B'

getOptionChainAsx <- function(symbol) {
  url = sprintf(URLASX, symbol)
  
  html <- read_html(url)
  
  # Use the second element in the list (the first element gives data on the underlying stock)
  #
  options = (html %>% html_nodes("table.options") %>% html_table(header = TRUE))[[2]] %>%
    plyr::rename(c("Bid" = "bid", "Offer" = "ask", "Openinterest" = "open.interest", "Volume" = "volume", "Expirydate" = "expiry",
                   "P/C" = "type", "Margin Price" = "premium", "Exercise" = "strike")) %>%
    transform(
      symbol        = symbol,
      retrieved     = Sys.time(),
      open.interest = suppressWarnings(as.integer(gsub(",", "", open.interest))),
      premium       = suppressWarnings(as.numeric(premium)),
      bid           = suppressWarnings(as.numeric(bid)),
      ask           = suppressWarnings(as.numeric(ask)),
      volume        = suppressWarnings(as.integer(gsub(",", "", volume))),
      expiry        = as.Date(expiry, format = "%d/%m/%Y")
    ) %>% dplyr::arrange(type, strike, expiry)
  options[, COLORDER]
}
