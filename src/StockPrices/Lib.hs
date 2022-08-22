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
import StockPrices.Model.TickerHistory (TickerHistory(..))

import StockPrices.Repository (retrieveTickerPrice, createTicker)
import Data.Time

{-
data Quote = Quote {
  ticker          :: T.Text,
  open            :: Double,
  high            :: Double,
  low             :: Double,
  closeP          :: Double,
  adjustedClose   :: Double,
  volume          :: Double,
  date            :: T.Text
} deriving (Generic, FromRow, FromJSON, ToJSON)


instance FromRow Quote where
    fromRow = Quote <$> filed <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*>

instance FromJSON Quote where
    parseJSON (Object o) =
      Quote <$> o .:? "ticker" .!= "defaultValue" 
        <*> o .: "date"
        <*> o .: "open"
        <*> o .: "high"
        <*> o .: "low"
        <*> o .: "close"
        <*> o .: "volume"
        <*> o .: "adjClose"
    parseJSON _ = fail "Expected object for Quote"

instance ToJSON Quote where
    toJSON (Quote date open high low close volume adjClose) =
      object
        [ "ticker"   .= ticker, 
          "date"     .= date,
          "open"     .= open,
          "high"     .= high,
          "low"      .= low,
          "close"    .= close,
          "volume"   .= volume,
          "adjClose" .= adjClose,
        ]
-}

getQuote :: T.Text -> T.Text -> Connection -> ActionM ()
getQuote _ticker _date conn = do
  let result = retrieveTickerPrice conn (T.unpack _ticker) (getDay . T.unpack $ _date)
  quote <- liftIO result :: ActionM (Maybe Y.YahooQuote)
  case quote of
    Nothing -> do
        status status400
        resp <- liftIO (getStockPrice _ticker _date) :: ActionM (Y.YahooQuote)
        _ <- liftIO (createTicker conn _ticker resp) :: ActionM (Int64)
        S.json resp
    Just q  -> do
        status status200
        S.json q


getDay :: String -> Day
getDay s = parseTimeOrError False defaultTimeLocale "%Y-%m-%d" s :: Day