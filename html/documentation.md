# LiveTime Programming Language Reference

# int
A number stored as a 32-bit integer

## maxValue
*Static public constant of type int of int*

The largest possible integer value

## minValue
*Static public constant of type int of int*

The smallest possible integer value

---

# string

## length
*Public member function of string*

Returns the number of characters in the string

Returns int

## toUpperCase
*Public member function of string*

Returns a string with each character converted to uppercase

Returns string

## toLowerCase
*Public member function of string*

Returns a string with each character converted to lowercase

Returns string

## toInt
*Public member function of string*

Returns int

## toFloat
*Public member function of string*

Returns int

## parseJson
*Public member function of string*

Returns dynamic

## split
*Public member function of string*

Splits the string at the given character into a list of substrings

| Parameter | Type   | Description                                                      |
| --------- | ------ | ---------------------------------------------------------------- |
| seperator | string | Separate the string at this character, optional, defaults to "," |

Returns string[]

## startsWith
*Public member function of string*

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns bool

## endsWith
*Public member function of string*

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns bool

## indexOf
*Public member function of string*

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns int

## indexOf
*Public member function of string*

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |
| startPos  | int    | Required parameter |

Returns int

## lastIndexOf
*Public member function of string*

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns int

## lastIndexOf
*Public member function of string*

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |
| startPos  | int    | Required parameter |

Returns int

## contains
*Public member function of string*

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| str       | string | Required parameter |

Returns bool

## substring
*Public member function of string*

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| from      | int  | Required parameter |

Returns string

## substring
*Public member function of string*

| Parameter | Type | Description                       |
| --------- | ---- | --------------------------------- |
| from      | int  | Optional parameter, defaults to 0 |
| to        | int  | Required parameter                |

Returns string

## trim
*Public member function of string*

Returns string

## trimStart
*Public member function of string*

Returns string

## trimEnd
*Public member function of string*

Returns string

---

# List
A data container that grows in size as needed

## add
*Public member function of List*

Add an item to the end of the list

| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| item      | T    | The item to add |

## addRange
*Public member function of List*

Add an list of item to the end of the list

| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| items     | T[]  | The list of items to add |

## insert
*Public member function of List*

Insert an item at a given index

| Parameter | Type | Description                                            |
| --------- | ---- | ------------------------------------------------------ |
| item      | T    | The item to insert                                     |
| index     | int  | Insert the item at this index, optional, defaults to 0 |

## insert
*Public member function of List*

Insert an item at a given index

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| item      | T    | The item to insert |
| after     | T    | Required parameter |

## remove
*Public member function of List*

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

## removeAt
*Public member function of List*

Remove the item at the given index from the list

| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| index     | int  | The index of the item to remove |

## removeRange
*Public member function of List*

Remove a range of items from the list

*Example: Remove the first 3 players from the list*
```
players.removeRange 0 to 3
```

| Parameter | Type | Description                                                    |
| --------- | ---- | -------------------------------------------------------------- |
| from      | int  | Remove items starting from this index, optional, defaults to 0 |
| to        | int  | Remove items up to (but not including) this index              |

## removeWhere
*Public member function of List*

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

## removeFirstWhere
*Public member function of List*

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

## ensure
*Public member function of List*

Add an item to the list if it isn't already in there

| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| item      | T    | The item to add |

## ensure
*Public member function of List*

Add each item from a list if it isn't already in there

| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| items     | T[]  | The list of items to add |

## contains
*Public member function of List*

Returns whether the list contains the given item

| Parameter | Type | Description                          |
| --------- | ---- | ------------------------------------ |
| item      | T    | Check if the list contains this item |

Returns bool

## indexOf
*Public member function of List*

The index of an item in the list

| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| item      | T    | Get the index of this item |

Returns int

## popFirst
*Public member function of List*

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

## length
*Public member function of List*

Gets the number of items in the list

Returns int

## clear
*Public member function of List*

Removes all items from the list

## random
*Public member function of List*

Gets a random item from the list

Returns T

## orderBy
*Public member function of List*

Sort the list by a given expression

| Parameter  | Type       | Description                    |
| ---------- | ---------- | ------------------------------ |
| expression | float(T a) | First order by this expression |

Returns T[]

## orderBy
*Public member function of List*

| Parameter  | Type         | Description                    |
| ---------- | ------------ | ------------------------------ |
| expression | float(T it)  | First order by this expression |
| thenBy     | string(T it) | Then order by this expression  |

Returns T[]

## orderBy
*Public member function of List*

Sort the list by a given expression

| Parameter  | Type         | Description                                                    |
| ---------- | ------------ | -------------------------------------------------------------- |
| expression | float(T a)   | First order by this expression                                 |
| order      | SortingOrder | Specifies if you want to sort in ascending or descending order |

Returns T[]

## find
*Public member function of List*

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

## shuffle
*Public member function of List*

Returns T[]

---

# Map
A data container that stores key-value pairs

## remove
*Public member function of Map*

Remove the item assosiated with the given key

| Parameter | Type | Description                                |
| --------- | ---- | ------------------------------------------ |
| key       | TKey | The key of the item to remove from the map |

## has
*Public member function of Map*

Does the map have an item with a specific key?

| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| key       | TKey | The key of the item to check |

Returns bool

## clear
*Public member function of Map*

Remove all items from the map

## length
*Public member function of Map*

Returns int

---

# object
The base class for all classes

## toJson
*Static public function of object*

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| value     | any  | Required parameter |

Returns string

---

# class Set
A data container that stores unique values of a given type

## add
*Public member function of class Set*

Add a new element to this set, if there isn't already an element with the same value

| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| value     | T    | The value to add |

## remove
*Public member function of class Set*

Remove a value from the set

| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| value     | T    | The value to remove |

## has
*Public member function of class Set*

Is a certain value in the set?

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| value     | T    | The value to check |

Returns bool

## clear
*Public member function of class Set*

Remove all items from the set

## length
*Public member function of class Set*

Return the number of items in the set

Returns int

---

# class math

## abs
*Static public function of class math*

Returns the absolute value

| Parameter | Type  | Description                               |
| --------- | ----- | ----------------------------------------- |
| value     | float | The value to return the absolute value of |

Returns float

## sign
*Static public function of class math*

Returns -1, 0, or 1 depending on the sign of the value

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Required parameter |

Returns float

## sqrt
*Static public function of class math*

Returns the positive square root of the given value

| Parameter | Type  | Description                            |
| --------- | ----- | -------------------------------------- |
| value     | float | The value to return the square root of |

Returns float

## floor
*Static public function of class math*

Returns the largest integer less than or equal to the given value

| Parameter | Type  | Description             |
| --------- | ----- | ----------------------- |
| value     | float | The value to round down |

Returns int

## ceil
*Static public function of class math*

Returns the smallest integer greater than or equal to the given value

| Parameter | Type  | Description           |
| --------- | ----- | --------------------- |
| value     | float | The value to round up |

Returns int

## round
*Static public function of class math*

Returns the given value rounded to the nearest integer

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | The value to round |

Returns int

## min
*Static public function of class math*

Returns the smallest of the given values

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| a         | float | The first value  |
| b         | float | The second value |

Returns float

## max
*Static public function of class math*

Returns the largest of the given values

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| a         | float | The first value  |
| b         | float | The second value |

Returns float

## sin
*Static public function of class math*

Returns the sine of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

## cos
*Static public function of class math*

Returns the cosine of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

## tan
*Static public function of class math*

Returns the tangent of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

## log
*Static public function of class math*

e raised to which power resuls in the given value?

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Required parameter |

Returns float

## log2
*Static public function of class math*

2 raised to which power resuls in the given value?

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Required parameter |

Returns float

## log10
*Static public function of class math*

10 raised to which power resuls in the given value?

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Required parameter |

Returns float

## pow
*Static public function of class math*

Return the given base raised to the power of the given exponent

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| base      | float | Required parameter |
| exponent  | float | Required parameter |

Returns float

## exp
*Static public function of class math*

Returns e raised to the power of a given number

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| exponent  | float | Required parameter |

Returns float

---

# struct Vector2

## x
*Public member variable of type float of struct Vector2*

The x coordinate of the vector

## y
*Public member variable of type float of struct Vector2*

The y coordinate of the vector

## length
*Public member function of struct Vector2*

The length of the vector

Returns float

---

# struct Dimension

## auto
*Global variable of type Dimension*

Automatically adjust the value to distribute the space evenly

---

# class Border

## none
*Global variable of type Border*

Display no border

---

# class FontWeight

## normal
*Global variable of type FontWeight*

Normal font weight. Same as 400.

## bold
*Global variable of type FontWeight*

Bold font weight. Same as 700.

## lighter
*Global variable of type FontWeight*

One relative font weight lighter than the parent element.

## bolder
*Global variable of type FontWeight*

One relative font weight heavier than the parent element.

---

# class Style

## alignItems
*Public member variable of type AlignItems of class Style*

Align the individual items along the cross axis.
Possible values: FlexStart, Center, FlexEnd, Stretch, Normal, SelfStart, SelfEnd, Baseline, FirstBaseline

*Example:*
```
div display:Flex, flexDirection:Column, width:100 percent
    div "CenteredText", alignItems:Center
```

## alignContent
*Public member variable of type AlignContent of class Style*

When wrapping, align the whole content along the cross axis.
Possible values: FlexStart, Center, FlexEnd, SpaceEvenly, SpaceBetween, SpaceAround, Normal, Baseline, Stretch

## alignSelf
*Public member variable of type string of class Style*

The alignment for selected items inside a flexible container

## animation
*Public member variable of type string of class Style*

A shorthand property for all the animation properties, except the animationPlayState

## animationDelay
*Public member variable of type string of class Style*

When the animation will start

## animationDirection
*Public member variable of type string of class Style*

Whether or not the animation should play in reverse on alternate cycles

## animationDuration
*Public member variable of type string of class Style*

How many seconds or milliseconds an animation takes to complete one cycle

## animationFillMode
*Public member variable of type string of class Style*

What values are applied by the animation outside the time it is executing

## animationIterationCount
*Public member variable of type string of class Style*

The number of times an animation should be played

## animationName
*Public member variable of type string of class Style*

A name for the @keyframes animation

## animationTimingFunction
*Public member variable of type string of class Style*

The speed curve of the animation

## animationPlayState
*Public member variable of type string of class Style*

Whether the animation is running or paused

## background
*Public member variable of type string of class Style*

All the background properties in one declaration

## backgroundAttachment
*Public member variable of type string of class Style*

Whether a background-image is fixed or scrolls with the page

## backgroundColor
*Public member variable of type Color of class Style*

The background-color of an element. You can use a color literal to define a color, e.g. backgroundColor:#ff0000

*Example:*
```
div "Abort", backgroundColor:#ff0000
```

## backgroundImage
*Public member variable of type Image of class Style*

The background-image for an element

## backgroundPosition
*Public member variable of type string of class Style*

The starting position of a background-image

## backgroundRepeat
*Public member variable of type string of class Style*

How to repeat (tile) a background-image

## backgroundClip
*Public member variable of type string of class Style*

The painting area of the background

## backgroundOrigin
*Public member variable of type string of class Style*

The positioning area of the background images

## backgroundSize
*Public member variable of type string of class Style*

The size of the background image

## backfaceVisibility
*Public member variable of type string of class Style*

Whether or not an element should be visible when not facing the screen

## border
*Public member variable of type Border of class Style*

The border of an element.

*Example:*
```
div "Text with border", border:{width:2px, style:Solid, color:#ff0000}
```

## borderBottom
*Public member variable of type Border of class Style*

All the borderBottom properties in one declaration

## borderBottomColor
*Public member variable of type Color of class Style*

The color of the bottom border. You can use a color literal to define a color, e.g. borderBottomColor:#ff0000

## borderBottomLeftRadius
*Public member variable of type Dimension of class Style*

The shape of the border of the bottom-left corner

## borderBottomRightRadius
*Public member variable of type Dimension of class Style*

The shape of the border of the bottom-right corner

## borderBottomStyle
*Public member variable of type BorderStyle of class Style*

The style of the bottom border

## borderBottomWidth
*Public member variable of type Dimension of class Style*

The width of the bottom border

## borderCollapse
*Public member variable of type string of class Style*

Whether the table border should be collapsed into a single border, or not

## borderColor
*Public member variable of type Color of class Style*

The color of an element's border. You can use a color literal to define a color, e.g. borderColor:#ff0000

## borderImage
*Public member variable of type string of class Style*

A shorthand property for setting or returning all the borderImage properties

## borderImageOutset
*Public member variable of type Dimension of class Style*

The amount by which the border image area extends beyond the border box

## borderImageRepeat
*Public member variable of type string of class Style*

Whether the image-border should be repeated, rounded or stretched

## borderImageSlice
*Public member variable of type string of class Style*

The inward offsets of the image-border

## borderImageSource
*Public member variable of type string of class Style*

The image to be used as a border

## borderImageWidth
*Public member variable of type Dimension of class Style*

The widths of the image-border

## borderLeft
*Public member variable of type Border of class Style*

All the borderLeft properties in one declaration

## borderLeftColor
*Public member variable of type Color of class Style*

The color of the left border

## borderLeftStyle
*Public member variable of type BorderStyle of class Style*

The style of the left border

## borderLeftWidth
*Public member variable of type Dimension of class Style*

The width of the left border

## borderRadius
*Public member variable of type Dimension of class Style*

A shorthand property for setting or returning all the four borderRadius properties

## borderRight
*Public member variable of type Border of class Style*

All the borderRight properties in one declaration

## borderRightColor
*Public member variable of type Color of class Style*

The color of the right border. You can use a color literal to define a color, e.g. borderRightColor:#ff0000

## borderRightStyle
*Public member variable of type BorderStyle of class Style*

The style of the right border

## borderRightWidth
*Public member variable of type Dimension of class Style*

The width of the right border

## borderSpacing
*Public member variable of type Dimension of class Style*

The space between cells in a table

## borderStyle
*Public member variable of type BorderStyle of class Style*

The style of an element's border (can have up to four values)

## borderTop
*Public member variable of type Border of class Style*

All the borderTop properties in one declaration

## borderTopColor
*Public member variable of type Color of class Style*

The color of the top border. You can use a color literal to define a color, e.g. borderTopColor:#ff0000

## borderTopLeftRadius
*Public member variable of type Dimension of class Style*

The shape of the border of the top-left corner

## borderTopRightRadius
*Public member variable of type Dimension of class Style*

The shape of the border of the top-right corner

## borderTopStyle
*Public member variable of type BorderStyle of class Style*

The style of the top border

## borderTopWidth
*Public member variable of type Dimension of class Style*

The width of the top border

## borderWidth
*Public member variable of type Dimension of class Style*

The width of an element's border (can have up to four values)

## bottom
*Public member variable of type Dimension of class Style*

The bottom position of a positioned element

## boxDecorationBreak
*Public member variable of type string of class Style*

The behaviour of the background and border at page-break or line-break

## boxShadow
*Public member variable of type BoxShadow of class Style*

Draws one or more drop-shadows to the box.

*Example:*
```
div "Text with box shadow", boxShadow:{offset:{8,8}, blur:50, spread:10, color:#c0c0c0}
```

## boxSizing
*Public member variable of type string of class Style*

Allows you to define certain elements to fit an area in a certain way

## captionSide
*Public member variable of type string of class Style*

The position of the table caption

## caretColor
*Public member variable of type Color of class Style*

The caret/cursor color of an element. You can use a color literal to define a color, e.g. caretColor:#ff0000

## clear
*Public member variable of type string of class Style*

The position of the element relative to floating objects

## clip
*Public member variable of type string of class Style*

Which part of a positioned element is visible

## color
*Public member variable of type Color of class Style*

The color of the text. You can use a color literal to define a color, e.g. color:#ff0000

*Example:*
```
app
    Color primaryColor = #808080
    draw
       div "Hello", color:primaryColor
```

## columnCount
*Public member variable of type string of class Style*

The number of columns an element should be divided into

## columnFill
*Public member variable of type string of class Style*

How to fill columns

## columnGap
*Public member variable of type Dimension of class Style*

The gap between the columns

## columnRule
*Public member variable of type string of class Style*

A shorthand property for setting or returning all the columnRule properties

## columnRuleColor
*Public member variable of type Color of class Style*

The color of the rule between columns. You can use a color literal to define a color, e.g. columnRuleColor:#ff0000

## columnRuleStyle
*Public member variable of type string of class Style*

The style of the rule between columns

## columnRuleWidth
*Public member variable of type Dimension of class Style*

The width of the rule between columns

## columns
*Public member variable of type string of class Style*

A shorthand property for setting or returning columnWidth and columnCount

## columnSpan
*Public member variable of type int of class Style*

How many columns an element should span across

## columnWidth
*Public member variable of type Dimension of class Style*

The width of the columns

## content
*Public member variable of type string of class Style*

Used with the :before and :after pseudo-elements, to insert generated content

## counterIncrement
*Public member variable of type string of class Style*

Increments one or more counters

## counterReset
*Public member variable of type string of class Style*

Creates or resets one or more counters

## cursor
*Public member variable of type Cursor of class Style*

The type of cursor to display for the mouse pointer

## direction
*Public member variable of type string of class Style*

The text direction

## display
*Public member variable of type Display of class Style*

An element's display type

## emptyCells
*Public member variable of type string of class Style*

Whether to show the border and background of empty cells, or not

## filter
*Public member variable of type string of class Style*

Image filters (visual effects, like blur and saturation)

## flex
*Public member variable of type string of class Style*

The length of the item, relative to the rest

## flexBasis
*Public member variable of type Dimension of class Style*

The initial length of a flexible item

## flexDirection
*Public member variable of type FlexDirection of class Style*

The direction of the flexible items.
Possible values: Row, RowReverse, Column, ColumnReverse

*Example:*
```
div display:Flex, flexDirection:Column
    for items as item
        div text:item.text
```

## flexFlow
*Public member variable of type string of class Style*

A shorthand property for the flexDirection and the flexWrap properties

## flexGrow
*Public member variable of type float of class Style*

How much the item will grow relative to the rest

## flexShrink
*Public member variable of type float of class Style*

How the item will shrink relative to the rest

## flexWrap
*Public member variable of type FlexWrap of class Style*

Whether the flexible items should wrap or not.
Possible values: NoWrap, Wrap, WrapReverse

*Example:*
```
div display:Flex, flexWrap:Wrap
    for items as item
        div text:item.text
```

## cssFloat
*Public member variable of type string of class Style*

The horizontal alignment of an element

## font
*Public member variable of type string of class Style*

FontStyle, fontVariant, fontWeight, fontSize, lineHeight, and fontFamily in one declaration

## fontFamily
*Public member variable of type string of class Style*

The font family for text

## fontSize
*Public member variable of type Dimension of class Style*

The font size of the text

## fontStyle
*Public member variable of type FontStyle of class Style*

Whether the style of the font is Normal, Italic or Oblique.

*Example:*
```
div "Hello", fontStyle:Italic
```

## fontVariant
*Public member variable of type string of class Style*

Whether the font should be displayed in small capital letters

## fontWeight
*Public member variable of type FontWeight of class Style*

The boldness of the font.
Possible values: normal, bold, lighter, bolder, or a number from 1 to 1000. Higher values mean bolder, lower numbers mean lighter.

*Example:*
```
div "Bold text", fontWeight:bold
```

## fontSizeAdjust
*Public member variable of type string of class Style*

Preserves the readability of text when font fallback occurs

## fontStretch
*Public member variable of type string of class Style*

Selects a normal, condensed, or expanded face from a font family

## gap
*Public member variable of type Dimension of class Style*

The gap between rows or columns

## hangingPunctuation
*Public member variable of type string of class Style*

Specifies whether a punctuation character may be placed outside the line box

## height
*Public member variable of type Dimension of class Style*

The height of an element

## hyphens
*Public member variable of type string of class Style*

Sets how to split words to improve the layout of paragraphs

## icon
*Public member variable of type string of class Style*

Provides the author the ability to style an element with an iconic equivalent

## imageOrientation
*Public member variable of type string of class Style*

Specifies a rotation in clockwise direction appied to an image

## isolation
*Public member variable of type string of class Style*

Defines whether an element must create a new stacking content

## justifyContent
*Public member variable of type JustifyContent of class Style*

Justify the whole content along the main axis (as in "justified text").
Possible values: FlexStart, Center, FlexEnd, SpaceEvenly, SpaceBetween, SpaceAround, Normal, Baseline

*Example:*
```
div display:Flex, flexDirection:Row, justifyContent:Center
    div "This is centered horizontally"
```

## left
*Public member variable of type Dimension of class Style*

The left position of a positioned element

## letterSpacing
*Public member variable of type Dimension of class Style*

The space between characters in a text

## lineHeight
*Public member variable of type string of class Style*

The distance between lines in a text

## listStyle
*Public member variable of type string of class Style*

ListStyleImage, listStylePosition, and listStyleType in one declaration

## listStyleImage
*Public member variable of type string of class Style*

An image as the list-item marker

## listStylePosition
*Public member variable of type string of class Style*

The position of the list-item marker

## listStyleType
*Public member variable of type string of class Style*

The list-item marker type

## margin
*Public member variable of type Margin of class Style*

Can be single float like 8 an object like {top:8, right:8, bottom:8, left:8}

## inset
*Public member variable of type Margin of class Style*

A shorthand for the top, right, bottom, left properties

## marginBottom
*Public member variable of type Dimension of class Style*

The bottom margin of an element

## marginLeft
*Public member variable of type Dimension of class Style*

The left margin of an element

## marginRight
*Public member variable of type Dimension of class Style*

The right margin of an element

## marginTop
*Public member variable of type Dimension of class Style*

The top margin of an element

## maxHeight
*Public member variable of type Dimension of class Style*

The maximum height of an element

## maxWidth
*Public member variable of type Dimension of class Style*

The maximum width of an element

## minHeight
*Public member variable of type Dimension of class Style*

The minimum height of an element

## minWidth
*Public member variable of type Dimension of class Style*

The minimum width of an element

## navDown
*Public member variable of type string of class Style*

Where to navigate when using the arrow-down navigation key

## navIndex
*Public member variable of type string of class Style*

The tabbing order for an element

## navLeft
*Public member variable of type string of class Style*

Where to navigate when using the arrow-left navigation key

## navRight
*Public member variable of type string of class Style*

Where to navigate when using the arrow-right navigation key

## navUp
*Public member variable of type string of class Style*

Where to navigate when using the arrow-up navigation key

## objectFit
*Public member variable of type ObjectFit of class Style*

Specifies how the contents of a replaced element should be fitted its box

## objectPosition
*Public member variable of type string of class Style*

Specifies the alignment of the replaced element inside its box

## opacity
*Public member variable of type float of class Style*

The opacity level for an element

## order
*Public member variable of type string of class Style*

The order of the flexible item, relative to the rest

## orphans
*Public member variable of type string of class Style*

The minimum number of lines that must be left at the bottom before a page-break

## outline
*Public member variable of type Border of class Style*

All the outline properties in one declaration

## outlineColor
*Public member variable of type Color of class Style*

The color of the outline around a element. You can use a color literal to define a color, e.g. outlineColor:#ff0000

## outlineOffset
*Public member variable of type string of class Style*

Offsets an outline, and draws it beyond the border edge

## outlineStyle
*Public member variable of type string of class Style*

The style of the outline around an element

## outlineWidth
*Public member variable of type Dimension of class Style*

The width of the outline around an element

## overflow
*Public member variable of type Overflow of class Style*

What to do with content that renders outside the element box

## overflowX
*Public member variable of type Overflow of class Style*

Specifies what to do with the left/right edges of content rendering outside the element box

## overflowY
*Public member variable of type Overflow of class Style*

Specifies what to do with the top/bottom edges of content rendering outside the element box

## padding
*Public member variable of type Padding of class Style*

Can be single float like 8 an object like {top:8, right:8, bottom:8, left:8}

## paddingBottom
*Public member variable of type Dimension of class Style*

The bottom padding of an element

## paddingLeft
*Public member variable of type Dimension of class Style*

The left padding of an element

## paddingRight
*Public member variable of type Dimension of class Style*

The right padding of an element

## paddingTop
*Public member variable of type Dimension of class Style*

The top padding of an element

## pageBreakAfter
*Public member variable of type string of class Style*

The page-break behavior after an element

## pageBreakBefore
*Public member variable of type string of class Style*

The page-break behavior before an element

## pageBreakInside
*Public member variable of type string of class Style*

The page-break behavior inside an element

## perspective
*Public member variable of type string of class Style*

The perspective on how 3D elements are viewed

## perspectiveOrigin
*Public member variable of type string of class Style*

The bottom position of 3D elements

## position
*Public member variable of type Position of class Style*

The type of positioning method used for an element.
Possible values: Absolute, Relative, Fixed, Sticky, Static

*Example:*
```
div position:Absolute, left:0px, top:0px
    div "This is positioned in the top left corner"
```

## quotes
*Public member variable of type string of class Style*

The type of quotation marks for embedded quotations

## resize
*Public member variable of type string of class Style*

Whether or not an element is resizable by the user

## right
*Public member variable of type Dimension of class Style*

The right position of a positioned element

## scrollBehavior
*Public member variable of type string of class Style*

Specifies whether to smoothly animate the scroll position when a link is clicked

## tableLayout
*Public member variable of type string of class Style*

The way to lay out table cells, rows, and columns

## tabSize
*Public member variable of type string of class Style*

The length of the tab-character

## textAlign
*Public member variable of type TextAlign of class Style*

The horizontal alignment of text.
Possible values: Left, Center, Right, Justify, Start, End, MatchParent

*Example:*
```
div textAlign:Center text:"This is centered horizontally"
```

## textAlignLast
*Public member variable of type string of class Style*

How the last line of a block is aligned when text-align is "justify"

## textDecoration
*Public member variable of type string of class Style*

The decoration of a text

## textDecorationColor
*Public member variable of type Color of class Style*

The color of the text-decoration. You can use a color literal to define a color, e.g. textDecorationColor:#ff0000

## textDecorationLine
*Public member variable of type string of class Style*

The type of line in a text-decoration

## textDecorationStyle
*Public member variable of type string of class Style*

The style of the line in a text decoration

## textIndent
*Public member variable of type string of class Style*

The indentation of the first line of text

## textJustify
*Public member variable of type string of class Style*

The justification method used when text-align is "justify"

## textOverflow
*Public member variable of type TextOverflow of class Style*

What should happen when text overflows the containing element.
Possible values: Ellipsis, Clip

*Example:*
```
div textOverflow:Ellipsis text:"This is an example of text overflow"
```

## textShadow
*Public member variable of type string of class Style*

The shadow effect of a text

## textTransform
*Public member variable of type string of class Style*

The capitalization of a text

## top
*Public member variable of type Dimension of class Style*

The top position of a positioned element

## transform
*Public member variable of type string of class Style*

Applies a 2D or 3D transformation to an element

## transformOrigin
*Public member variable of type string of class Style*

The position of transformed elements

## transformStyle
*Public member variable of type string of class Style*

How nested elements are rendered in 3D space

## transition
*Public member variable of type string of class Style*

A shorthand property for setting or returning the four transition properties

## transitionProperty
*Public member variable of type string of class Style*

The CSS property that the transition effect is for

## transitionDuration
*Public member variable of type string of class Style*

How many seconds or milliseconds a transition effect takes to complete

## transitionTimingFunction
*Public member variable of type string of class Style*

The speed curve of the transition effect

## transitionDelay
*Public member variable of type string of class Style*

When the transition effect will start

## unicodeBidi
*Public member variable of type string of class Style*

Whether the text should be overridden to support multiple languages in the same document

## userSelect
*Public member variable of type string of class Style*

Whether the text of an element can be selected or not

## verticalAlign
*Public member variable of type string of class Style*

The vertical alignment of the content in an element

## visibility
*Public member variable of type string of class Style*

Whether an element should be visible

## whiteSpace
*Public member variable of type WhiteSpace of class Style*

How to handle tabs, line breaks and whitespace in a text

## width
*Public member variable of type Dimension of class Style*

The width of an element

## wordBreak
*Public member variable of type string of class Style*

Line breaking rules for non-CJK scripts

## wordSpacing
*Public member variable of type string of class Style*

The spacing between words in a text

## wordWrap
*Public member variable of type string of class Style*

Allows long, unbreakable words to be broken and wrap to the next line

## widows
*Public member variable of type string of class Style*

The minimum number of lines for an element that must be visible at the top of a page

## zIndex
*Public member variable of type int of class Style*

The stack order of a positioned element

## gridTemplateColumns
*Public member variable of type string of class Style*

The line names and track sizing functions of the grid columns

## translate
*Public member variable of type Vector2 of class Style*

Move the element by this vector

## rotate
*Public member variable of type Angle of class Style*

Rotate the element by this angle

---

# class Attributes

## id
*Public member variable of type string of class Attributes*

A unique string to indentify a specic element, often used to style a single element

## class
*Public member variable of type string of class Attributes*

A string to assign a class to one or more elements, often used to style several elements

## key
*Public member variable of type string of class Attributes*

A unique identifier used to find the node that should be reused

## onClick
*Public member variable of type void() of class Attributes*

Execute this code when the user clicks the HTML element

## onLeftClick
*Public member variable of type void(HtmlEvent ev) of class Attributes*

Execute this code when the user clicks the HTML element

## onRightClick
*Public member variable of type void(HtmlEvent ev) of class Attributes*

Execute this code when the user clicks the HTML element with the right mouse button

## onKeyDown
*Public member variable of type void(HtmlKeyboardEvent ev) of class Attributes*

Execute this code when the user presses a key on the keyboard

## onKeyUp
*Public member variable of type void(HtmlKeyboardEvent ev) of class Attributes*

Execute this code when the user releases a key on the keyboard

---

# class html

## div
*Global function*

Render a html element within the draw function. It renders a div by default, but you can specify a different tag.
In addition to the listed parameters, you can also specify html attributes and css styles.
You can use all members of the Styles class as parameters to apply css styles to the element.
You can use all members of the Attributes class as parameters to apply html attributes to the element.
You can render the children of the element in an indented block of code underneath the div.

*Example:*
```
app
    draw
        div display:Flex, flexDirection:Column, gap:30, fontSize:60, margin:{top:80 left:80}
            div tag:"h1", text:"Todo List"
            for items as item
		           div text:item.text, fontStyle:Italic
```

| Parameter | Type    | Description                                                                                                      |
| --------- | ------- | ---------------------------------------------------------------------------------------------------------------- |
| text      | string  | The text content of the element, optional, defaults to null                                                      |
| tag       | string  | The tag of element, defaults to "div", optional, defaults to "div"                                               |
| data      | dynamic | The data attributes of the element, optional, defaults to {}                                                     |
| onHover   | Style   | Apply this css style to the element when the user moves their mouse over the element, optional, defaults to null |
| children  | void()  | A block of code that renders the children of the element, optional, defaults to null                             |

Returns Node

## img
*Global function*

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

Returns Node

## img
*Global function*

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
    User currentUser
    draw
        currentUser.drawProfile
```

| Parameter | Type   | Description                      |
| --------- | ------ | -------------------------------- |
| src       | string | The file of the image to display |

Returns Node

## button
*Global function*

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

| Parameter | Type               | Description                                                        |
| --------- | ------------------ | ------------------------------------------------------------------ |
| text      | string             | The text to display on the button, optional, defaults to null      |
| onClick   | void(HtmlEvent ev) | Called when the user clicks the button, optional, defaults to null |

Returns Node

## button
*Global function*

| Parameter         | Type               | Description                                                              |
| ----------------- | ------------------ | ------------------------------------------------------------------------ |
| text              | string             | The text to display on the button, optional, defaults to null            |
| onClick           | bool(HtmlEvent ev) | Called when the user clicks the button, optional, defaults to null       |
| disableAfterClick | bool               | Disable the button after the user clicks it, optional, defaults to false |

Returns Node

## link
*Global function*

Render a html anchor element to link to a url

| Parameter | Type   | Description                          |
| --------- | ------ | ------------------------------------ |
| text      | string | Optional parameter, defaults to null |
| href      | string | Optional parameter, defaults to "#"  |

Returns Node

## span
*Global function*

Render a html span element to display text

| Parameter | Type   | Description                                                     |
| --------- | ------ | --------------------------------------------------------------- |
| text      | string | The text to display within the span, optional, defaults to null |

Returns Node

