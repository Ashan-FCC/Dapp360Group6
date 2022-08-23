{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables  #-}
module StockPrices.App (runApp) where

import Network.HTTP.Types.Status (Status, status200, status400)
import Web.Scotty (ActionM, get, scotty, param, status)
import Database.PostgreSQL.Simple
import Data.Time
import qualified Data.Text as T
import qualified Web.Scotty as S
import Data.Char

import StockPrices.Repository (retrieveTickerPrice, createTicker)
import StockPrices.Database (getDbConnection)
import StockPrices.Environment (readConfig)
import StockPrices.Lib (getQuote)
import StockPrices.DateHelper (getDay)
import StockPrices.Model.ApiError (ApiError(..))

runApp :: IO ()
runApp = do
  config <- readConfig
  conn   <- getDbConnection config
  routes conn

routes :: Connection -> IO ()
routes conn = scotty 8080 $ do
  get "/api/getprice/:ticker/:date" $ do
    _ticker <- param "ticker" :: ActionM T.Text
    _date   <- param "date"   :: ActionM T.Text
    let invalidInput = validateInput _ticker _date
    case invalidInput of
      Just err -> do
        status status400
        S.json err
      _ -> getQuote (mapToUpper _ticker) _date conn


validateInput :: T.Text -> T.Text -> Maybe ApiError
validateInput t d = do
  let day = getDay . T.unpack $ d
  case day of
    Nothing -> Just (ApiError ["Date should be in YYYY-mm-dd format"])
    _       -> Nothing

mapToUpper :: T.Text -> T.Text
mapToUpper t = T.pack (map toUpper (T.unpack t))


