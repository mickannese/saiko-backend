{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad.IO.Class
import DB
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC
import qualified Data.Text as T
import Hasql.Connection (Connection)
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Middleware.AddHeaders
import Network.Wai.Middleware.Cors
import Server
import System.Environment
import Web.Scotty

main :: IO ()
main = do
  [user, pass] <- map BC.pack <$> mapM getEnv ["POSTGRE_USER", "POSTGRE_PASS"]
  conn <- connDB (user, pass)
  putStrLn "connected!"
  scotty 3000 (route conn)

corsPolicy :: CorsResourcePolicy
corsPolicy = CorsResourcePolicy Nothing methods cont Nothing Nothing False False False
  where
    methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cont = simpleContentTypes <> ["application/json"]

sCors :: Middleware
sCors =
  addHeaders
    [ ("Access-Control-Allow-Headers", "Origin, content-type, application/json"),
      ("Access-Control-Allow-Methods", "GET, POST, PATCH, PUT, DELETE, OPTIONS"),
      ("Access-Control-Allow-Origin", "*")
    ]

route :: Connection -> ScottyM ()
route conn =
  do
    --   middleware (cors $ const (Just corsPolicy))
    --   middleware $ addHeaders [("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token")]
    middleware $ cors (const $ Just corsPolicy)
  options
  (regex ".*")
    $ do
      req <- request
      liftIO (print req)
      sts200 >> text "yee"
    get
    "/"
    handleRoot
    get
    "/channels"
    handleChannelGet
    get
    "/messages"
    handleMessageGet
    get
    "/users"
    handleUsersGet
    post
    "/channels"
    (handleChannelPost conn)
    post
    "/messages"
    (handleMessagePost conn)
    post
    "/users"
    (handleUsersPost conn)