# The LiveTime Programming Language

---

# struct int
A number stored as a 32-bit integer
## undefined (static member function of int)
Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)

Returns int

## remainder (member function of int)
The remainer after a division by the given value. The sign stays the same.

| Parameter | Type | Description |
| --- | --- | --- |
| value | int | The value to divide by |
Returns int

## toBool (member function of int)
Returns true if the integer is not zero

Returns bool

## toString (member function of int)
Returns string

## toTime (member function of int)
Returns Time

## fromHex (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of fromHex |
Returns int

## formatWithSpaces (member function of int)
Returns string

## format (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| minIntegerDigits | int | Parameter of format |
| grouping | bool | Parameter of format |
Returns string

## abs (member function of int)
Returns the absolute value of the integer

Returns int

## shiftLeft (member function of int)
Shift the bits of the int to the left. Excess bits shifted off to the left are discarded

| Parameter | Type | Description |
| --- | --- | --- |
| count | int | The amount of bits to shift |
Returns int

## shiftRight (member function of int)
Shift the bits of the int to the right. Excess bits shifted off to the right are discarded

| Parameter | Type | Description |
| --- | --- | --- |
| count | int | The amount of bits to shift |
Returns int

## bitwiseOr (member function of int)
Perform a bitwise "or" operation

| Parameter | Type | Description |
| --- | --- | --- |
| value | int | The value to perform the bitwise "or" with |
Returns int

## bitwiseAnd (member function of int)
Perform a bitwise "and" operation

| Parameter | Type | Description |
| --- | --- | --- |
| value | int | The value to perform the bitwise "and" with |
Returns int

## isSet (member function of int)
Check if a certain bit it set

| Parameter | Type | Description |
| --- | --- | --- |
| value | int | The value of the bits to check (for example 1, 2, 4, 8, 16, ...) |
Returns bool

## isNotSet (member function of int)
Check if a certain bit it not set

| Parameter | Type | Description |
| --- | --- | --- |
| value | int | The value of the bits to check (for example 1, 2, 4, 8, 16, ...) |
Returns bool

## setFlag (member function of int)
Set a specific bit of the integer

| Parameter | Type | Description |
| --- | --- | --- |
| bitIndex | int | The index of the bit to set |
Returns int

## clearFlag (member function of int)
Clear a specific bit of the integer

| Parameter | Type | Description |
| --- | --- | --- |
| bitIndex | int | The index of the bit to clear |
Returns int

## limit (member function of int)
Limit the value to a specific range

Example: Limit the player's to be between 0 and 100
```
Player
    int health
    changeHealth: int delta
        health = (health + delta) limit 0..100
```

| Parameter | Type | Description |
| --- | --- | --- |
| from | int | The inclusive minimum value |
| to | int | The inclusive maximum value |
Returns int

## limit (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| from | float | The inclusive minimum value |
| to | float | The inclusive maximum value |
Returns float

## limit (member function of int)
Make sure the value never exceets a maximum value

Example: Make sure the card count never exceets a maximum value of 5
```
cardCount = cardCount limit ..5
```

| Parameter | Type | Description |
| --- | --- | --- |
| to | int | Parameter of limit |
Returns int

## limit (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| to | float | Parameter of limit |
Returns float

## limit (member function of int)
Make sure the value never falls below a minimum value

Example: Make sure the score never fall below 0
```
score = score limit 0..
```

| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of limit |
Returns int

## limit (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| from | float | Parameter of limit |
Returns float

## atLeast (member function of int)
Make sure the value never falls below a minimum value

Example: Make sure the score never fall below 0
```
score = score atLeast 0
```

| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of atLeast |
Returns int

## atLeast (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of atLeast |
Returns float

## atMost (member function of int)
Make sure the value never exceets a maximum value

Example: Make sure the card count never exceets a maximum value of 5
```
cardCount = cardCount atMost 5
```

| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of atMost |
Returns int

## atMost (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of atMost |
Returns float

## setIfLarger (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| newValue | int | Parameter of setIfLarger |
Returns int

## incrementAndWrap (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| max | int | When the integer reaches this value, it wraps around to zero |
Returns int

## decrementAndWrap (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| max | int | When the integer reaches this value, it wraps around to zero |
Returns int

## incrementUpTo (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| max | int | Parameter of incrementUpTo |
Returns int

## incrementUpToExclusive (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| max | int | Parameter of incrementUpToExclusive |
Returns int

## incrementBy (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of incrementBy |
| upTo | int | Parameter of incrementBy |
Returns int

## decrementDownTo (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| min | int | Parameter of decrementDownTo |
Returns int

## decrementDownToExclusive (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| min | int | Parameter of decrementDownToExclusive |
Returns int

## within (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| range | Range | Parameter of within |
Returns bool

## withinInclusively (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| range | Range | Parameter of withinInclusively |
Returns bool

## assignIfGreater (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of assignIfGreater |
Returns int

## enumerate (static member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of enumerate |
| to | int | Parameter of enumerate |
| selector | TResult(int i) | Parameter of enumerate |
Returns TResult[]

## enumerate (static member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of enumerate |
| to | int | Parameter of enumerate |
| step | int | Parameter of enumerate |
| selector | TResult(int i) | Parameter of enumerate |
Returns TResult[]

## times (member function of int)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | TResult(int i) | Parameter of times |
Returns TResult[]

---

# struct float
## maxValue (static member function of float)
The largest possible floating point value

Returns float

## minValue (static member function of float)
The smallest possible floating point value

Returns float

## undefined (static member function of float)
Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)

Returns int

## infinity (static member function of float)
Positiv infinity

Returns float

## epsilon (static member function of float)
Returns float

## operator (static member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| a | float | Parameter of operator |
| b | float | Parameter of operator |
Returns float

## operator (static member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| a | float | Parameter of operator |
| b | float | Parameter of operator |
Returns float

## notANumber (static member function of float)
Can result from failed conversion or operations with undefined or complex result

Returns float

## remainder (member function of float)
The remainer after a division by the given value. The sign stays the same.

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of remainder |
Returns float

## toInt (member function of float)
Returns int

## toBool (member function of float)
Returns true if the floot is not zero

Returns bool

## toString (member function of float)
Returns string

## format (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| fractionDigits | int | Parameter of format |
| minIntegerDigits | int | Parameter of format |
| grouping | bool | Parameter of format |
Returns string

## format (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| fractionDigits | int | Parameter of format |
| grouping | bool | Parameter of format |
Returns string

## format (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| minIntegerDigits | int | Parameter of format |
| grouping | bool | Parameter of format |
Returns string

## abs (member function of float)
Returns the absolute value

Returns float

## sign (member function of float)
Returns -1, 0, or 1 depending on the sign of the value

Returns float

## ceil (member function of float)
Returns the smallest integer greater than or equal to the given value

Returns int

## floor (member function of float)
Returns the largest integer less than or equal to the given value

Returns int

## round (member function of float)
Returns the given value rounded to the nearest integer

Returns int

## limit (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| from | float | Parameter of limit |
| to | float | Parameter of limit |
Returns float

## limit (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| to | float | Parameter of limit |
Returns float

## limit (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| from | float | Parameter of limit |
Returns float

## atLeast (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of atLeast |
Returns float

## atMost (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of atMost |
Returns float

## isApproximately (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of isApproximately |
| epsilon | float | Parameter of isApproximately |
Returns bool

## moveTowards (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of moveTowards |
| speed | float | Parameter of moveTowards |
Returns float

## moveTowardsAndEaseOut (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of moveTowardsAndEaseOut |
| speed | float | Parameter of moveTowardsAndEaseOut |
Returns float

## incrementBy (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of incrementBy |
| to | float | Parameter of incrementBy |
Returns float

## toOrdinalString (member function of float)
Returns string

## toTime (member function of float)
Returns Time

## milliseconds (member function of float)
Milliseconds

Returns Time

## seconds (member function of float)
Seconds

Returns Time

## minutes (member function of float)
Minutes

Returns Time

## hours (member function of float)
Hours

Returns Time

## days (member function of float)
Days

Returns Time

## weeks (member function of float)
Weeks

Returns Time

## toDimension (member function of float)
Returns Dimension

## px (member function of float)
Pixels

Returns Dimension

## percent (member function of float)
Makes the value relative to its parent's value

Returns Dimension

## fr (member function of float)
A fraction of the available space

Returns Dimension

## em (member function of float)
Font size of the parent (for font-size), font size of the element itself (for other properties)

Returns Dimension

## rem (member function of float)
Font size of the root element

Returns Dimension

## vw (member function of float)
Percentage of the viewport's width

Returns Dimension

## vh (member function of float)
Percentage of the viewport's height

Returns Dimension

## svw (member function of float)
Percentage of the small viewport's width (without the address bar on mobile)

Returns Dimension

## svh (member function of float)
Percentage of the small viewport's height (without the address bar on mobile)

Returns Dimension

## toAngle (member function of float)
Returns Dimension

## operator (static member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of operator |
Returns Angle

## turns (member function of float)
One full rotation is 1

Returns Angle

## radians (member function of float)
One full rotation is 2π (about 6.2832)

Returns Angle

## degrees (member function of float)
One full rotation is 360

Returns Angle

## gradians (member function of float)
One full rotation is 400

Returns Angle

## interpolateTo (member function of float)
Interpolates to another value

| Parameter | Type | Description |
| --- | --- | --- |
| target | float | The target value to interpolate to |
| progress | float | The progress of the interpolation (0: return the start value, 1: returns the target value) |
Returns float

## interpolateTo (member function of float)
| Parameter | Type | Description |
| --- | --- | --- |
| target | float | The target value to interpolate to |
| progress | float | Between "from" and "to" ("from" returns the start value, "to" returns the target value) |
| from | float | The beginning of the input range, if "progress" is "from" or less, the start value is returned |
| to | float | The end of the input range, if "progress" is "to" or more, the target value is returned |
Returns float

## interpolateTo (member function of float)
Interpolates to another value

| Parameter | Type | Description |
| --- | --- | --- |
| target | float | The target value to interpolate to |
| progress | float | The progress of the interpolation (0: return the start value, 1: returns the target value) |
| ease | EaseFunction | The easing function to apply (e.g InQuad, OutBack, ...) |
Returns float

## toPadding (member function of float)
Returns Padding

## toMargin (member function of float)
Returns Margin

---

# class string
## length (member function of string)
Returns the number of characters in the string

Returns int

## toUpperCase (member function of string)
Returns a string with each character converted to uppercase

Returns string

## toLowerCase (member function of string)
Returns a string with each character converted to lowercase

Returns string

## toBool (member function of string)
Returns true if the string is not null and not empty

Returns bool

## toString (member function of string)
Returns string

## toInt (member function of string)
Returns int

## toFloat (member function of string)
Returns int

## parseJson (member function of string)
Returns dynamic

## parseInt (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| radix | int | Parameter of parseInt |
Returns int

## undefined (static member function of string)
Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)

Returns string

## split (member function of string)
Splits the string at the given character into a list of substrings

| Parameter | Type | Description |
| --- | --- | --- |
| seperator | string | Separate the string at this character |
Returns string[]

## splitByLine (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| seperator | string | Separate the string at this character |
Returns string[]

## splitToList (member function of string)
Splits the string and return a list with the selected field or expression for each item

| Parameter | Type | Description |
| --- | --- | --- |
| selector | TValue(string it) | Selects a field or expression for each item |
| seperator | string | Separate the string at this character |
Returns TValue[]

## splitToObject (member function of string)
Splits the string, passes a list of strings to a function and returns its return value

| Parameter | Type | Description |
| --- | --- | --- |
| selector | TValue(string[] it) | This functions gets a list of strings and should create an object from it |
| seperator | string | Separate the string at this character |
Returns TValue

## startsWith (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| str | string | Parameter of startsWith |
Returns bool

## endsWith (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| str | string | Parameter of endsWith |
Returns bool

## indexOf (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| str | string | Parameter of indexOf |
Returns int

## indexOf (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| str | string | Parameter of indexOf |
| startPos | int | Parameter of indexOf |
Returns int

## lastIndexOf (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| str | string | Parameter of lastIndexOf |
Returns int

## lastIndexOf (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| str | string | Parameter of lastIndexOf |
| startPos | int | Parameter of lastIndexOf |
Returns int

## contains (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| str | string | Parameter of contains |
Returns bool

## getCharCodeAt (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| index | int | Parameter of getCharCodeAt |
Returns int

## fromCharCode (static member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| charCode | int | Parameter of fromCharCode |
Returns string

## substring (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of substring |
Returns string

## substring (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of substring |
| to | int | Parameter of substring |
Returns string

## getUntil (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of getUntil |
| start | int | Parameter of getUntil |
Returns string

## getUntilUnescaped (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| character | string | Parameter of getUntilUnescaped |
| start | int | Parameter of getUntilUnescaped |
| escapeCharacter | string | Parameter of getUntilUnescaped |
Returns string

## getUntilLast (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of getUntilLast |
| start | int | Parameter of getUntilLast |
Returns string

## getAfter (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of getAfter |
| start | int | Parameter of getAfter |
Returns string

## getBetween (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| from | string | Parameter of getBetween |
| to | string | Parameter of getBetween |
| start | int | Parameter of getBetween |
Returns string

## getBetweenLast (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| from | string | Parameter of getBetweenLast |
| to | string | Parameter of getBetweenLast |
Returns string

## compareTo (member function of string)
Returns 0 for an exact match, 1 if first is larger, -1 if second is larger

| Parameter | Type | Description |
| --- | --- | --- |
| value | string | The string to compare to |
Returns int

## trim (member function of string)
Returns string

## trimStart (member function of string)
Returns string

## trimEnd (member function of string)
Returns string

## trimQuotes (member function of string)
Returns string

## trimTabs (member function of string)
Returns string

## getExtension (member function of string)
Returns string

## interleaveWith (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| charCode | int | Parameter of interleaveWith |
Returns string

## replace (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of replace |
| with | string | Parameter of replace |
Returns string

## replaced (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of replaced |
| with | string | Parameter of replaced |
Returns string

## padStart (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| targetLength | int | Parameter of padStart |
| padString | string | Parameter of padStart |
Returns string

## padEnd (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| targetLength | int | Parameter of padEnd |
| padString | string | Parameter of padEnd |
Returns string

## get (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| index | int | Parameter of get |
Returns string

## get (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of get |
| to | int | Parameter of get |
Returns string

## get (member function of string)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of get |
Returns string

## capitalize (member function of string)
Returns string

## capitalizeWords (member function of string)
Returns string

## onlyLetters (member function of string)
Returns string

## onlyNumbers (member function of string)
Returns string

## backspace (member function of string)
Returns string

## isLetter (member function of string)
Returns bool

## toPlainTimeString (member function of string)
Returns PlainTimeString

## toTimeString (member function of string)
Returns TimeString

---

# class List
## each (member function of List)
Do something for each item in a list

| Parameter | Type | Description |
| --- | --- | --- |
| do | void(T it, int i) | Do this for each item in a list |
Returns void

## each (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(T it, int i) | Do this for each item in a list |
Returns void

## eachChangable (member function of List)
Do something for each item in a list. You can add or remove items inside the loop.

| Parameter | Type | Description |
| --- | --- | --- |
| do | void(T it, int i) | Do this for each item in a list |
Returns void

## eachChangable (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(T it, int i) | Do this for each item in a list |
Returns void

## eachDistinct (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | TKey(T it) | Parameter of eachDistinct |
| sortBy | EachDistinctSortBy | Parameter of eachDistinct |
| do | void(TKey it, T[] items, int i) | Parameter of eachDistinct |
Returns void

## add (member function of List)
Add an item to the end of the list

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to add |
Returns void

## add (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to add |
| item2 | T | The second item to add |
Returns void

## add (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to add |
| item2 | T | The second item to add |
| item3 | T | The third item to add |
Returns void

## add (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to add |
| item2 | T | The second item to add |
| item3 | T | The third item to add |
| item4 | T | The fourth item to add |
Returns void

## add (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to add |
| item2 | T | The second item to add |
| item3 | T | The third item to add |
| item4 | T | The fourth item to add |
| item5 | T | The fifth item to add |
Returns void

## add (member function of List)
Add an item and remove a item from the beginning if the length exceeds a maximum value

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to add |
| maxLength | int | If the list gets longer than this maximum length, remove an item from the beginning |
Returns void

## add (member function of List)
Add an list of item to the end of the list

| Parameter | Type | Description |
| --- | --- | --- |
| items | T[] | The list of items to add |
Returns void

## addRange (member function of List)
Add an list of item to the end of the list

| Parameter | Type | Description |
| --- | --- | --- |
| items | T[] | The list of items to add |
Returns void

## insert (member function of List)
Insert an item at a given index

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to insert |
| index | int | Insert the item at this index |
Returns void

## insert (member function of List)
Insert an item at a given index

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to insert |
| after | T | Parameter of insert |
Returns void

## remove (member function of List)
Remove an item from the list

Example: Remove the current player instrance from the list of playeres when they died
```
Player
    die
        players.remove me
```

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to remove |
Returns void

## remove (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The first item to remove |
| item2 | T | The second item to remove |
Returns void

## remove (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The first item to remove |
| item2 | T | The second item to remove |
| item3 | T | The third item to remove |
Returns void

## remove (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The first item to remove |
| item2 | T | The second item to remove |
| item3 | T | The third item to remove |
| item4 | T | The forth item to remove |
Returns void

## remove (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The first item to remove |
| item2 | T | The second item to remove |
| item3 | T | The third item to remove |
| item4 | T | The forth item to remove |
| item5 | T | The fifth item to remove |
Returns void

## remove (member function of List)
Remove a list of items from the list

| Parameter | Type | Description |
| --- | --- | --- |
| items | T[] | The items to remove |
Returns void

## removeAt (member function of List)
Remove the item at the given index from the list

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to remove |
Returns void

## removeRange (member function of List)
Remove a range of items from the list

Example: Remove the first 3 players from the list
```
players.removeRange 0 to 3
```

| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Remove items starting from this index |
| to | int | Remove items up to (but not including) this index |
Returns void

## removeWhere (member function of List)
Remove all item the meet a specific condition

Example: Remove all players that have died.
```
Player
    bool hasDied
```

app
gameOver
players.removeWhere.hasDied

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
Returns void

## removeFirstWhere (member function of List)
Remove the first item the meet a specific condition

Example: Remove the first player with a health smaller than 10.
```
Player
    int health
```

app
gameOver
players.removeFirstWhere.health < 10

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
Returns T

## ensure (member function of List)
Add an item to the list if it isn't already in there

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to add |
Returns void

## ensure (member function of List)
Add each item from a list if it isn't already in there

| Parameter | Type | Description |
| --- | --- | --- |
| items | T[] | The list of items to add |
Returns void

## toggle (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to add |
Returns void

## contains (member function of List)
Returns whether the list contains the given item

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | Check if the list contains this item |
Returns bool

## containsAny (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| list | T[] | Parameter of containsAny |
Returns bool

## containsNone (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| list | T[] | Parameter of containsNone |
Returns bool

## indexOf (member function of List)
The index of an item in the list

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | Get the index of this item |
Returns int

## setList (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| list | T[] | Parameter of setList |
Returns void

## setFilteredList (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| list | T[] | Parameter of setFilteredList |
| condition | bool(T a) | Parameter of setFilteredList |
Returns void

## setFilteredList (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| list | T[] | Parameter of setFilteredList |
| condition | bool(T a) | Parameter of setFilteredList |
| maxCount | int | Parameter of setFilteredList |
Returns void

## pop (member function of List)
Remove the last item from the list and return it

Example: Print and remove "Orange" from the list
```
let fruits = ["Apple", "Lemon", "Orange"]
print fruits.pop
```

Returns T

## popAt (member function of List)
Remove an item at a specific index from the list and return it

Example: Print and remove "Lemon" from the list
```
let fruits = ["Apple", "Lemon", "Orange"]
print fruits.popAt 1
```

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | Parameter of popAt |
Returns T

## popRange (member function of List)
Remove a range of items from the list and return a new list containing the removed items

Example: Remote "Lemon" and "Orange" from the list of fruits a create a new list with those fruits
```
let fruits = ["Apple", "Pear", "Lemon", "Orange"]
let citrusFruit  = fruits.popRange 2 to 4
```

| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of popRange |
| to | int | Parameter of popRange |
Returns T[]

## popWhere (member function of List)
Remove the first item that meet a given condition and return it
Exmaple: Remove the first player with a health below 10
let firstActivePlayer = players.popWhere.health < 10

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition for the item to meet |
Returns T

## popFirst (member function of List)
Remove the first item from the list and return it

Example: Print and remove "Apple" from the list
```
let fruits = ["Apple", "Lemon", "Orange"]
print fruits.popFirst
```

Returns T

## length (member function of List)
Gets the number of items in the list

Returns int

## setLength (member function of List)
Truncated or expands the list the given number of items

| Parameter | Type | Description |
| --- | --- | --- |
| length | int | The new length of the list |
Returns int

## clear (member function of List)
Removes all items from the list

Returns void

## clone (member function of List)
Create a shallow clone of the list

Returns T[]

## toString (member function of List)
Create a string representation of the list

Returns string

## random (member function of List)
Gets a random item from the list

Returns T

## randomWhere (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | Parameter of randomWhere |
Returns T

## popRandom (member function of List)
Remove a random item from the list and return it

Returns T

## popRandomWhere (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | Parameter of popRandomWhere |
Returns T

## next (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| currentItem | T | Parameter of next |
Returns T

## next (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| currentItem | T | Parameter of next |
| where | bool(T item) | Parameter of next |
Returns T

## previous (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| currentItem | T | Parameter of previous |
Returns T

## prev (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| currentItem | T | Parameter of prev |
Returns T

## pickWithinRangeOrClosest (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of pickWithinRangeOrClosest |
| min | float | Parameter of pickWithinRangeOrClosest |
| max | float | Parameter of pickWithinRangeOrClosest |
Returns T

## toBool (member function of List)
Returns true if the list is not null and not empty

Returns bool

## reverse (member function of List)
Reverses the order of the items of the list in place

Returns T[]

## reversed (member function of List)
Returns T[]

## distinct (member function of List)
Return a list with all unique items of the original list

Returns T[]

## moveToBack (member function of List)
Moves an item to the end of the list

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to move to the end of the list |
Returns void

## moveToFront (member function of List)
Moves an item to the end of the list

| Parameter | Type | Description |
| --- | --- | --- |
| item | T | The item to move to the end of the list |
Returns void

## sort (member function of List)
Sort the list

Returns T[]

## sort (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| comparer | float(T a, T b) | A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal |
Returns T[]

## sort (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| comparer | Time(T a, T b) | A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal |
Returns T[]

## sort (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| comparer | Angle(T a, T b) | A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal |
Returns T[]

## orderBy (member function of List)
Sort the list by a given expression

| Parameter | Type | Description |
| --- | --- | --- |
| expression | float(T a) | First order by this expression |
Returns T[]

## orderBy (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| expression | float(T it) | First order by this expression |
| thenBy | float(T it) | Then order by this expression |
Returns T[]

## orderBy (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| expression | float(T it) | First order by this expression |
| thenBy | string(T it) | Then order by this expression |
Returns T[]

## orderBy (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| expression | string(T it) | First order by this expression |
| thenBy | float(T it) | Then order by this expression |
Returns T[]

## orderBy (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| expression | string(T a) | First order by this expression |
Returns T[]

## orderBy (member function of List)
Sort the list by a given expression

| Parameter | Type | Description |
| --- | --- | --- |
| expression | float(T a) | First order by this expression |
| order | SortingOrder | Specifies if you want to sort in ascending or descending order |
Returns T[]

## orderBy (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| expression | Time(T a) | First order by this expression |
Returns T[]

## orderBy (member function of List)
Sort the list by a given expression

| Parameter | Type | Description |
| --- | --- | --- |
| expression | Time(T a) | First order by this expression |
| order | SortingOrder | Specifies if you want to sort in ascending or descending order |
Returns T[]

## orderBy (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| expression | Angle(T a) | First order by this expression |
Returns T[]

## any (member function of List)
Returns true if the given condition is true for any item in the list

| Parameter | Type | Description |
| --- | --- | --- |
| predicate | bool(T a) | The condition to check |
Returns bool

## none (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| predicate | bool(T a) | The condition to check |
Returns bool

## all (member function of List)
Returns true if the given condition is true for all items in the list

| Parameter | Type | Description |
| --- | --- | --- |
| predicate | bool(T a) | The condition to check |
Returns bool

## select (member function of List)
Return a list that contains the selected field or expression for each item

| Parameter | Type | Description |
| --- | --- | --- |
| selector | TValue(T it, int i) | Selects a field or expression for each item |
Returns TValue[]

## flatten (member function of List)
Get the selected field or expression for each item and flattens the result

| Parameter | Type | Description |
| --- | --- | --- |
| selector | TValue[](T it) | Parameter of flatten |
Returns TValue[]

## find (member function of List)
Find an item the meets the given condition

Example: Find a player with a specific id
```
app
    getPlayerById: int id
        return players.find.id == id
```

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
Returns T

## find (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
Returns T

## find (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
| startIndex | int | Start searching at this index |
Returns T

## find (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
| startIndex | int | Start searching at this index |
Returns T

## findIn (member function of List)
Execute a selector for each item and if it returns a value that isn't null, return this value

Example: Find object that is nested within another object
```
transport.routes.findIn.trips.find.id == tripId
```

| Parameter | Type | Description |
| --- | --- | --- |
| selector | TValue(T it) | Parameter of findIn |
Returns TValue

## has (member function of List)
Does the list have an item that meets the given condition?

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
| startIndex | int | Start searching at this index |
Returns bool

## indexWhere (member function of List)
Find the index of the item the meets the given condition

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
| startIndex | int | Start searching at this index |
Returns int

## indexWhere (member function of List)
Find the index of the item the meets the given condition

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
| startIndex | int | Start searching at this index |
Returns int

## lastIndexWhere (member function of List)
Seaching backwards, find the last index of the item the meets the given condition

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
| startIndex | int | Start searching at this index |
Returns int

## where (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
Returns T[]

## except (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | Parameter of except |
Returns T[]

## take (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| count | int | Parameter of take |
Returns T[]

## total (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T it) | Parameter of total |
Returns int

## total (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T it) | Parameter of total |
| where | bool(T a) | Parameter of total |
Returns int

## total (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T it) | Parameter of total |
Returns float

## sum (member function of List)
Returns int

## average (member function of List)
Returns float

## joinToString (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | string(T a) | Parameter of joinToString |
| separator | string | Parameter of joinToString |
Returns string

## shuffle (member function of List)
Returns T[]

## shuffled (member function of List)
Returns T[]

## percentile (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of percentile |
Returns T

## min (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of min |
| threshold | int | Parameter of min |
| default | int | Parameter of min |
Returns int

## min (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of min |
| threshold | float | Parameter of min |
| default | float | Parameter of min |
Returns float

## min (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of min |
| threshold | int | Parameter of min |
| default | int | Parameter of min |
| where | bool(T a) | Parameter of min |
Returns int

## min (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of min |
| threshold | float | Parameter of min |
| default | float | Parameter of min |
| where | bool(T a) | Parameter of min |
Returns float

## min (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | Time(T a) | Parameter of min |
| threshold | Time | Parameter of min |
| default | Time | Parameter of min |
Returns Time

## max (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of max |
| threshold | int | Parameter of max |
| default | int | Parameter of max |
Returns int

## max (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of max |
| threshold | float | Parameter of max |
| default | float | Parameter of max |
Returns float

## max (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of max |
| threshold | int | Parameter of max |
| default | int | Parameter of max |
| where | bool(T a) | Parameter of max |
Returns int

## max (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of max |
| threshold | float | Parameter of max |
| default | float | Parameter of max |
| where | bool(T a) | Parameter of max |
Returns float

## max (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | Time(T a) | Parameter of max |
| threshold | Time | Parameter of max |
| default | Time | Parameter of max |
Returns Time

## max (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | Time(T a) | Parameter of max |
| threshold | Time | Parameter of max |
| default | Time | Parameter of max |
| where | bool(T a) | Parameter of max |
Returns Time

## maxUnique (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of maxUnique |
| threshold | int | Parameter of maxUnique |
| default | int | Parameter of maxUnique |
Returns int

## minIndex (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of minIndex |
| startIndex | int | Parameter of minIndex |
| threshold | float | Parameter of minIndex |
Returns int

## maxIndex (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of maxIndex |
| startIndex | int | Parameter of maxIndex |
| threshold | float | Parameter of maxIndex |
Returns int

## withMin (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of withMin |
| threshold | int | Parameter of withMin |
Returns T

## withMin (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of withMin |
| threshold | float | Parameter of withMin |
Returns T

## withMin (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of withMin |
| threshold | int | Parameter of withMin |
| where | bool(T a) | Parameter of withMin |
Returns T

## withMin (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of withMin |
| threshold | float | Parameter of withMin |
| where | bool(T a) | Parameter of withMin |
Returns T

## withMax (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of withMax |
| threshold | int | Parameter of withMax |
Returns T

## withMax (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of withMax |
| threshold | float | Parameter of withMax |
Returns T

## withMax (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of withMax |
| threshold | int | Parameter of withMax |
| where | bool(T a) | Parameter of withMax |
Returns T

## withMax (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | float(T a) | Parameter of withMax |
| threshold | float | Parameter of withMax |
| where | bool(T a) | Parameter of withMax |
Returns T

## popMax (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of popMax |
| threshold | int | Parameter of popMax |
Returns T

## popMax (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| selector | int(T a) | Parameter of popMax |
| threshold | float | Parameter of popMax |
Returns T

## count (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| predicate | bool(T a) | Parameter of count |
Returns int

## countNot (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| predicate | bool(T a) | Parameter of countNot |
Returns int

## rotate (member function of List)
Returns void

## rotate (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| count | int | Parameter of rotate |
Returns void

## intersectWith (member function of List)
| Parameter | Type | Description |
| --- | --- | --- |
| other | T[] | Parameter of intersectWith |
Returns T[]

## first (member function of List)
The first item of the list

Returns T

## second (member function of List)
The second item of the list

Returns T

## last (member function of List)
The last item of the list

Returns T

## get (member function of List)
Get an item from the list

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to get |
Returns T

## get (member function of List)
Get a new list that is a subset of this list

| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Return a new list starting from this index, a negative index will start from the end of the list |
| to | int | Return a new list up to (but not including) this index, a negative index is counted from the end |
Returns T[]

## get (member function of List)
Get a new list that is a subset of this list

| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Return a new list starting from this index, a negative index will start from the end of the list |
Returns T[]

## set (member function of List)
Set the item at a given index

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to set |
| value | T | The new value to set |
Returns T

## getOrSet (member function of List)
Tries to get an item from the list. If it doesn't exist, it sets it.
TODO: Support index with side effect (e.g. list[index++] ?= 0)

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | Parameter of getOrSet |
| value | T | Parameter of getOrSet |
Returns T

## addToItem (member function of List)
Add a value to an item of the list

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to change |
| value | T | The value to add to the item |
Returns T

## subtractFromItem (member function of List)
Subtract a value from an item of the list

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to change |
| value | T | The value to subtract from the item |
Returns T

## multiplyItem (member function of List)
Multiply an item of the list by a value

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to change |
| value | T | The value to multiply the item by |
Returns T

## divideItem (member function of List)
Divide an item of the list by a value

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to change |
| value | T | The value to divide the item by |
Returns T

## incrementItem (member function of List)
Add 1 to item of the list

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to change |
Returns T

## decrementItem (member function of List)
Subtract 1 from an item of the list

| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to change |
Returns T

---

# class Map
A data container that stores key-value pairs
## get (member function of Map)
Get the item assosiated with the given key

| Parameter | Type | Description |
| --- | --- | --- |
| key | TKey | The key of the item to get from the map |
Returns TValue

## set (member function of Map)
Set the item for the given key

| Parameter | Type | Description |
| --- | --- | --- |
| key | TKey | The key of the item to add to the map |
| value | TValue | The item to add to the map |
Returns void

## getOrSet (member function of Map)
| Parameter | Type | Description |
| --- | --- | --- |
| key | TKey | Parameter of getOrSet |
| value | TValue | Parameter of getOrSet |
Returns TValue

## addToItem (member function of Map)
Add a value to an item of the list

| Parameter | Type | Description |
| --- | --- | --- |
| key | TKey | The key of the item to add to the map |
| value | TValue | The item to add to the map |
Returns T

## incrementItem (member function of Map)
Add 1 to item of the map

| Parameter | Type | Description |
| --- | --- | --- |
| key | TKey | Parameter of incrementItem |
Returns T

## decrementItem (member function of Map)
Subtract 1 to item of the map

| Parameter | Type | Description |
| --- | --- | --- |
| key | TKey | Parameter of decrementItem |
Returns T

## remove (member function of Map)
Remove the item assosiated with the given key

| Parameter | Type | Description |
| --- | --- | --- |
| key | TKey | The key of the item to remove from the map |
Returns void

## has (member function of Map)
Does the map have an item with a specific key?

| Parameter | Type | Description |
| --- | --- | --- |
| key | TKey | The key of the item to check |
Returns bool

## clear (member function of Map)
Remove all items from the map

Returns void

## length (member function of Map)
Returns int

## removeWhere (member function of Map)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(TValue it) | The condition to check |
Returns void

---

# class SourceCodeLocation
This struct is automatically filled with the source code location
## toBool (member function of SourceCodeLocation)
Returns bool

## toString (member function of SourceCodeLocation)
Returns string

## find (member function of SourceCodeLocation)
| Parameter | Type | Description |
| --- | --- | --- |
| file | string | Parameter of find |
| pos | int | Parameter of find |
Returns SourceCodeLocation

## find (member function of SourceCodeLocation)
| Parameter | Type | Description |
| --- | --- | --- |
| location | SourceCodeLocation | Parameter of find |
Returns SourceCodeLocation

## leaf (member function of SourceCodeLocation)
Returns SourceCodeLocation

---

# class object
The base class for all classes
## undefined (static member function of object)
Returns any

## toBool (member function of object)
Returns bool

## toJson (static member function of object)
| Parameter | Type | Description |
| --- | --- | --- |
| value | any | Parameter of toJson |
Returns string

## toFormattedJson (static member function of object)
| Parameter | Type | Description |
| --- | --- | --- |
| value | any | Parameter of toFormattedJson |
Returns string

## isEqualAndSameType (static member function of object)
| Parameter | Type | Description |
| --- | --- | --- |
| a | any | Parameter of isEqualAndSameType |
| b | any | Parameter of isEqualAndSameType |
Returns bool

---

# class Image
## toString (member function of Image)
Returns string

---

# class ImmutableList
## get (member function of ImmutableList)
| Parameter | Type | Description |
| --- | --- | --- |
| index | int | The index of the item to get |
Returns T

---

# class Set
A data container that stores unique values of a given type
## get (member function of Set)
Return a boolean indicating whether an element with the specified value exists in this set

| Parameter | Type | Description |
| --- | --- | --- |
| value | T | The value to check |
Returns bool

## add (member function of Set)
Add a new element to this set, if there isn't already an element with the same value

| Parameter | Type | Description |
| --- | --- | --- |
| value | T | The value to add |
Returns void

## remove (member function of Set)
Remove a value from the set

| Parameter | Type | Description |
| --- | --- | --- |
| value | T | The value to remove |
Returns void

## has (member function of Set)
Is a certain value in the set?

| Parameter | Type | Description |
| --- | --- | --- |
| value | T | The value to check |
Returns bool

## toList (member function of Set)
Returns T[]

## clear (member function of Set)
Remove all items from the set

Returns void

## length (member function of Set)
Return the number of items in the set

Returns int

---

# struct Reference
## set (member function of Reference)
| Parameter | Type | Description |
| --- | --- | --- |
| value | T | Parameter of set |
Returns void

## get (member function of Reference)
Returns T

---

# class Error
## toString (member function of Error)
Returns string

---

# static class System
## if (global function)
Executes code depending on whether a given condition is true or false

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool | The condition to check |
| then | void() | Do this if the condition is true |
Returns void

## if (global function)
Executes code depending on whether a given condition is true or false

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool | The condition to check |
| then | void() | Do this if the condition is true |
| else | void() | Do this if the condition is false |
Returns void

## if (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool | Parameter of if |
| then | T | Parameter of if |
| else | T | Parameter of if |
Returns T

## while (global function)
Executes code as long as a given condition is true

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool | The condition to check |
| do | void() | Do this while to condition is true |
Returns void

## loop (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void() | Parameter of loop |
Returns void

## do (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void() | Do this while to condition is true |
| while | bool | The condition to check |
Returns void

## promise (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| resolve | void(void(T a) resolve) | Parameter of promise |
Returns Promise<T>

## doNotSerialize (static member function of System)
| Parameter | Type | Description |
| --- | --- | --- |
| object | any | Parameter of doNotSerialize |
Returns void

## for (global function)
Do something a given number of times or for each item in a list

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, int i) | Do this for each item in a list |
Returns void

## for (global function)
Do something a given number of times or for each item in a list

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, int i) | Do this for each item in a list |
Returns void

## for (global function)
Do something a given number of times or for each item in a list

| Parameter | Type | Description |
| --- | --- | --- |
| subject | TValue[TKey] | The list to iterate over |
| do | void(TValue it, TKey key) | Do this for each item in a list |
Returns void

## for (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | The integer to start iterating from (for exmaple "for 2 to 5: print ." prints 2, 3, 4) |
| do | void(int i) | Do this for each value in the given range |
| to | int | The exclusive upper bound to iterate towards (for exmaple "for 3: print ." prints 0, 1, 2) |
Returns void

## for (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | The integer to start iterating from |
| do | void(int i) | Do this for each value in the given range |
| to | int | The exclusive upper bound to iterate towards |
Returns void

## for (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| to | int | The exclusive upper bound to iterate towards |
| do | void(int i) | Do this the given number of times |
Returns void

## for (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| to | int | The exclusive upper bound to iterate towards |
| do | void(int i) | Do this the given number of times |
Returns void

## for (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | string | Iterate over every character of this string |
| do | void(string it, int i) | Do this for each character in the given string |
Returns void

## for (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | string | Iterate over every character of this string |
| do | void(string it, int i) | Do this for each character in the given string |
Returns void

## for (global function)
Do something a given number of times or for each item in a list

| Parameter | Type | Description |
| --- | --- | --- |
| subject | dynamic | The list to iterate over |
| do | void(dynamic it, string key) | Do this for each item in a list |
Returns void

## for (global function)
Creates a new list populated with the results of calling a function on every element of the list

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | TResult(T it) | Select the field or expression to be included in the result |
Returns TResult[]

## for (global function)
Creates a new list populated with the results of calling a function on every element of the list

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | TResult(T it) | Select the field or expression to be included in the result |
Returns TResult[]

## for (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| to | int | The exclusive upper bound to iterate towards |
| do | TResult(int i) | Select the field or expression to be included in the result |
Returns TResult[]

## for (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | The integer to start iterating from |
| do | TResult(int i) | Select the field or expression to be included in the result |
| to | int | The exclusive upper bound to iterate towards |
| step | int | Parameter of for |
Returns TResult[]

## forChangeable (global function)
Do something for each item in a list. You can add or remove items inside the loop.

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, int i) | Do this for each item in a list |
Returns void

## forChangeable (global function)
Do something for each item in a list. You can add or remove items inside the loop.

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, int i) | Do this for each item in a list |
Returns void

## forLookAhead (global function)
[a,b,c] -> (a, next:b), (b, next:c), (c, next:null)

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T next, int i) | Do this for each consecutive pair in a list |
Returns void

## forLookAhead (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T next, int i) | Do this for each consecutive pair in a list |
Returns void

## forLookBack (global function)
[a,b,c] -> (prev:null, a), (prev:a, b), (prev:b, c)

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T prev, int i) | Do this for each consecutive pair in a list |
Returns void

## forLookBack (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T prev, int i) | Do this for each consecutive pair in a list |
Returns void

## forLookAheadAndBack (global function)
[a,b,c] -> (prev:null, a, next:b), (prev:a, b, next:c), (prev:b, c, next:null)

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T prev, T next, int i) | Do this for each triple in a list |
Returns void

## forLookAheadAndBack (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T prev, T next, int i) | Do this for each triple in a list |
Returns void

## forPairs (global function)
[a,b,c] -> (a, next:b), (b, next:c)

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T next, int i) | Do this for each consecutive pair in a list |
Returns void

## forPairs (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T next, int i) | Do this for each consecutive pair in a list |
Returns void

## forWrappingPairs (global function)
[a,b,c] -> (a, next:b), (b, next:c), (c, next:a)

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T next, int i) | Do this for each consecutive pair in a list |
Returns void

## forWrappingPairs (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T next, int i) | Do this for each consecutive pair in a list |
Returns void

## forTriples (global function)
[a,b,c] -> (prev:a, b, next:c)

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T prev, T next, int i) | Do this for each triple in a list |
Returns void

## forTriples (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T prev, T next, int i) | Do this for each triple in a list |
Returns void

## forWrappingTriples (global function)
[a,b,c] -> (prev:c, a, next:b), (prev:a, b, next:c), (prev:b, c, next:a)

| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T prev, T next, int i) | Do this for each triple in a list |
Returns void

## forWrappingTriples (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| subject | T[] | The list to iterate over |
| do | void(T it, T prev, T next, int i) | Do this for each triple in a list |
Returns void

## log (static member function of System)
| Parameter | Type | Description |
| --- | --- | --- |
| value | any | Parameter of log |
Returns void

## watch (global function)
Display a message in the timeline

| Parameter | Type | Description |
| --- | --- | --- |
| text | string | The text, variables or expressions to watch |
| sourceCodeLocation | SourceCodeLocation | Parameter of watch |
Returns void

## alert (global function)
Shows a dialog box with a given message

| Parameter | Type | Description |
| --- | --- | --- |
| message | string | The message to show |
Returns void

## break (global function)
Returns void

## continue (global function)
Returns void

## try (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| code | void() | Parameter of try |
| catch | void(Error error) | Parameter of try |
Returns void

## try (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| code | void() | Parameter of try |
| catch | void(Error error) | Parameter of try |
| finally | void() | Parameter of try |
Returns void

## try (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| code | void() | Parameter of try |
| finally | void() | Parameter of try |
Returns void

## print (global function)
Prints a message to the console

| Parameter | Type | Description |
| --- | --- | --- |
| text | string | The text, variables or expressions to print |
| location | SourceCodeLocation | Parameter of print |
Returns void

---

# static class math
## abs (static member function of math)
Returns the absolute value

| Parameter | Type | Description |
| --- | --- | --- |
| value | int | The value to return the absolute value of |
Returns int

## abs (static member function of math)
Returns the absolute value

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | The value to return the absolute value of |
Returns float

## abs (static member function of math)
Returns the absolute value

| Parameter | Type | Description |
| --- | --- | --- |
| value | Angle | The angle to return the absolute value of |
Returns Angle

## sign (static member function of math)
Returns -1, 0, or 1 depending on the sign of the value

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of sign |
Returns float

## sqrt (static member function of math)
Returns the positive square root of the given value

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | The value to return the square root of |
Returns float

## hypot (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| a | float | Parameter of hypot |
| b | float | Parameter of hypot |
Returns float

## moveTowards (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of moveTowards |
| targetValue | float | Parameter of moveTowards |
| speed | float | Parameter of moveTowards |
Returns float

## moveTowards (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | Angle | Parameter of moveTowards |
| targetValue | Angle | Parameter of moveTowards |
| speed | Angle | Parameter of moveTowards |
Returns Angle

## floor (static member function of math)
Returns the largest integer less than or equal to the given value

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | The value to round down |
Returns int

## floor (static member function of math)
Returns the largest integer less than or equal to the given value

| Parameter | Type | Description |
| --- | --- | --- |
| value | Time | The value to round down |
Returns Time

## floor (static member function of math)
Returns the largest integer less than or equal to the given value

| Parameter | Type | Description |
| --- | --- | --- |
| value | Angle | The angle to round down |
Returns Angle

## ceil (static member function of math)
Returns the smallest integer greater than or equal to the given value

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | The value to round up |
Returns int

## ceil (static member function of math)
Returns the smallest integer greater than or equal to the given value

| Parameter | Type | Description |
| --- | --- | --- |
| value | Time | The value to round up |
Returns Time

## ceil (static member function of math)
Returns the smallest integer greater than or equal to the given value

| Parameter | Type | Description |
| --- | --- | --- |
| value | Angle | The angle to round up |
Returns Angle

## round (static member function of math)
Returns the given value rounded to the nearest integer

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | The value to round |
Returns int

## round (static member function of math)
Returns the given value rounded to the nearest integer

| Parameter | Type | Description |
| --- | --- | --- |
| value | Time | The angle to round |
Returns Time

## round (static member function of math)
Returns the given value rounded to the nearest integer

| Parameter | Type | Description |
| --- | --- | --- |
| value | Angle | The angle to round |
Returns Angle

## min (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| a | int | The first value |
| b | int | The second value |
Returns int

## min (static member function of math)
Returns the smallest of the given values

| Parameter | Type | Description |
| --- | --- | --- |
| a | float | The first value |
| b | float | The second value |
Returns float

## min (static member function of math)
Returns the smallest of the given values

| Parameter | Type | Description |
| --- | --- | --- |
| a | Angle | The first angle |
| b | Angle | The second angle |
Returns Angle

## max (static member function of math)
Returns the largest of the given values

| Parameter | Type | Description |
| --- | --- | --- |
| a | int | The first value |
| b | int | The second value |
Returns int

## max (static member function of math)
Returns the largest of the given values

| Parameter | Type | Description |
| --- | --- | --- |
| a | float | The first value |
| b | float | The second value |
Returns float

## max (static member function of math)
Returns the largest of the given values

| Parameter | Type | Description |
| --- | --- | --- |
| a | Time | The first time |
| b | Time | The second time |
Returns Time

## max (static member function of math)
Returns the largest of the given values

| Parameter | Type | Description |
| --- | --- | --- |
| a | Angle | The first angle |
| b | Angle | The second angle |
Returns Angle

## sin (static member function of math)
Returns the sine of an angle in turns

| Parameter | Type | Description |
| --- | --- | --- |
| angle | Angle | The angle in turns (one full rotation is 1) |
Returns float

## cos (static member function of math)
Returns the cosine of an angle in turns

| Parameter | Type | Description |
| --- | --- | --- |
| angle | Angle | The angle in turns (one full rotation is 1) |
Returns float

## tan (static member function of math)
Returns the tangent of an angle in turns

| Parameter | Type | Description |
| --- | --- | --- |
| angle | Angle | Parameter of tan |
Returns float

## atan2 (static member function of math)
Returns the inverse tangent in turns

| Parameter | Type | Description |
| --- | --- | --- |
| y | float | Parameter of atan2 |
| x | float | Parameter of atan2 |
Returns Angle

## log (static member function of math)
e raised to which power resuls in the given value?

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of log |
Returns float

## log2 (static member function of math)
2 raised to which power resuls in the given value?

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of log2 |
Returns float

## log10 (static member function of math)
10 raised to which power resuls in the given value?

| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of log10 |
Returns float

## pow (static member function of math)
Return the given base raised to the power of the given exponent

| Parameter | Type | Description |
| --- | --- | --- |
| base | float | Parameter of pow |
| exponent | float | Parameter of pow |
Returns float

## exp (static member function of math)
Returns e raised to the power of a given number

| Parameter | Type | Description |
| --- | --- | --- |
| exponent | float | Parameter of exp |
Returns float

## shiftLeft (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of shiftLeft |
| count | int | Parameter of shiftLeft |
Returns int

## shiftRight (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of shiftRight |
| count | int | Parameter of shiftRight |
Returns int

## limit (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of limit |
| min | int | Parameter of limit |
| max | int | Parameter of limit |
Returns int

## limit (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of limit |
| max | int | Parameter of limit |
Returns int

## limit (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of limit |
| min | int | Parameter of limit |
Returns int

## limit (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of limit |
| min | float | Parameter of limit |
| max | float | Parameter of limit |
Returns float

## limit (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of limit |
| max | float | Parameter of limit |
Returns float

## limit (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of limit |
| min | float | Parameter of limit |
Returns float

## randomString (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| length | int | Parameter of randomString |
Returns string

## getAngleForVector (static member function of math)
Returns the arctangent of the quotient of the given values

| Parameter | Type | Description |
| --- | --- | --- |
| vector | Vector2 | Parameter of getAngleForVector |
Returns Angle

## getVectorForAngle (static member function of math)
| Parameter | Type | Description |
| --- | --- | --- |
| angle | Angle | The angle in turns (0: straight up, 1: one full rotation clockwise) |
| radius | float | Parameter of getVectorForAngle |
Returns Vector2

## map (static member function of math)
Maps a value from an input range to an output range

| Parameter | Type | Description |
| --- | --- | --- |
| progress | float | The input value |
| from | float | The beginning of the input range |
| to | float | The end of the input range |
| start | float | The lowest possible output value, will be returned for values smaller than "from". |
| target | float | The highest possible output value, will be returned for values larger than "to". |
Returns float

## map (static member function of math)
Maps a value from an input range to an output range

| Parameter | Type | Description |
| --- | --- | --- |
| progress | float | The input value |
| start | float | The lowest possible output value, will be returned for values smaller than "from". |
| target | float | The highest possible output value, will be returned for values larger than "to". |
Returns float

## map (static member function of math)
// Maps a value from an input range to an output range

| Parameter | Type | Description |
| --- | --- | --- |
| progress | float | The input value |
| from | float | The beginning of the input range |
| to | float | The end of the input range |
| start | float | The lowest possible output value, will be returned for values smaller than "from". |
| target | float | The highest possible output value, will be returned for values larger than "to". |
| ease | EaseFunction | The easing function to apply |
Returns float

## interpolate (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| from | float | Parameter of interpolate |
| to | float | Parameter of interpolate |
| startTime | Time | Parameter of interpolate |
| duration | Time | Parameter of interpolate |
Returns float

## randomInteger (global function)
Generates a random integer

| Parameter | Type | Description |
| --- | --- | --- |
| min | int | The inclusive lower bound of the random integer |
| max | int | The exclusive upper bound of the random integer |
Returns int

## randomInteger (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| max | int | The exclusive upper bound of the random integer |
Returns int

## randomFloat (global function)
Generates a random float

Returns int

---

# struct RollingList
## add (member function of RollingList)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of add |
Returns void

## measure (member function of RollingList)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void() | Parameter of measure |
Returns void

## average (member function of RollingList)
Returns float

## max (member function of RollingList)
Returns float

## min (member function of RollingList)
Returns float

## toString (member function of RollingList)
Returns string

---

# class Range
## contains (member function of Range)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of contains |
Returns bool

## containsInclusively (member function of Range)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of containsInclusively |
Returns bool

---

# class File
## objectUrl (member function of File)
Returns string

---

# static class Loca
## languageName (static member function of Loca)
Returns string

## setLanguage (static member function of Loca)
| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of setLanguage |
| locale | string | Parameter of setLanguage |
Returns void

## format (static member function of Loca)
| Parameter | Type | Description |
| --- | --- | --- |
| id | int | Parameter of format |
Returns string

---

# class Buffer
## writeInt (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of writeInt |
Returns void

## readInt (member function of Buffer)
Returns int

## writeUnsignedInt (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of writeUnsignedInt |
Returns void

## readUnsignedInt (member function of Buffer)
Returns int

## writeString (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of writeString |
Returns void

## readString (member function of Buffer)
Returns string

## setInt16 (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| index | int | Parameter of setInt16 |
| value | int | Parameter of setInt16 |
Returns void

## writeInt8 (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of writeInt8 |
Returns void

## writeUnsignedInt8 (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of writeUnsignedInt8 |
Returns void

## writeInt16 (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of writeInt16 |
Returns void

## writeUnsignedInt16 (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of writeUnsignedInt16 |
Returns void

## writeInt32 (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | int | Parameter of writeInt32 |
Returns void

## writeFloat32 (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of writeFloat32 |
Returns void

## writeFloat64 (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of writeFloat64 |
Returns void

## writeBool (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| value | bool | Parameter of writeBool |
Returns void

## writeBuffer (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| source | Buffer | Parameter of writeBuffer |
Returns void

## writeBuffer (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| source | Buffer | Parameter of writeBuffer |
| start | int | Parameter of writeBuffer |
| length | int | Parameter of writeBuffer |
Returns void

## insertArrayBuffer (member function of Buffer)
Insert a raw array buffer at the writePos without writing its length

| Parameter | Type | Description |
| --- | --- | --- |
| sourceArrayBuffer | any | Parameter of insertArrayBuffer |
Returns void

## copyFromBuffer (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| source | Buffer | Parameter of copyFromBuffer |
Returns void

## set (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| source | Buffer | Parameter of set |
Returns void

## peekInt8 (member function of Buffer)
Returns int

## peekInt16 (member function of Buffer)
Returns int

## peekInt32 (member function of Buffer)
Returns int

## readInt8 (member function of Buffer)
Returns int

## readUnsignedInt8 (member function of Buffer)
Returns int

## readInt16 (member function of Buffer)
Returns int

## readUnsignedInt16 (member function of Buffer)
Returns int

## readInt32 (member function of Buffer)
Returns int

## readFloat32 (member function of Buffer)
Returns float

## readFloat64 (member function of Buffer)
Returns float

## readBool (member function of Buffer)
Returns bool

## readBuffer (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| writeBuffer | Buffer | Parameter of readBuffer |
| writeStart | int | Parameter of readBuffer |
Returns int

## toString (member function of Buffer)
Returns string

## toRangeString (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| start | int | Parameter of toRangeString |
| end | int | Parameter of toRangeString |
Returns string

## init (static member function of Buffer)
Returns void

## canRead (member function of Buffer)
Returns bool

## toByteArray (member function of Buffer)
Returns object

## subArrayBuffer (member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of subArrayBuffer |
| to | int | Parameter of subArrayBuffer |
Returns dynamic

## reset (member function of Buffer)
Returns void

## rewind (member function of Buffer)
Returns void

## checksum (member function of Buffer)
Returns int

## listToChecksum (static member function of Buffer)
| Parameter | Type | Description |
| --- | --- | --- |
| list | int[] | Parameter of listToChecksum |
Returns int

## toList (member function of Buffer)
Returns int[]

---

# class Time
## dayMonthString (member function of Time)
(31.12.)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthString |
Returns string

## dayMonthYearString (member function of Time)
(31.12.2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearString |
Returns string

## dayMonthNameYearString (member function of Time)
(31 December 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthNameYearString |
Returns string

## dayOfWeekDayMonthString (member function of Time)
(Monday, December 31)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthString |
Returns string

## dayOfWeekString (member function of Time)
(Monday)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekString |
Returns string

## dayOfWeekDayMonthAtHourMinuteString (member function of Time)
(Monday, December 31 at 12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthAtHourMinuteString |
Returns string

## hourMinuteString (member function of Time)
(23:59) The time is assumed to be local time, doesn't account for timezone offset

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of hourMinuteString |
Returns string

## toHourMinuteString (static member function of Time)
(23:59) The time is assumed to be local time, doesn't account for timezone offset

| Parameter | Type | Description |
| --- | --- | --- |
| value | Time | Parameter of toHourMinuteString |
| language | Language | Parameter of toHourMinuteString |
Returns string

## minuteSecondString (member function of Time)
(59:59) The time is assumed to be local time, doesn't account for timezone offset

Returns string

## hourMinuteSecondString (member function of Time)
(23:59:59)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of hourMinuteSecondString |
Returns string

## dayMonthYearHourMinuteString (member function of Time)
(31.12.2000 23:59)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearHourMinuteString |
Returns string

## dayMonthYearHourMinuteSecondString (member function of Time)
(31.12.2000 23:59:59)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearHourMinuteSecondString |
Returns string

## invariantDayMonthYearHourMinuteSecondString (member function of Time)
(31-12-2000 23-59-59)

Returns string

## compactString (member function of Time)
(20001231235959+02:00)

Returns string

## minutesHoursDaysOrWeeksString (member function of Time)
(7 weeks)

| Parameter | Type | Description |
| --- | --- | --- |
| showWeeksAfterDays | int | Parameter of minutesHoursDaysOrWeeksString |
Returns string

## maxValue (static member function of Time)
The largest possible time value

Returns Time

## minValue (static member function of Time)
The smallest possible time value

Returns Time

## fromTimeString (static member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| timeString | string | Parameter of fromTimeString |
Returns Time

## fromIsoString (static member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| isoString | string | Parameter of fromIsoString |
Returns Time

## fromValues (static member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| year | int | Parameter of fromValues |
| month | int | Parameter of fromValues |
| day | int | Parameter of fromValues |
| hour | int | Parameter of fromValues |
| minute | int | Parameter of fromValues |
| second | int | Parameter of fromValues |
Returns Time

## toFloat (member function of Time)
Returns float

## toInt (member function of Time)
Returns int

## toString (member function of Time)
Returns string

## toBool (member function of Time)
Returns true if the time is not zero

Returns bool

## format (member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| fractionDigits | int | Parameter of format |
| minIntegerDigits | int | Parameter of format |
| grouping | bool | Parameter of format |
Returns string

## format (member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| fractionDigits | int | Parameter of format |
| grouping | bool | Parameter of format |
Returns string

## format (member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| minIntegerDigits | int | Parameter of format |
| grouping | bool | Parameter of format |
Returns string

## milliseconds (member function of Time)
Returns int

## seconds (member function of Time)
Returns int

## minutes (member function of Time)
Returns int

## hours (member function of Time)
Returns int

## totalSeconds (member function of Time)
Returns int

## totalMinutes (member function of Time)
Returns int

## totalHours (member function of Time)
Returns int

## totalDays (member function of Time)
Returns int

## totalWeeks (member function of Time)
Returns int

## measure (static member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void() | Parameter of measure |
Returns float

## in (member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| unit | TimeUnit | Convert the time to this unit |
Returns float

## startTimer (static member function of Time)
Returns void

## printTimer (static member function of Time)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | Parameter of printTimer |
Returns void

## preciseTime (static member function of Time)
Returns float

## now (static member function of Time)
The number of milliseconds elapsed since January 1, 1970

Returns Time

---

# class TimeString
## now (static member function of TimeString)
Returns TimeString

## fromTime (static member function of TimeString)
| Parameter | Type | Description |
| --- | --- | --- |
| value | Time | Parameter of fromTime |
Returns TimeString

## toBool (member function of TimeString)
Returns bool

## toString (member function of TimeString)
Returns string

## dayMonthString (member function of TimeString)
(31.12.)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthString |
Returns string

## dayMonthYearString (member function of TimeString)
(31.12.2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearString |
Returns string

## dayMonthNameYearString (member function of TimeString)
(31 December 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthNameYearString |
Returns string

## dayShortMonthNameString (member function of TimeString)
(31 Dec)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayShortMonthNameString |
Returns string

## dayOfWeekDayMonthNameYearString (member function of TimeString)
(31 December 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthNameYearString |
Returns string

## dayOfWeekDayMonthString (member function of TimeString)
(Monday, December 31)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthString |
Returns string

## dayOfWeekString (member function of TimeString)
(Monday)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekString |
Returns string

## dayOfWeekShortString (member function of TimeString)
(Monday)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekShortString |
Returns string

## hourMinuteString (member function of TimeString)
(12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of hourMinuteString |
Returns string

## dayOfWeekDayMonthAtHourMinuteString (member function of TimeString)
(Monday, December 31 at 12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthAtHourMinuteString |
Returns string

## dayOfWeekDayMonthYearHourMinuteString (member function of TimeString)
(Monday, 31 December 2000, 12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthYearHourMinuteString |
Returns string

---

# class PlainTimeString
## now (static member function of PlainTimeString)
Returns PlainTimeString

## toBool (member function of PlainTimeString)
Returns bool

## toString (member function of PlainTimeString)
Returns string

## dayMonthString (member function of PlainTimeString)
(31.12.)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthString |
Returns string

## dayMonthYearString (member function of PlainTimeString)
(31.12.2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearString |
Returns string

## dayMonthNameYearString (member function of PlainTimeString)
(31 December 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthNameYearString |
Returns string

## dayShortMonthNameString (member function of PlainTimeString)
(31 Dec)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayShortMonthNameString |
Returns string

## dayOfWeekDayMonthNameYearString (member function of PlainTimeString)
(31 December 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthNameYearString |
Returns string

## dayOfWeekDayMonthString (member function of PlainTimeString)
(Monday, December 31)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthString |
Returns string

## dayOfWeekString (member function of PlainTimeString)
(Monday)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekString |
Returns string

## dayOfWeekShortString (member function of PlainTimeString)
(Monday)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekShortString |
Returns string

## hourMinuteString (member function of PlainTimeString)
(12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of hourMinuteString |
Returns string

## dayOfWeekDayMonthAtHourMinuteString (member function of PlainTimeString)
(Monday, December 31 at 12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthAtHourMinuteString |
Returns string

## dayOfWeekDayMonthYearHourMinuteString (member function of PlainTimeString)
(Monday, 31 December 2000, 12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthYearHourMinuteString |
Returns string

---

# class DateTime
Calculate dates using pure math for better performance without using the Date class
## twoDigitDay (member function of DateTime)
Returns string

## twoDigitMonth (member function of DateTime)
Returns string

## twoDigitHour (member function of DateTime)
Returns string

## twoDigitMinute (member function of DateTime)
Returns string

## twoDigitSecond (member function of DateTime)
Returns string

## now (static member function of DateTime)
Returns DateTime

## fromTimeInSeconds (static member function of DateTime)
| Parameter | Type | Description |
| --- | --- | --- |
| timeInSeconds | float | Parameter of fromTimeInSeconds |
| outputTimezone | int | Parameter of fromTimeInSeconds |
Returns DateTime

## fromTime (static member function of DateTime)
| Parameter | Type | Description |
| --- | --- | --- |
| time | Time | Parameter of fromTime |
| outputTimezone | int | Parameter of fromTime |
Returns DateTime

## fromValues (static member function of DateTime)
| Parameter | Type | Description |
| --- | --- | --- |
| year | int | Parameter of fromValues |
| month | int | Parameter of fromValues |
| day | int | Parameter of fromValues |
| hour | int | Parameter of fromValues |
| minute | int | Parameter of fromValues |
| second | int | Parameter of fromValues |
| milliseconds | int | Parameter of fromValues |
| inputTimezone | int | Parameter of fromValues |
| outputTimezone | int | Parameter of fromValues |
Returns DateTime

## getDaysInMonth (static member function of DateTime)
| Parameter | Type | Description |
| --- | --- | --- |
| month | int | Parameter of getDaysInMonth |
| year | int | Parameter of getDaysInMonth |
Returns int

## dayMonthString (member function of DateTime)
(31.12.)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthString |
Returns string

## dayMonthYearString (member function of DateTime)
(31.12.2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearString |
Returns string

## dayMonthNameYearString (member function of DateTime)
(31 December 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthNameYearString |
Returns string

## dayShortMonthNameString (member function of DateTime)
(31 Dec)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayShortMonthNameString |
Returns string

## dayOfWeekDayMonthNameYearString (member function of DateTime)
(31 December 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthNameYearString |
Returns string

## dayOfWeekDayMonthString (member function of DateTime)
(Monday, December 31)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthString |
Returns string

## dayOfWeekString (member function of DateTime)
(Monday)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekString |
Returns string

## dayOfWeekShortString (member function of DateTime)
(Monday)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekShortString |
Returns string

## hourMinuteString (member function of DateTime)
(12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of hourMinuteString |
Returns string

## dayOfWeekDayMonthAtHourMinuteString (member function of DateTime)
(Monday, December 31 at 12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthAtHourMinuteString |
Returns string

## dayOfWeekDayMonthYearHourMinuteString (member function of DateTime)
(Monday, 31 December 2000, 12:59 pm)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekDayMonthYearHourMinuteString |
Returns string

## compactString (member function of DateTime)
(20001231235959+02:00)

Returns string

## fromTimeString (static member function of DateTime)
| Parameter | Type | Description |
| --- | --- | --- |
| timeString | TimeString | Parameter of fromTimeString |
Returns DateTime

## fromTimeString (static member function of DateTime)
| Parameter | Type | Description |
| --- | --- | --- |
| timeString | PlainTimeString | Parameter of fromTimeString |
Returns DateTime

## fromIsoString (static member function of DateTime)
With Milliseconds
1  1  1  2   2. 2
0    5  8  1  4  7  0   4  7
2024-10-17 15:23:30.504+02:00
2024-10-17 15:23:30.504Z

Without Milliseconds
1  1  1  2  2
0    5  8  1  4  7  0  3
2024-10-17 15:23:30+02:00
2024-10-17 15:23:30Z

| Parameter | Type | Description |
| --- | --- | --- |
| str | string | Parameter of fromIsoString |
| outputTimezone | int | Parameter of fromIsoString |
Returns DateTime

## toPlainTimeString (member function of DateTime)
Returns PlainTimeString

## toTimeString (member function of DateTime)
Returns TimeString

---

# class Date
Calculate dates using the JavaScript Date class
## now (static member function of Date)
Returns Date

## year (member function of Date)
Returns int

## month (member function of Date)
Returns int

## day (member function of Date)
Returns int

## dayOfWeek (member function of Date)
Returns int

## hour (member function of Date)
Returns int

## minute (member function of Date)
Returns int

## second (member function of Date)
Returns int

## millisecond (member function of Date)
Returns int

## twoDigitMonth (member function of Date)
Returns string

## twoDigitDay (member function of Date)
Returns string

## twoDigitHour (member function of Date)
Returns string

## twoDigitMinute (member function of Date)
Returns string

## twoDigitSecond (member function of Date)
Returns string

## timeOfDay (member function of Date)
Returns Time

## dayMonthString (member function of Date)
(31.12.)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthString |
Returns string

## dayMonthYearString (member function of Date)
(31.12.2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearString |
Returns string

## dayLongMonthNameYearString (member function of Date)
(31 December 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayLongMonthNameYearString |
Returns string

## dayShortMonthNameYearString (member function of Date)
(31 Dec 2000)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayShortMonthNameYearString |
Returns string

## dayOfWeekString (member function of Date)
(Monday)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayOfWeekString |
Returns string

## shortDayOfWeekString (member function of Date)
(Mon)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of shortDayOfWeekString |
Returns string

## hourMinuteString (member function of Date)
(23:59)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of hourMinuteString |
Returns string

## hourMinuteSecondString (member function of Date)
(23:59:59)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of hourMinuteSecondString |
Returns string

## hourMinuteSecondMillisecondString (member function of Date)
(23:59:59.999)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of hourMinuteSecondMillisecondString |
Returns string

## dayMonthYearHourMinuteString (member function of Date)
(31.12.2000 23:59)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearHourMinuteString |
Returns string

## dayMonthYearHourMinuteSecondString (member function of Date)
(31.12.2000 23:59:59)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of dayMonthYearHourMinuteSecondString |
Returns string

## invariantDayMonthYearHourMinuteSecondString (member function of Date)
(31-12-2000 23-59-59)

| Parameter | Type | Description |
| --- | --- | --- |
| language | Language | Parameter of invariantDayMonthYearHourMinuteSecondString |
Returns string

## time (member function of Date)
The number of milliseconds elapsed since January 1, 1970

Returns Time

## isoString (member function of Date)
The data and time in ISO 8601 format, for example "2000-12-31T17:30:00.000Z"

Returns string

## fromTime (static member function of Date)
| Parameter | Type | Description |
| --- | --- | --- |
| time | Time | Parameter of fromTime |
Returns Date

## fromValues (static member function of Date)
| Parameter | Type | Description |
| --- | --- | --- |
| year | int | Parameter of fromValues |
| month | int | Parameter of fromValues |
| day | int | Parameter of fromValues |
| hour | int | Parameter of fromValues |
| minute | int | Parameter of fromValues |
| second | int | Parameter of fromValues |
Returns Date

## realtime (static member function of Date)
Returns the real time, even during replay. Be careful: This can break the replay.

Returns Date

---

# class Node
## class (member function of Node)
A string to assign a class to one or more elements, often used to style several elements

Returns string

## class (member function of Node)
A string to assign a class to one or more elements, often used to style several elements

| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of class |
Returns string

## remove (member function of Node)
Returns Node

## appendChild (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| node | Node | Parameter of appendChild |
Returns void

## insertBefore (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| newNode | Node | Parameter of insertBefore |
| referenceNode | Node | Parameter of insertBefore |
Returns void

## setSelectionRange (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Parameter of setSelectionRange |
| to | int | Parameter of setSelectionRange |
Returns void

## select (member function of Node)
Returns void

## setCursorPosition (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| index | int | Parameter of setCursorPosition |
Returns void

## focus (member function of Node)
Returns void

## scrollToBottom (member function of Node)
Returns void

## scrollIntoView (member function of Node)
Returns void

## on (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| eventName | string | Parameter of on |
| listener | void(dynamic event) | Parameter of on |
Returns void

## getContext (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| type | string | Parameter of getContext |
Returns dynamic

## setAttribute (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| name | string | Parameter of setAttribute |
| value | string | Parameter of setAttribute |
Returns void

## set (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| name | string | Parameter of set |
| value | string | Parameter of set |
Returns void

## get (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| name | string | Parameter of get |
Returns void

## create (static member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| tagName | string | Parameter of create |
Returns Node

## click (member function of Node)
Returns void

## animate (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| from | Style | Parameter of animate |
| to | Style | Parameter of animate |
| duration | Time | Parameter of animate |
| fill | AnimationFill | Parameter of animate |
| easing | string | Parameter of animate |
Returns void

## onTouchDown (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(Touch touch, Touch[] touches, Node node, PointerEvent event) | Parameter of onTouchDown |
Returns void

## onTouchMove (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(Touch touch, Touch[] touches, Node node, PointerEvent event) | Parameter of onTouchMove |
Returns void

## onTouchUp (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(Touch touch, Touch[] touches, Node node, PointerEvent event) | Parameter of onTouchUp |
Returns void

## onTouchCancel (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(Touch touch, Touch[] touches, Node node, PointerEvent event) | Parameter of onTouchCancel |
Returns void

## onScroll (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(Vector2 position, Vector2 delta, bool isPinch) | Parameter of onScroll |
Returns void

## captureTouch (member function of Node)
| Parameter | Type | Description |
| --- | --- | --- |
| touch | Touch | Parameter of captureTouch |
Returns void

---

# class PointerEvent
## stopPropagation (member function of PointerEvent)
Returns void

## preventDefault (member function of PointerEvent)
Returns void

## position (member function of PointerEvent)
The position of the pointer relative to the whole document

Returns Vector2

---

# class HtmlEvent
## stopPropagation (member function of HtmlEvent)
Returns void

## preventDefault (member function of HtmlEvent)
Returns void

## relativeTouchPosition (member function of HtmlEvent)
Returns Vector2

## touchPosition (member function of HtmlEvent)
Returns Vector2

---

# class HtmlKeyboardEvent
## stopPropagation (member function of HtmlKeyboardEvent)
Returns void

## preventDefault (member function of HtmlKeyboardEvent)
Returns void

---

# static class Html
## scrollPosition (static member function of Html)
Returns Vector2

## scrollTo (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| x | float | Parameter of scrollTo |
| y | float | Parameter of scrollTo |
Returns void

## get (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| id | string | Parameter of get |
Returns Node

## documentBody (static member function of Html)
Returns Node

## getNodeAt (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| x | float | Parameter of getNodeAt |
| y | float | Parameter of getNodeAt |
Returns Node

## init (static member function of Html)
Returns void

## initHandlers (static member function of Html)
Returns void

## enableScrolling (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| value | bool | Parameter of enableScrolling |
Returns void

## expandStyle (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| style | Style | Parameter of expandStyle |
Returns Style

## getUserMedia (static member function of Html)
Returns Promise<any>

## getRelativeMousePosition (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| event | HtmlEvent | Parameter of getRelativeMousePosition |
| node | Node | Parameter of getRelativeMousePosition |
Returns Vector2

## setCursorPosition (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| element | Node | Parameter of setCursorPosition |
| position | int | Parameter of setCursorPosition |
Returns void

## refresh (global function)
Returns void

## script (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| src | string | Parameter of script |
| data | dynamic | Parameter of script |
Returns void

## css (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| src | string | Parameter of css |
Returns void

## style (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | Parameter of style |
Returns Node

## row (global function)
Lays outs its children in a horizontal row

| Parameter | Type | Description |
| --- | --- | --- |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| children | void() | The children of the HTML element |
| location | SourceCodeLocation | Parameter of row |
Returns Node

## column (global function)
Lays out its children in a vertical column

| Parameter | Type | Description |
| --- | --- | --- |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| children | void() | The children of the HTML element |
| location | SourceCodeLocation | Parameter of column |
Returns Node

## grid (global function)
Lays out its children in a grid

| Parameter | Type | Description |
| --- | --- | --- |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| gridTemplateColumns | float[] | The sizes of the columns |
| children | void() | The children of the HTML element |
| location | SourceCodeLocation | Parameter of grid |
Returns Node

## img (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| image | Image | The image to display |
| onClick | void(HtmlEvent ev) | Called when the user clicks the image |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| visible | bool | Parameter of img |
| location | SourceCodeLocation | Parameter of img |
Returns Node

## img (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| src | string | The file of the image to display |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| location | SourceCodeLocation | Parameter of img |
Returns Node

## img (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| src | string | The file of the image to display |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| location | SourceCodeLocation | Parameter of img |
Returns Node

## link (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | Parameter of link |
| href | string | Parameter of link |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| location | SourceCodeLocation | Parameter of link |
Returns Node

## span (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | Parameter of span |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| location | SourceCodeLocation | Parameter of span |
Returns Node

## button (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | Parameter of button |
| onClick | void(HtmlEvent ev) | Called when the user clicks the button |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| location | SourceCodeLocation | Parameter of button |
Returns Node

## button (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | Parameter of button |
| onClick | bool(HtmlEvent ev) | Called when the user clicks the button |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| disableAfterClick | bool | Parameter of button |
| location | SourceCodeLocation | Parameter of button |
Returns Node

## video (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| src | string | The file of the video to display |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| location | SourceCodeLocation | Parameter of video |
Returns void

## iframe (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| src | string | The url of the content to display |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| frameborder | int | Parameter of iframe |
| allow | string | Parameter of iframe |
| referrerpolicy | string | Parameter of iframe |
| allowfullscreen | bool | Parameter of iframe |
| location | SourceCodeLocation | Parameter of iframe |
Returns Node

## webview (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| initialUrl | string | The url of the content to display |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| onNavigate | void(string url) | Parameter of webview |
| location | SourceCodeLocation | Parameter of webview |
Returns WebView

## body (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| attributes | Attributes | The attributes of the element |
| style | Style | Apply this css style to the element |
| children | void() | Parameter of body |
| header | void() | Parameter of body |
| location | SourceCodeLocation | Parameter of body |
Returns void

## div (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | The text content of the element |
| tag | string | The tag of element |
| attributes | Attributes | The attributes of the element |
| style | Style | Apply this css style to the element |
| data | dynamic | The data attributes of the element |
| onHover | Style | Apply this css style to the element when the user moves their mouse over the element |
| children | void() | The children of the element |
| location | SourceCodeLocation | Parameter of div |
Returns Node

## overlay (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| attributes | Attributes | The attributes of the element |
| style | Style | Apply this css style to the element |
| children | void() | The children of the element |
| location | SourceCodeLocation | Parameter of overlay |
Returns Node

## onChange (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| onChange | void() | Parameter of onChange |
| do | void() | Parameter of onChange |
Returns void

## radio (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| model | int | The variable that holds the value. This will be updated when the user clicks the radio button |
| value | int | The value of this state of the radio button |
| image | Image | The image to display |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| location | SourceCodeLocation | Parameter of radio |
Returns void

## radio (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| model | int | The variable that holds the value. This will be updated when the user clicks the radio button |
| value | int | The value of this state of the radio button |
| image | Image | The image to display |
| onInput | void() | Called when the user clicks the radio button |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| location | SourceCodeLocation | Parameter of radio |
Returns void

## toggle (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| model | bool | The variable that holds the value. This will be updated when the user clicks the toggle button |
| images | Image[] | A list with one image per state of the toggle |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| location | SourceCodeLocation | Parameter of toggle |
Returns void

## toggle (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| model | bool | The variable that holds the value. This will be updated when the user clicks the toggle button |
| images | Image[] | A list with one image per state of the toggle |
| onInput | void() | Called when the user clicks the toggle button |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| location | SourceCodeLocation | Parameter of toggle |
Returns void

## field (global function)
Automatic Text Input: Updates the model automatically in with every keystroke

| Parameter | Type | Description |
| --- | --- | --- |
| model | string | The variable that holds the value. This will be updated when the user changed the text |
| focused | bool | Whether the cursor should be placed in the field |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| location | SourceCodeLocation | Parameter of field |
Returns void

## field (global function)
Automatic Text Input: Updates the model automatically in with every keystroke

| Parameter | Type | Description |
| --- | --- | --- |
| model | string | The variable that holds the value. This will be updated when the user changed the text |
| focused | bool | Whether the cursor should be placed in the field |
| onEnter | void() | Called when the user presses the enter key |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| location | SourceCodeLocation | Parameter of field |
Returns void

## field (global function)
Manual Text Input: If you specify a onChange handler, the model won't be updated automatically

| Parameter | Type | Description |
| --- | --- | --- |
| model | string | The variable that holds the value. This will be updated when the user changed the text |
| focused | bool | Whether the cursor should be placed in the field |
| onChange | void(string value) | If you specify a onChange handler, the model won't be updated automatically |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| realtime | bool | Should onChange be called with every keystroke? |
| location | SourceCodeLocation | Parameter of field |
Returns void

## fileInput (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| accept | string | Parameter of fileInput |
| capture | string | Parameter of fileInput |
| multiple | bool | Parameter of fileInput |
| onChange | void(Node node) | Parameter of fileInput |
| style | Style | Parameter of fileInput |
| location | SourceCodeLocation | Parameter of fileInput |
Returns Node

## getDataUrlForFile (static member function of Html)
| Parameter | Type | Description |
| --- | --- | --- |
| file | File | Parameter of getDataUrlForFile |
Returns Promise<string>

## editableText (global function)
Automatic Editable Text: Updates the model automatically in with every keystroke

| Parameter | Type | Description |
| --- | --- | --- |
| model | string | The variable that holds the value. This will be updated when the user changed the text |
| onChanged | void(string value) | Called after the model changed |
| tabIndex | int | Parameter of editableText |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| realtime | bool | Should onChange be called with every keystroke? |
| location | SourceCodeLocation | Parameter of editableText |
Returns void

## editableText (global function)
Automatic Editable Text: Updates the model automatically in with every keystroke

| Parameter | Type | Description |
| --- | --- | --- |
| model | string | The variable that holds the value. This will be updated when the user changed the text |
| onChanged | void(string value) | Called after the model changed |
| onClick | void() | Parameter of editableText |
| tabIndex | int | Parameter of editableText |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| data | dynamic | The data attributes of the element |
| realtime | bool | Should onChange be called with every keystroke? |
| location | SourceCodeLocation | Parameter of editableText |
Returns void

## textarea (global function)
Automatic Text Area: Updates the model automatically in with every keystroke

| Parameter | Type | Description |
| --- | --- | --- |
| model | string | The variable that holds the value. This will be updated when the user changed the text |
| focused | bool | Whether the cursor should be placed in the field |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| location | SourceCodeLocation | Parameter of textarea |
Returns void

## canvas (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| size | Vector2 | Parameter of canvas |
| attributes | Attributes | The attributes of the HTML element |
| style | Style | The css style of the HTML element |
| draw | void() | Parameter of canvas |
| location | SourceCodeLocation | Parameter of canvas |
Returns Node

## drawRectangle (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| pos | Vector2 | Parameter of drawRectangle |
| size | Vector2 | Parameter of drawRectangle |
| color | Color | Parameter of drawRectangle |
Returns void

## drawText (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | Parameter of drawText |
| pos | Vector2 | Parameter of drawText |
| size | float | Parameter of drawText |
| font | Font | Parameter of drawText |
| color | Color | Parameter of drawText |
Returns void

---

# struct Angle
## toFloat (member function of Angle)
Returns float

## toString (member function of Angle)
Returns string

## toBool (member function of Angle)
Returns true if the angle is not zero

Returns bool

## assign (member function of Angle)
| Parameter | Type | Description |
| --- | --- | --- |
| other | Angle | Parameter of assign |
Returns Angle

## assign (member function of Angle)
| Parameter | Type | Description |
| --- | --- | --- |
| other | float | Parameter of assign |
Returns Angle

## operator (static member function of Angle)
| Parameter | Type | Description |
| --- | --- | --- |
| a | Angle | Parameter of operator |
Returns Angle

---

# static class input
## init (static member function of input)
Returns void

## initHandlers (static member function of input)
Returns void

## clear (static member function of input)
Returns void

## onKeyDown (static member function of input)
| Parameter | Type | Description |
| --- | --- | --- |
| key | Key | Parameter of onKeyDown |
| do | void(Key key) | Parameter of onKeyDown |
Returns void

---

# struct Vector2
## interpolateTo (member function of Vector2)
Interpolates to another vector

| Parameter | Type | Description |
| --- | --- | --- |
| target | Vector2 | The target position to interpolate to |
| progress | float | The progress of the interpolation (0: return the start vector, 1: returns the target vector) |
Returns Vector2

## interpolateTo (member function of Vector2)
Interpolates to another vector

| Parameter | Type | Description |
| --- | --- | --- |
| target | Vector2 | The target position to interpolate to |
| startTime | Time | Parameter of interpolateTo |
| duration | Time | Parameter of interpolateTo |
Returns Vector2

## interpolateTo (member function of Vector2)
Interpolates to another vector

| Parameter | Type | Description |
| --- | --- | --- |
| target | Vector2 | The target position to interpolate to |
| progress | float | The progress of the interpolation (0: return the start vector, 1: returns the target vector) |
| ease | EaseFunction | Parameter of interpolateTo |
Returns Vector2

## interpolateTo (member function of Vector2)
Interpolates to another vector

| Parameter | Type | Description |
| --- | --- | --- |
| target | Vector2 | The target position to interpolate to |
| startTime | Time | Parameter of interpolateTo |
| duration | Time | Parameter of interpolateTo |
| ease | EaseFunction | Parameter of interpolateTo |
Returns Vector2

## interpolateTo (member function of Vector2)
// Interpolates to another vector

| Parameter | Type | Description |
| --- | --- | --- |
| target | Vector2 | The target position to interpolate to |
| progress | float | Between "from" and "to" ("from" returns the start value, "to" returns the target value) |
| from | float | The beginning of the input range, if "progress" is "from" or less, the start value is returned |
| to | float | The end of the input range, if "progress" is "to" or more, the target value is returned |
Returns Vector2

## interpolateTo (member function of Vector2)
// Interpolates to another vector

| Parameter | Type | Description |
| --- | --- | --- |
| target | Vector2 | The target position to interpolate to |
| progress | float | Between "from" and "to" ("from" returns the start value, "to" returns the target value) |
| from | float | The beginning of the input range, if "progress" is "from" or less, the start value is returned |
| to | float | The end of the input range, if "progress" is "to" or more, the target value is returned |
| ease | EaseFunction | The easing function to apply |
Returns Vector2

## none (static member function of Vector2)
Used to specify that the vector is not set or invalid

Returns Vector2

## minValue (static member function of Vector2)
{float.minValue, float.minValue}

Returns Vector2

## maxValue (static member function of Vector2)
{float.maxValue, float.maxValue}

Returns Vector2

## zero (static member function of Vector2)
{0,0}

Returns Vector2

## toString (member function of Vector2)
A string representation of the vector

Returns string

## toBool (member function of Vector2)
Returns true if the vector is not equal to Vector2.None

Returns bool

## clone (member function of Vector2)
Creates a copy of the vector with the same values

Returns Vector2

## assignReference (member function of Vector2)
| Parameter | Type | Description |
| --- | --- | --- |
| value | Vector2 | Parameter of assignReference |
Returns Vector2

## assign (member function of Vector2)
| Parameter | Type | Description |
| --- | --- | --- |
| other | Vector2 | Parameter of assign |
Returns Vector2

## length (member function of Vector2)
The length of the vector

Returns float

## floor (member function of Vector2)
A vector with each coordinate rounded down to an integer value

Returns Vector2

## ceil (member function of Vector2)
A vector with each coordinate rounded down to an integer value

Returns Vector2

## inverse (member function of Vector2)
A vector with the sign of each coordinate flipped

Returns Vector2

## normalized (member function of Vector2)
A vector that points in the same direction, but has a length of 1

Returns Vector2

## distanceTo (member function of Vector2)
The distance to another vector

| Parameter | Type | Description |
| --- | --- | --- |
| value | Vector2 | The second vector |
Returns float

---

# static class http
## get (static member function of http)
Perform an http get request

| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of get |
Returns Promise<any>

## get (static member function of http)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of get |
| do | void(dynamic result) | Parameter of get |
Returns void

## getText (static member function of http)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of getText |
Returns Promise<any>

## getText (static member function of http)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of getText |
| do | void(string result) | Parameter of getText |
Returns void

## getArrayBuffer (static member function of http)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of getArrayBuffer |
Returns Promise<any>

## getFile (static member function of http)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of getFile |
| do | void(dynamic result) | Parameter of getFile |
Returns void

## post (static member function of http)
Perform an http post request

| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of post |
| body | dynamic | Parameter of post |
| do | void(any result) | Parameter of post |
Returns void

## put (static member function of http)
Perform an http post request

| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of put |
| body | dynamic | Parameter of put |
| do | void(dynamic result) | Parameter of put |
Returns void

## delete (static member function of http)
Perform an http delete request

| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of delete |
| do | void(dynamic result) | Parameter of delete |
Returns void

---

# static class Platform
## url (static member function of Platform)
Info

Returns string

## host (static member function of Platform)
Returns string

## basePath (static member function of Platform)
Returns string

## protocolAndHost (static member function of Platform)
Returns string

## referrer (static member function of Platform)
Returns string

## encodeURIComponent (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of encodeURIComponent |
Returns string

## decodeURIComponent (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| value | string | Parameter of decodeURIComponent |
Returns string

## networkInformation (static member function of Platform)
Returns dynamic

## start (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| isDebug | bool | Parameter of start |
Returns Promise<null>

## openMedia (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| success | void() | Parameter of openMedia |
Returns void

## initAll (static member function of Platform)
Returns void

## replay (static member function of Platform)
Returns Promise<null>

## stop (static member function of Platform)
Returns void

## generateObjectId (static member function of Platform)
Returns string

## toggleSmallScreen (static member function of Platform)
Returns void

## setLocalStorageString (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| key | string | Parameter of setLocalStorageString |
| value | string | Parameter of setLocalStorageString |
Returns void

## getLocalStorageString (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| key | string | Parameter of getLocalStorageString |
Returns string

## setLocalStorageObject (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| key | string | Parameter of setLocalStorageObject |
| value | any | Parameter of setLocalStorageObject |
Returns void

## getLocalStorageObject (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| key | string | Parameter of getLocalStorageObject |
| defaultValue | any | Parameter of getLocalStorageObject |
Returns any

## alert (static member function of Platform)
Shows a dialog box with a given message

| Parameter | Type | Description |
| --- | --- | --- |
| message | string | The message to show |
Returns void

## openLink (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of openLink |
Returns void

## redirect (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of redirect |
Returns void

## pushState (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of pushState |
| state | object | Parameter of pushState |
Returns void

## replaceState (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of replaceState |
| state | object | Parameter of replaceState |
Returns void

## copyToClipboard (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| text | string | Parameter of copyToClipboard |
Returns void

## delay (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| time | Time | Parameter of delay |
| do | void() | Parameter of delay |
Returns int

## delay (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| time | Time | Parameter of delay |
Returns Promise<void>

## clearDelay (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| handle | int | Parameter of clearDelay |
Returns int

## onBlur (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void() | Parameter of onBlur |
Returns void

## onFocus (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void() | Parameter of onFocus |
Returns void

## interval (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| time | Time | Parameter of interval |
| do | void() | Parameter of interval |
Returns int

## clearInterval (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| handle | int | Parameter of clearInterval |
Returns int

## stack (static member function of Platform)
Returns object

## debugger (static member function of Platform)
Returns void

## onNavigate (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(string url) | Parameter of onNavigate |
Returns void

## onPaste (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(DateTransfer data) | Parameter of onPaste |
Returns void

## blur (static member function of Platform)
Returns void

## setMenu (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| menuTemplate | MenuItem[] | Parameter of setMenu |
Returns void

## getCurrentLocation (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| enableHighAccuracy | bool | Parameter of getCurrentLocation |
| maximumAge | int | Parameter of getCurrentLocation |
| timeout | int | Parameter of getCurrentLocation |
Returns Promise<Vector2>

## onDeviceOrientation (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(Angle angle) | Parameter of onDeviceOrientation |
| else | void(string error) | Parameter of onDeviceOrientation |
Returns Promise<void>

## onCurrentLocation (static member function of Platform)
| Parameter | Type | Description |
| --- | --- | --- |
| do | void(Vector2 location) | Parameter of onCurrentLocation |
| else | void(string error) | Parameter of onCurrentLocation |
| enableHighAccuracy | bool | Parameter of onCurrentLocation |
| maximumAge | int | Parameter of onCurrentLocation |
| timeout | int | Parameter of onCurrentLocation |
Returns void

---

# class DataTransferItem
## getAsString (member function of DataTransferItem)
Returns Promise<string>

## getAsFile (member function of DataTransferItem)
Returns File

---

# class Color
A color comprised of a red, green, blue and alpha component
## toString (member function of Color)
Returns string

## componentToHex (static member function of Color)
| Parameter | Type | Description |
| --- | --- | --- |
| c | int | Parameter of componentToHex |
Returns string

## withAlpha (member function of Color)
| Parameter | Type | Description |
| --- | --- | --- |
| alpha | float | Parameter of withAlpha |
Returns Color

---

# class Sound
A sound
## open (member function of Sound)
Returns void

## stop (member function of Sound)
Returns void

## currentTime (member function of Sound)
| Parameter | Type | Description |
| --- | --- | --- |
| value | float | Parameter of currentTime |
Returns void

## play (member function of Sound)
Returns void

---

# static class audio
A collection of functions for playing audio
## playSound (global function)
| Parameter | Type | Description |
| --- | --- | --- |
| sound | Sound | Parameter of playSound |
Returns void

## stop (static member function of audio)
Returns void

---

# struct Dimension
## toString (member function of Dimension)
Returns string

## toBool (member function of Dimension)
Returns bool

---

# class Padding
## toString (member function of Padding)
Returns string

---

# class Margin
## toString (member function of Margin)
Returns string

---

# class Border
## toString (member function of Border)
Returns string

---

# class BoxShadow
## toString (member function of BoxShadow)
Returns string

---

# static class pocketBase
## connect (static member function of pocketBase)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of connect |
Returns Promise<void>

## connect (static member function of pocketBase)
Returns Promise<void>

## autoCancellation (static member function of pocketBase)
| Parameter | Type | Description |
| --- | --- | --- |
| value | bool | Parameter of autoCancellation |
Returns void

## onAuthChanged (static member function of pocketBase)
| Parameter | Type | Description |
| --- | --- | --- |
| code | void(any user) | Parameter of onAuthChanged |
Returns void

## authRefresh (static member function of pocketBase)
| Parameter | Type | Description |
| --- | --- | --- |
| ifNotLoggedIn | void() | Parameter of authRefresh |
Returns void

## token (static member function of pocketBase)
Returns string

## get (static member function of pocketBase)
| Parameter | Type | Description |
| --- | --- | --- |
| collectionName | string | Parameter of get |
Returns dynamic

## authWithPassword (static member function of pocketBase)
| Parameter | Type | Description |
| --- | --- | --- |
| email | string | Parameter of authWithPassword |
| password | string | Parameter of authWithPassword |
Returns Promise<dynamic>

## logout (static member function of pocketBase)
Returns void

---

# class Collection
## subscribe (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| topic | string | Parameter of subscribe |
| filter | string | Parameter of subscribe |
| fields | string | Parameter of subscribe |
| expand | string | Parameter of subscribe |
Returns Promise<void>

## fetchAll (member function of Collection)
Returns Promise<T[]>

## fetch (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| filter | string | Parameter of fetch |
| sort | string | Parameter of fetch |
| fields | string | Parameter of fetch |
| expand | string | Parameter of fetch |
| page | int | Parameter of fetch |
| perPage | int | Parameter of fetch |
| skipTotal | bool | Parameter of fetch |
Returns Promise<T[]>

## fetchOne (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| filter | string | Parameter of fetchOne |
| sort | string | Parameter of fetchOne |
| expand | string | Parameter of fetchOne |
Returns Promise<T>

## get (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| id | string | Parameter of get |
Returns Promise<T>

## get (member function of Collection)
Get a new list that is a subset of this list

| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Return a new list starting from this index, a negative index will start from the end of the list |
| to | int | Return a new list up to (but not including) this index, a negative index is counted from the end |
Returns T[]

## get (member function of Collection)
Get a new list that is a subset of this list

| Parameter | Type | Description |
| --- | --- | --- |
| from | int | Return a new list starting from this index, a negative index will start from the end of the list |
Returns T[]

## add (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| item | any | Parameter of add |
Returns Promise<string>

## update (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | Parameter of update |
Returns Promise<T>

## update (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| id | string | Parameter of update |
| update | dynamic | Parameter of update |
Returns Promise<T>

## save (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | Parameter of save |
Returns Promise<T>

## remove (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | Parameter of remove |
Returns Promise<void>

## upload (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | Parameter of upload |
| fileFieldName | string | Parameter of upload |
| files | File[] | Parameter of upload |
Returns Promise<void>

## uploadFromUrls (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| item | T | Parameter of uploadFromUrls |
| fileFieldName | string | Parameter of uploadFromUrls |
| urls | string[] | Parameter of uploadFromUrls |
Returns Promise<void>

## length (member function of Collection)
Gets the number of items in the list

Returns int

## find (member function of Collection)
Find an item the meets the given condition

Example: Find a player with a specific id
```
app
    getPlayerById: int id
        return players.find.id == id
```

| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
Returns T

## where (member function of Collection)
| Parameter | Type | Description |
| --- | --- | --- |
| condition | bool(T a) | The condition to check |
Returns T[]

## shuffle (member function of Collection)
Returns void

## popRandom (member function of Collection)
Remove a random item from the list and return it

Returns T

---

# class WebView
## downloadURL (member function of WebView)
| Parameter | Type | Description |
| --- | --- | --- |
| url | string | Parameter of downloadURL |
Returns void

## goBack (member function of WebView)
Returns void

