--- Copyright 2020 The Australian National University, All rights reserved

module View where

import CodeWorld
import Data.Text (pack)
import Model

-- | Render all the parts of a Model to a CodeWorld picture.
modelToPicture :: Model -> Picture
modelToPicture (Model ss t c)
  = translated 0 8 toolText
  & translated 0 7 colourText
  & translated 0 (-8) areaText
  & colourShapesToPicture ss
  & coordinatePlane
  where
    colourText = stringToText (show c)
    toolText = stringToText (toolToLabel t)
    areaText = stringToText (areaToLabel ss t)
    stringToText = lettering . pack

{- | Using the areaShapes function, return a string that describes the area
   of all the shapes matching the current tool. -}
areaToLabel :: [ColourShape] -> Tool -> String
areaToLabel css t = case t of
  RectangleTool _       -> "The total area of the rectangles is "
                           ++ (show $ areaShapes ss t) ++ " units."
  CircleTool _          -> "The total area of the circles is "
                           ++ (show $ areaShapes ss t) ++ " units."
  EllipseTool _         -> "The total area of the ellipses is "
                           ++ (show $ areaShapes ss t) ++ " units."
  ParallelogramTool _ _ -> "The total area of the parallelograms is "
                          ++ (show $ areaShapes ss t) ++ " units."
  _                     -> []
  where ss = map snd css


-- TODO
toolToLabel :: Tool -> String
toolToLabel tool = case tool of
  LineTool _ -> "Line... click-drag-release"
  PolygonTool _ -> "Polygon... click 3 or more times then spacebar"
  RectangleTool _ -> "Rectangle... click-drag-release"
  CircleTool _ -> "Circle... click-drag-release"
  EllipseTool _ -> "Ellipse... click-drag-release"
  ParallelogramTool _ _ -> "Parallelogram... click two opposite vertices, then a third"


-- TODO
colourShapesToPicture :: [ColourShape] -> Picture
colourShapesToPicture = undefined

-- TODO
colourShapeToPicture :: ColourShape -> Picture
colourShapeToPicture = undefined

-- TODO
colourNameToColour :: ColourName -> Colour
colourNameToColour = undefined

-- TODO
shapeToPicture :: Shape -> Picture
shapeToPicture = undefined

-- TODO
areaShapes :: [Shape] -> Tool -> Double
areaShapes = undefined
