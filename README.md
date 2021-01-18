# Introduction

The project consists of a Haskell program made using CodeWorld API to draw colourful shapes on the screen and present their area. The program is made using the MVC (Model-View-Controller) Architecture which is widely used in building GUI Desktop/Web Apps.

# Contents
## Program Design

When the `Main` procedure is run, it calls the function `activityOf` relating to the three parts of MVC paradigm:

1.  `emptyModel` (The Initialized Model)
2.  `handleEvent` (Handles Events and makes the respective changes)
3.  `modelToPicture` (Content actually been viewed on the website)


### Model

Initially, we construct the structure of the `Model`. It is constructed in the following manner :

1.  `Shape` : List of Shapes with required specification
2.  `ColourShape` : a type Combining `Shape` and `ColourName` to give a single `ColourShape`
3.  `Tool` : List of tools with specification to build Shape
4.  `ColourName` : List of colours

We now define `Model` data type itself which combines and stores the information as a singular point of access for actions in the Controller/View. It's implementation w.r.t `[Shapes]` in the context of the current program can be thought of as a Stack data structure.

Finally `emptyModel` (The main data) is initialized to `Model` with default parameters.


### Controller

The dependency tree is given as follows:

1.  Separate functions for changing colour/tool (`nextColour` and `nextTool` respectively) in `KeyPress` is made for readability.
2.  Rotated parameter is initialized to zero on drawing `Rectangle` and `Ellipse` and when rotated it's changed by \( \frac{\pi}{180} \). (Since conversion of \( degree \leftrightarrow radians \) )
3.  While drawing the shape parameters of the current `tool` are changed and in the end, the new shape is pre-pended to the `[Shape]` with the current colour on the basis of other parameters.
4.  In cases of `LineTool`, `CircleTool`, `RectangleTool`, and `EllipseTool` combination of both `PointerPress` and `PointerRelease` is important, while in other cases (`ParallelogramTool` and `PolygonTool`) only `PointerPress` determines the overall shape.


### View

The dependency tree is given as follows:

1.  For the whole program, `coordinatePlane` needs to be shown and Information texts have to be displayed for the current colour and tool with usage instructions.
2.  `ColourShapesToPicture`  acts as a higher order function to `ColourShapeToPicture` for making a list out of individual Shapes and passing to Model.
3.  `ColourShapeToPicture` itself takes `ColourNameToColour` and `ShapeToPicture` as functions.
4.  Below table gives implementation of `ShapeToPicture` and `areaToLabel` for basic shapes

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
<caption class="t-above"><span class="table-number">Table 1:</span> Techniques Used for shapeToPicture and areaShapes</caption>

<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">**Shape Name**</th>
<th scope="col" class="org-left">**Picture Conversion**</th>
<th scope="col" class="org-left">**Area**</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Line x y</td>
<td class="org-left">`PolyLine` function on x, y</td>
<td class="org-left">By Default 0</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">Polygon [points]</td>
<td class="org-left">`SolidPolygon` function w.r.t p</td>
<td class="org-left">Calculated using Shoelace formula</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">\(\forall p \in points\)</td>
<td class="org-left">w.r.t all points</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">Rectangle (x1,y1)</td>
<td class="org-left">Calculate l,b by calculating</td>
<td class="org-left">Calculate l, b and use \(abs(lb) \)</td>
</tr>


<tr>
<td class="org-left">(x2, y2)</td>
<td class="org-left">difference between x and y components</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">and use in `solidRectangle` function</td>
<td class="org-left">&#xa0;</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">Circle c e</td>
<td class="org-left">Calculate r using distance formula on</td>
<td class="org-left">Calculate r and use \( \pi r^2 \)</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">centre (c) and edge (e) points and use</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">`solidCircle`</td>
<td class="org-left">&#xa0;</td>
</tr>
</tbody>
</table>

In addition to the listed things above:

-   `rotated` has to used with the parameters of Rectangle and Parallelogram
-   To build Rectangle, Circle, Ellipse and Parallelogram `translated` has to be used after finding out the center in the respective shapes. (After calculating their centres)

For more complex shapes :-

-   **Ellipse:**

    Let the opposite corners be \( (x_1, y_1) \) and \( (x_2, y_2) \). Initially, we calculate the length (l) and breadth (b) of major and minor axis by calculating difference between x and y components. Alongside we calculate the center to where translation needs to be done.
    
    After implementing the above there are three cases   
    <span class="underline">Case 1</span> `Length > Breadth`  : Draw Circle with Radius b and scale l by \( l/b \)   
    <span class="underline">Case 2</span> `Length < Breadth`  : Draw Circle with Radius l and scale b by \( b/l \)   
    <span class="underline">Case 3</span> `(Length || Breadth) == 0` : Make the Circle with Radius 0   
    
    For **area** we use the formula as \( \pi l b \). (l and b are calculated with `abs`)

-   **Parallelogram:**

    Given four adjacent points in terms of \( x_i , y_i \) and using the fact that diagonals of a parallelogram bisect each other, we get the following relation:
    
    Hence if the fourth point is unknown we can derive it and use `solidPolygon` on four points-
    
    For **area** of parallelogram we can think of three points as a linear transformation w.r.t taking it as basis vectors and take it's determinant in the following manner -


## Assumptions

The general assumptions is that the end user needs to know a lot of controls so he may experiment a lot with the app. So a lot of testing has been done w.r.t combinations of events.


## Testing

The Testing of the program has been done in the following manner -

-   **Mystery Image:** The mystery image exactly matches the one given in the specification, hence we can say with a high degree of certainty that `shapesToPicture` works fine since mystery image contained implementation of all `shapesToPicture`.
-   **Test Images for Area:** `Doctests` for all the shapes in area for which the area was already known were written which came out to be correct. (Written above `areaShapes` for reference).
-   **Boundary Cases:** Tested to work in all conditions with boundary cases on combinations of keypress and pointers and removed errors such as:
    1.  Picture when [Shapes] is given as an empty list to `ColourShapesToPicture` -> return `mempty`
    2.  Press `BackSpace/Esc` when there are no shapes drawn -> return [] w.r.t `[Shapes]`
    3.  Drawing when length or breadth is 0 in ellipse -> Can't scale by &infin; so make radius 0 in drawing
    4.  Pressing `Spacebar` in Polygon before clicking on three points shouldn't do anything
    5.  Not changing `tool` when the user is halfway through an operation in any shape
