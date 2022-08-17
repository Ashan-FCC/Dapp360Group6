CREATE DATABASE stock_prices OWNER postgres;
\connect stock_prices;
CREATE SCHEMA dbo;
CREATE TABLE dbo.tickers (
   id SERIAL PRIMARY KEY,
   ticker character varying(255) NOT NULL UNIQUE,
   company_name character varying(255) NOT NULL,
   created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
   updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE dbo.ticker_history (
    ticker VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    adj_close float NOT NULL,
    close float NOT NULL,
    high float NOT NULL,
    low float NOT NULL,
    open float NOT NULL,
    volume float NOT NULL
);
CREATE UNIQUE INDEX ticker_date_idx ON dbo.ticker_history(ticker, date);