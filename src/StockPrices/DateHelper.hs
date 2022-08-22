module StockPrices.DateHelper where

import Data.Time

getDay :: String -> Day
getDay s = parseTimeOrError False defaultTimeLocale "%Y-%m-%d" s :: Day