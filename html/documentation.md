# LiveTime Programming Language Reference

# int
A number stored as a 32-bit integer


## Constants

### int maxValue
The largest possible integer value

### int minValue
The smallest possible integer value

## Member Functions

### mod
The true modulo operator, like it's used in mathematics, useful for wrapping around values.
It returns the remainder after a floored division, always producing a result with the same sign as the divisor.
In other words: A number modulo a positive value will always be positive.
This is different from the % operator in C, C++, C#, Java or JavaScript, which returns the remainder after a truncated division.

*Example:*
```
int bufferSize = 100
int a = 107 mod bufferSize // a =  7
int b =  -1 mod bufferSize // b = 99
```

| Parameter | Type | Description                                               |
| --------- | ---- | --------------------------------------------------------- |
| divisor   | int  | Returns the remainder of a floored division by this value |

Returns int

### remainder
Returns the remainder after a truncated division, like the % operator in C, C++, C#, Java or JavaScript.

*Example:*
```
int bufferSize = 100
int a = 107 remainder bufferSize // a =  7
int b =  -1 remainder bufferSize // b = -1
```

| Parameter | Type | Description                                                 |
| --------- | ---- | ----------------------------------------------------------- |
| divisor   | int  | Returns the remainder of a truncated division by this value |

Returns int

---

# float

## Member Functions

### isValidNumber
Checks if the float is not NaN (Not a Number). If you convert a string to a float, it will be NaN if the string is not a valid number.
Dividing by 0, or taking the square root of a negative number will also result in NaN.

*Example:*
```
convertToFloat: string stringValue, float defaultValue = 0
    float floatValue = stringValue.toFloat
    return floatValue.isValidNumber ? floatValue : defaultValue
```

Returns bool

### mod
The true modulo operator, like it's used in mathematics, useful for wrapping around values.
It returns the remainder after a floored division, always producing a result with the same sign as the divisor.
In other words: A number modulo a positive value will always be positive.
This is different from the % operator in C, C++, C#, Java or JavaScript, which returns the remainder after a truncated division.

*Example:*
```
float bufferSize = 100.0
float a = 107.5 mod bufferSize // a =  7.5
float b =  -0.5 mod bufferSize // b = 99.5
```

| Parameter | Type  | Description                                               |
| --------- | ----- | --------------------------------------------------------- |
| divisor   | float | Returns the remainder of a floored division by this value |

Returns float

### remainder
Returns the remainder after a truncated division, like the % operator in C, C++, C#, Java or JavaScript.

*Example:*
```
float bufferSize = 100.0
float a = 107.5 mod bufferSize // a =  7.5
float b =  -0.5 mod bufferSize // b = -0.5
```

*Output:*
```
7
-1
```

| Parameter | Type  | Description                                                 |
| --------- | ----- | ----------------------------------------------------------- |
| divisor   | float | Returns the remainder of a truncated division by this value |

Returns float

---

# string

## Member Functions

### length
Returns the number of characters in the string

Returns int

### toUpperCase
Returns a string with each character converted to uppercase

Returns string

### toLowerCase
Returns a string with each character converted to lowercase

Returns string

### toInt
Returns int

### toFloat
Returns int

### parseJson
Returns dynamic

### parseYaml
Returns dynamic

### split
Splits the string at the given character into a list of substrings

| Parameter | Type   | Description                                                      |
| --------- | ------ | ---------------------------------------------------------------- |
| seperator | string | Separate the string at this character, optional, defaults to "," |

Returns string[]

### startsWith
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns bool

### endsWith
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns bool

### indexOf
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns int

### indexOf
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |
| startPos  | int    | Required parameter |

Returns int

### lastIndexOf
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns int

### lastIndexOf
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |
| startPos  | int    | Required parameter |

Returns int

### contains
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns bool

### isEmail
Returns bool

### substring
| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| from      | int  | Required parameter |

Returns string

### substring
| Parameter | Type | Description                       |
| --------- | ---- | --------------------------------- |
| from      | int  | Optional parameter, defaults to 0 |
| to        | int  | Required parameter                |

Returns string

### trim
Returns string

### trimStart
Returns string

### trimEnd
Returns string

---

# class List<T>
An array that grows and shrinks in size as needed


## Member Functions

### add
Add an item to the end of the list

| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| item      | T    | The item to add |


### addRange
Add an list of items to the end of the list

| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| items     | T[]  | The list of items to add |


### insert
Insert an item at a given index

| Parameter | Type | Description                                            |
| --------- | ---- | ------------------------------------------------------ |
| item      | T    | The item to insert                                     |
| index     | int  | Insert the item at this index, optional, defaults to 0 |


### insert
Insert an item at a given index

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| item      | T    | The item to insert |
| after     | T    | Required parameter |


### remove
Remove an item from the list

*Example: Remove the current player instrance from the list of playeres when they died*
```
Player
    die
        alivePlayers.remove this
```

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| item      | T    | The item to remove |


### removeAt
Remove the item at the given index from the list

| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| index     | int  | The index of the item to remove |


### removeRange
Remove a range of items from the list

*Example: Remove the first 3 players from the list*
```
players.removeRange 0 to 3
```

| Parameter | Type | Description                                                    |
| --------- | ---- | -------------------------------------------------------------- |
| from      | int  | Remove items starting from this index, optional, defaults to 0 |
| to        | int  | Remove items up to (but not including) this index              |


### removeWhere
Remove all item the meet a specific condition

*Example: Remove all players that have died.*
```
Player
    bool hasDied
 app
     gameOver
         players.removeWhere.hasDied
```

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| condition | bool(T a) | The condition to check |


### removeFirstWhere
Remove the first item the meet a specific condition

*Example: Remove the first player with a health smaller than 10.*
```
Player
    int health
app
    gameOver
        players.removeFirstWhere.health < 10
```

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| condition | bool(T a) | The condition to check |

Returns T

### ensure
Add an item to the list if it isn't already in there

| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| item      | T    | The item to add |


### ensure
Add each item from a list if it isn't already in there

| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| items     | T[]  | The list of items to add |


### contains
Returns whether the list contains the given item

| Parameter | Type | Description                          |
| --------- | ---- | ------------------------------------ |
| item      | T    | Check if the list contains this item |

Returns bool

### indexOf
The index of an item in the list

| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| item      | T    | Get the index of this item |

Returns int

### popFirst
Remove the first item from the list and return it

*Example: Print and remove "Apple" from the list*
```
let fruits = ["Apple", "Lemon", "Orange"]
print fruits.popFirst
print fruits
```

*Output:*
```
Apple
[Lemon, Orange]
```

Returns T

### length
Gets the number of items in the list

Returns int

### clear
Removes all items from the list


### random
Gets a random item from the list

Returns T

### orderBy
Sort the list by a given expression

| Parameter  | Type       | Description                    |
| ---------- | ---------- | ------------------------------ |
| expression | float(T a) | First order by this expression |

Returns T[]

### orderBy
| Parameter  | Type         | Description                    |
| ---------- | ------------ | ------------------------------ |
| expression | float(T it)  | First order by this expression |
| thenBy     | string(T it) | Then order by this expression  |

Returns T[]

### orderBy
Sort the list by a given expression

| Parameter  | Type         | Description                                                    |
| ---------- | ------------ | -------------------------------------------------------------- |
| expression | float(T a)   | First order by this expression                                 |
| order      | SortingOrder | Specifies if you want to sort in ascending or descending order |

Returns T[]

### find
Find an item the meets the given condition

*Example: Find a player with a specific id*
```
app
    getPlayerById: int id
        return players.find.id == id
```

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| condition | bool(T a) | The condition to check |

Returns T

### shuffle
Returns T[]

---

# class Dictionary<TKey, TValue>
A hashtable that maps keys to values


## Member Functions

### remove
Remove the item assosiated with the given key

| Parameter | Type | Description                                       |
| --------- | ---- | ------------------------------------------------- |
| key       | TKey | The key of the item to remove from the dictionary |


### has
Does the dictionary have an item with a specific key?

| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| key       | TKey | The key of the item to check |

Returns bool

### clear
Remove all items from the dictionary


### length
Returns int

---

# class Set<T>
A data container that stores unique values of a given type


## Member Functions

### add
Add a new element to this set, if there isn't already an element with the same value

| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| value     | T    | The value to add |


### remove
Remove a value from the set

| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| value     | T    | The value to remove |


### has
Is a certain value in the set?

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| value     | T    | The value to check |

Returns bool

### clear
Remove all items from the set


### length
Return the number of items in the set

Returns int

---

# static class json

## Static Functions

### parse
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| value     | string | Required parameter |

Returns dynamic

### stringify
| Parameter | Type    | Description        |
| --------- | ------- | ------------------ |
| value     | dynamic | Required parameter |

Returns string

---

# static class math

## Static Functions

### abs
Returns the absolute value

| Parameter | Type  | Description                               |
| --------- | ----- | ----------------------------------------- |
| value     | float | The value to return the absolute value of |

Returns float

### sign
Returns -1, 0, or 1 depending on the sign of the value

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Required parameter |

Returns float

### sqrt
Returns the positive square root of the given value

| Parameter | Type  | Description                            |
| --------- | ----- | -------------------------------------- |
| value     | float | The value to return the square root of |

Returns float

### floor
Returns the largest integer less than or equal to the given value

| Parameter | Type  | Description             |
| --------- | ----- | ----------------------- |
| value     | float | The value to round down |

Returns int

### ceil
Returns the smallest integer greater than or equal to the given value

| Parameter | Type  | Description           |
| --------- | ----- | --------------------- |
| value     | float | The value to round up |

Returns int

### round
Returns the given value rounded to the nearest integer

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | The value to round |

Returns int

### min
Returns the smallest of the given values

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| a         | float | The first value  |
| b         | float | The second value |

Returns float

### max
Returns the largest of the given values

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| a         | float | The first value  |
| b         | float | The second value |

Returns float

### sin
Returns the sine of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

### cos
Returns the cosine of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

### tan
Returns the tangent of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

### log
e raised to which power resuls in the given value?

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Required parameter |

Returns float

### log2
2 raised to which power resuls in the given value?

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Required parameter |

Returns float

### log10
10 raised to which power resuls in the given value?

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Required parameter |

Returns float

### pow
Return the given base raised to the power of the given exponent

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| base      | float | Required parameter |
| exponent  | float | Required parameter |

Returns float

### exp
Returns e raised to the power of a given number

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| exponent  | float | Required parameter |

Returns float

---

# struct Vector2

## Member Variables

### float x
The x coordinate of the vector

### float y
The y coordinate of the vector

## Member Functions

### length
The length of the vector

Returns float

---

# struct Dimension

## Constants

### Dimension auto
Automatically adjust the value to distribute the space evenly

---

# class Border

## Constants

### Border none
Display no border

---

# class FontWeight

## Constants

### FontWeight normal
Normal font weight. Same as 400.

### FontWeight bold
Bold font weight. Same as 700.

### FontWeight lighter
One relative font weight lighter than the parent element.

### FontWeight bolder
One relative font weight heavier than the parent element.

---

# class Style

## Member Variables

### AlignItems alignItems
Align the individual items along the cross axis.
Possible values: start, center, end, stretch, normal, selfStart, selfEnd, baseline, firstBaseline, flexStart, flexEnd

*Example:*
```
div display:flex, flexDirection:column, width:100%
    div "CenteredText", alignItems:center
```

### AlignContent alignContent
When wrapping, align the whole content along the cross axis.
Possible values: start, center, end, spaceEvenly, spaceBetween, spaceAround, normal, baseline, stretch, flexStart, flexEnd

### string alignSelf
The alignment for selected items inside a flexible container

### string animation
A shorthand property for all the animation properties, except the animationPlayState

### string animationDelay
When the animation will start

### string animationDirection
Whether or not the animation should play in reverse on alternate cycles

### string animationDuration
How many seconds or milliseconds an animation takes to complete one cycle

### string animationFillMode
What values are applied by the animation outside the time it is executing

### string animationIterationCount
The number of times an animation should be played

### string animationName
A name for the @keyframes animation

### string animationTimingFunction
The speed curve of the animation

### string animationPlayState
Whether the animation is running or paused

### string background
All the background properties in one declaration

### string backgroundAttachment
Whether a background-image is fixed or scrolls with the page

### Color backgroundColor
The background-color of an element. You can use a color literal to define a color, e.g. backgroundColor:#ff0000

*Example:*
```
div "Abort", backgroundColor:#ff0000
```

### Image backgroundImage
The background-image for an element

### string backgroundPosition
The starting position of a background-image

### string backgroundRepeat
How to repeat (tile) a background-image

### string backgroundClip
The painting area of the background

### string backgroundOrigin
The positioning area of the background images

### string backgroundSize
The size of the background image

### string backfaceVisibility
Whether or not an element should be visible when not facing the screen

### Border border
The border of an element.

*Example:*
```
div "Text with border", border:{width:2px, style:solid, color:#ff0000}
```

### Border borderBottom
All the borderBottom properties in one declaration

### Color borderBottomColor
The color of the bottom border. You can use a color literal to define a color, e.g. borderBottomColor:#ff0000

### Dimension borderBottomLeftRadius
The shape of the border of the bottom-left corner

### Dimension borderBottomRightRadius
The shape of the border of the bottom-right corner

### BorderStyle borderBottomStyle
The style of the bottom border

### Dimension borderBottomWidth
The width of the bottom border

### string borderCollapse
Whether the table border should be collapsed into a single border, or not

### Color borderColor
The color of an element's border. You can use a color literal to define a color, e.g. borderColor:#ff0000

### string borderImage
A shorthand property for setting or returning all the borderImage properties

### Dimension borderImageOutset
The amount by which the border image area extends beyond the border box

### string borderImageRepeat
Whether the image-border should be repeated, rounded or stretched

### string borderImageSlice
The inward offsets of the image-border

### string borderImageSource
The image to be used as a border

### Dimension borderImageWidth
The widths of the image-border

### Border borderLeft
All the borderLeft properties in one declaration

### Color borderLeftColor
The color of the left border

### BorderStyle borderLeftStyle
The style of the left border

### Dimension borderLeftWidth
The width of the left border

### Dimension borderRadius
A shorthand property for setting or returning all the four borderRadius properties

### Border borderRight
All the borderRight properties in one declaration

### Color borderRightColor
The color of the right border. You can use a color literal to define a color, e.g. borderRightColor:#ff0000

### BorderStyle borderRightStyle
The style of the right border

### Dimension borderRightWidth
The width of the right border

### Dimension borderSpacing
The space between cells in a table

### BorderStyle borderStyle
The style of an element's border (can have up to four values)

### Border borderTop
All the borderTop properties in one declaration

### Color borderTopColor
The color of the top border. You can use a color literal to define a color, e.g. borderTopColor:#ff0000

### Dimension borderTopLeftRadius
The shape of the border of the top-left corner

### Dimension borderTopRightRadius
The shape of the border of the top-right corner

### BorderStyle borderTopStyle
The style of the top border

### Dimension borderTopWidth
The width of the top border

### Dimension borderWidth
The width of an element's border (can have up to four values)

### Dimension bottom
The bottom position of a positioned element

### string boxDecorationBreak
The behaviour of the background and border at page-break or line-break

### BoxShadow boxShadow
Draws one or more drop-shadows to the box.

*Example:*
```
div "Text with box shadow", boxShadow:{offset:{8,8}, blur:50, spread:10, color:#c0c0c0}
```

### string boxSizing
Allows you to define certain elements to fit an area in a certain way

### string captionSide
The position of the table caption

### Color caretColor
The caret/cursor color of an element. You can use a color literal to define a color, e.g. caretColor:#ff0000

### string clear
The position of the element relative to floating objects

### string clip
Which part of a positioned element is visible

### Color color
The color of the text. You can use a color literal to define a color, e.g. color:#ff0000

*Example:*
```
app
    Color mainColor = #ff0000
    draw
       div "Red text", color:mainColor
       div "Blue text", color:#0000ff
```

### string columnCount
The number of columns an element should be divided into

### string columnFill
How to fill columns

### Dimension columnGap
The gap between the columns

### string columnRule
A shorthand property for setting or returning all the columnRule properties

### Color columnRuleColor
The color of the rule between columns. You can use a color literal to define a color, e.g. columnRuleColor:#ff0000

### string columnRuleStyle
The style of the rule between columns

### Dimension columnRuleWidth
The width of the rule between columns

### string columns
A shorthand property for setting or returning columnWidth and columnCount

### int columnSpan
How many columns an element should span across

### Dimension columnWidth
The width of the columns

### string content
Used with the :before and :after pseudo-elements, to insert generated content

### string counterIncrement
Increments one or more counters

### string counterReset
Creates or resets one or more counters

### Cursor cursor
The type of cursor to display for the mouse pointer

### string direction
The text direction

### Display display
An element's display type

### string emptyCells
Whether to show the border and background of empty cells, or not

### string filter
Image filters (visual effects, like blur and saturation)

### string flex
The length of the item, relative to the rest

### Dimension flexBasis
The initial length of a flexible item

### FlexDirection flexDirection
The direction of the flexible items.
Possible values: row, rowReverse, column, columnReverse

*Example:*
```
div display:flex, flexDirection:column, width:100%
    for items as item
        div text:item.text
```

### string flexFlow
A shorthand property for the flexDirection and the flexWrap properties

### float flexGrow
How much the item will grow relative to the rest

### float flexShrink
How the item will shrink relative to the rest

### FlexWrap flexWrap
Whether the flexible items should wrap or not.
Possible values: noWrap, wrap, wrapReverse

*Example:*
```
div display:flex, flexWrap:wrap, width:100%
    for items as item
        div text:item.text
```

### string cssFloat
The horizontal alignment of an element

### string font
FontStyle, fontVariant, fontWeight, fontSize, lineHeight, and fontFamily in one declaration

### string fontFamily
The font family for text

### Dimension fontSize
The font size of the text

### FontStyle fontStyle
Whether the style of the font is normal, italic or oblique.

*Example:*
```
div "Hello", fontStyle:italic
```

### string fontVariant
Whether the font should be displayed in small capital letters

### FontWeight fontWeight
The boldness of the font.
Possible values: normal, bold, lighter, bolder, or a number from 1 to 1000. Higher values mean bolder, lower numbers mean lighter.

*Example:*
```
div "Bold text", fontWeight:bold
```

### string fontSizeAdjust
Preserves the readability of text when font fallback occurs

### string fontStretch
Selects a normal, condensed, or expanded face from a font family

### Dimension gap
The gap between rows or columns

### string hangingPunctuation
Specifies whether a punctuation character may be placed outside the line box

### Dimension height
The height of an element

### string hyphens
Sets how to split words to improve the layout of paragraphs

### string icon
Provides the author the ability to style an element with an iconic equivalent

### string imageOrientation
Specifies a rotation in clockwise direction appied to an image

### string isolation
Defines whether an element must create a new stacking content

### JustifyContent justifyContent
Justify the whole content along the main axis (as in "justified text").
Possible values: start, center, end, spaceEvenly, spaceBetween, spaceAround, normal, baseline, flexStart, flexEnd

*Example:*
```
div display:flex, flexDirection:row, justifyContent:center, width:100%
    div "This is centered horizontally"
```

### Dimension left
The left position of a positioned element

### Dimension letterSpacing
The space between characters in a text

### string lineHeight
The distance between lines in a text

### string listStyle
ListStyleImage, listStylePosition, and listStyleType in one declaration

### string listStyleImage
An image as the list-item marker

### string listStylePosition
The position of the list-item marker

### string listStyleType
The list-item marker type

### Margin margin
Can be single float like 8 an object like {top:8, right:8, bottom:8, left:8}

### Margin inset
A shorthand for the top, right, bottom, left properties

### Dimension marginBottom
The bottom margin of an element

### Dimension marginLeft
The left margin of an element

### Dimension marginRight
The right margin of an element

### Dimension marginTop
The top margin of an element

### Dimension maxHeight
The maximum height of an element

### Dimension maxWidth
The maximum width of an element

### Dimension minHeight
The minimum height of an element

### Dimension minWidth
The minimum width of an element

### string navDown
Where to navigate when using the arrow-down navigation key

### string navIndex
The tabbing order for an element

### string navLeft
Where to navigate when using the arrow-left navigation key

### string navRight
Where to navigate when using the arrow-right navigation key

### string navUp
Where to navigate when using the arrow-up navigation key

### ObjectFit objectFit
Specifies how the contents of a replaced element should be fitted its box

### string objectPosition
Specifies the alignment of the replaced element inside its box

### float opacity
The opacity level for an element

### int order
The order of the flexible item, relative to the rest

### string orphans
The minimum number of lines that must be left at the bottom before a page-break

### Border outline
All the outline properties in one declaration

### Color outlineColor
The color of the outline around a element. You can use a color literal to define a color, e.g. outlineColor:#ff0000

### string outlineOffset
Offsets an outline, and draws it beyond the border edge

### string outlineStyle
The style of the outline around an element

### Dimension outlineWidth
The width of the outline around an element

### Overflow overflow
What to do with content that renders outside the element box

### Overflow overflowX
Specifies what to do with the left/right edges of content rendering outside the element box

### Overflow overflowY
Specifies what to do with the top/bottom edges of content rendering outside the element box

### Padding padding
Can be single float like 8 an object like {top:8, right:8, bottom:8, left:8}

### Dimension paddingBottom
The bottom padding of an element

### Dimension paddingLeft
The left padding of an element

### Dimension paddingRight
The right padding of an element

### Dimension paddingTop
The top padding of an element

### string pageBreakAfter
The page-break behavior after an element

### string pageBreakBefore
The page-break behavior before an element

### string pageBreakInside
The page-break behavior inside an element

### string perspective
The perspective on how 3D elements are viewed

### string perspectiveOrigin
The bottom position of 3D elements

### Position position
The type of positioning method used for an element.
Possible values: absolute, relative, fixed, sticky, static

*Example:*
```
div position:absolute, left:0px, top:0px
    div "This is positioned in the top left corner"
```

### string quotes
The type of quotation marks for embedded quotations

### string resize
Whether or not an element is resizable by the user

### Dimension right
The right position of a positioned element

### string scrollBehavior
Specifies whether to smoothly animate the scroll position when a link is clicked

### string tableLayout
The way to lay out table cells, rows, and columns

### string tabSize
The length of the tab-character

### TextAlign textAlign
The horizontal alignment of text.
Possible values: left, center, right, justify, start, end, matchParent

*Example:*
```
div textAlign:center text:"This is centered horizontally"
```

### string textAlignLast
How the last line of a block is aligned when text-align is "justify"

### string textDecoration
The decoration of a text

### Color textDecorationColor
The color of the text-decoration. You can use a color literal to define a color, e.g. textDecorationColor:#ff0000

### string textDecorationLine
The type of line in a text-decoration

### string textDecorationStyle
The style of the line in a text decoration

### string textIndent
The indentation of the first line of text

### string textJustify
The justification method used when text-align is "justify"

### TextOverflow textOverflow
What should happen when text overflows the containing element.
Possible values: ellipsis, clip

*Example:*
```
div textOverflow:ellipsis text:"This is an example of text overflow"
```

### string textShadow
The shadow effect of a text

### string textTransform
The capitalization of a text

### Dimension top
The top position of a positioned element

### string transform
Applies a 2D or 3D transformation to an element

### string transformOrigin
The position of transformed elements

### string transformStyle
How nested elements are rendered in 3D space

### string transition
A shorthand property for setting or returning the four transition properties

### string transitionProperty
The CSS property that the transition effect is for

### string transitionDuration
How many seconds or milliseconds a transition effect takes to complete

### string transitionTimingFunction
The speed curve of the transition effect

### string transitionDelay
When the transition effect will start

### string unicodeBidi
Whether the text should be overridden to support multiple languages in the same document

### string userSelect
Whether the text of an element can be selected or not

### string verticalAlign
The vertical alignment of the content in an element

### string visibility
Whether an element should be visible

### WhiteSpace whiteSpace
How to handle tabs, line breaks and whitespace in a text

### Dimension width
The width of an element

### string wordBreak
Line breaking rules for non-CJK scripts

### string wordSpacing
The spacing between words in a text

### string wordWrap
Allows long, unbreakable words to be broken and wrap to the next line

### string widows
The minimum number of lines for an element that must be visible at the top of a page

### int zIndex
The stack order of a positioned element

### string gridTemplateColumns
The line names and track sizing functions of the grid columns

### Vector2 translate
Move the element by this vector

### Angle rotate
Rotate the element by this angle

---

# class Attributes

## Member Variables

### string id
A unique string to indentify a specic element, often used to style a single element

### string class
A string to assign a class to one or more elements, often used to style several elements

### string key
A unique identifier used to find the html element that should be reused

### void() onClick
Execute this code when the user releases the left mouse button on the HTML element

### void(HtmlEvent ev) onRightClick
Execute this code when the user releases the right mouse button on the HTML element

### void(PointerEvent ev) onPointerDown
Execute this code when the user presses down the left mouse button on the HTML element

### void(PointerEvent ev) onPointerOver
Execute this code when the pointer hovers over the element

### void(PointerEvent ev) onPointerOut
Execute this code when the pointer stops hovering over the element

### void(HtmlKeyboardEvent ev) onKeyDown
Execute this code when the user presses a key on the keyboard

### void(HtmlKeyboardEvent ev) onKeyUp
Execute this code when the user releases a key on the keyboard

### void(FocusEvent ev) onBlur
Execute this code when the element loses focus

### void(FocusEvent ev) onFocus
Execute this code when the element gains focus

---

# static class Time
In LiveTime, the term "time" always means the number of milliseconds since 1 January 1970


## Static Functions

### now
The number of milliseconds elapsed since 1 January 1970

Returns float

---

# static class html

## Global Functions

### div
Render a html element within the draw function. It renders a div by default, but you can specify a different tag.
In addition to the listed parameters, you can also specify html attributes and css styles.
You can use all members of the Styles class as parameters to apply css styles to the element.
You can use all members of the Attributes class as parameters to apply html attributes to the element.
You can render the children of the element in an indented block of code underneath the div.

*Example:*
```
app
    draw
        column gap:30, fontSize:60, margin:{top:80 left:80}, width:100%
            div tag:"h1", text:"Todo List"
            for items as item
		           div text:item.text, fontStyle:italic
```

| Parameter | Type    | Description                                                                                                      |
| --------- | ------- | ---------------------------------------------------------------------------------------------------------------- |
| text      | string  | The text content of the element, optional, defaults to null                                                      |
| tag       | string  | The tag of element, defaults to "div", optional, defaults to "div"                                               |
| data      | dynamic | The data attributes of the element, optional, defaults to {}                                                     |
| onHover   | Style   | Apply this css style to the element when the user moves their mouse over the element, optional, defaults to null |
| children  | void()  | A block of code that renders the children of the element, optional, defaults to null                             |

Returns HTMLElement

### img
Render an image html element within the draw function.
Place an image in the folder "assets/pb_public/media" and it will automatically show up in the auto completions (without the file extension).


*Example: We place the image "OkButton.png" in "assets/pb_public/media".*
```
app
    int clicks = 0
    draw
        div "You clicked {clicks} times."
        img OkButton, onClick:clicks++; refresh
```

*Example: We place the images "On.png" and "Off.png" in "assets/pb_public/media".*
```
app
    bool isOn = true
    draw
        img isOn ? On : Off, onClick:isOn = not isOn; refresh
```

| Parameter | Type               | Description                                                       |
| --------- | ------------------ | ----------------------------------------------------------------- |
| image     | Image              | The image to display                                              |
| onClick   | void(HtmlEvent ev) | Called when the user clicks the image, optional, defaults to null |
| data      | dynamic            | The data attributes of the element, optional, defaults to null    |
| visible   | bool               | Optional parameter, defaults to true                              |

Returns HTMLElement

### img
Render an external image html element within the draw function.

*Example:*
```
User
    string name
    string profilePicture
    drawProfile
        div name
        img profilePicture
app
    User user
    draw
        user.drawProfile
```

| Parameter | Type   | Description                      |
| --------- | ------ | -------------------------------- |
| src       | string | The file of the image to display |

Returns HTMLElement

### button
Render a html button element within the draw function.
You can specify the onClick handler in an indented block of code underneath the button.

*Example:*
```
app
    int clicks = 0
    draw
        button "You clicked {clicks} times."
            clicks++
            refresh
```

| Parameter           | Type   | Description                                                                                                                     |
| ------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------- |
| text                | string | The text to display on the button, optional, defaults to null                                                                   |
| onClick             | void() | Called when the user clicks the button, optional, defaults to null                                                              |
| triggerWithEnterKey | bool   | Make this the default button that triggers the onClick handler when the user presses the enter key, optional, defaults to false |

Returns HTMLElement

### button
| Parameter         | Type               | Description                                                              |
| ----------------- | ------------------ | ------------------------------------------------------------------------ |
| text              | string             | The text to display on the button, optional, defaults to null            |
| onClick           | bool(HtmlEvent ev) | Called when the user clicks the button, optional, defaults to null       |
| disableAfterClick | bool               | Disable the button after the user clicks it, optional, defaults to false |

Returns HTMLElement

### row
Render a html div element with a flex layout and a flex direction of row
Convenience shortcut for: div display:flex, flexDirection:row

*Example:*
```
app
    drawToolbar
        row gap:8, alignItems:center, justifyContent:spaceBetween, width:100%
            img OpenIcon, size:{32,32}
            img SaveIcon, size:{32,32}
```

| Parameter | Type   | Description                                                  |
| --------- | ------ | ------------------------------------------------------------ |
| children  | void() | The children of the HTML element, optional, defaults to null |

Returns HTMLElement

### column
Render a html div element with a flex layout and a flex direction of column.
Convenience shortcut for: div display:flex, flexDirection:column

*Example:*
```
app
    drawSidebar
        column gap:8, alignItems:end, justifyContent:start, width:100%
            for sidebarItems as item
                div item.text, color:#808080
```

| Parameter | Type   | Description                                                  |
| --------- | ------ | ------------------------------------------------------------ |
| children  | void() | The children of the HTML element, optional, defaults to null |

Returns HTMLElement

### link
Render a html anchor element to link to a url

| Parameter | Type   | Description                          |
| --------- | ------ | ------------------------------------ |
| text      | string | Optional parameter, defaults to null |
| href      | string | Optional parameter, defaults to "#"  |

Returns HTMLElement

### span
Render a html span element to display text

| Parameter | Type   | Description                                                     |
| --------- | ------ | --------------------------------------------------------------- |
| text      | string | The text to display within the span, optional, defaults to null |

Returns HTMLElement

### input
Render a html input element in the draw function

| Parameter   | Type               | Description                                                                   |
| ----------- | ------------------ | ----------------------------------------------------------------------------- |
| value       | string             | The value to display in the field, optional, defaults to ""                   |
| placeholder | string             | The placeholder text to display in the field, optional, defaults to ""        |
| readOnly    | bool               | Whether the field should be read only, optional, defaults to false            |
| onInput     | void(string value) | Called immediately after every keystroke, optional, defaults to null          |
| focused     | bool               | Whether the cursor should be placed in the field, optional, defaults to false |
| data        | dynamic            | The data attributes of the element, optional, defaults to {}                  |

Returns HTMLElement

---

# static class http

## Static Functions

### get
Fetch JSON data from a url with a http GET request. Returns a promise to the parsed JSON response.

*Example:*
```
dynamic config = await http.get "/api/config.json"
```

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| url       | string | Required parameter |

Returns Promise<dynamic>

### getText
Fetch a string from a url with a http GET request. Returns a promise to the text response.
string configString = await http.getText "/api/config.txt"

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| url       | string | Required parameter |

Returns Promise<string>

### post
Fetch JSON data from a url with a http POST request. Returns a promise to the parsed JSON response.

*Example:*
```
User user = {name:"John", age:30}
dynamic result = await http.post "/api/saveUser", user
```

| Parameter | Type    | Description                                                                    |
| --------- | ------- | ------------------------------------------------------------------------------ |
| url       | string  | Required parameter                                                             |
| body      | dynamic | The body object that will be send as a JSON string, optional, defaults to null |

Returns Promise<dynamic>

---

# static class database
Use this static class to login and logout users from the PocketBase backend.
You can administer the local PocketBase instance at: http://localhost:8090/_
If you want to dive deeper into PocketBase, you can find the complete documentation at: https://pocketbase.io/docs/

*Example:*
```
class User
    string id
    string name
static class app
    User user
    start
        user = await database.getAuthenticatedUser
        refresh
    login: string email, string password
        user = await database.authWithPassword email, password
        refresh
    logout
        database.logout
        user = null
        refresh
```


## Static Functions

### getAuthenticatedUser
Calls the PocketBase authRefresh function to get the authenticated user. Call this function when the application starts.

*Example:*
```
app
    User user
    start
        user = await database.getAuthenticatedUser
        refresh
```

Returns Promise<dynamic>

### authWithPassword
Log in a user with an email and password and return the authenticated user

*Example:*
```
app
   drawLogin
       field model:email, type:email, placeholder:"Email"
       field model:password, type:password, placeholder:"Password"
       button text:"Login", padding:buttonPadding, color:white, backgroundColor:primaryColor
           onClick:
               user = await database.authWithPassword email, password
```

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| email     | string | Required parameter |
| password  | string | Required parameter |

Returns Promise<dynamic>

### signupNewUser
Create a new user and then call authWithPassword to log in the user.
Ensure the user object has a valid email, password and passwordConfirm member variables.

*Example:*
```
app
   User user
   drawSignup
       field model:user.email, type:email, placeholder:"Email"
       field model:user.password, type:password, placeholder:"Choose Password"
       field model:user.passwordConfirm, type:password, placeholder:"Confirm Password"
       button text:"Signup", padding:buttonPadding, color:white, backgroundColor:primaryColor
           onClick:
               await database.signupNewUser user
```

| Parameter | Type    | Description        |
| --------- | ------- | ------------------ |
| user      | dynamic | Required parameter |

Returns Promise<dynamic>

### logout
Log out the current user

*Example:*
```
app
    User user
    logout
        database.logout
        user = null
```


---

# class DatabaseTable<T>
Use this class to add, remove, fetch and update items from a remote PocketBase collection.
The items are stored locally in the member variable "items". Use the functions "get", "find", "where" and "length" to access the local items.
You can also subscribe to changes in the remote PocketBase collection to automatically keep the local items up to date in realtime.


## Member Variables

### string name
The name of the remote PocketBase collection

### T[] items
The items you fetch from the database are stored locally in this list

## Member Functions

### add
Add an item to the database table and the local items and set its id member variable to the id assigned by the database

*Example:*
```
class Item
    string id
    string name
app
    DatabaseTable<Item> items = {name:"items"}
    string newItemName
    draw
        field model:newItemName, placeholder:"Item name"
        button text:"Add", onClick:addItem {name:newItemName}
    addItem: Item item
        await items.add item
        print "Added item to database and assigned id: {item.id}"
        refresh
```

| Parameter | Type | Description                                                          |
| --------- | ---- | -------------------------------------------------------------------- |
| item      | T    | An item with a id member variable of type string that is not set yet |

Returns Promise<void>

### remove
Remove an item from the database table and the local items

*Example:*
```
app
    DatabaseTable<Item> items = {name:"items"}
    draw
        for items as item
            div item.name
            div "Remove item", onClick:items.remove item; refresh
```

| Parameter | Type | Description                                            |
| --------- | ---- | ------------------------------------------------------ |
| item      | T    | An item with a valid id member variable of type string |

Returns Promise<void>

### fetchAll
Fetch all items from the database table and store them locally in the member variable "items"

*Example:*
```
class Item
    string id
    string name
app
    DatabaseTable<Item> items = {name:"items"}
    start
        await items.fetchAll
        refresh
    draw
        for items as item
            div item.name
```

Returns Promise<T[]>

### fetch
Fetch a subset of items from the database table and store them locally in the member variable "items"

*Example:*
```
class Item
    string id
    string userId
    string active
    TimeString created
app
    DatabaseTable<Item> items = {name:"items"}
    User user
    start
        await items.fetch filter:"userId = '{user.id}' && active = true", sort:"-created"
        refresh
    draw
        div "{user.name} has {items.length} active items:"
        for items as item
            div item.name
```

| Parameter | Type   | Description                          |
| --------- | ------ | ------------------------------------ |
| filter    | string | Optional parameter, defaults to null |
| sort      | string | Optional parameter, defaults to null |
| fields    | string | Optional parameter, defaults to null |
| expand    | string | Optional parameter, defaults to null |
| page      | int    | Optional parameter, defaults to 1    |
| perPage   | int    | Optional parameter, defaults to 1000 |
| skipTotal | bool   | Optional parameter, defaults to true |

Returns Promise<T[]>

### fetchOne
Fetch and return a single item from the database table

| Parameter | Type   | Description                          |
| --------- | ------ | ------------------------------------ |
| filter    | string | Optional parameter, defaults to ""   |
| sort      | string | Optional parameter, defaults to null |
| expand    | string | Optional parameter, defaults to null |

Returns Promise<T>

### fetchOneById
Fetch and return a single item from the database by id

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| id        | string | Required parameter |

Returns Promise<T>

### update
Update an item with a valid id member variable in the database table and the local items

*Example:*
```
app
    DatabaseTable<Item> items = {name:"items"}
    drawItem: Item item
        div "{item.name}, active:{item.active}"
        div "Make item active", onClick:items.update item, {active:true}; refresh
```

| Parameter | Type    | Description        |
| --------- | ------- | ------------------ |
| item      | T       | Required parameter |
| update    | dynamic | Required parameter |

Returns Promise<void>

