module Main where

import Database.PostgreSQL.Simple
import Lib
import Web.Scotty (delete, get, post, put, scotty)

localPG :: ConnectInfo
localPG =
  defaultConnectInfo
    { connectHost = "0.0.0.0",
      connectDatabase = "stock_prices",
      connectUser = "postgres",
      connectPassword = "postgres"
    }

main :: IO ()
main = do
  conn <- connect localPG
  
  routes conn

routes :: Connection -> IO ()
routes conn = scotty 5433 $ do
  get "/api/getprice/:ticker" $ getQuote conn
