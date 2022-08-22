{-# LANGUAGE OverloadedStrings, DeriveGeneric, DeriveAnyClass #-}

module StockPrices.Lib
  ( getQuote)
where

import Control.Monad.IO.Class (liftIO)
import GHC.Generics (Generic)
import Data.Aeson
import Data.Int
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Network.HTTP.Types.Status (Status, status200, status201, status204, status400)
import Web.Scotty (ActionM, jsonData, param, post, status, text)
import qualified Web.Scotty as S
import StockPrices.YahooApi (getStockPrice)
import qualified StockPrices.Model.YahooQuote as Y
import qualified Data.Text as T
--import StockPrices.Model.TickerHistory (TickerHistory(..))
import StockPrices.DateHelper (getDay)
import StockPrices.Repository (retrieveTickerPrice, createTicker)

getQuote :: T.Text -> T.Text -> Connection -> ActionM ()
getQuote _ticker _date conn = do
  let result = retrieveTickerPrice conn (T.unpack _ticker) (getDay . T.unpack $ _date)
  quote <- liftIO result :: ActionM (Maybe Y.YahooQuote)
  case quote of
    Nothing -> do
        status status200
        resp <- liftIO (getStockPrice _ticker _date) :: ActionM (Y.YahooQuote)
        _ <- liftIO (createTicker conn _ticker resp) :: ActionM (Int64)
        S.json resp
    Just q  -> do
        status status200
        S.json q
