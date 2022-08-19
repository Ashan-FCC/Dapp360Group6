{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
module StockPrices.Repository (retrieveTickerPrice, createTicker) where

import qualified Data.Text as Tt
import Data.Text.Encoding
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.Errors
import Database.PostgreSQL.Simple.Internal
import qualified StockPrices.Model.TickerHistory as T
import qualified Data.ByteString as BS
import Data.Time
import GHC.Int
import Control.Exception
import Database.PostgreSQL.Simple.Internal

fetchQuery :: Query
fetchQuery = "SELECT ticker, close, open, low, high, adj_close, volume, date from dbo.ticker_history where ticker = ? and date = ?"

insertQuery :: Query
insertQuery = "INSERT into dbo.ticker_history (ticker, open, high, low, close, adj_close, volume, date) values (?, ?, ?, ?, ?, ?, ?, ?)"

retrieveTickerPrice :: Connection -> String -> Day -> IO (Maybe T.TickerHistory)
retrieveTickerPrice conn tkr date = do
    xs <- query conn fetchQuery (tkr :: String, date :: Day)
    case xs of
        []      -> return $ Nothing
        (x:[])  -> return $ Just x

createTicker :: Connection -> T.TickerHistory -> IO (Int64)
createTicker conn (T.TickerHistory t d a c h l o v) = do
    x <- catchJust constraintViolation (execute conn insertQuery (t, d, a, c, h, l, o, v)) handler
    return x
  where
    handler :: ConstraintViolation -> IO (Int64)
    handler (NotNullViolation a)      = do
        print $ "Column can't be null" ++ (bsToStr a)
        return $ (-1)
    handler (ForeignKeyViolation t c) = do
        print $ concat ["FK violation in Table", (bsToStr t), "constraint: ", (bsToStr c) ]
        return $ (-1)
    handler (UniqueViolation a)       = do
        print $ concat ["UniqueViolation: ", (bsToStr a)]
        return $ (-1)
    handler (CheckViolation t c)      = do
        print $ concat ["Check violation in Table", (bsToStr t), "constraint: ", (bsToStr c) ]
        return $ (-1)
    handler (ExclusionViolation a)    = do
        print $ "Excelution violation: " ++ (bsToStr a)
        return $ (-1)

bsToStr :: BS.ByteString -> String
bsToStr s = Tt.unpack $ decodeUtf8 s
