module StockPrices.Lib
  ( getQuote)
where

import Control.Monad.IO.Class (liftIO)
import Data.Aeson
import Data.Int
import Data.Maybe
import Database.PostgreSQL.Simple
import Network.HTTP.Types.Status (Status, status200, status400)
import Web.Scotty (ActionM, jsonData, param, status)
import qualified Web.Scotty as S
import qualified Data.Text as T
import Network.Wreq
import Data.Time
import StockPrices.Model.YahooQuote (YahooQuote(..))
import StockPrices.YahooApi (getStockPrice)
import StockPrices.DateHelper (getDay)
import StockPrices.Repository (retrieveTickerPrice, createTicker)
import StockPrices.Model.ApiError (ApiError(..))

getQuote :: T.Text -> T.Text -> Connection -> ActionM ()
getQuote _ticker _date conn = do
  let day = fromJust . getDay . T.unpack $ _date
  let result = retrieveTickerPrice conn (T.unpack _ticker) day
  quote <- liftIO result :: ActionM (Maybe YahooQuote)
  case quote of
    Nothing -> do
        resp <- liftIO (getStockPrice _ticker _date) :: ActionM (Maybe YahooQuote)
        case resp of
          Just r -> do
            let action | date r /= day = returnError _ticker _date
                       | otherwise = insertDataAndReturn conn _ticker r
            action
          Nothing -> returnError  _ticker _date
    Just q  -> returnSuccess q

insertDataAndReturn :: Connection -> T.Text -> YahooQuote -> ActionM ()
insertDataAndReturn conn ticker r = do
  _ <- liftIO (createTicker conn ticker r) :: ActionM Int64
  returnSuccess r

returnError :: T.Text -> T.Text -> ActionM ()
returnError t d = do
  status status400
  S.json (ApiError ["Ticker Not Found: " ++ T.unpack t ++ ", for date: " ++ T.unpack d])

returnSuccess :: YahooQuote -> ActionM ()
returnSuccess q = do
  status status200
  S.json q


