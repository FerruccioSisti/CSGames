{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TupleSections #-}
module Main (main) where

import qualified System.Console.Repline as R
import System.Console.Haskeline.Completion (display)
import Text.Parsec (ParseError, parse, try, (<|>))
import Text.Parsec.Token (comma)
import Data.Text.Prettyprint.Doc (Doc)
import System.Console.Terminal.Size (size, width)
import System.FilePath (isExtensionOf)
import Control.Monad.State.Strict
  (MonadState, StateT, evalStateT, get, lift, liftIO, modify, put)
import Safe (readMay)

import qualified Data.Map.Strict as M
import Data.List (isPrefixOf, isInfixOf)
import Data.Maybe (catMaybes, fromMaybe)
import System.Environment (getArgs)
import System.IO.Error (tryIOError)
import Control.Arrow ((&&&), (***))
import Control.Monad (forM_, (<=<), liftM2)

import qualified PrettyPrinter as PP
import Language
import Parser
import Evaluation
import Modules

import ColorIO

-- State
data Settings =
  Settings
  { shouldShowSteps :: Bool
  , evalStrategy :: EvalStrategy
  } deriving (Show)

data LambdaState =
  LambdaState
  { settings :: Settings
  , moduleContext :: ModuleContext
  }

newtype ModuleContext =
  ModuleContext (MacroMap, LoadedModules) deriving (Semigroup, Monoid)

moduleContextEnv :: ModuleContext -> MacroMap
moduleContextEnv (ModuleContext (env, loaded)) =
  env <> foldMap snd loaded

addAssignment :: Assignment -> LambdaState -> LambdaState
addAssignment (s, e) state =
  let (ModuleContext (env, loaded)) = moduleContext state in
    state {moduleContext = ModuleContext ((M.insert s e env), loaded)}

-- REPL monad stack
type Lambdastic a =
  R.HaskelineT (StateT LambdaState IO) a

data Cmd = A Assignment | E Expr | Noop

parseCmd :: String -> Either ParseError Cmd
parseCmd =
  parse cmdParser "(cmdline)"
  where
    cmdParser =
      try (only whitespaceParser >> return Noop) <|>
      try (only (A <$> assignParser)) <|>
      only (E <$> exprParser)

makeSubstitutions :: Expr -> Lambdastic (Either [Symbol] Expr)
makeSubstitutions expr =
  do
    state <- lift get
    let env = moduleContextEnv $ moduleContext state
    let subs = substituteMacros env expr
    return $
      case unboundSymbols subs of
        [] -> Right subs
        symbols -> Left symbols

cmd :: String -> Lambdastic ()
cmd input =
  either (liftIO . printErr) applyCommand $ parseCmd input
  where
    render :: Doc ann -> IO String
    render pretty =
      do
        s <- size
        let w = maybe 80 width s
        return $ PP.renderStr w pretty

    maybePutSteps :: Settings -> [Expr] -> Lambdastic ()
    maybePutSteps setts steps' =
      liftIO $
      do
        s <- size
        let w = maybe 80 width s
        let (intermediateSteps, lastStep) = PP.stepsToStrings w steps'
        if shouldShowSteps setts
          then
          do
            forM_ intermediateSteps (\str -> putGray str >> putStrLn "")
            putStrLn lastStep
          else
          putStrLn . PP.showExpr w $ last steps'

    applyCommand c =
      do
        state <- lift get
        case c of
          E e -> do
            maybeSubs <- makeSubstitutions e
            case maybeSubs of
              Left symbols ->
                liftIO $ putErr $ "Unbound symbols : " ++ show symbols
              Right subs ->
                let
                  steps' = steps (evalStrategy $ settings state) subs
                in
                  maybePutSteps (settings state) $ steps'
          A (s, e) -> do
            maybeSubs <- makeSubstitutions e
            case maybeSubs of
              Left symbols ->
                liftIO $ putErr $ "Unbound symbols : " ++ show symbols
              Right subs ->
                do
                  let steps' = steps (evalStrategy $ settings state) subs
                  let assignment = (s, last steps')
                  maybePutSteps (settings state) steps'
                  liftIO $
                    putStrLn <=< render $ PP.prettyAssignment assignment
                  lift . modify $ addAssignment assignment
          Noop -> return ()

symbolCompleter :: (MonadState LambdaState m) => R.WordCompleter m
symbolCompleter word =
  do
    context <- moduleContext <$> get
    let names = M.keys $ moduleContextEnv context
    let optionStrings = map ((':':) . fst) options
    return $ filter (isPrefixOf word) $ names ++ optionStrings

load :: [String] -> Lambdastic ()
load modnames =
  do
    mods <- liftIO $ catMaybes <$> mapM loadfile modnames
    state <- lift get
    let ModuleContext (env, loaded) = moduleContext state
    let (newLoaded, loadLog) = loadModules loaded mods
    liftIO $ mapM_ print loadLog
    let newModuleContext =
          ModuleContext . (env,) $ fromMaybe loaded newLoaded
    lift . put $ state {moduleContext = newModuleContext}
      where
        loadfile :: String -> IO (Maybe Module)
        loadfile fname =
          do
            res <- tryIOError $ parseFile fname
            either traceErr (either traceErr (return . Just)) res
        traceErr :: (Show s) => s -> IO (Maybe a)
        traceErr e =
          do
            printErr e
            return Nothing

set :: [String] -> Lambdastic ()
set (["shouldShowSteps", boolStr])
  | Just b <- readMay boolStr :: Maybe Bool =
      do
        state <- lift get
        let newSettings = (settings state) { shouldShowSteps = b }
        lift . put $ state { settings = newSettings }
        info
set (["evalStrategy", evalStr]) =
  do
    state <- lift get
    let setts = settings state
    let strategy =
          fromMaybe (evalStrategy setts) $
          lookup evalStr $
          (strategyName &&& id) <$> evalStrategies
    let newSettings = (settings state) { evalStrategy = strategy }
    lift . put $ state { settings = newSettings }
    info
set _ =
  liftIO $ putErr "Could not parse line"

info :: Lambdastic ()
info =
  do
    setts <- settings <$> lift get
    liftIO $
      do
        putStrLn $ "Current settings: " ++ show setts
        putStrLn $ "Available strategies: " ++ show evalStrategies

parseCmp :: String -> Either ParseError (Expr, Expr)
parseCmp =
  parse cmpParser "(cmdline)"
  where
    cmpParser =
      only $
      do
        e1 <- exprParser
        _ <- comma lexer
        e2 <- exprParser
        return (e1, e2)

both :: (a -> b) -> (a, a) -> (b, b)
both f = f *** f

equal :: [String] -> Lambdastic ()
equal args =
  case parseCmp (unwords args) of
    Right (e1, e2) ->
      do
        maybeSubs1 <- makeSubstitutions e1
        maybeSubs2 <- makeSubstitutions e2
        liftIO $
          case liftM2 (,) maybeSubs1 maybeSubs2 of
            Right subs ->
              print $ uncurry alphaEquiv $ both (eval normal) $ subs
            Left symbols ->
              putErr $ "Unbound symbols : " ++ show symbols
    Left err ->
      liftIO $ printErr err

int :: [String] -> Lambdastic ()
int args =
  either (liftIO . printErr) doInt $ parseExpr (unwords args)
  where
    doInt expr =
      do
        maybeSubs <- makeSubstitutions expr
        liftIO $
          case maybeSubs of
            Right subs ->
              print $ toInt subs
            Left symbols ->
              putErr $ "Unbound symbols : " ++ show symbols

options :: [(String, [String] -> Lambdastic ())]
options = [ ("load", load)
          , ("import", load)
          , ("set", set)
          , ("info", const info)
          , ("equal", equal)
          , ("int", int)]

filterCompleter ::
  Monad m =>
  (String -> Bool) -> R.CompletionFunc m -> R.CompletionFunc m
filterCompleter predicate comp args =
  do
    (unused, completions) <- comp args
    return (unused, filter (predicate . display) completions)

settingsCompleter :: Monad m => R.CompletionFunc m
settingsCompleter (before, after) =
  chosenCompleter (before, after)
  where
    chosenCompleter =
      case reverse before of
        bef | "evalStrategy" `isInfixOf` bef ->
              R.listCompleter $ strategyName <$> evalStrategies
        bef | "shouldShowSteps" `isInfixOf` bef ->
              R.listCompleter $ ["True", "False"]
        _ ->
          R.listCompleter ["evalStrategy", "shouldShowSteps"]

main :: IO ()
main =
  do
    putStrLn "Welcome to the Lambdastic interpreter!"
    flip evalStateT initState $
      R.evalRepl (pure "> ") cmd options (Just ':') completer initRepl
  where
    initRepl = liftIO getArgs >>= load
    initState = LambdaState (Settings True (head evalStrategies)) mempty
    fileCompleter =
      filterCompleter (extension `isExtensionOf`) R.fileCompleter
    optionCompleters =
      ((":set",settingsCompleter):
       ((,fileCompleter) <$> [":import", ":load"]))
    completer =
      R.Prefix (R.wordCompleter symbolCompleter) optionCompleters
