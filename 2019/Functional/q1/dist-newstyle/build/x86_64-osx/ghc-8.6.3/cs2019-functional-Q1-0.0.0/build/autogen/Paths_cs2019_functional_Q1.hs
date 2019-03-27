{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_cs2019_functional_Q1 (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/ferruccio/.cabal/bin"
libdir     = "/Users/ferruccio/.cabal/lib/x86_64-osx-ghc-8.6.3/cs2019-functional-Q1-0.0.0-inplace"
dynlibdir  = "/Users/ferruccio/.cabal/lib/x86_64-osx-ghc-8.6.3"
datadir    = "/Users/ferruccio/.cabal/share/x86_64-osx-ghc-8.6.3/cs2019-functional-Q1-0.0.0"
libexecdir = "/Users/ferruccio/.cabal/libexec/x86_64-osx-ghc-8.6.3/cs2019-functional-Q1-0.0.0"
sysconfdir = "/Users/ferruccio/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "cs2019_functional_Q1_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "cs2019_functional_Q1_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "cs2019_functional_Q1_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "cs2019_functional_Q1_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "cs2019_functional_Q1_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "cs2019_functional_Q1_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
