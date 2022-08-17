{-
module Main where

import qualified MyLib (someFunc)

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  MyLib.someFunc
-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE ScopedTypeVariables  #-}

module Main where

import qualified Data.Text as T
import Data.Time
import GHC.Generics (Generic)
import Database.PostgreSQL.Simple
import GHC.Int

localPG :: ConnectInfo
localPG = defaultConnectInfo
        { connectHost = "127.0.0.1"
        , connectDatabase = "stock_prices"
        , connectUser = "postgres"
        , connectPassword = "postgres"
        }

data TickerHistory = TickerHistory {
        ticker          :: T.Text,
        open            :: Double,
        high            :: Double,
        low             :: Double,
        closeP          :: Double,
        adjustedClose   :: Double,
        volume          :: Double,
        date            :: Day
    } deriving (Generic, FromRow, Show)


main :: IO ()
main = do
  conn <- connect localPG
  xs   <- insertTickerHistory conn (TickerHistory { ticker = "AAPL", date = (getDay "2022-08-12"),  adjustedClose = 100,   closeP = 1000,   high = 1001,  low = 989,   open = 990,   volume = 10000 })
  res  <- retrieveTickerPrice conn "NFLX" (getDay "2022-08-15")
  putStrLn . show $ res

getDay :: String -> Day
getDay s = parseTimeOrError False defaultTimeLocale "%Y-%m-%d" s :: Day

fetchQuery :: Query
fetchQuery = "SELECT ticker, close, open, low, high, adj_close, volume, date from dbo.ticker_history where ticker = ? and date = ?"

insertQuery :: Query
insertQuery = "INSERT into dbo.ticker_history (ticker, open, high, low, close, adj_close, volume, date) values (?, ?, ?, ?, ?, ?, ?, ?)"

retrieveTickerPrice :: Connection -> String -> Day -> IO [TickerHistory]
retrieveTickerPrice conn tkr date = query conn fetchQuery (tkr :: String, date :: Day)

insertTickerHistory :: Connection -> TickerHistory -> IO GHC.Int.Int64
insertTickerHistory conn (TickerHistory t d a c h l o v) = execute conn insertQuery (t, d, a, c, h, l, o, v)


