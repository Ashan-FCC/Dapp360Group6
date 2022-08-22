{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings  #-}
module StockPrices.YahooApi (getStockPrice, YahooQuote(..)) where

import Network.Wreq (Options, defaults, param, header,getWith, asValue, responseBody,asJSON)
import Data.Aeson (FromJSON)
import Data.Text (Text)
import Data.Map
import GHC.Generics (Generic)
import Control.Lens
import Data.Aeson (Value)
import Data.Map as Map
import Control.Monad (forM_)
import StockPrices.Model.YahooQuote (YahooQuote(..))
import StockPrices.Model.TranslateRsponse (TranslateRsponse(..))

stockOptions :: Text -> Text -> Options
stockOptions pSymbol pDate= defaults & header "X-RapidAPI-Key" .~ ["6fd3e0bae8msh6c11f25ca5950e0p188990jsn7dbf851d79eb"] & param "EndDateInclusive" .~ [pDate] 
  & param "StartDateInclusive" .~ [pDate] & param "Symbol" .~ [pSymbol]

getStockPrice :: Text -> Text -> IO YahooQuote
getStockPrice stockSymbol stockDate = do
  response <-  getWith (stockOptions stockSymbol stockDate) "https://yahoofinance-stocks1.p.rapidapi.com/stock-prices"
  jsonResponse <- asJSON response
  pure( head(results (jsonResponse ^. responseBody)))
  --forM_  (results (jsonResponse ^. responseBody)) $ \q  -> do


 