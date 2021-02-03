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
  PolygonTool _       -> "The total area of the polygons is "
                           ++ (show $ areaShapes ss t) ++ " units."
  CircleTool _          -> "The total area of the circles is "
                           ++ (show $ areaShapes ss t) ++ " units."
  EllipseTool _         -> "The total area of the ellipses is "
                           ++ (show $ areaShapes ss t) ++ " units."
  ParallelogramTool _ _ -> "The total area of the parallelograms is "
                          ++ (show $ areaShapes ss t) ++ " units."
  _                     -> []
  where ss = map snd css


-- | Given a tool, give instructions to the user
toolToLabel :: Tool -> String
toolToLabel tool = case tool of
  LineTool _ -> "Line... click-drag-release"
  PolygonTool _ -> "Polygon... click 3 or more times then spacebar"
  RectangleTool _ -> "Rectangle... click-drag-release"
  CircleTool _ -> "Circle... click-drag-release"
  EllipseTool _ -> "Ellipse... click-drag-release"
  ParallelogramTool _ _ -> "Parallelogram... click two opposite vertices, then a third"


-- | Given a set of coloured shapes convert to picture
colourShapesToPicture :: [ColourShape] -> Picture
colourShapesToPicture = foldl (\x y -> x  & colourShapeToPicture y) mempty

-- | Given a colour and shape convert to a coloured picture
colourShapeToPicture :: ColourShape -> Picture
colourShapeToPicture (colourname, shape )= coloured
                                           (colourNameToColour colourname)
                                           (shapeToPicture shape)

-- | Convert user defined colourname to Colours of codeworld specification
colourNameToColour :: ColourName -> Colour
colourNameToColour colourname = case colourname of
  Black -> black
  Red -> red
  Orange -> orange
  Yellow -> yellow
  Green -> green
  Blue -> blue
  Purple -> purple

-- | Calculates the dimensions of shape and converts it into picture
shapeToPicture :: Shape -> Picture
shapeToPicture shape = case shape of
  Line a b -> polyline [a,b]
  Polygon a -> solidPolygon a
  Circle (a,b) (c,d) -> translated a b (solidCircle (radius (a,b) (c,d)))
  Rectangle (a,b) (c,d) rec_ang -> translated ((a+c)/2) ((b+d)/2) (
                                   rotated rec_ang (
                                       solidRectangle (abs (c-a))  (abs (d-b))
                                   ))
  Ellipse (a,b) (c,d) ell_ang -> translated ((a+c)/2) ((b+d)/2) (
                                  rotated ell_ang (
                                      ellipse (a,b) (c,d)
                                      ))
  Parallelogram (x1,y1) (x2,y2) (x3,y3) -> solidPolygon [(x1,y1),(x3,y3),(x2,y2),(x1+x2-x3,y1+y2-y3)]

-- | Helper function to draw ellipse
ellipse :: (Double, Double) -> (Double, Double) -> Picture
ellipse (a,b) (c,d) =if (c-a) == 0 || (d-b) == 0 then
                       solidCircle 0
                     else if (c-a) > (d-b) then
                            scaled (abs((c-a)/(d-b))) 1.0 (solidCircle ((d-b)/2))
                          else
                            scaled  1.0 (abs((d-b)/(c-a))) (solidCircle ((c-a)/2))

-- | Helper function to draw circle
radius :: Point -> Point -> Double
radius (a,b) (c,d) = sqrt $ (a - c)**2 + (b - d)**2

-- | Tests
-- >>> areaShapes[Line (1.0,1.0) (2.0,2.0)] (LineTool Nothing)
-- 0.0
-- >>> areaShapes [Polygon [(3,4),(5,11),(12,8),(9,5),(5,6)]] (PolygonTool [])
-- 30.0
-- >>> areaShapes[Rectangle (0.0,0.0) (2.0,4.0) 0.0 , Rectangle (5.0,5.0) (10.0,10.0) 0.0  ] (RectangleTool Nothing)
-- 33.0
-- >>> areaShapes[Circle (0.0,0.0) (0.0,2.0)] (CircleTool Nothing)
-- 12.566370614359172
-- >>> areaShapes[Ellipse (0.0,0.0) (7.0,2.0) 0.0] (EllipseTool Nothing)
-- 10.995574287564276
-- >>> areaShapes[Parallelogram (0.0,0.0) (10.0,5.0) (5.0,0.0)] (ParallelogramTool Nothing Nothing)
-- 25.0


-- | Calculates areas of Shapes with respect to the current tool
areaShapes :: [Shape] -> Tool -> Double
areaShapes a b = sum $ map helpArea filteredShapeList
  where
    filteredShapeList :: [Shape]
    filteredShapeList = case b of
                          (LineTool _) -> [x | x@Line {} <- a]
                          (PolygonTool _) -> [x | x@Polygon {} <- a]
                          (RectangleTool _) -> [x | x@Rectangle {} <- a]
                          (CircleTool _) -> [x | x@Circle {} <- a]
                          (EllipseTool _) -> [x | x@Ellipse {} <- a]
                          (ParallelogramTool _ _) -> [x | x@Parallelogram {} <- a]

det :: Point -> Point -> Double
det (x1,y1) (x2, y2) = x1 * y2 - x2 * y1

zipAdjElem :: [a] -> [(a,a)]
zipAdjElem [] = []
zipAdjElem (x:xs) = zip (x:xs) (xs ++[x])

helpArea :: Shape -> Double
helpArea shape = case shape of
  Line _ _ -> 0
  Rectangle (x1, y1) (x2, y2) _ -> abs $ (x2 - x1) * (y2 - y1)
  Polygon points -> sum $ map (abs . uncurry det) (zipAdjElem points)
  Circle x y -> pi * radius x y **2.0
  Ellipse (x1, y1) (x2, y2) _ -> abs $ pi * (x2 - x1) * (y2 - y1) / 4
  Parallelogram a b c -> abs $ det a b + det b c + det c a
