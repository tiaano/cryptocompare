library(httr)
library(jsonlite)


u_base <- "https://min-api.cryptocompare.com/data/histominute"

u_from_sym <- "BTC"
u_to_sym <- "USD"
u_limit <- 60
u_agg <- 3

u_tail <- paste("fsym=",u_from_sym,"&tsym=",u_to_sym,"&limit=",u_limit,"&aggregate=",u_agg,"&e=CCCAGG",sep = "")

p_url <- paste(u_base,u_tail,sep="?")

get_prices <- GET(p_url)

get_prices_text <- content(get_prices, "text")

get_prices_json <- fromJSON(get_prices_text, flatten = TRUE)

dt_prices_3 <- as.data.frame(get_prices_json$Data)


