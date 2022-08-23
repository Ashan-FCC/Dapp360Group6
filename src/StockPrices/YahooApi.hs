{-# LANGUAGE OverloadedStrings  #-}
module StockPrices.YahooApi (getStockPrice) where

import Network.Wreq (checkResponse, Response, Options, defaults, param, header, getWith, asValue, responseBody, asJSON, responseStatus, statusCode)
import Data.Aeson (FromJSON, Value)
import Data.Text (Text)
import GHC.Generics (Generic)
import Control.Lens
import Data.Map as Map
import Control.Exception (Exception, catch)
import qualified Data.ByteString as BS

import StockPrices.Model.YahooQuote (YahooQuote(..))
import StockPrices.Model.TranslateRsponse (TranslateRsponse(..))

stockOptions :: Text -> Text -> Options
stockOptions pSymbol pDate= set checkResponse (Just $ \_ _ -> return ()) defaults & header "X-RapidAPI-Key" .~ ["6fd3e0bae8msh6c11f25ca5950e0p188990jsn7dbf851d79eb"] & param "EndDateInclusive" .~ [pDate]
  & param "StartDateInclusive" .~ [pDate] & param "Symbol" .~ [pSymbol]

getStockPrice :: Text -> Text -> IO (Maybe YahooQuote)
getStockPrice stockSymbol stockDate = do
  response <-  getWith (stockOptions stockSymbol stockDate) "https://yahoofinance-stocks1.p.rapidapi.com/stock-prices"
  let status = response ^. responseStatus . statusCode
  case status of
    200 -> do
      jsonResponse <- asJSON response
      pure( Just (head(results (jsonResponse ^. responseBody))))
    _ -> return Nothing


 