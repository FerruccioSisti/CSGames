{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}
module Parser (
    assignParser
  , exprParser
  , modParser
  , whitespaceParser
  , parseExpr
  , parseAssign
  , parseFile
  , only
  , readExpr
  , reservedIdents
  , lexer
  ) where

import Control.Monad
import Data.Either
import Data.Functor.Identity

import qualified Text.Parsec as P
import Text.Parsec ((<|>), (<?>))
import Text.Parsec.Char
import Text.Parsec.Token

import System.FilePath

import Language as L
import Modules as M

-- Lexer
lang =
  LanguageDef
    { commentStart   = "{-"
    , commentEnd     = "-}"
    , commentLine    = "--"
    , nestedComments = True
    , identStart     = letter
    , identLetter    = alphaNum <|> oneOf "_'"
    , reservedNames  = reservedIdents
    , opStart        = opLetter lang
    , opLetter       = P.parserZero
    , reservedOpNames= []
    , caseSensitive  = True
    }

reservedIdents =
  ["module", "import", "let", "in"]

lexer = makeTokenParser lang

-- Basic symbol tokens
lambda = void $ lexeme lexer $ char '\\'
arrow = void $ lexeme lexer $ string "->"
app = void $ lexeme lexer $ char '$'
eq = void $ lexeme lexer $ char '='

-- Core syntax
varExpr =
  do
    i <- identifier lexer
    return $ L.Var i

lambdaExpr =
  do
    lambda
    ids <- P.many1 $ identifier lexer
    arrow
    L.makeNestedLambda ids <$> expr

appExpr =
  do
    app
    fun <- expr
    L.makeNestedApp fun <$> P.many1 expr

-- Synctactic sugar for a "let" expression
assignment =
  flip P.label "assignement" $
  do
    lhs <- identifier lexer
    eq
    rhs <- expr
    return (lhs, rhs)

letExpr =
  do
    reserved lexer "let"
    assigns <- commaSep1 lexer assignment
    reserved lexer "in"
    L.makeLet assigns <$> expr

-- Putting it all together
expr = varExpr
  <|> lambdaExpr
  <|> appExpr
  <|> letExpr
  <|> parens lexer expr
  <?> "expression"

-- Module syntax
modname = stringLiteral lexer

importStmt =
  do
    reserved lexer "import"
    modname

modDef =
  do
    reserved lexer "module"
    n <- modname
    _ <- dot lexer
    stmts <- P.many modStmt
    return $ M.Module n (lefts stmts) (rights stmts)
    where
      modStmt =
        do
          stmt <- P.try $ Left <$> importStmt <|>
                  Right <$> assignment
          _ <- dot lexer
          return stmt

-- Exports
only p =
  do
    res <- p
    P.eof
    return res

assignParser ::
  (P.Stream s Identity Char) => P.Parsec s () L.Assignment
assignParser = assignment

exprParser ::
  (P.Stream s Identity Char) => P.Parsec s () L.Expr
exprParser = expr

modParser ::
  (P.Stream s Identity Char) => P.Parsec s () M.Module
modParser = modDef

whitespaceParser ::
  (P.Stream s Identity Char) => P.Parsec s () ()
whitespaceParser = whiteSpace lexer

parseExpr :: String -> Either P.ParseError L.Expr
parseExpr = P.parse (only expr) "(source)"

parseAssign :: String -> Either P.ParseError L.Assignment
parseAssign = P.parse (only assignment) "(source)"

parseFile :: String -> IO (Either P.ParseError M.Module)
parseFile fname =
  do
    let fnameExt =
          if extension `isExtensionOf` fname
          then fname
          else fname <.> M.extension
    c <- readFile fnameExt
    return $ P.parse (only modDef) fname c

readExpr :: String -> Expr
readExpr = either (\e -> error (show e)) id . parseExpr
