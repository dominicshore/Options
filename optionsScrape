require(dplyr)
require(plyer)
require(data.table)
require(jsonlite)
require(httr)
require(rvest)
require(XML)
require(plyr)

.onAttach <- function(libname, pkgname) {
  description = packageDescription("flipsideR")
  
  packageStartupMessage(description$Package, " (version ", description$Version, ") ",
                        format(eval(parse(text = description$`Authors@R`)), include = c("given", "family", "email"))
  )
}

.onLoad <- function(libname, pkgname) {
  invisible()
}

COLORDER = c("symbol", "type", "expiry", "strike", "premium", "bid", "ask", "volume", "open.interest", "retrieved")
# TODO: Add column for exchange in data.

# TODO: Trying to avoid using dplyr and plyr. Right now dplyr is just being used for soring in a magrittr chain. Ideally
# I would like to move across to dplyr completely but I don't see an equivalent to mlply().

# Initial version of this code based on http://mktstk.wordpress.com/2014/12/29/start-trading-like-a-quant-download-option-chains-from-google-finance-in-r/

# A more direct method to fix the JSON data (making sure that all the keys are quoted). This will be a lot faster
# for large JSON packages.
#
fixJSON <- function(json) {
  gsub('([^,{:]+):', '"\\1":', json)
  
}

# AUSTRALIAN OPTIONS --------------------------------------------------------------------------------------------------

# ASX is the Australian Securities Exchange.

URLASX = 'http://www.asx.com.au/asx/markets/optionPrices.do?by=underlyingCode&underlyingCode=%s&expiryDate=&optionType=B'

#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_table
#' @import magrittr
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
