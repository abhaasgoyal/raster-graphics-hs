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

      | k == "Backspace" || k == "Delete" -> case ss of
                                             [] -> m
                                             _  -> Model (init ss) t c
      | k == " " -> case t of
          PolygonTool  (x:y:z:xs) -> Model ((c, Polygon  (x:y:z:xs)):ss) (PolygonTool []) c
          _ -> m

      | k == "T" -> Model ss (nextTool t) c  -- TODO: switch tool

      | k == "C" -> Model ss t (nextColour c)  -- TODO: switch colour
      -- TODO: FIX CONVERSION
      | k == "Left" -> case (head ss) of
          (_, Rectangle p q x) -> Model ((c, Rectangle p q (x+(1/180*pi))):(tail ss)) t c
          (_, Ellipse p q x) -> Model ((c, Ellipse p q (x+(1/180*pi))):(tail ss)) t c
          _ -> m

      | k == "Right" -> case (head ss) of
          (_, Rectangle p q x) -> Model ((c, Rectangle p q (x-(1/180*pi) )):(tail ss)) t c
          (_, Ellipse p q x) -> Model ((c, Ellipse p q (x-(1/180*pi))):(tail ss)) t c
          _ -> m
      -- ignore other events
      | otherwise -> m
      where
        k = unpack key

    PointerPress p -> case t of
      LineTool Nothing -> Model ss (LineTool (Just p)) c
      PolygonTool xs -> Model ss (PolygonTool (p:xs)) c
      RectangleTool Nothing -> Model ss (RectangleTool (Just p)) c
      CircleTool Nothing -> Model ss (CircleTool (Just p)) c
      EllipseTool Nothing -> Model ss (EllipseTool (Just p)) c
      ParallelogramTool Nothing _ -> Model ss (ParallelogramTool (Just p) Nothing) c
      ParallelogramTool (Just p') Nothing -> Model ss (ParallelogramTool (Just p') (Just p)) c
      ParallelogramTool (Just p') (Just q') -> Model ((c, Parallelogram p' q' p):ss) (ParallelogramTool Nothing Nothing) c
      _ -> m

    PointerRelease p -> case t of
      LineTool (Just q) -> Model ((c, Line p q):ss) (LineTool Nothing) c
      RectangleTool (Just q) -> Model ((c, Rectangle p q 0.0):ss) (RectangleTool Nothing) c
      CircleTool (Just q) -> Model ((c, Circle q p):ss)  (CircleTool Nothing) c
      EllipseTool (Just q) -> Model ((c, Ellipse p q 0.0):ss)  (EllipseTool Nothing) c
      _ -> m
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
