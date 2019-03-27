module Modules
  ( MacroMap
  , ModName
  , Module (..)
  , LoadedModules
  , LoadMessage
  , LoadLog
  , substituteMacros
  , loadModules
  , extension
  ) where

import Control.Monad
import Control.Monad.Trans.Maybe
import Control.Monad.Trans.Class
import Control.Monad.Writer.Lazy

import qualified Data.Map as M
import Data.Maybe (fromMaybe)

import Language

type MacroMap = M.Map Symbol Expr

type ModName = String
data Module =
  Module { name :: ModName
         , imports :: [ModName]
         , defs :: [Assignment]
         }
  deriving (Eq, Ord, Show)

type LoadedModules = M.Map ModName (Module, MacroMap)
data LoadMessage = CyclicImport Module [Module]
                 | Loaded Module MacroMap
                 | UnboundSymbols Assignment Module
                 | UnknownModule ModName Module
type LoadLog = [LoadMessage]

instance Show LoadMessage where
  show (CyclicImport modu stack) =
    "Encountered cyclical import while processing " ++ name modu ++
    " with import stack : " ++ show (map name stack) ++ "."
  show (Loaded modu _) =
    "Loaded " ++ name modu ++ "."
  show (UnboundSymbols assign modu) =
    "Encountered unbound symbols " ++
    show (unboundSymbols $ snd assign) ++
    " in the definition of " ++ show (fst assign) ++
    " in module " ++ name modu ++ "."
  show (UnknownModule modname modu) =
    "Unknown module " ++ modname ++ " in the imports of " ++
    name modu ++ "."


substituteMacros :: MacroMap -> Expr -> Expr
substituteMacros env e@(Var s) =
  fromMaybe e $ M.lookup s env
substituteMacros env (Lambda s sub) =
  Lambda s $ substituteMacros (M.delete s env) sub
substituteMacros env (App fun arg) =
  App (substituteMacros env fun) (substituteMacros env arg)

makeImportSubs :: MacroMap -> MacroMap -> MacroMap
makeImportSubs importEnv localEnv =
  let outEnv = importEnv M.\\ localEnv in
    fmap (substituteMacros outEnv) localEnv

makeLocalSubs :: [(Symbol, Expr)] -> [(Symbol, Expr)]
makeLocalSubs assocs =
  makeLocalSubs' assocs (mempty :: MacroMap)
  where
    makeLocalSubs' [] env =
      fmap ((\x -> (x, env M.! x)) . fst) assocs
    makeLocalSubs' ((sym,expr):xs) env =
      makeLocalSubs' xs $ M.insert sym (substituteMacros env expr) env

loadModules ::
  LoadedModules -> [Module] -> (Maybe LoadedModules, LoadLog)
loadModules alreadyLoaded mods =
  runWriter $ runMaybeT $ foldM (load []) alreadyLoaded mods
  where
    ls `upto` l =
      let (a, b) = span (/= l) ls in
        a ++ take 1 b

    modMap = M.fromList $ fmap (\m -> (name m, m)) mods

    failure = MaybeT (return Nothing)

    load loading _ m
      | m `elem` loading =
          do
            lift $ tell [CyclicImport m $ reverse (m:loading `upto` m)]
            failure
    load loading loaded m =
      let
        deps = imports m
        unloadedDeps = filter (`M.notMember` loaded) deps
      in
        case unloadedDeps of
          [] ->
            let
              importEnv = foldMap snd $ map (loaded M.!) deps
              localEnv = M.fromList $ defs m
              imported = makeImportSubs importEnv localEnv
              importedAssocList =
                (\s -> (s, imported M.! s)) . fst <$> defs m
              assocs = makeLocalSubs importedAssocList
              env = M.fromList assocs
            in
              case filter (not . noUnbound . snd) assocs of
                [] ->
                    do
                      lift $ tell [Loaded m env]
                      let loaded' = M.insert (name m) (m, env) loaded
                      case loading of
                        [] -> return loaded'
                        (l:ls) ->
                          load ls loaded' l
                (unbound:_) ->
                  lift (tell [UnboundSymbols unbound m]) >> failure
          (loadNext:_) ->
            case M.lookup loadNext modMap of
              Just n -> load (m:loading) loaded n
              Nothing ->
                lift (tell [UnknownModule loadNext m]) >> failure

extension :: String
extension = "lam"
