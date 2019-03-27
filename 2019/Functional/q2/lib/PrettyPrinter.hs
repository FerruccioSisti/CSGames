{-# OPTIONS_GHC -Wno-missing-signatures #-}
module PrettyPrinter (
    prettySymbol
  , prettyExpr
  , prettyAssignment
  , stepsToStrings
  , renderStr
  , showSymbol
  , showExpr
  , showAssignment
  , showIntermediates
  , showSteps
  , showNSteps
  )
where

import Data.Text.Prettyprint.Doc.Render.String
import Data.Text.Prettyprint.Doc

import Data.String

import qualified Language as L
import Util (splitAtLast, lengthAtLeast)

prettySymbol :: L.Symbol -> Doc ann
prettySymbol = fromString

lambda = pretty "\\"
arrow = pretty "->"
app = pretty "$"
eq = pretty "="

prettyExpr :: L.Expr -> Doc ann
prettyExpr (L.Var sym) = prettySymbol sym
prettyExpr l@(L.Lambda _ _) =
  let
    (syms, sub) = L.unnestLambda l
    prettySyms = align . fillSep $ prettySymbol <$> syms
  in
    group
    (lambda <+> prettySyms <+> arrow <>
      nest 2 (line <> prettyExpr sub))
prettyExpr a@(L.App _ _) =
  let
    (fun, args) = L.unnestApp a
    exprs = prettyParensExpr <$> (fun:args)
    notFlat = app <+> align (vsep exprs)
    flat = app <+> hsep exprs
  in
    group $ flatAlt notFlat flat

prettyParensExpr v@(L.Var _) =
  prettyExpr v
prettyParensExpr l =
  parens $ prettyExpr l

prettyAssignment :: L.Assignment -> Doc ann
prettyAssignment (sym, expr) =
  prettySymbol sym <+> eq <+> nest 2 (line <> prettyExpr expr)

hardlines docs =
  hcat $ punctuate hardline docs

prettyIntermediates :: [L.Expr] -> [Doc acc]
prettyIntermediates steps =
  zipWith (\i e ->
             pretty (i :: Int) <>
             pretty ":" <+> prettyExpr e
          ) [1..] steps

prettyLast :: L.Expr -> Doc ann
prettyLast lastStep =
  pretty "Irreducible:" <+> prettyExpr lastStep

prettySteps :: [L.Expr] -> [Doc ann]
prettySteps steps =
  let (intermediate, lastStep) = splitAtLast steps in
    prettyIntermediates intermediate ++ pure (prettyLast lastStep)

stepsToStrings :: Int -> [L.Expr] -> ([String], String)
stepsToStrings w steps =
  let (intermediate, lastStep) = splitAtLast steps in
    (renderStr w <$> prettyIntermediates intermediate,
     renderStr w $ prettyLast lastStep)

prettyNSteps :: Int -> [L.Expr] -> Doc ann
prettyNSteps n steps =
  if lengthAtLeast (n + 1) steps
  then
    let
      intermediate = take n steps
      prettyEllipsis = pretty "..."
    in
      hardlines (prettyIntermediates intermediate ++
                 pure prettyEllipsis)
  else hardlines $ prettySteps steps

renderStr :: Int -> Doc ann -> String
renderStr w =
  let
    layoutOpts = LayoutOptions {
      layoutPageWidth = AvailablePerLine w 0.4
      }
  in
    renderString . layoutSmart layoutOpts

showSymbol i = renderStr i . prettySymbol
showExpr i = renderStr i . prettyExpr
showAssignment i = renderStr i . prettyAssignment
showIntermediates i xs = renderStr i <$> prettyIntermediates xs
showSteps i = renderStr i . hardlines . prettySteps
showNSteps i n = renderStr i . prettyNSteps n
