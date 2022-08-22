{-# LANGUAGE OverloadedStrings #-}

module Lib
  ( getProduct,
    getProducts,
    createProduct,
    updateProduct,
    deleteProduct,
  )
where

import Control.Monad.IO.Class (liftIO)
import Data.Aeson
import Data.Int
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Network.HTTP.Types.Status (Status, status200, status201, status204, status400)
import Web.Scotty (ActionM, jsonData, param, post, status, text)
import qualified Web.Scotty as S

data Quote = Quote {
  ticker :: Text,
  date :: Text,
  open :: Float,
  high :: Float ,
  low :: Float ,
  close :: Float ,
  volume :: Float ,
  adjClose :: Float 
}

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

getQuote :: Connection -> ActionM ()
getQuote conn = do
  _ticker <- param "ticker" :: ActionM Str 
  _date   <- param "date"   :: ActionM Str
  let result = retrieveTickerPrice conn _ticker _date 
  quote <- liftIO result :: ActionM [Quote]
  case quote of
    [] -> do
        status status400
        S.json $ object ["error" .= ("Product not found" :: String)]
        let api getStockPrice _ticker _date
        quote <- liftIO api :: ActionM [Quote]
        createTicker conn quote 
        S.json (head api)
    _  -> do
        status status200
        S.json (head quote)
