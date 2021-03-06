library(readxl)
library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(readr)

# Get symbol pairs from xlsx

working_dir = "/crypto_arch/scripts/cryptocompare/"


setwd(working_dir)

# rxls <- read_xlsx("/crypto_arch/scripts/cryptocompare/Binance Trading Pairs.xlsx",sheet = "Binance")
 rxls <- read_xlsx("Binance Trading Pairs.xlsx",sheet = "Binance")

rxls <- rxls %>% select(TradeCoin,BaseCoin) %>% mutate(BaseCoin = gsub(pattern = "USDT",replacement = "USD",x = BaseCoin,fixed = T))

itt <- 0


Get_Trade_Info <- function(p_from_sym,p_to_sym) {
  
  itt <<- itt + 1
  # Init variables ----
  u_base <- "https://min-api.cryptocompare.com/data/histominute"
  
  u_from_sym <- p_from_sym
  u_to_sym <- p_to_sym
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
  
  
  dt_prices$from_sym <- u_from_sym
  dt_prices$to_sym <- u_to_sym
  
  #print(itt)
  
  return(dt_prices)
  

  
}



itt <- 0
options(scipen=999)

write_lines(paste0(date()," - ","Start Minute Run"),"Crypto_Log.log",append = T)

trade_data <- map2(rxls$TradeCoin,rxls$BaseCoin,Get_Trade_Info)

tbl_trade_data <- bind_rows(trade_data)
write_lines(paste0(date()," - ", "Minute run scraped ",nrow(tbl_trade_data)," records"),"Crypto_Log.log",append = T)


tbl_trade_data$CTime <- as.POSIXct(tbl_trade_data$time, origin="1970-01-01")
tbl_trade_data$time <- NULL

if (file.exists("min_latest.rds")){
  latest_mins <- readRDS(file = "min_latest.rds")
  
  tbl_trade_data <- tbl_trade_data %>% left_join(latest_mins, by = c("from_sym", "to_sym")) %>%
  filter(CTime > LastTime)
  }

tbl_trade_data %>% group_by(from_sym,to_sym) %>% summarise(LastTime = max(CTime)) %>% 
  saveRDS("min_latest.rds")


write_csv(tbl_trade_data,"trade_data_min.csv",append = T)

write_lines(paste0(date()," - ", "Minute run ended (added ",nrow(tbl_trade_data)," new records)"),"Crypto_Log.log",append = T)

