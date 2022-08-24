{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
module StockPrices.Repository (retrieveTickerPrice, createTicker) where

import qualified Data.Text as Tt
import Data.Text.Encoding
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.Errors
import Database.PostgreSQL.Simple.Internal
import StockPrices.Model.YahooQuote
import qualified Data.ByteString as BS
import StockPrices.DateHelper (getDay)
import GHC.Int
import Control.Exception
import Data.Time

fetchQuery :: Query
fetchQuery = "SELECT date, open, high, low, close, volume, adj_close from dbo.ticker_history where ticker = ? and date = ?"

insertQuery :: Query
insertQuery = "INSERT into dbo.ticker_history (ticker, open, high, low, close, adj_close, volume, date) values (?, ?, ?, ?, ?, ?, ?, ?)"

retrieveTickerPrice :: Connection -> String -> Day -> IO (Maybe YahooQuote)
retrieveTickerPrice conn tkr date = do
    xs <- query conn fetchQuery (tkr :: String, date :: Day)
    case xs of
        []   -> return Nothing
        [x]  -> do
          print ("Data from DB: " ++ tkr)
          return $ Just x

createTicker :: Connection -> Tt.Text -> YahooQuote -> IO Int64
createTicker conn t (YahooQuote d o h l c v a) = do
  catchJust constraintViolation (execute conn insertQuery (t, o, h, l, c, a, v, d)) handler
  where
    handler :: ConstraintViolation -> IO Int64
    handler (NotNullViolation a)      = do
        print ("Column can't be null" ++ bsToStr a)
        return (-1)
    handler (ForeignKeyViolation t c) = do
        print $ concat ["FK violation in Table", bsToStr t, "constraint: ", bsToStr c ]
        return (-1)
    handler (UniqueViolation a)       = do
        print ("UniqueViolation: " ++ bsToStr a)
        return (-1)
    handler (CheckViolation t c)      = do
        print $ concat ["Check violation in Table", bsToStr t, "constraint: ", bsToStr c ]
        return (-1)
    handler (ExclusionViolation a)    = do
        print ("Excelution violation: " ++ bsToStr a)
        return (-1)

bsToStr :: BS.ByteString -> String
bsToStr s = Tt.unpack $ decodeUtf8 s
