{-# LANGUAGE OverloadedStrings #-}
module StockPrices.Repository (retrieveTickerPrice, insertTickerHistory) where

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

insertTickerHistory :: Connection -> T.TickerHistory -> IO Int64
--insertTickerHistory conn (T.TickerHistory t d a c h l o v) = execute conn insertQuery (t, d, a, c, h, l, o, v)
insertTickerHistory conn (T.TickerHistory t d a c h l o v) = do
    res <- try (execute conn insertQuery (t, d, a, c, h, l, o, v))
    case res of
      Right a -> return a
      Left  b -> return (-1)


{-
createUser = handleJust constraintViolation handler $ execute conn ...
  where
    handler (UniqueViolation "user_login_key") = ...
    handler _ = ...
-}
-- handleJust :: Exception e => (e -> Maybe b) -> (b -> IO a) -> IO a -> IO a
-- constraintViolation :: SqlError -> Maybe ConstraintViolation
-- constraintViolationE :: SqlError -> Maybe (SqlError, ConstraintViolation)

-- a = IO (Maybe Int64)
{-
createTicker :: Connection -> T.TickerHistory -> IO (Maybe GHC.Int.Int64)
createTicker conn (T.TickerHistory t d a c h l o v) = do
    x <- handleJust constraintViolation handler $ execute conn insertQuery (t, d, a, c, h, l, o, v)
    case x of
      Just i -> do
        putStrLn "i is Just"
        return $ Just i
      Nothing -> return Nothing
  where
    handler :: ConstraintViolation -> IO (Maybe Int64)
    handler (NotNullViolation a)      = do
        print $ "Column can't be null" ++ (bsToStr a)
        return $ Just (-1)
    handler (ForeignKeyViolation t c) = do
        print $ concat ["FK violation in Table", (bsToStr t), "constraint: ", (bsToStr c) ]
        return $ Just (-1)
    handler (UniqueViolation a)       = do
        print $ concat ["UniqueViolation: ", (bsToStr a)]
        return $ Just (-1)
    handler (CheckViolation t c)      = do
        print $ concat ["Check violation in Table", (bsToStr t), "constraint: ", (bsToStr c) ]
        return $ Just (-1)
    handler (ExclusionViolation a)    = do
        print $ "Excelution violation: " ++ (bsToStr a)
        return $ Just (-1)
    handler _                         = return $ Nothing
-}
bsToStr :: BS.ByteString -> String
bsToStr s = Tt.unpack $ decodeUtf8 s

{-
create2 :: Connection -> T.TickerHistory -> IO (GHC.Int.Int64)
create2 conn (T.TickerHistory t d a c h l o v) = do
    catch (execute conn insertQuery (t, d, a, c, h, l, o, v)) (\e -> return $ (fromIntegral (-1):: GHC.Int.Int64))
    -}