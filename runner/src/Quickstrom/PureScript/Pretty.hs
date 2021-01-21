{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Quickstrom.PureScript.Pretty where

import Data.Text.Prettyprint.Doc
import Language.PureScript.AST (SourceSpan, sourcePosColumn, sourcePosLine, spanEnd, spanName, spanStart)
import Quickstrom.Prelude
import Quickstrom.PureScript.Eval.Error
import Quickstrom.PureScript.Eval.Name

prettySourceSpan :: SourceSpan -> Doc ann
prettySourceSpan ss =
  pretty (spanName ss)
    <> colon
    <> pretty (sourcePosLine (spanStart ss))
    <> colon
    <> pretty (sourcePosColumn (spanStart ss))
    <> "-"
    <> pretty (sourcePosLine (spanEnd ss))
    <> colon
    <> pretty (sourcePosColumn (spanEnd ss))

prettyName :: Name -> Doc ann
prettyName (Name n) = pretty n

prettyModuleName :: ModuleName -> Doc ann
prettyModuleName (ModuleName n) = pretty n

prettyQualifiedName :: QualifiedName -> Doc ann
prettyQualifiedName (QualifiedName mns n) =
  concatWith (surround dot) (prettyModuleName <$> mns) <> dot <> prettyName n

prettyEvalError :: EvalError -> Doc ann
prettyEvalError = \case
  UnexpectedError _ t -> "Unexpected error:" <+> pretty t
  UnexpectedType _ t val -> "Expected value of type" <+> pretty t <+> "but got" <+> pretty val
  EntryPointNotDefined qn -> "Entry point not in scope:" <+> prettyQualifiedName qn
  InvalidEntryPoint n -> "Entry point is invalid:" <+> prettyName n
  NotInScope _ qn -> "Not in scope:" <+> either prettyQualifiedName prettyName qn
  ForeignFunctionNotSupported _ qn -> "Foreign function is not supported in Quickstrom:" <+> prettyQualifiedName qn
  InvalidString _ -> "Invalid string"
  InvalidBuiltInFunctionApplication _ _fn _param -> "Invalid function application"
  InvalidBuiltInReference _ss name -> "Invalid reference to built-in:" <+> pretty name
  ForeignFunctionError _ t -> pretty t
  InvalidURI _ input t -> "Invalid URI:" <> colon <+> pretty input <> comma <+> pretty t
  UnsupportedQueryExpression _ -> "Unsupported query expression: must not refer to local bindings"
  InvalidQueryDependency _ -> "Other queries may not depend on the result of this query"
  Undetermined -> "The formula cannot be determined as there are not enough observed states"

prettyEvalErrorWithSourceSpan :: EvalError -> Doc ann
prettyEvalErrorWithSourceSpan err =
  let prefix = case errorSourceSpan err of
        Just ss -> prettySourceSpan ss <> ":" <+> "error:"
        Nothing -> "<no source information>" <+> "error:"
   in prefix <+> prettyEvalError err
