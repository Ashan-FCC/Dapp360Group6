module StockPrices.DateHelper where

import Data.Time

getDay :: String -> Maybe Day
getDay s = parseTimeM False defaultTimeLocale "%Y-%m-%d" s :: Maybe Day