module ColorIO where

import qualified System.Console.ANSI as A
import System.IO (Handle, hIsTerminalDevice, hPutStrLn, stderr, stdout)

printErr :: (Show s) => s -> IO ()
printErr = putErr . show

putErr :: String -> IO ()
putErr = hPutColor stderr A.Vivid A.Red

putGray :: String -> IO ()
putGray = hPutColor stdout A.Dull A.White

hPutColor :: Handle -> A.ColorIntensity -> A.Color -> String -> IO ()
hPutColor handle intensity color s =
  do
    isTerm <- hIsTerminalDevice handle
    if isTerm
      then A.hSetSGR handle $
           [A.SetColor A.Foreground intensity color]
      else return ()
    hPutStrLn handle s
    if isTerm
      then A.hSetSGR handle [A.Reset]
      else return ()
