--- Copyright 2020 The Australian National University, All rights reserved

module Controller where

import CodeWorld
import Model

import Data.Text (pack, unpack)

-- | Compute the new Model in response to an Event.
handleEvent :: Event -> Model -> Model
handleEvent event m@(Model ss t c) =
  case event of
    KeyPress key
      -- revert to an empty canvas
      | k == "Esc" -> emptyModel

      -- write the current model to the console
      | k == "D" -> trace (pack (show m)) m

      -- display the mystery image
      | k == "M" -> Model mystery t c

      | k == "Backspace" || k == "Delete" -> Model (init ss) t c  -- TODO: drop the last added shape

      | k == " " -> undefined -- case t of
          -- PolygonTool x:y:z:xs -> Model ((c, Polygon x:y:z:xs):ss) (PolygonTool []) c
          -- _ -> m

      | k == "T" -> Model ss (nextTool t) c  -- TODO: switch tool

      | k == "C" -> Model ss t (nextColour c)  -- TODO: switch colour

      | k == "Left" -> undefined  -- TODO: rotate anticlockwise

      | k == "Right" -> undefined  -- TODO: rotate clockwise

      -- ignore other events
      | otherwise -> m
      where
        k = unpack key

    PointerPress p -> undefined   -- TODO

    PointerRelease p -> undefined  -- TODO
    _ -> m

-- TODO
nextColour :: ColourName -> ColourName
nextColour color = case color of
  Black -> Red
  Red -> Orange
  Orange -> Yellow
  Yellow -> Green
  Green -> Blue
  Blue -> Purple
  Purple -> Black

-- TODO
nextTool :: Tool -> Tool
nextTool tool = case tool of
  LineTool Nothing -> PolygonTool []
  PolygonTool [] -> RectangleTool Nothing
  RectangleTool Nothing -> CircleTool Nothing
  CircleTool Nothing -> EllipseTool Nothing
  EllipseTool Nothing -> ParallelogramTool Nothing Nothing
  ParallelogramTool Nothing Nothing -> LineTool Nothing
  _ -> tool
