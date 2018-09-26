library(httr)
library(jsonlite)


# Init variables ----
u_base <- "https://min-api.cryptocompare.com/data/histominute"

u_from_sym <- "BTC"
u_to_sym <- "USD"
u_limit <- 60
u_agg <- 1

# Init URL ----
u_tail <- paste("fsym=",u_from_sym,"&tsym=",u_to_sym,"&limit=",u_limit,"&aggregate=",u_agg,"&e=CCCAGG",sep = "")

p_url <- paste(u_base,u_tail,sep="?")

# Call API ----

get_prices <- GET(p_url)

# Get Data ----

get_prices_text <- content(get_prices, "text")

get_prices_json <- fromJSON(get_prices_text, flatten = TRUE)

dt_prices <- as.data.frame(get_prices_json$Data)

# Clean Data ----


dt_prices$CTime <- as.POSIXct(dt_prices$time, origin="1970-01-01")
str(dt_prices)

