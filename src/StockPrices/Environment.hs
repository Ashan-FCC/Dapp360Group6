{-# LANGUAGE OverloadedStrings #-}
module StockPrices.Environment (
    Config(..),
    readConfig
) where

import System.Environment
import Control.Monad.Trans.Reader
import qualified Data.ByteString as BS
import qualified Data.Text as T
import Data.Text.Encoding
import GHC.Word

data Config = Config {
    dbHost     :: String,
    dbPort     :: Word16,
    dbUser     :: String,
    dbPassword :: String,
    dbName     :: String
} deriving (Eq, Show)

readConfig :: IO Config
readConfig = do
   host <- lookupEnv "DB_HOST"
   port <- lookupEnv "DB_PORT"
   user <- lookupEnv "DB_USER"
   pw   <- lookupEnv "DB_PASSWORD"
   db   <- lookupEnv "DB_NAME"
   case (host, port, user, pw, db) of
    (Just dbhost, Just dbport, Just dbuser, Just dbpw, Just dbname) -> return $ Config dbhost (convertPort dbport) dbuser dbpw dbname
    (Nothing, Nothing, Nothing, Nothing, Nothing)                   -> return $ Config "127.0.0.1" (convertPort "5432") "postgres" "postgres" "stock_prices"
    (Nothing, _, _, _, _)                                           -> error "DB_HOST env. variable is not set"
    (_, Nothing, _, _, _)                                           -> error "DB_PORT env. variable is not set"
    (_, _, Nothing, _, _)                                           -> error "DB_USER env. variable is not set"
    (_, _, _, Nothing, _)                                           -> error "DB_PASSWORD env. variable is not set"
    (_, _, _, _, Nothing)                                           -> error "DB_NAME env. variable is not set"

convertPort :: String -> Word16
convertPort s = read s :: Word16