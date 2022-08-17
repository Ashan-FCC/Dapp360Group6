module StockPrices.Database (getDbConnection) where

import qualified StockPrices.Environment as E
import Database.PostgreSQL.Simple

getDbConnection :: E.Config -> IO Connection
getDbConnection (E.Config h p u pw db) = do
    connect defaultConnectInfo {
        connectHost = h,
        connectPort = p,
        connectDatabase = db,
        connectUser = u,
        connectPassword = pw
    }
