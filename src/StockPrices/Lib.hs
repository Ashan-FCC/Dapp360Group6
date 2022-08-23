module StockPrices.Lib
  ( getQuote)
where

import Control.Monad.IO.Class (liftIO)
import GHC.Generics (Generic)
import Data.Aeson
import Data.Int
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Network.HTTP.Types.Status (Status, status200, status400)
import Web.Scotty (ActionM, jsonData, param, post, status, text)
import qualified Web.Scotty as S
import StockPrices.YahooApi (getStockPrice)
import qualified StockPrices.Model.YahooQuote as Y
import qualified Data.Text as T
import StockPrices.DateHelper (getDay)
import StockPrices.Repository (retrieveTickerPrice, createTicker)
import StockPrices.Model.ApiError (ApiError(..))
import Network.Wreq
import Data.Time

getQuote :: T.Text -> T.Text -> Connection -> ActionM ()
getQuote _ticker _date conn = do
  let day = getJust . getDay . T.unpack $ _date
  let result = retrieveTickerPrice conn (T.unpack _ticker) day
  quote <- liftIO result :: ActionM (Maybe Y.YahooQuote)
  case quote of
    Nothing -> do
        resp <- liftIO (getStockPrice _ticker _date) :: ActionM (Maybe Y.YahooQuote)
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
  where
    getJust :: Maybe Day -> Day
    getJust (Just d) = d

