{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables  #-}
module StockPrices.App (runApp, getDay) where

import StockPrices.Repository (retrieveTickerPrice, createTicker)
import StockPrices.Database (getDbConnection)
import StockPrices.Environment (readConfig)
import StockPrices.Model.TickerHistory (TickerHistory(..))
import Data.Time

runApp :: IO ()
runApp = do
  config <- readConfig
  conn   <- getDbConnection config
  xs     <- createTicker conn (TickerHistory { ticker = "AAPL", date = getDay "2022-08-12",  adjustedClose = 100,   closeP = 1000,   high = 1001,  low = 989,   open = 990,   volume = 10000 })
  res    <- retrieveTickerPrice conn "NFLX" (getDay "2022-08-15")
  print res

getDay :: String -> Day
getDay s = parseTimeOrError False defaultTimeLocale "%Y-%m-%d" s :: Day



