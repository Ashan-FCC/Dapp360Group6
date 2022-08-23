{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables  #-}
module StockPrices.App (runApp) where

import StockPrices.Repository (retrieveTickerPrice, createTicker)
import StockPrices.Database (getDbConnection)
import StockPrices.Environment (readConfig)
--import StockPrices.Model.TickerHistory (TickerHistory(..))
import Data.Time
import StockPrices.Lib (getQuote)
import Web.Scotty (ActionM, delete, get, post, put, scotty, param)
import Database.PostgreSQL.Simple
import qualified Data.Text as T
import qualified Web.Scotty as S
import Network.HTTP.Types.Status (status400)

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
    getQuote _ticker _date conn


validateInput :: T.Text -> T.Text -> Maybe InvalidInput
validateInput t d = undefined


data InvalidInput = InvalidInput String String
