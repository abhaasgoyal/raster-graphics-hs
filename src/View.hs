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
colourShapesToPicture a = case a of
  [x]  -> colourShapeToPicture x
  x:xs ->  (colourShapeToPicture x & colourShapesToPicture xs)
  []  -> error "in function colourShapesToPicture: Empty List given"

-- TODOw
colourShapeToPicture :: ColourShape -> Picture
colourShapeToPicture (colourname, shape)= coloured (colourNameToColour colourname) (shapeToPicture shape)

-- TODO
colourNameToColour :: ColourName -> Colour
colourNameToColour colourname = case colourname of
  Black -> black
  Red -> red
  Orange -> orange
  Yellow -> yellow
  Green -> green
  Blue -> blue
  Purple -> purple



-- TODO
shapeToPicture :: Shape -> Picture
shapeToPicture shape = case shape of
  Line a b -> polyline [a,b]
  Polygon a -> solidPolygon a
  Circle (a,b) (c,d) -> translated a b (solidCircle (sqrt ( (a-c)^(2 :: Integer) + (b-d)^(2 :: Integer) )))
  Rectangle (a,b) (c,d) rec_ang -> translated ((a+c)/2) ((b+d)/2) (
                                   rotated rec_ang (
                                       solidRectangle (abs (c-a))  (abs (d-b))
                                   ))
  Ellipse (a,b) (c,d) ell_ang -> translated ((a+c)/2) ((b+d)/2) (
                                  rotated ell_ang (
                                      ellipse (a,b) (c,d)
                                      ))
  Parallelogram (x1,y1) (x2,y2) (x3,y3) -> solidPolygon [(x1,y1),(x3,y3),(x2,y2),(x1+x2-x3,y1+y2-y3)]


-- TODO
areaShapes :: [Shape] -> Tool -> Double
areaShapes _ _ = 0

ellipse :: (Double, Double) -> (Double, Double) -> Picture
ellipse (a,b) (c,d) = if (c-a) > (d-b) then
                      scaled ((c-a)/(d-b)) 1.0 (solidCircle ((d-b)/2))
                    else
                      scaled  1.0 ((d-b)/(c-a)) (solidCircle ((c-a)/2))
