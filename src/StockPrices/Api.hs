module Api where

import Database.PostgreSQL.Simple


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
  {- continue -}

