# LiveTime Programming Language Reference

# struct Vector2

## Member Variables

### float x
The x coordinate of the vector

### float y
The y coordinate of the vector

## Member Functions

### length
The length of the vector


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
Possible values: FlexStart, Center, FlexEnd, Stretch, Normal, SelfStart, SelfEnd, Baseline, FirstBaseline

*Example:*
```
div display:Flex, flexDirection:Column, width:100 percent
    div "CenteredText", alignItems:Center
```

### AlignContent alignContent
When wrapping, align the whole content along the cross axis.
Possible values: FlexStart, Center, FlexEnd, SpaceEvenly, SpaceBetween, SpaceAround, Normal, Baseline, Stretch

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
div "Text with border", border:{width:2px, style:Solid, color:#ff0000}
```

### Border borderBottom
All the borderBottom properties in one declaration

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

### BorderStyle borderLeftStyle
The style of the left border

### Dimension borderLeftWidth
The width of the left border

### Dimension borderRadius
A shorthand property for setting or returning all the four borderRadius properties

### Border borderRight
All the borderRight properties in one declaration

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

### string clear
The position of the element relative to floating objects

### string clip
Which part of a positioned element is visible

### string columnCount
The number of columns an element should be divided into

### string columnFill
How to fill columns

### Dimension columnGap
The gap between the columns

### string columnRule
A shorthand property for setting or returning all the columnRule properties

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
Possible values: Row, RowReverse, Column, ColumnReverse

*Example:*
```
div display:Flex, flexDirection:Column
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
Possible values: NoWrap, Wrap, WrapReverse

*Example:*
```
div display:Flex, flexWrap:Wrap
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
Whether the style of the font is Normal, Italic or Oblique.

*Example:*
```
div "Hello", fontStyle:Italic
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
Possible values: FlexStart, Center, FlexEnd, SpaceEvenly, SpaceBetween, SpaceAround, Normal, Baseline

*Example:*
```
div display:Flex, flexDirection:Row, justifyContent:Center
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

### string order
The order of the flexible item, relative to the rest

### string orphans
The minimum number of lines that must be left at the bottom before a page-break

### Border outline
All the outline properties in one declaration

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
Possible values: Absolute, Relative, Fixed, Sticky, Static

*Example:*
```
div position:Absolute, left:0px, top:0px
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
Possible values: Left, Center, Right, Justify, Start, End, MatchParent

*Example:*
```
div textAlign:Center text:"This is centered horizontally"
```

### string textAlignLast
How the last line of a block is aligned when text-align is "justify"

### string textDecoration
The decoration of a text

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
Possible values: Ellipsis, Clip

*Example:*
```
div textOverflow:Ellipsis text:"This is an example of text overflow"
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

