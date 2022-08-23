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
            _ <- liftIO (createTicker conn _ticker r) :: ActionM Int64
            status status200
            S.json r
          Nothing -> do
            status status400
            S.json (ApiError ["Ticker Not Found: " ++ T.unpack _ticker])
    Just q  -> do
        status status200
        S.json q

