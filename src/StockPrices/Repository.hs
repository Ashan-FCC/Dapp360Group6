module StockPrices.Repository (retrieveTickerPrice, insertTickerHistory) where

import Database.PostgreSQL.Simple
import qualified StockPrices.Model.TickerHistory as T
import Data.Time
import GHC.Int

fetchQuery :: Query
fetchQuery = "SELECT ticker, close, open, low, high, adj_close, volume, date from dbo.ticker_history where ticker = ? and date = ?"

insertQuery :: Query
insertQuery = "INSERT into dbo.ticker_history (ticker, open, high, low, close, adj_close, volume, date) values (?, ?, ?, ?, ?, ?, ?, ?)"

retrieveTickerPrice :: Connection -> String -> Day -> IO [T.TickerHistory]
retrieveTickerPrice conn tkr date = query conn fetchQuery (tkr :: String, date :: Day)

insertTickerHistory :: Connection -> T.TickerHistory -> IO GHC.Int.Int64
insertTickerHistory conn (T.TickerHistory t d a c h l o v) = execute conn insertQuery (t, d, a, c, h, l, o, v)