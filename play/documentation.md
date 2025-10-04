# The LiveTime Programming Language

# struct int

## undefined (static public member function of int)
Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)

Returns int

## remainder (public member function of int)
The remainer after a division by the given value. The sign stays the same.

| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| value     | int  | The value to divide by |

Returns int

## toBool (public member function of int)
Returns true if the integer is not zero

Returns bool

## toString (public member function of int)
Returns string

## fromHex (public member function of int)
| Parameter | Type   | Description          |
| --------- | ------ | -------------------- |
| value     | string | Parameter of fromHex |

Returns int

## formatWithSpaces (public member function of int)
Returns string

## format (public member function of int)
| Parameter        | Type | Description         |
| ---------------- | ---- | ------------------- |
| minIntegerDigits | int  | Parameter of format |
| grouping         | bool | Parameter of format |

Returns string

## abs (public member function of int)
Returns the absolute value of the integer

Returns int

## shiftLeft (public member function of int)
Shift the bits of the int to the left. Excess bits shifted off to the left are discarded

| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| count     | int  | The amount of bits to shift |

Returns int

## shiftRight (public member function of int)
Shift the bits of the int to the right. Excess bits shifted off to the right are discarded

| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| count     | int  | The amount of bits to shift |

Returns int

## bitwiseOr (public member function of int)
Perform a bitwise "or" operation

| Parameter | Type | Description                                |
| --------- | ---- | ------------------------------------------ |
| value     | int  | The value to perform the bitwise "or" with |

Returns int

## bitwiseAnd (public member function of int)
Perform a bitwise "and" operation

| Parameter | Type | Description                                 |
| --------- | ---- | ------------------------------------------- |
| value     | int  | The value to perform the bitwise "and" with |

Returns int

## isSet (public member function of int)
Check if a certain bit it set

| Parameter | Type | Description                                                      |
| --------- | ---- | ---------------------------------------------------------------- |
| value     | int  | The value of the bits to check (for example 1, 2, 4, 8, 16, ...) |

Returns bool

## isNotSet (public member function of int)
Check if a certain bit it not set

| Parameter | Type | Description                                                      |
| --------- | ---- | ---------------------------------------------------------------- |
| value     | int  | The value of the bits to check (for example 1, 2, 4, 8, 16, ...) |

Returns bool

## setFlag (public member function of int)
Set a specific bit of the integer

| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| bitIndex  | int  | The index of the bit to set |

Returns int

## clearFlag (public member function of int)
Clear a specific bit of the integer

| Parameter | Type | Description                   |
| --------- | ---- | ----------------------------- |
| bitIndex  | int  | The index of the bit to clear |

Returns int

## limit (public member function of int)
Limit the value to a specific range

Example: Limit the player's to be between 0 and 100
```
Player
    int health
    changeHealth: int delta
        health = (health + delta) limit 0..100
```

| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| from      | int  | The inclusive minimum value |
| to        | int  | The inclusive maximum value |

Returns int

## limit (public member function of int)
| Parameter | Type  | Description                 |
| --------- | ----- | --------------------------- |
| from      | float | The inclusive minimum value |
| to        | float | The inclusive maximum value |

Returns float

## limit (public member function of int)
Make sure the value never exceets a maximum value

Example: Make sure the card count never exceets a maximum value of 5
```
cardCount = cardCount limit ..5
```

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| to        | int  | Parameter of limit |

Returns int

## limit (public member function of int)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| to        | float | Parameter of limit |

Returns float

## limit (public member function of int)
Make sure the value never falls below a minimum value

Example: Make sure the score never fall below 0
```
score = score limit 0..
```

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| from      | int  | Parameter of limit |

Returns int

## limit (public member function of int)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| from      | float | Parameter of limit |

Returns float

## atLeast (public member function of int)
Make sure the value never falls below a minimum value

Example: Make sure the score never fall below 0
```
score = score atLeast 0
```

| Parameter | Type | Description          |
| --------- | ---- | -------------------- |
| value     | int  | Parameter of atLeast |

Returns int

## atLeast (public member function of int)
| Parameter | Type  | Description          |
| --------- | ----- | -------------------- |
| value     | float | Parameter of atLeast |

Returns float

## atMost (public member function of int)
Make sure the value never exceets a maximum value

Example: Make sure the card count never exceets a maximum value of 5
```
cardCount = cardCount atMost 5
```

| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| value     | int  | Parameter of atMost |

Returns int

## atMost (public member function of int)
| Parameter | Type  | Description         |
| --------- | ----- | ------------------- |
| value     | float | Parameter of atMost |

Returns float

## setIfLarger (public member function of int)
| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| newValue  | int  | Parameter of setIfLarger |

Returns int

## incrementAndWrap (public member function of int)
| Parameter | Type | Description                                                  |
| --------- | ---- | ------------------------------------------------------------ |
| max       | int  | When the integer reaches this value, it wraps around to zero |

Returns int

## decrementAndWrap (public member function of int)
| Parameter | Type | Description                                                  |
| --------- | ---- | ------------------------------------------------------------ |
| max       | int  | When the integer reaches this value, it wraps around to zero |

Returns int

## incrementUpTo (public member function of int)
| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| max       | int  | Parameter of incrementUpTo |

Returns int

## incrementUpToExclusive (public member function of int)
| Parameter | Type | Description                         |
| --------- | ---- | ----------------------------------- |
| max       | int  | Parameter of incrementUpToExclusive |

Returns int

## incrementBy (public member function of int)
| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| value     | int  | Parameter of incrementBy |
| upTo      | int  | Parameter of incrementBy |

Returns int

## decrementDownTo (public member function of int)
| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| min       | int  | Parameter of decrementDownTo |

Returns int

## decrementDownToExclusive (public member function of int)
| Parameter | Type | Description                           |
| --------- | ---- | ------------------------------------- |
| min       | int  | Parameter of decrementDownToExclusive |

Returns int

## within (public member function of int)
| Parameter | Type  | Description         |
| --------- | ----- | ------------------- |
| range     | Range | Parameter of within |

Returns bool

## withinInclusively (public member function of int)
| Parameter | Type  | Description                    |
| --------- | ----- | ------------------------------ |
| range     | Range | Parameter of withinInclusively |

Returns bool

## assignIfGreater (public member function of int)
| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| value     | int  | Parameter of assignIfGreater |

Returns int

## enumerate (static public member function of int)
| Parameter | Type           | Description            |
| --------- | -------------- | ---------------------- |
| from      | int            | Parameter of enumerate |
| to        | int            | Parameter of enumerate |
| selector  | TResult(int i) | Parameter of enumerate |

Returns TResult[]

## enumerate (static public member function of int)
| Parameter | Type           | Description            |
| --------- | -------------- | ---------------------- |
| from      | int            | Parameter of enumerate |
| to        | int            | Parameter of enumerate |
| step      | int            | Parameter of enumerate |
| selector  | TResult(int i) | Parameter of enumerate |

Returns TResult[]

## times (public member function of int)
| Parameter | Type           | Description        |
| --------- | -------------- | ------------------ |
| selector  | TResult(int i) | Parameter of times |

Returns TResult[]

---

# struct float

## maxValue (static public member function of float)
The largest possible floating point value

Returns float

## minValue (static public member function of float)
The smallest possible floating point value

Returns float

## undefined (static public member function of float)
Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)

Returns int

## infinity (static public member function of float)
Positiv infinity

Returns float

## epsilon (static public member function of float)
Returns float

## notANumber (static public member function of float)
Can result from failed conversion or operations with undefined or complex result

Returns float

## remainder (public member function of float)
The remainer after a division by the given value. The sign stays the same.

| Parameter | Type  | Description            |
| --------- | ----- | ---------------------- |
| value     | float | Parameter of remainder |

Returns float

## toInt (public member function of float)
Returns int

## toBool (public member function of float)
Returns true if the floot is not zero

Returns bool

## toString (public member function of float)
Returns string

## format (public member function of float)
| Parameter        | Type | Description         |
| ---------------- | ---- | ------------------- |
| fractionDigits   | int  | Parameter of format |
| minIntegerDigits | int  | Parameter of format |
| grouping         | bool | Parameter of format |

Returns string

## format (public member function of float)
| Parameter      | Type | Description         |
| -------------- | ---- | ------------------- |
| fractionDigits | int  | Parameter of format |
| grouping       | bool | Parameter of format |

Returns string

## format (public member function of float)
| Parameter        | Type | Description         |
| ---------------- | ---- | ------------------- |
| minIntegerDigits | int  | Parameter of format |
| grouping         | bool | Parameter of format |

Returns string

## abs (public member function of float)
Returns the absolute value

Returns float

## sign (public member function of float)
Returns -1, 0, or 1 depending on the sign of the value

Returns float

## ceil (public member function of float)
Returns the smallest integer greater than or equal to the given value

Returns int

## floor (public member function of float)
Returns the largest integer less than or equal to the given value

Returns int

## round (public member function of float)
Returns the given value rounded to the nearest integer

Returns int

## limit (public member function of float)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| from      | float | Parameter of limit |
| to        | float | Parameter of limit |

Returns float

## limit (public member function of float)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| to        | float | Parameter of limit |

Returns float

## limit (public member function of float)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| from      | float | Parameter of limit |

Returns float

## atLeast (public member function of float)
| Parameter | Type  | Description          |
| --------- | ----- | -------------------- |
| value     | float | Parameter of atLeast |

Returns float

## atMost (public member function of float)
| Parameter | Type  | Description         |
| --------- | ----- | ------------------- |
| value     | float | Parameter of atMost |

Returns float

## isApproximately (public member function of float)
| Parameter | Type  | Description                  |
| --------- | ----- | ---------------------------- |
| value     | float | Parameter of isApproximately |
| epsilon   | float | Parameter of isApproximately |

Returns bool

## moveTowards (public member function of float)
| Parameter | Type  | Description              |
| --------- | ----- | ------------------------ |
| value     | float | Parameter of moveTowards |
| speed     | float | Parameter of moveTowards |

Returns float

## moveTowardsAndEaseOut (public member function of float)
| Parameter | Type  | Description                        |
| --------- | ----- | ---------------------------------- |
| value     | float | Parameter of moveTowardsAndEaseOut |
| speed     | float | Parameter of moveTowardsAndEaseOut |

Returns float

## incrementBy (public member function of float)
| Parameter | Type  | Description              |
| --------- | ----- | ------------------------ |
| value     | float | Parameter of incrementBy |
| to        | float | Parameter of incrementBy |

Returns float

## toOrdinalString (public member function of float)
Returns string

## milliseconds (public member function of float)
Milliseconds

Returns float

## seconds (public member function of float)
Seconds

Returns float

## minutes (public member function of float)
Minutes

Returns float

## hours (public member function of float)
Hours

Returns float

## days (public member function of float)
Days

Returns float

## weeks (public member function of float)
Weeks

Returns float

## toDayMonthString (public member function of float)
(31.12.)

| Parameter | Type     | Description                   |
| --------- | -------- | ----------------------------- |
| language  | Language | Parameter of toDayMonthString |

Returns string

## toDayMonthYearString (public member function of float)
(31.12.2000)

| Parameter | Type     | Description                       |
| --------- | -------- | --------------------------------- |
| language  | Language | Parameter of toDayMonthYearString |

Returns string

## toDayMonthNameYearString (public member function of float)
(31 December 2000)

| Parameter | Type     | Description                           |
| --------- | -------- | ------------------------------------- |
| language  | Language | Parameter of toDayMonthNameYearString |

Returns string

## toDayOfWeekDayMonthString (public member function of float)
(Monday, December 31)

| Parameter | Type     | Description                            |
| --------- | -------- | -------------------------------------- |
| language  | Language | Parameter of toDayOfWeekDayMonthString |

Returns string

## toDayOfWeekString (public member function of float)
(Monday)

| Parameter | Type     | Description                    |
| --------- | -------- | ------------------------------ |
| language  | Language | Parameter of toDayOfWeekString |

Returns string

## toDayOfWeekDayMonthAtHourMinuteString (public member function of float)
(Monday, December 31 at 12:59 pm)

| Parameter | Type     | Description                                        |
| --------- | -------- | -------------------------------------------------- |
| language  | Language | Parameter of toDayOfWeekDayMonthAtHourMinuteString |

Returns string

## toMinuteSecondString (public member function of float)
(59:59) The time is assumed to be local time, doesn't account for timezone offset

Returns string

## toHourMinuteSecondString (public member function of float)
(23:59:59)

| Parameter | Type     | Description                           |
| --------- | -------- | ------------------------------------- |
| language  | Language | Parameter of toHourMinuteSecondString |

Returns string

## toDayMonthYearHourMinuteString (public member function of float)
(31.12.2000 23:59)

| Parameter | Type     | Description                                 |
| --------- | -------- | ------------------------------------------- |
| language  | Language | Parameter of toDayMonthYearHourMinuteString |

Returns string

## toDayMonthYearHourMinuteSecondString (public member function of float)
(31.12.2000 23:59:59)

| Parameter | Type     | Description                                       |
| --------- | -------- | ------------------------------------------------- |
| language  | Language | Parameter of toDayMonthYearHourMinuteSecondString |

Returns string

## toInvariantDayMonthYearHourMinuteSecondString (public member function of float)
(31-12-2000 23-59-59)

Returns string

## toCompactTimeString (public member function of float)
(20001231235959+02:00)

Returns string

## fromTimeString (static public member function of float)
| Parameter  | Type   | Description                 |
| ---------- | ------ | --------------------------- |
| timeString | string | Parameter of fromTimeString |

Returns float

## fromIsoString (static public member function of float)
| Parameter | Type   | Description                |
| --------- | ------ | -------------------------- |
| isoString | string | Parameter of fromIsoString |

Returns float

## timeMilliseconds (public member function of float)
Returns int

## timeSeconds (public member function of float)
Returns int

## timeMinutes (public member function of float)
Returns int

## timeHours (public member function of float)
Returns int

## totalSeconds (public member function of float)
Returns int

## totalMinutes (public member function of float)
Returns int

## totalHours (public member function of float)
Returns int

## totalDays (public member function of float)
Returns int

## totalWeeks (public member function of float)
Returns int

## in (public member function of float)
| Parameter | Type     | Description                   |
| --------- | -------- | ----------------------------- |
| unit      | TimeUnit | Convert the time to this unit |

Returns float

## startTimer (static public member function of float)
Returns void

## printTimer (static public member function of float)
| Parameter | Type   | Description             |
| --------- | ------ | ----------------------- |
| text      | string | Parameter of printTimer |

Returns void

## preciseTime (static public member function of float)
Returns float

## animateTo (public member function of float)
Animate the float to a target value over a given period of time

| Parameter | Type  | Description                                           |
| --------- | ----- | ----------------------------------------------------- |
| target    | float | The target value to animate to                        |
| delay     | float | The delay before the animation starts in milliseconds |
| duration  | float | The duration of the animation in milliseconds         |

Returns void

## animateTo (public member function of float)
Animate the float to a target value over a given period of time

| Parameter | Type         | Description                                           |
| --------- | ------------ | ----------------------------------------------------- |
| target    | float        | The target value to animate to                        |
| delay     | float        | The delay before the animation starts in milliseconds |
| duration  | float        | The duration of the animation in milliseconds         |
| ease      | EaseFunction | The easing function to apply                          |

Returns void

## turns (public member function of float)
One full rotation is 1

Returns float

## radians (public member function of float)
One full rotation is 2π (about 6.2832)

Returns float

## degrees (public member function of float)
One full rotation is 360

Returns float

## gradians (public member function of float)
One full rotation is 400

Returns float

## interpolateTo (public member function of float)
Interpolates to another value

| Parameter | Type  | Description                                                                                |
| --------- | ----- | ------------------------------------------------------------------------------------------ |
| target    | float | The target value to interpolate to                                                         |
| progress  | float | The progress of the interpolation (0: return the start value, 1: returns the target value) |

Returns float

## interpolateTo (public member function of float)
| Parameter | Type  | Description                                                                                    |
| --------- | ----- | ---------------------------------------------------------------------------------------------- |
| target    | float | The target value to interpolate to                                                             |
| progress  | float | Between "from" and "to" ("from" returns the start value, "to" returns the target value)        |
| from      | float | The beginning of the input range, if "progress" is "from" or less, the start value is returned |
| to        | float | The end of the input range, if "progress" is "to" or more, the target value is returned        |

Returns float

## interpolateTo (public member function of float)
Interpolates to another value

| Parameter | Type         | Description                                                                                |
| --------- | ------------ | ------------------------------------------------------------------------------------------ |
| target    | float        | The target value to interpolate to                                                         |
| progress  | float        | The progress of the interpolation (0: return the start value, 1: returns the target value) |
| ease      | EaseFunction | The easing function to apply (e.g InQuad, OutBack, ...)                                    |

Returns float

---

# class string

## length (public member function of string)
Returns the number of characters in the string

Returns int

## toUpperCase (public member function of string)
Returns a string with each character converted to uppercase

Returns string

## toLowerCase (public member function of string)
Returns a string with each character converted to lowercase

Returns string

## toBool (public member function of string)
Returns true if the string is not null and not empty

Returns bool

## toString (public member function of string)
Returns string

## toInt (public member function of string)
Returns int

## toFloat (public member function of string)
Returns int

## parseJson (public member function of string)
Returns dynamic

## parseInt (public member function of string)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| radix     | int  | Parameter of parseInt |

Returns int

## undefined (static public member function of string)
Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)

Returns string

## split (public member function of string)
Splits the string at the given character into a list of substrings

| Parameter | Type   | Description                           |
| --------- | ------ | ------------------------------------- |
| seperator | string | Separate the string at this character |

Returns string[]

## splitByLine (public member function of string)
| Parameter | Type   | Description                           |
| --------- | ------ | ------------------------------------- |
| seperator | string | Separate the string at this character |

Returns string[]

## splitToList (public member function of string)
Splits the string and return a list with the selected field or expression for each item

| Parameter | Type              | Description                                 |
| --------- | ----------------- | ------------------------------------------- |
| selector  | TValue(string it) | Selects a field or expression for each item |
| seperator | string            | Separate the string at this character       |

Returns TValue[]

## splitToObject (public member function of string)
Splits the string, passes a list of strings to a function and returns its return value

| Parameter | Type                | Description                                                               |
| --------- | ------------------- | ------------------------------------------------------------------------- |
| selector  | TValue(string[] it) | This functions gets a list of strings and should create an object from it |
| seperator | string              | Separate the string at this character                                     |

Returns TValue

## startsWith (public member function of string)
| Parameter | Type   | Description             |
| --------- | ------ | ----------------------- |
| str       | string | Parameter of startsWith |

Returns bool

## endsWith (public member function of string)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| str       | string | Parameter of endsWith |

Returns bool

## indexOf (public member function of string)
| Parameter | Type   | Description          |
| --------- | ------ | -------------------- |
| str       | string | Parameter of indexOf |

Returns int

## indexOf (public member function of string)
| Parameter | Type   | Description          |
| --------- | ------ | -------------------- |
| str       | string | Parameter of indexOf |
| startPos  | int    | Parameter of indexOf |

Returns int

## lastIndexOf (public member function of string)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| str       | string | Parameter of lastIndexOf |

Returns int

## lastIndexOf (public member function of string)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| str       | string | Parameter of lastIndexOf |
| startPos  | int    | Parameter of lastIndexOf |

Returns int

## contains (public member function of string)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| str       | string | Parameter of contains |

Returns bool

## getCharCodeAt (public member function of string)
| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| index     | int  | Parameter of getCharCodeAt |

Returns int

## fromCharCode (static public member function of string)
| Parameter | Type | Description               |
| --------- | ---- | ------------------------- |
| charCode  | int  | Parameter of fromCharCode |

Returns string

## substring (public member function of string)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| from      | int  | Parameter of substring |

Returns string

## substring (public member function of string)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| from      | int  | Parameter of substring |
| to        | int  | Parameter of substring |

Returns string

## getUntil (public member function of string)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| value     | string | Parameter of getUntil |
| start     | int    | Parameter of getUntil |

Returns string

## getUntilUnescaped (public member function of string)
| Parameter       | Type   | Description                    |
| --------------- | ------ | ------------------------------ |
| character       | string | Parameter of getUntilUnescaped |
| start           | int    | Parameter of getUntilUnescaped |
| escapeCharacter | string | Parameter of getUntilUnescaped |

Returns string

## getUntilLast (public member function of string)
| Parameter | Type   | Description               |
| --------- | ------ | ------------------------- |
| value     | string | Parameter of getUntilLast |
| start     | int    | Parameter of getUntilLast |

Returns string

## getAfter (public member function of string)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| value     | string | Parameter of getAfter |
| start     | int    | Parameter of getAfter |

Returns string

## getBetween (public member function of string)
| Parameter | Type   | Description             |
| --------- | ------ | ----------------------- |
| from      | string | Parameter of getBetween |
| to        | string | Parameter of getBetween |
| start     | int    | Parameter of getBetween |

Returns string

## getBetweenLast (public member function of string)
| Parameter | Type   | Description                 |
| --------- | ------ | --------------------------- |
| from      | string | Parameter of getBetweenLast |
| to        | string | Parameter of getBetweenLast |

Returns string

## compareTo (public member function of string)
Returns 0 for an exact match, 1 if first is larger, -1 if second is larger

| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| value     | string | The string to compare to |

Returns int

## trim (public member function of string)
Returns string

## trimStart (public member function of string)
Returns string

## trimEnd (public member function of string)
Returns string

## trimQuotes (public member function of string)
Returns string

## trimTabs (public member function of string)
Returns string

## getExtension (public member function of string)
Returns string

## interleaveWith (public member function of string)
| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| charCode  | int  | Parameter of interleaveWith |

Returns string

## replace (public member function of string)
| Parameter | Type   | Description          |
| --------- | ------ | -------------------- |
| value     | string | Parameter of replace |
| with      | string | Parameter of replace |

Returns string

## replaced (public member function of string)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| value     | string | Parameter of replaced |
| with      | string | Parameter of replaced |

Returns string

## padStart (public member function of string)
| Parameter    | Type   | Description           |
| ------------ | ------ | --------------------- |
| targetLength | int    | Parameter of padStart |
| padString    | string | Parameter of padStart |

Returns string

## padEnd (public member function of string)
| Parameter    | Type   | Description         |
| ------------ | ------ | ------------------- |
| targetLength | int    | Parameter of padEnd |
| padString    | string | Parameter of padEnd |

Returns string

## get (public member function of string)
| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| index     | int  | Parameter of get |

Returns string

## get (public member function of string)
| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| from      | int  | Parameter of get |
| to        | int  | Parameter of get |

Returns string

## get (public member function of string)
| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| from      | int  | Parameter of get |

Returns string

## capitalize (public member function of string)
Returns string

## capitalizeWords (public member function of string)
Returns string

## onlyLetters (public member function of string)
Returns string

## onlyNumbers (public member function of string)
Returns string

## backspace (public member function of string)
Returns string

## isLetter (public member function of string)
Returns bool

## toPlainTimeString (public member function of string)
Returns PlainTimeString

## toTimeString (public member function of string)
Returns TimeString

## toVector2 (public member function of string)
Returns Vector2

---

# class List

## each (public member function of List)
Do something for each item in a list

| Parameter | Type              | Description                     |
| --------- | ----------------- | ------------------------------- |
| do        | void(T it, int i) | Do this for each item in a list |

Returns void

## each (public member function of List)
| Parameter | Type              | Description                     |
| --------- | ----------------- | ------------------------------- |
| do        | void(T it, int i) | Do this for each item in a list |

Returns void

## eachChangable (public member function of List)
Do something for each item in a list. You can add or remove items inside the loop.

| Parameter | Type              | Description                     |
| --------- | ----------------- | ------------------------------- |
| do        | void(T it, int i) | Do this for each item in a list |

Returns void

## eachChangable (public member function of List)
| Parameter | Type              | Description                     |
| --------- | ----------------- | ------------------------------- |
| do        | void(T it, int i) | Do this for each item in a list |

Returns void

## eachDistinct (public member function of List)
| Parameter | Type                            | Description               |
| --------- | ------------------------------- | ------------------------- |
| selector  | TKey(T it)                      | Parameter of eachDistinct |
| sortBy    | EachDistinctSortBy              | Parameter of eachDistinct |
| do        | void(TKey it, T[] items, int i) | Parameter of eachDistinct |

Returns void

## add (public member function of List)
Add an item to the end of the list

| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| item      | T    | The item to add |

Returns void

## add (public member function of List)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| item      | T    | The item to add        |
| item2     | T    | The second item to add |

Returns void

## add (public member function of List)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| item      | T    | The item to add        |
| item2     | T    | The second item to add |
| item3     | T    | The third item to add  |

Returns void

## add (public member function of List)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| item      | T    | The item to add        |
| item2     | T    | The second item to add |
| item3     | T    | The third item to add  |
| item4     | T    | The fourth item to add |

Returns void

## add (public member function of List)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| item      | T    | The item to add        |
| item2     | T    | The second item to add |
| item3     | T    | The third item to add  |
| item4     | T    | The fourth item to add |
| item5     | T    | The fifth item to add  |

Returns void

## add (public member function of List)
Add an item and remove a item from the beginning if the length exceeds a maximum value

| Parameter | Type | Description                                                                         |
| --------- | ---- | ----------------------------------------------------------------------------------- |
| item      | T    | The item to add                                                                     |
| maxLength | int  | If the list gets longer than this maximum length, remove an item from the beginning |

Returns void

## add (public member function of List)
Add an list of item to the end of the list

| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| items     | T[]  | The list of items to add |

Returns void

## addRange (public member function of List)
Add an list of item to the end of the list

| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| items     | T[]  | The list of items to add |

Returns void

## insert (public member function of List)
Insert an item at a given index

| Parameter | Type | Description                   |
| --------- | ---- | ----------------------------- |
| item      | T    | The item to insert            |
| index     | int  | Insert the item at this index |

Returns void

## insert (public member function of List)
Insert an item at a given index

| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| item      | T    | The item to insert  |
| after     | T    | Parameter of insert |

Returns void

## remove (public member function of List)
Remove an item from the list

Example: Remove the current player instrance from the list of playeres when they died
```
Player
    die
        players.remove me
```

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| item      | T    | The item to remove |

Returns void

## remove (public member function of List)
| Parameter | Type | Description               |
| --------- | ---- | ------------------------- |
| item      | T    | The first item to remove  |
| item2     | T    | The second item to remove |

Returns void

## remove (public member function of List)
| Parameter | Type | Description               |
| --------- | ---- | ------------------------- |
| item      | T    | The first item to remove  |
| item2     | T    | The second item to remove |
| item3     | T    | The third item to remove  |

Returns void

## remove (public member function of List)
| Parameter | Type | Description               |
| --------- | ---- | ------------------------- |
| item      | T    | The first item to remove  |
| item2     | T    | The second item to remove |
| item3     | T    | The third item to remove  |
| item4     | T    | The forth item to remove  |

Returns void

## remove (public member function of List)
| Parameter | Type | Description               |
| --------- | ---- | ------------------------- |
| item      | T    | The first item to remove  |
| item2     | T    | The second item to remove |
| item3     | T    | The third item to remove  |
| item4     | T    | The forth item to remove  |
| item5     | T    | The fifth item to remove  |

Returns void

## remove (public member function of List)
Remove a list of items from the list

| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| items     | T[]  | The items to remove |

Returns void

## removeAt (public member function of List)
Remove the item at the given index from the list

| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| index     | int  | The index of the item to remove |

Returns void

## removeRange (public member function of List)
Remove a range of items from the list

Example: Remove the first 3 players from the list
```
players.removeRange 0 to 3
```

| Parameter | Type | Description                                       |
| --------- | ---- | ------------------------------------------------- |
| from      | int  | Remove items starting from this index             |
| to        | int  | Remove items up to (but not including) this index |

Returns void

## removeWhere (public member function of List)
Remove all item the meet a specific condition

Example: Remove all players that have died.
```
Player
    bool hasDied
```

app
gameOver
players.removeWhere.hasDied

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| condition | bool(T a) | The condition to check |

Returns void

## removeFirstWhere (public member function of List)
Remove the first item the meet a specific condition

Example: Remove the first player with a health smaller than 10.
```
Player
    int health
```

app
gameOver
players.removeFirstWhere.health < 10

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| condition | bool(T a) | The condition to check |

Returns T

## ensure (public member function of List)
Add an item to the list if it isn't already in there

| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| item      | T    | The item to add |

Returns void

## ensure (public member function of List)
Add each item from a list if it isn't already in there

| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| items     | T[]  | The list of items to add |

Returns void

## toggle (public member function of List)
| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| item      | T    | The item to add |

Returns void

## contains (public member function of List)
Returns whether the list contains the given item

| Parameter | Type | Description                          |
| --------- | ---- | ------------------------------------ |
| item      | T    | Check if the list contains this item |

Returns bool

## containsAny (public member function of List)
| Parameter | Type | Description              |
| --------- | ---- | ------------------------ |
| list      | T[]  | Parameter of containsAny |

Returns bool

## containsNone (public member function of List)
| Parameter | Type | Description               |
| --------- | ---- | ------------------------- |
| list      | T[]  | Parameter of containsNone |

Returns bool

## indexOf (public member function of List)
The index of an item in the list

| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| item      | T    | Get the index of this item |

Returns int

## setList (public member function of List)
| Parameter | Type | Description          |
| --------- | ---- | -------------------- |
| list      | T[]  | Parameter of setList |

Returns void

## setFilteredList (public member function of List)
| Parameter | Type      | Description                  |
| --------- | --------- | ---------------------------- |
| list      | T[]       | Parameter of setFilteredList |
| condition | bool(T a) | Parameter of setFilteredList |

Returns void

## setFilteredList (public member function of List)
| Parameter | Type      | Description                  |
| --------- | --------- | ---------------------------- |
| list      | T[]       | Parameter of setFilteredList |
| condition | bool(T a) | Parameter of setFilteredList |
| maxCount  | int       | Parameter of setFilteredList |

Returns void

## pop (public member function of List)
Remove the last item from the list and return it

Example: Print and remove "Orange" from the list
```
let fruits = ["Apple", "Lemon", "Orange"]
print fruits.pop
```

Returns T

## popAt (public member function of List)
Remove an item at a specific index from the list and return it

Example: Print and remove "Lemon" from the list
```
let fruits = ["Apple", "Lemon", "Orange"]
print fruits.popAt 1
```

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| index     | int  | Parameter of popAt |

Returns T

## popRange (public member function of List)
Remove a range of items from the list and return a new list containing the removed items

Example: Remote "Lemon" and "Orange" from the list of fruits a create a new list with those fruits
```
let fruits = ["Apple", "Pear", "Lemon", "Orange"]
let citrusFruit  = fruits.popRange 2 to 4
```

| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| from      | int  | Parameter of popRange |
| to        | int  | Parameter of popRange |

Returns T[]

## popWhere (public member function of List)
Remove the first item that meet a given condition and return it
Exmaple: Remove the first player with a health below 10
let firstActivePlayer = players.popWhere.health < 10

| Parameter | Type      | Description                        |
| --------- | --------- | ---------------------------------- |
| condition | bool(T a) | The condition for the item to meet |

Returns T

## popFirst (public member function of List)
Remove the first item from the list and return it

Example: Print and remove "Apple" from the list
```
let fruits = ["Apple", "Lemon", "Orange"]
print fruits.popFirst
```

Returns T

## length (public member function of List)
Gets the number of items in the list

Returns int

## setLength (public member function of List)
Truncated or expands the list the given number of items

| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| length    | int  | The new length of the list |

Returns int

## clear (public member function of List)
Removes all items from the list

Returns void

## clone (public member function of List)
Create a shallow clone of the list

Returns T[]

## toString (public member function of List)
Create a string representation of the list

Returns string

## random (public member function of List)
Gets a random item from the list

Returns T

## randomWhere (public member function of List)
| Parameter | Type      | Description              |
| --------- | --------- | ------------------------ |
| condition | bool(T a) | Parameter of randomWhere |

Returns T

## popRandom (public member function of List)
Remove a random item from the list and return it

Returns T

## popRandomWhere (public member function of List)
| Parameter | Type      | Description                 |
| --------- | --------- | --------------------------- |
| condition | bool(T a) | Parameter of popRandomWhere |

Returns T

## next (public member function of List)
| Parameter   | Type | Description       |
| ----------- | ---- | ----------------- |
| currentItem | T    | Parameter of next |

Returns T

## next (public member function of List)
| Parameter   | Type         | Description       |
| ----------- | ------------ | ----------------- |
| currentItem | T            | Parameter of next |
| where       | bool(T item) | Parameter of next |

Returns T

## previous (public member function of List)
| Parameter   | Type | Description           |
| ----------- | ---- | --------------------- |
| currentItem | T    | Parameter of previous |

Returns T

## prev (public member function of List)
| Parameter   | Type | Description       |
| ----------- | ---- | ----------------- |
| currentItem | T    | Parameter of prev |

Returns T

## pickWithinRangeOrClosest (public member function of List)
| Parameter | Type       | Description                           |
| --------- | ---------- | ------------------------------------- |
| selector  | float(T a) | Parameter of pickWithinRangeOrClosest |
| min       | float      | Parameter of pickWithinRangeOrClosest |
| max       | float      | Parameter of pickWithinRangeOrClosest |

Returns T

## toBool (public member function of List)
Returns true if the list is not null and not empty

Returns bool

## reverse (public member function of List)
Reverses the order of the items of the list in place

Returns T[]

## reversed (public member function of List)
Returns T[]

## distinct (public member function of List)
Return a list with all unique items of the original list

Returns T[]

## moveToBack (public member function of List)
Moves an item to the end of the list

| Parameter | Type | Description                             |
| --------- | ---- | --------------------------------------- |
| item      | T    | The item to move to the end of the list |

Returns void

## moveToFront (public member function of List)
Moves an item to the end of the list

| Parameter | Type | Description                             |
| --------- | ---- | --------------------------------------- |
| item      | T    | The item to move to the end of the list |

Returns void

## sort (public member function of List)
Sort the list

Returns T[]

## sort (public member function of List)
| Parameter | Type            | Description                                                                       |
| --------- | --------------- | --------------------------------------------------------------------------------- |
| comparer  | float(T a, T b) | A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal |

Returns T[]

## orderBy (public member function of List)
Sort the list by a given expression

| Parameter  | Type       | Description                    |
| ---------- | ---------- | ------------------------------ |
| expression | float(T a) | First order by this expression |

Returns T[]

## orderBy (public member function of List)
| Parameter  | Type        | Description                    |
| ---------- | ----------- | ------------------------------ |
| expression | float(T it) | First order by this expression |
| thenBy     | float(T it) | Then order by this expression  |

Returns T[]

## orderBy (public member function of List)
| Parameter  | Type         | Description                    |
| ---------- | ------------ | ------------------------------ |
| expression | float(T it)  | First order by this expression |
| thenBy     | string(T it) | Then order by this expression  |

Returns T[]

## orderBy (public member function of List)
| Parameter  | Type         | Description                    |
| ---------- | ------------ | ------------------------------ |
| expression | string(T it) | First order by this expression |
| thenBy     | float(T it)  | Then order by this expression  |

Returns T[]

## orderBy (public member function of List)
| Parameter  | Type        | Description                    |
| ---------- | ----------- | ------------------------------ |
| expression | string(T a) | First order by this expression |

Returns T[]

## orderBy (public member function of List)
Sort the list by a given expression

| Parameter  | Type         | Description                                                    |
| ---------- | ------------ | -------------------------------------------------------------- |
| expression | float(T a)   | First order by this expression                                 |
| order      | SortingOrder | Specifies if you want to sort in ascending or descending order |

Returns T[]

## any (public member function of List)
Returns true if the given condition is true for any item in the list

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| predicate | bool(T a) | The condition to check |

Returns bool

## none (public member function of List)
| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| predicate | bool(T a) | The condition to check |

Returns bool

## all (public member function of List)
Returns true if the given condition is true for all items in the list

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| predicate | bool(T a) | The condition to check |

Returns bool

## select (public member function of List)
Return a list that contains the selected field or expression for each item

| Parameter | Type                | Description                                 |
| --------- | ------------------- | ------------------------------------------- |
| selector  | TValue(T it, int i) | Selects a field or expression for each item |

Returns TValue[]

## flatten (public member function of List)
Get the selected field or expression for each item and flattens the result

| Parameter | Type           | Description          |
| --------- | -------------- | -------------------- |
| selector  | TValue[](T it) | Parameter of flatten |

Returns TValue[]

## find (public member function of List)
Find an item the meets the given condition

Example: Find a player with a specific id
```
app
    getPlayerById: int id
        return players.find.id == id
```

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| condition | bool(T a) | The condition to check |

Returns T

## find (public member function of List)
| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| condition | bool(T a) | The condition to check |

Returns T

## find (public member function of List)
| Parameter  | Type      | Description                   |
| ---------- | --------- | ----------------------------- |
| condition  | bool(T a) | The condition to check        |
| startIndex | int       | Start searching at this index |

Returns T

## find (public member function of List)
| Parameter  | Type      | Description                   |
| ---------- | --------- | ----------------------------- |
| condition  | bool(T a) | The condition to check        |
| startIndex | int       | Start searching at this index |

Returns T

## findIn (public member function of List)
Execute a selector for each item and if it returns a value that isn't null, return this value

Example: Find object that is nested within another object
```
transport.routes.findIn.trips.find.id == tripId
```

| Parameter | Type         | Description         |
| --------- | ------------ | ------------------- |
| selector  | TValue(T it) | Parameter of findIn |

Returns TValue

## has (public member function of List)
Does the list have an item that meets the given condition?

| Parameter  | Type      | Description                   |
| ---------- | --------- | ----------------------------- |
| condition  | bool(T a) | The condition to check        |
| startIndex | int       | Start searching at this index |

Returns bool

## indexWhere (public member function of List)
Find the index of the item the meets the given condition

| Parameter  | Type      | Description                   |
| ---------- | --------- | ----------------------------- |
| condition  | bool(T a) | The condition to check        |
| startIndex | int       | Start searching at this index |

Returns int

## indexWhere (public member function of List)
Find the index of the item the meets the given condition

| Parameter  | Type      | Description                   |
| ---------- | --------- | ----------------------------- |
| condition  | bool(T a) | The condition to check        |
| startIndex | int       | Start searching at this index |

Returns int

## lastIndexWhere (public member function of List)
Seaching backwards, find the last index of the item the meets the given condition

| Parameter  | Type      | Description                   |
| ---------- | --------- | ----------------------------- |
| condition  | bool(T a) | The condition to check        |
| startIndex | int       | Start searching at this index |

Returns int

## where (public member function of List)
| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| condition | bool(T a) | The condition to check |

Returns T[]

## except (public member function of List)
| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| item      | T    | Parameter of except |

Returns T[]

## take (public member function of List)
| Parameter | Type | Description       |
| --------- | ---- | ----------------- |
| count     | int  | Parameter of take |

Returns T[]

## total (public member function of List)
| Parameter | Type          | Description        |
| --------- | ------------- | ------------------ |
| selector  | Vector2(T it) | Parameter of total |

Returns Vector2

## total (public member function of List)
| Parameter | Type      | Description        |
| --------- | --------- | ------------------ |
| selector  | int(T it) | Parameter of total |

Returns int

## total (public member function of List)
| Parameter | Type      | Description        |
| --------- | --------- | ------------------ |
| selector  | int(T it) | Parameter of total |
| where     | bool(T a) | Parameter of total |

Returns int

## total (public member function of List)
| Parameter | Type        | Description        |
| --------- | ----------- | ------------------ |
| selector  | float(T it) | Parameter of total |

Returns float

## sum (public member function of List)
Returns int

## average (public member function of List)
| Parameter | Type          | Description          |
| --------- | ------------- | -------------------- |
| selector  | Vector2(T it) | Parameter of average |

Returns Vector2

## average (public member function of List)
| Parameter | Type          | Description          |
| --------- | ------------- | -------------------- |
| selector  | Vector2(T it) | Parameter of average |
| where     | bool(T it)    | Parameter of average |

Returns Vector2

## average (public member function of List)
Returns float

## joinToString (public member function of List)
| Parameter | Type        | Description               |
| --------- | ----------- | ------------------------- |
| selector  | string(T a) | Parameter of joinToString |
| separator | string      | Parameter of joinToString |

Returns string

## shuffle (public member function of List)
Returns T[]

## shuffled (public member function of List)
Returns T[]

## percentile (public member function of List)
| Parameter | Type | Description             |
| --------- | ---- | ----------------------- |
| value     | int  | Parameter of percentile |

Returns T

## min (public member function of List)
| Parameter | Type     | Description      |
| --------- | -------- | ---------------- |
| selector  | int(T a) | Parameter of min |
| threshold | int      | Parameter of min |
| default   | int      | Parameter of min |

Returns int

## min (public member function of List)
| Parameter | Type       | Description      |
| --------- | ---------- | ---------------- |
| selector  | float(T a) | Parameter of min |
| threshold | float      | Parameter of min |
| default   | float      | Parameter of min |

Returns float

## min (public member function of List)
| Parameter | Type      | Description      |
| --------- | --------- | ---------------- |
| selector  | int(T a)  | Parameter of min |
| threshold | int       | Parameter of min |
| default   | int       | Parameter of min |
| where     | bool(T a) | Parameter of min |

Returns int

## min (public member function of List)
| Parameter | Type       | Description      |
| --------- | ---------- | ---------------- |
| selector  | float(T a) | Parameter of min |
| threshold | float      | Parameter of min |
| default   | float      | Parameter of min |
| where     | bool(T a)  | Parameter of min |

Returns float

## max (public member function of List)
| Parameter | Type     | Description      |
| --------- | -------- | ---------------- |
| selector  | int(T a) | Parameter of max |
| threshold | int      | Parameter of max |
| default   | int      | Parameter of max |

Returns int

## max (public member function of List)
| Parameter | Type       | Description      |
| --------- | ---------- | ---------------- |
| selector  | float(T a) | Parameter of max |
| threshold | float      | Parameter of max |
| default   | float      | Parameter of max |

Returns float

## max (public member function of List)
| Parameter | Type      | Description      |
| --------- | --------- | ---------------- |
| selector  | int(T a)  | Parameter of max |
| threshold | int       | Parameter of max |
| default   | int       | Parameter of max |
| where     | bool(T a) | Parameter of max |

Returns int

## max (public member function of List)
| Parameter | Type       | Description      |
| --------- | ---------- | ---------------- |
| selector  | float(T a) | Parameter of max |
| threshold | float      | Parameter of max |
| default   | float      | Parameter of max |
| where     | bool(T a)  | Parameter of max |

Returns float

## maxUnique (public member function of List)
| Parameter | Type     | Description            |
| --------- | -------- | ---------------------- |
| selector  | int(T a) | Parameter of maxUnique |
| threshold | int      | Parameter of maxUnique |
| default   | int      | Parameter of maxUnique |

Returns int

## minIndex (public member function of List)
| Parameter  | Type       | Description           |
| ---------- | ---------- | --------------------- |
| selector   | float(T a) | Parameter of minIndex |
| startIndex | int        | Parameter of minIndex |
| threshold  | float      | Parameter of minIndex |

Returns int

## maxIndex (public member function of List)
| Parameter  | Type       | Description           |
| ---------- | ---------- | --------------------- |
| selector   | float(T a) | Parameter of maxIndex |
| startIndex | int        | Parameter of maxIndex |
| threshold  | float      | Parameter of maxIndex |

Returns int

## withMin (public member function of List)
| Parameter | Type     | Description          |
| --------- | -------- | -------------------- |
| selector  | int(T a) | Parameter of withMin |
| threshold | int      | Parameter of withMin |

Returns T

## withMin (public member function of List)
| Parameter | Type       | Description          |
| --------- | ---------- | -------------------- |
| selector  | float(T a) | Parameter of withMin |
| threshold | float      | Parameter of withMin |

Returns T

## withMin (public member function of List)
| Parameter | Type      | Description          |
| --------- | --------- | -------------------- |
| selector  | int(T a)  | Parameter of withMin |
| threshold | int       | Parameter of withMin |
| where     | bool(T a) | Parameter of withMin |

Returns T

## withMin (public member function of List)
| Parameter | Type       | Description          |
| --------- | ---------- | -------------------- |
| selector  | float(T a) | Parameter of withMin |
| threshold | float      | Parameter of withMin |
| where     | bool(T a)  | Parameter of withMin |

Returns T

## withMax (public member function of List)
| Parameter | Type     | Description          |
| --------- | -------- | -------------------- |
| selector  | int(T a) | Parameter of withMax |
| threshold | int      | Parameter of withMax |

Returns T

## withMax (public member function of List)
| Parameter | Type       | Description          |
| --------- | ---------- | -------------------- |
| selector  | float(T a) | Parameter of withMax |
| threshold | float      | Parameter of withMax |

Returns T

## withMax (public member function of List)
| Parameter | Type      | Description          |
| --------- | --------- | -------------------- |
| selector  | int(T a)  | Parameter of withMax |
| threshold | int       | Parameter of withMax |
| where     | bool(T a) | Parameter of withMax |

Returns T

## withMax (public member function of List)
| Parameter | Type       | Description          |
| --------- | ---------- | -------------------- |
| selector  | float(T a) | Parameter of withMax |
| threshold | float      | Parameter of withMax |
| where     | bool(T a)  | Parameter of withMax |

Returns T

## popMax (public member function of List)
| Parameter | Type     | Description         |
| --------- | -------- | ------------------- |
| selector  | int(T a) | Parameter of popMax |
| threshold | int      | Parameter of popMax |

Returns T

## popMax (public member function of List)
| Parameter | Type     | Description         |
| --------- | -------- | ------------------- |
| selector  | int(T a) | Parameter of popMax |
| threshold | float    | Parameter of popMax |

Returns T

## count (public member function of List)
| Parameter | Type      | Description        |
| --------- | --------- | ------------------ |
| predicate | bool(T a) | Parameter of count |

Returns int

## countNot (public member function of List)
| Parameter | Type      | Description           |
| --------- | --------- | --------------------- |
| predicate | bool(T a) | Parameter of countNot |

Returns int

## rotate (public member function of List)
Returns void

## rotate (public member function of List)
| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| count     | int  | Parameter of rotate |

Returns void

## intersectWith (public member function of List)
| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| other     | T[]  | Parameter of intersectWith |

Returns T[]

## first (public member function of List)
The first item of the list

Returns T

## second (public member function of List)
The second item of the list

Returns T

## last (public member function of List)
The last item of the list

Returns T

## get (public member function of List)
Get an item from the list

| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| index     | int  | The index of the item to get |

Returns T

## get (public member function of List)
Get a new list that is a subset of this list

| Parameter | Type | Description                                                                                      |
| --------- | ---- | ------------------------------------------------------------------------------------------------ |
| from      | int  | Return a new list starting from this index, a negative index will start from the end of the list |
| to        | int  | Return a new list up to (but not including) this index, a negative index is counted from the end |

Returns T[]

## get (public member function of List)
Get a new list that is a subset of this list

| Parameter | Type | Description                                                                                      |
| --------- | ---- | ------------------------------------------------------------------------------------------------ |
| from      | int  | Return a new list starting from this index, a negative index will start from the end of the list |

Returns T[]

## set (public member function of List)
Set the item at a given index

| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| index     | int  | The index of the item to set |
| value     | T    | The new value to set         |

Returns T

## getOrSet (public member function of List)
Tries to get an item from the list. If it doesn't exist, it sets it.
TODO: Support index with side effect (e.g. list[index++] ?= 0)

| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| index     | int  | Parameter of getOrSet |
| value     | T    | Parameter of getOrSet |

Returns T

## addToItem (public member function of List)
Add a value to an item of the list

| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| index     | int  | The index of the item to change |
| value     | T    | The value to add to the item    |

Returns T

## subtractFromItem (public member function of List)
Subtract a value from an item of the list

| Parameter | Type | Description                         |
| --------- | ---- | ----------------------------------- |
| index     | int  | The index of the item to change     |
| value     | T    | The value to subtract from the item |

Returns T

## multiplyItem (public member function of List)
Multiply an item of the list by a value

| Parameter | Type | Description                       |
| --------- | ---- | --------------------------------- |
| index     | int  | The index of the item to change   |
| value     | T    | The value to multiply the item by |

Returns T

## divideItem (public member function of List)
Divide an item of the list by a value

| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| index     | int  | The index of the item to change |
| value     | T    | The value to divide the item by |

Returns T

## incrementItem (public member function of List)
Add 1 to item of the list

| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| index     | int  | The index of the item to change |

Returns T

## decrementItem (public member function of List)
Subtract 1 from an item of the list

| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| index     | int  | The index of the item to change |

Returns T

---

# class Map
A data container that stores key-value pairs

## get (public member function of Map)
Get the item assosiated with the given key

| Parameter | Type | Description                             |
| --------- | ---- | --------------------------------------- |
| key       | TKey | The key of the item to get from the map |

Returns TValue

## set (public member function of Map)
Set the item for the given key

| Parameter | Type   | Description                           |
| --------- | ------ | ------------------------------------- |
| key       | TKey   | The key of the item to add to the map |
| value     | TValue | The item to add to the map            |

Returns void

## getOrSet (public member function of Map)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| key       | TKey   | Parameter of getOrSet |
| value     | TValue | Parameter of getOrSet |

Returns TValue

## addToItem (public member function of Map)
Add a value to an item of the list

| Parameter | Type   | Description                           |
| --------- | ------ | ------------------------------------- |
| key       | TKey   | The key of the item to add to the map |
| value     | TValue | The item to add to the map            |

Returns T

## incrementItem (public member function of Map)
Add 1 to item of the map

| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| key       | TKey | Parameter of incrementItem |

Returns T

## decrementItem (public member function of Map)
Subtract 1 to item of the map

| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| key       | TKey | Parameter of decrementItem |

Returns T

## remove (public member function of Map)
Remove the item assosiated with the given key

| Parameter | Type | Description                                |
| --------- | ---- | ------------------------------------------ |
| key       | TKey | The key of the item to remove from the map |

Returns void

## has (public member function of Map)
Does the map have an item with a specific key?

| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| key       | TKey | The key of the item to check |

Returns bool

## clear (public member function of Map)
Remove all items from the map

Returns void

## length (public member function of Map)
Returns int

## removeWhere (public member function of Map)
| Parameter | Type            | Description            |
| --------- | --------------- | ---------------------- |
| condition | bool(TValue it) | The condition to check |

Returns void

---

# class SourceCodeLocation
This struct is automatically filled with the source code location

## toBool (public member function of SourceCodeLocation)
Returns bool

## toString (public member function of SourceCodeLocation)
Returns string

## find (public member function of SourceCodeLocation)
| Parameter | Type   | Description       |
| --------- | ------ | ----------------- |
| file      | string | Parameter of find |
| pos       | int    | Parameter of find |

Returns SourceCodeLocation

## find (public member function of SourceCodeLocation)
| Parameter | Type               | Description       |
| --------- | ------------------ | ----------------- |
| location  | SourceCodeLocation | Parameter of find |

Returns SourceCodeLocation

## leaf (public member function of SourceCodeLocation)
Returns SourceCodeLocation

---

# class object
The base class for all classes

## undefined (static public member function of object)
Returns any

## toBool (public member function of object)
Returns bool

## toJson (static public member function of object)
| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| value     | any  | Parameter of toJson |

Returns string

## toFormattedJson (static public member function of object)
| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| value     | any  | Parameter of toFormattedJson |

Returns string

## isEqualAndSameType (static public member function of object)
| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| a         | any  | Parameter of isEqualAndSameType |
| b         | any  | Parameter of isEqualAndSameType |

Returns bool

---

# class Player

## toString (public member function of Player)
Returns string

## highlightPerspectiveColor (public member function of Player)
Returns Color

## me (public member function of Player)
The current player instance, equivalent to "this"

Returns Player

---

# class Font
A font that can be used to draw text

## open (public member function of Font)
Returns void

---

# static class Platform

## url (static public member function of Platform)
Returns string

## hostname (static public member function of Platform)
Returns string

## protocolAndHost (static public member function of Platform)
Returns string

## userAgent (static public member function of Platform)
Returns int

## usedMemory (static public member function of Platform)
Returns float

## getAbsoluteUrl (static public member function of Platform)
| Parameter   | Type   | Description                 |
| ----------- | ------ | --------------------------- |
| relativeUrl | string | Parameter of getAbsoluteUrl |

Returns string

## setTitle (static public member function of Platform)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| title     | string | Parameter of setTitle |

Returns void

## setFullscreen (static public member function of Platform)
| Parameter | Type   | Description                |
| --------- | ------ | -------------------------- |
| value     | bool   | Parameter of setFullscreen |
| forPlayer | Player | Parameter of setFullscreen |

Returns Promise<void>

## preventScrolling (static public member function of Platform)
Returns void

## setLocalStorageObject (static public member function of Platform)
| Parameter | Type   | Description                        |
| --------- | ------ | ---------------------------------- |
| key       | string | Parameter of setLocalStorageObject |
| value     | any    | Parameter of setLocalStorageObject |
| then      | void() | Parameter of setLocalStorageObject |
| else      | void() | Parameter of setLocalStorageObject |

Returns void

## getLocalStorageObject (static public member function of Platform)
| Parameter | Type   | Description                        |
| --------- | ------ | ---------------------------------- |
| key       | string | Parameter of getLocalStorageObject |

Returns any

## setLocalStorageString (static public member function of Platform)
| Parameter | Type   | Description                        |
| --------- | ------ | ---------------------------------- |
| key       | string | Parameter of setLocalStorageString |
| value     | string | Parameter of setLocalStorageString |

Returns bool

## getLocalStorageString (static public member function of Platform)
| Parameter | Type   | Description                        |
| --------- | ------ | ---------------------------------- |
| key       | string | Parameter of getLocalStorageString |

Returns string

## vibrate (static public member function of Platform)
| Parameter | Type | Description          |
| --------- | ---- | -------------------- |
| duration  | int  | Parameter of vibrate |

Returns void

## alert (static public member function of Platform)
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| message   | string | Parameter of alert |

Returns void

## delay (static public member function of Platform)
| Parameter | Type   | Description               |
| --------- | ------ | ------------------------- |
| time      | float  | The delay in milliseconds |
| then      | void() | Parameter of delay        |

Returns void

## copyToClipboard (static public member function of Platform)
| Parameter | Type   | Description                  |
| --------- | ------ | ---------------------------- |
| text      | string | Parameter of copyToClipboard |

Returns void

## setLocation (static public member function of Platform)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| url       | string | Parameter of setLocation |

Returns void

## openLink (static public member function of Platform)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| url       | string | Parameter of openLink |

Returns void

## setInterval (static public member function of Platform)
| Parameter | Type   | Description                  |
| --------- | ------ | ---------------------------- |
| interval  | float  | The interval in milliseconds |
| code      | void() | Parameter of setInterval     |

Returns void

## setTimeout (static public member function of Platform)
| Parameter | Type   | Description               |
| --------- | ------ | ------------------------- |
| time      | float  | The delay in milliseconds |
| code      | void() | Parameter of setTimeout   |

Returns int

## clearTimeout (static public member function of Platform)
| Parameter | Type | Description               |
| --------- | ---- | ------------------------- |
| id        | int  | Parameter of clearTimeout |

Returns void

## pushState (static public member function of Platform)
| Parameter | Type    | Description            |
| --------- | ------- | ---------------------- |
| url       | string  | Parameter of pushState |
| state     | dynamic | Parameter of pushState |

Returns void

## replaceState (static public member function of Platform)
| Parameter | Type    | Description               |
| --------- | ------- | ------------------------- |
| url       | string  | Parameter of replaceState |
| state     | dynamic | Parameter of replaceState |

Returns void

## back (static public member function of Platform)
Returns void

## reload (static public member function of Platform)
Returns void

## openScript (static public member function of Platform)
| Parameter | Type   | Description             |
| --------- | ------ | ----------------------- |
| url       | string | Parameter of openScript |

Returns void

## appName (static public member function of Platform)
Info

Returns string

## buildVersion (static public member function of Platform)
Returns int

## generateIntegrationTest (static public member function of Platform)
| Parameter | Type                        | Description                          |
| --------- | --------------------------- | ------------------------------------ |
| mode      | GenerateIntegrationTestMode | Parameter of generateIntegrationTest |

Returns void

## generateObjectId (static public member function of Platform)
Returns string

## stack (static public member function of Platform)
Returns object

## debugger (static public member function of Platform)
Returns void

## openDevTools (static public member function of Platform)
Returns void

## getHostnameFromUrl (static public member function of Platform)
| Parameter | Type   | Description                     |
| --------- | ------ | ------------------------------- |
| url       | string | Parameter of getHostnameFromUrl |

Returns string

## navigate (static public member function of Platform)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| url       | string | Parameter of navigate |

Returns void

---

# class ImmutableList

## get (public member function of ImmutableList)
| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| index     | int  | The index of the item to get |

Returns T

---

# class Set
A data container that stores unique values of a given type

## get (public member function of Set)
Return a boolean indicating whether an element with the specified value exists in this set

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| value     | T    | The value to check |

Returns bool

## add (public member function of Set)
Add a new element to this set, if there isn't already an element with the same value

| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| value     | T    | The value to add |

Returns void

## remove (public member function of Set)
Remove a value from the set

| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| value     | T    | The value to remove |

Returns void

## has (public member function of Set)
Is a certain value in the set?

| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| value     | T    | The value to check |

Returns bool

## toList (public member function of Set)
Returns T[]

## clear (public member function of Set)
Remove all items from the set

Returns void

## length (public member function of Set)
Return the number of items in the set

Returns int

---

# struct Reference

## set (public member function of Reference)
| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| value     | T    | Parameter of set |

Returns void

## get (public member function of Reference)
Returns T

---

# class Error

## toString (public member function of Error)
Returns string

---

# static class System

## if (global function)
Executes code depending on whether a given condition is true or false

| Parameter | Type   | Description                      |
| --------- | ------ | -------------------------------- |
| condition | bool   | The condition to check           |
| then      | void() | Do this if the condition is true |

Returns void

## if (global function)
Executes code depending on whether a given condition is true or false

| Parameter | Type   | Description                       |
| --------- | ------ | --------------------------------- |
| condition | bool   | The condition to check            |
| then      | void() | Do this if the condition is true  |
| else      | void() | Do this if the condition is false |

Returns void

## if (global function)
| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| condition | bool | Parameter of if |
| then      | T    | Parameter of if |
| else      | T    | Parameter of if |

Returns T

## while (global function)
Executes code as long as a given condition is true

| Parameter | Type   | Description                        |
| --------- | ------ | ---------------------------------- |
| condition | bool   | The condition to check             |
| do        | void() | Do this while to condition is true |

Returns void

## loop (global function)
| Parameter | Type   | Description       |
| --------- | ------ | ----------------- |
| do        | void() | Parameter of loop |

Returns void

## do (global function)
| Parameter | Type   | Description                        |
| --------- | ------ | ---------------------------------- |
| do        | void() | Do this while to condition is true |
| while     | bool   | The condition to check             |

Returns void

## promise (global function)
| Parameter | Type                    | Description          |
| --------- | ----------------------- | -------------------- |
| resolve   | void(void(T a) resolve) | Parameter of promise |

Returns Promise<T>

## doNotSerialize (static public member function of System)
| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| object    | any  | Parameter of doNotSerialize |

Returns void

## for (global function)
Do something a given number of times or for each item in a list

| Parameter | Type              | Description                     |
| --------- | ----------------- | ------------------------------- |
| subject   | T[]               | The list to iterate over        |
| do        | void(T it, int i) | Do this for each item in a list |

Returns void

## for (global function)
Do something a given number of times or for each item in a list

| Parameter | Type              | Description                     |
| --------- | ----------------- | ------------------------------- |
| subject   | T[]               | The list to iterate over        |
| do        | void(T it, int i) | Do this for each item in a list |

Returns void

## for (global function)
Do something a given number of times or for each item in a list

| Parameter | Type                      | Description                     |
| --------- | ------------------------- | ------------------------------- |
| subject   | TValue[TKey]              | The list to iterate over        |
| do        | void(TValue it, TKey key) | Do this for each item in a list |

Returns void

## for (global function)
| Parameter | Type        | Description                                                                                |
| --------- | ----------- | ------------------------------------------------------------------------------------------ |
| from      | int         | The integer to start iterating from (for exmaple "for 2 to 5: print ." prints 2, 3, 4)     |
| do        | void(int i) | Do this for each value in the given range                                                  |
| to        | int         | The exclusive upper bound to iterate towards (for exmaple "for 3: print ." prints 0, 1, 2) |

Returns void

## for (global function)
| Parameter | Type        | Description                                  |
| --------- | ----------- | -------------------------------------------- |
| from      | int         | The integer to start iterating from          |
| do        | void(int i) | Do this for each value in the given range    |
| to        | int         | The exclusive upper bound to iterate towards |

Returns void

## for (global function)
| Parameter | Type        | Description                                  |
| --------- | ----------- | -------------------------------------------- |
| to        | int         | The exclusive upper bound to iterate towards |
| do        | void(int i) | Do this the given number of times            |

Returns void

## for (global function)
| Parameter | Type        | Description                                  |
| --------- | ----------- | -------------------------------------------- |
| to        | int         | The exclusive upper bound to iterate towards |
| do        | void(int i) | Do this the given number of times            |

Returns void

## for (global function)
| Parameter | Type                               | Description                                  |
| --------- | ---------------------------------- | -------------------------------------------- |
| subject   | IntVector2                         | The exclusive upper bound to iterate towards |
| do        | void(IntVector2 pos, int x, int y) | Do this the given number of times            |

Returns void

## for (global function)
| Parameter | Type                               | Description                                  |
| --------- | ---------------------------------- | -------------------------------------------- |
| subject   | IntVector2                         | The exclusive upper bound to iterate towards |
| do        | void(IntVector2 pos, int x, int y) | Do this the given number of times            |

Returns void

## for (global function)
| Parameter | Type                              | Description                     |
| --------- | --------------------------------- | ------------------------------- |
| subject   | Grid<T>                           | The grid to iterate over        |
| do        | void(T it, IntVector2 pos, int i) | Do this for each item in a list |

Returns void

## for (global function)
| Parameter    | Type                              | Description                     |
| ------------ | --------------------------------- | ------------------------------- |
| subject      | Grid<T>                           | The grid to iterate over        |
| includeEmpty | bool                              | Include items that are null     |
| do           | void(T it, IntVector2 pos, int i) | Do this for each item in a list |

Returns void

## for (global function)
| Parameter | Type                   | Description                                                                    |
| --------- | ---------------------- | ------------------------------------------------------------------------------ |
| to        | IntVector2             | Iterator over both dimensions of the vector towards this exclusive upper bound |
| do        | TResult(IntVector2 it) | Select the field or expression to be included in the result                    |

Returns TResult[]

## for (global function)
| Parameter | Type                   | Description                                                                    |
| --------- | ---------------------- | ------------------------------------------------------------------------------ |
| from      | IntVector2             | Iterator over both dimensions of the vector starting from this vector          |
| do        | TResult(IntVector2 it) | Select the field or expression to be included in the result                    |
| to        | IntVector2             | Iterator over both dimensions of the vector towards this exclusive upper bound |

Returns TResult[]

## for (global function)
| Parameter | Type                   | Description                                    |
| --------- | ---------------------- | ---------------------------------------------- |
| subject   | string                 | Iterate over every character of this string    |
| do        | void(string it, int i) | Do this for each character in the given string |

Returns void

## for (global function)
| Parameter | Type                   | Description                                    |
| --------- | ---------------------- | ---------------------------------------------- |
| subject   | string                 | Iterate over every character of this string    |
| do        | void(string it, int i) | Do this for each character in the given string |

Returns void

## for (global function)
Do something a given number of times or for each item in a list

| Parameter | Type                         | Description                     |
| --------- | ---------------------------- | ------------------------------- |
| subject   | dynamic                      | The list to iterate over        |
| do        | void(dynamic it, string key) | Do this for each item in a list |

Returns void

## for (global function)
Creates a new list populated with the results of calling a function on every element of the list

| Parameter | Type          | Description                                                 |
| --------- | ------------- | ----------------------------------------------------------- |
| subject   | T[]           | The list to iterate over                                    |
| do        | TResult(T it) | Select the field or expression to be included in the result |

Returns TResult[]

## for (global function)
Creates a new list populated with the results of calling a function on every element of the list

| Parameter | Type          | Description                                                 |
| --------- | ------------- | ----------------------------------------------------------- |
| subject   | T[]           | The list to iterate over                                    |
| do        | TResult(T it) | Select the field or expression to be included in the result |

Returns TResult[]

## for (global function)
| Parameter | Type           | Description                                                 |
| --------- | -------------- | ----------------------------------------------------------- |
| to        | int            | The exclusive upper bound to iterate towards                |
| do        | TResult(int i) | Select the field or expression to be included in the result |

Returns TResult[]

## for (global function)
| Parameter | Type           | Description                                                 |
| --------- | -------------- | ----------------------------------------------------------- |
| from      | int            | The integer to start iterating from                         |
| do        | TResult(int i) | Select the field or expression to be included in the result |
| to        | int            | The exclusive upper bound to iterate towards                |
| step      | int            | Parameter of for                                            |

Returns TResult[]

## forChangeable (global function)
Do something for each item in a list. You can add or remove items inside the loop.

| Parameter | Type              | Description                     |
| --------- | ----------------- | ------------------------------- |
| subject   | T[]               | The list to iterate over        |
| do        | void(T it, int i) | Do this for each item in a list |

Returns void

## forChangeable (global function)
Do something for each item in a list. You can add or remove items inside the loop.

| Parameter | Type              | Description                     |
| --------- | ----------------- | ------------------------------- |
| subject   | T[]               | The list to iterate over        |
| do        | void(T it, int i) | Do this for each item in a list |

Returns void

## forLookAhead (global function)
[a,b,c] -> (a, next:b), (b, next:c), (c, next:null)

| Parameter | Type                      | Description                                 |
| --------- | ------------------------- | ------------------------------------------- |
| subject   | T[]                       | The list to iterate over                    |
| do        | void(T it, T next, int i) | Do this for each consecutive pair in a list |

Returns void

## forLookAhead (global function)
| Parameter | Type                      | Description                                 |
| --------- | ------------------------- | ------------------------------------------- |
| subject   | T[]                       | The list to iterate over                    |
| do        | void(T it, T next, int i) | Do this for each consecutive pair in a list |

Returns void

## forLookBack (global function)
[a,b,c] -> (prev:null, a), (prev:a, b), (prev:b, c)

| Parameter | Type                      | Description                                 |
| --------- | ------------------------- | ------------------------------------------- |
| subject   | T[]                       | The list to iterate over                    |
| do        | void(T it, T prev, int i) | Do this for each consecutive pair in a list |

Returns void

## forLookBack (global function)
| Parameter | Type                      | Description                                 |
| --------- | ------------------------- | ------------------------------------------- |
| subject   | T[]                       | The list to iterate over                    |
| do        | void(T it, T prev, int i) | Do this for each consecutive pair in a list |

Returns void

## forLookAheadAndBack (global function)
[a,b,c] -> (prev:null, a, next:b), (prev:a, b, next:c), (prev:b, c, next:null)

| Parameter | Type                              | Description                       |
| --------- | --------------------------------- | --------------------------------- |
| subject   | T[]                               | The list to iterate over          |
| do        | void(T it, T prev, T next, int i) | Do this for each triple in a list |

Returns void

## forLookAheadAndBack (global function)
| Parameter | Type                              | Description                       |
| --------- | --------------------------------- | --------------------------------- |
| subject   | T[]                               | The list to iterate over          |
| do        | void(T it, T prev, T next, int i) | Do this for each triple in a list |

Returns void

## forPairs (global function)
[a,b,c] -> (a, next:b), (b, next:c)

| Parameter | Type                      | Description                                 |
| --------- | ------------------------- | ------------------------------------------- |
| subject   | T[]                       | The list to iterate over                    |
| do        | void(T it, T next, int i) | Do this for each consecutive pair in a list |

Returns void

## forPairs (global function)
| Parameter | Type                      | Description                                 |
| --------- | ------------------------- | ------------------------------------------- |
| subject   | T[]                       | The list to iterate over                    |
| do        | void(T it, T next, int i) | Do this for each consecutive pair in a list |

Returns void

## forWrappingPairs (global function)
[a,b,c] -> (a, next:b), (b, next:c), (c, next:a)

| Parameter | Type                      | Description                                 |
| --------- | ------------------------- | ------------------------------------------- |
| subject   | T[]                       | The list to iterate over                    |
| do        | void(T it, T next, int i) | Do this for each consecutive pair in a list |

Returns void

## forWrappingPairs (global function)
| Parameter | Type                      | Description                                 |
| --------- | ------------------------- | ------------------------------------------- |
| subject   | T[]                       | The list to iterate over                    |
| do        | void(T it, T next, int i) | Do this for each consecutive pair in a list |

Returns void

## forTriples (global function)
[a,b,c] -> (prev:a, b, next:c)

| Parameter | Type                              | Description                       |
| --------- | --------------------------------- | --------------------------------- |
| subject   | T[]                               | The list to iterate over          |
| do        | void(T it, T prev, T next, int i) | Do this for each triple in a list |

Returns void

## forTriples (global function)
| Parameter | Type                              | Description                       |
| --------- | --------------------------------- | --------------------------------- |
| subject   | T[]                               | The list to iterate over          |
| do        | void(T it, T prev, T next, int i) | Do this for each triple in a list |

Returns void

## forWrappingTriples (global function)
[a,b,c] -> (prev:c, a, next:b), (prev:a, b, next:c), (prev:b, c, next:a)

| Parameter | Type                              | Description                       |
| --------- | --------------------------------- | --------------------------------- |
| subject   | T[]                               | The list to iterate over          |
| do        | void(T it, T prev, T next, int i) | Do this for each triple in a list |

Returns void

## forWrappingTriples (global function)
| Parameter | Type                              | Description                       |
| --------- | --------------------------------- | --------------------------------- |
| subject   | T[]                               | The list to iterate over          |
| do        | void(T it, T prev, T next, int i) | Do this for each triple in a list |

Returns void

## log (static public member function of System)
| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| value     | any  | Parameter of log |

Returns void

## watch (global function)
Display a message in the timeline

| Parameter          | Type               | Description                                 |
| ------------------ | ------------------ | ------------------------------------------- |
| text               | string             | The text, variables or expressions to watch |
| sourceCodeLocation | SourceCodeLocation | Parameter of watch                          |

Returns void

## alert (global function)
Shows a dialog box with a given message

| Parameter | Type   | Description         |
| --------- | ------ | ------------------- |
| message   | string | The message to show |

Returns void

## break (global function)
Returns void

## continue (global function)
Returns void

## try (global function)
| Parameter | Type              | Description      |
| --------- | ----------------- | ---------------- |
| code      | void()            | Parameter of try |
| catch     | void(Error error) | Parameter of try |

Returns void

## try (global function)
| Parameter | Type              | Description      |
| --------- | ----------------- | ---------------- |
| code      | void()            | Parameter of try |
| catch     | void(Error error) | Parameter of try |
| finally   | void()            | Parameter of try |

Returns void

## try (global function)
| Parameter | Type   | Description      |
| --------- | ------ | ---------------- |
| code      | void() | Parameter of try |
| finally   | void() | Parameter of try |

Returns void

## forPositions (global function)
| Parameter | Type                     | Description                                  |
| --------- | ------------------------ | -------------------------------------------- |
| to        | int                      | The exclusive upper bound to iterate towards |
| start     | Vector2                  | Left or top align items at this position     |
| delta     | Vector2                  | Distance between items                       |
| do        | void(Vector2 pos, int i) | Do this for each item in a list              |

Returns void

## forPositions (global function)
| Parameter | Type                     | Description                                  |
| --------- | ------------------------ | -------------------------------------------- |
| to        | int                      | The exclusive upper bound to iterate towards |
| center    | Vector2                  | Center items at this position                |
| delta     | Vector2                  | Distance between items                       |
| do        | void(Vector2 pos, int i) | Do this for each item in a list              |

Returns void

## forPositions (global function)
| Parameter | Type                     | Description                                  |
| --------- | ------------------------ | -------------------------------------------- |
| to        | int                      | The exclusive upper bound to iterate towards |
| end       | Vector2                  | Center items at this position                |
| delta     | Vector2                  | Distance between items                       |
| do        | void(Vector2 pos, int i) | Do this for each item in a list              |

Returns void

## forPositions (global function)
| Parameter | Type                           | Description                              |
| --------- | ------------------------------ | ---------------------------------------- |
| subject   | T[]                            | The list to iterate over                 |
| start     | Vector2                        | Left or top align items at this position |
| delta     | Vector2                        | Distance between items                   |
| do        | void(T it, Vector2 pos, int i) | Do this for each item in a list          |

Returns void

## forPositions (global function)
| Parameter | Type                           | Description                                   |
| --------- | ------------------------------ | --------------------------------------------- |
| subject   | T[]                            | The list to iterate over                      |
| start     | Vector2                        | Left or top align items at this position      |
| delta     | Vector2                        | Distance between items                        |
| width     | float                          | Wrap to the next row when we reach this width |
| do        | void(T it, Vector2 pos, int i) | Do this for each item in a list               |

Returns void

## forPositions (global function)
| Parameter | Type                           | Description                     |
| --------- | ------------------------------ | ------------------------------- |
| subject   | T[]                            | The list to iterate over        |
| center    | Vector2                        | Center items at this position   |
| delta     | Vector2                        | Distance between items          |
| do        | void(T it, Vector2 pos, int i) | Do this for each item in a list |

Returns void

## forPositions (global function)
| Parameter | Type                           | Description                                  |
| --------- | ------------------------------ | -------------------------------------------- |
| subject   | T[]                            | The list to iterate over                     |
| end       | Vector2                        | Right or bottom align items at this position |
| delta     | Vector2                        | Distance between items                       |
| do        | void(T it, Vector2 pos, int i) | Do this for each item in a list              |

Returns void

## forPositions (global function)
| Parameter | Type                           | Description                          |
| --------- | ------------------------------ | ------------------------------------ |
| subject   | T[]                            | The list to iterate over             |
| grid      | IntVector2                     | Align items in a grid with this size |
| center    | Vector2                        | Center items at this position        |
| delta     | Vector2                        | Distance between items               |
| do        | void(T it, Vector2 pos, int i) | Do this for each item in a list      |

Returns void

## forPositions (global function)
| Parameter | Type                           | Description                                  |
| --------- | ------------------------------ | -------------------------------------------- |
| to        | int                            | The exclusive upper bound to iterate towards |
| grid      | IntVector2                     | Align items in a grid with this size         |
| center    | Vector2                        | Center items at this position                |
| delta     | Vector2                        | Distance between items                       |
| do        | void(T it, Vector2 pos, int i) | Do this for each item in a list              |

Returns void

## visualize (global function)
| Parameter | Type               | Description            |
| --------- | ------------------ | ---------------------- |
| position  | Vector2            | Parameter of visualize |
| color     | Color              | Parameter of visualize |
| text      | string             | Parameter of visualize |
| location  | SourceCodeLocation | Parameter of visualize |

Returns void

## restart (global function)
Reset all variables to their initial value and restart the app

Returns void

## refresh (global function)
Returns void

## print (global function)
Prints a message to the console

| Parameter | Type               | Description                                 |
| --------- | ------------------ | ------------------------------------------- |
| text      | string             | The text, variables or expressions to print |
| location  | SourceCodeLocation | Parameter of print                          |

Returns void

---

# static class math

## abs (static public member function of math)
Returns the absolute value

| Parameter | Type | Description                               |
| --------- | ---- | ----------------------------------------- |
| value     | int  | The value to return the absolute value of |

Returns int

## abs (static public member function of math)
Returns the absolute value

| Parameter | Type  | Description                               |
| --------- | ----- | ----------------------------------------- |
| value     | float | The value to return the absolute value of |

Returns float

## sign (static public member function of math)
Returns -1, 0, or 1 depending on the sign of the value

| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| value     | float | Parameter of sign |

Returns float

## sqrt (static public member function of math)
Returns the positive square root of the given value

| Parameter | Type  | Description                            |
| --------- | ----- | -------------------------------------- |
| value     | float | The value to return the square root of |

Returns float

## hypot (static public member function of math)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| a         | float | Parameter of hypot |
| b         | float | Parameter of hypot |

Returns float

## moveTowards (static public member function of math)
| Parameter   | Type  | Description              |
| ----------- | ----- | ------------------------ |
| value       | float | Parameter of moveTowards |
| targetValue | float | Parameter of moveTowards |
| speed       | float | Parameter of moveTowards |

Returns float

## floor (static public member function of math)
Returns the largest integer less than or equal to the given value

| Parameter | Type  | Description             |
| --------- | ----- | ----------------------- |
| value     | float | The value to round down |

Returns int

## ceil (static public member function of math)
Returns the smallest integer greater than or equal to the given value

| Parameter | Type  | Description           |
| --------- | ----- | --------------------- |
| value     | float | The value to round up |

Returns int

## round (static public member function of math)
Returns the given value rounded to the nearest integer

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | The value to round |

Returns int

## min (static public member function of math)
| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| a         | int  | The first value  |
| b         | int  | The second value |

Returns int

## min (static public member function of math)
Returns the smallest of the given values

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| a         | float | The first value  |
| b         | float | The second value |

Returns float

## max (static public member function of math)
Returns the largest of the given values

| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| a         | int  | The first value  |
| b         | int  | The second value |

Returns int

## max (static public member function of math)
Returns the largest of the given values

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| a         | float | The first value  |
| b         | float | The second value |

Returns float

## moveTowardsAngle (static public member function of math)
| Parameter   | Type  | Description                   |
| ----------- | ----- | ----------------------------- |
| value       | float | Parameter of moveTowardsAngle |
| targetValue | float | Parameter of moveTowardsAngle |
| speed       | float | Parameter of moveTowardsAngle |

Returns float

## sin (static public member function of math)
Returns the sine of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

## cos (static public member function of math)
Returns the cosine of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

## tan (static public member function of math)
Returns the tangent of an angle in radians

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns float

## atan (static public member function of math)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| x         | float | Parameter of atan |

Returns float

## atan2 (static public member function of math)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| y         | float | Parameter of atan2 |
| x         | float | Parameter of atan2 |

Returns float

## log (static public member function of math)
e raised to which power resuls in the given value?

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| value     | float | Parameter of log |

Returns float

## log2 (static public member function of math)
2 raised to which power resuls in the given value?

| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| value     | float | Parameter of log2 |

Returns float

## log10 (static public member function of math)
10 raised to which power resuls in the given value?

| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Parameter of log10 |

Returns float

## pow (static public member function of math)
Return the given base raised to the power of the given exponent

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| base      | float | Parameter of pow |
| exponent  | float | Parameter of pow |

Returns float

## exp (static public member function of math)
Returns e raised to the power of a given number

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| exponent  | float | Parameter of exp |

Returns float

## shiftLeft (static public member function of math)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| value     | int  | Parameter of shiftLeft |
| count     | int  | Parameter of shiftLeft |

Returns int

## shiftRight (static public member function of math)
| Parameter | Type | Description             |
| --------- | ---- | ----------------------- |
| value     | int  | Parameter of shiftRight |
| count     | int  | Parameter of shiftRight |

Returns int

## limit (static public member function of math)
| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| value     | int  | Parameter of limit |
| min       | int  | Parameter of limit |
| max       | int  | Parameter of limit |

Returns int

## limit (static public member function of math)
| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| value     | int  | Parameter of limit |
| max       | int  | Parameter of limit |

Returns int

## limit (static public member function of math)
| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| value     | int  | Parameter of limit |
| min       | int  | Parameter of limit |

Returns int

## limit (static public member function of math)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Parameter of limit |
| min       | float | Parameter of limit |
| max       | float | Parameter of limit |

Returns float

## limit (static public member function of math)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Parameter of limit |
| max       | float | Parameter of limit |

Returns float

## limit (static public member function of math)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| value     | float | Parameter of limit |
| min       | float | Parameter of limit |

Returns float

## randomString (static public member function of math)
| Parameter | Type | Description               |
| --------- | ---- | ------------------------- |
| length    | int  | Parameter of randomString |

Returns string

## getAngleForVector (static public member function of math)
Returns the arctangent of the quotient of the given values

| Parameter | Type    | Description                    |
| --------- | ------- | ------------------------------ |
| vector    | Vector2 | Parameter of getAngleForVector |

Returns float

## getVectorForAngle (static public member function of math)
| Parameter | Type  | Description                                                      |
| --------- | ----- | ---------------------------------------------------------------- |
| angle     | float | The angle in radians (-pi/2: left, 0: up, pi/2: right, pi: down) |
| radius    | float | Parameter of getVectorForAngle                                   |

Returns Vector2

## intersectLines (static public member function of math)
| Parameter | Type     | Description                 |
| --------- | -------- | --------------------------- |
| startA    | Vector2  | Parameter of intersectLines |
| endA      | Vector2  | Parameter of intersectLines |
| startB    | Vector2  | Parameter of intersectLines |
| endB      | Vector2  | Parameter of intersectLines |
| typeA     | LineType | Parameter of intersectLines |
| typeB     | LineType | Parameter of intersectLines |

Returns Vector2

## projectPointOnLine (static public member function of math)
| Parameter | Type     | Description                     |
| --------- | -------- | ------------------------------- |
| from      | Vector2  | Parameter of projectPointOnLine |
| to        | Vector2  | Parameter of projectPointOnLine |
| type      | LineType | Parameter of projectPointOnLine |
| point     | Vector2  | Parameter of projectPointOnLine |

Returns Vector2

## closestPointOnLine (static public member function of math)
| Parameter | Type     | Description                     |
| --------- | -------- | ------------------------------- |
| from      | Vector2  | Parameter of closestPointOnLine |
| to        | Vector2  | Parameter of closestPointOnLine |
| type      | LineType | Parameter of closestPointOnLine |
| point     | Vector2  | Parameter of closestPointOnLine |

Returns Vector2

## map (static public member function of math)
Maps a value from an input range to an output range

| Parameter | Type  | Description                                                                        |
| --------- | ----- | ---------------------------------------------------------------------------------- |
| progress  | float | The input value                                                                    |
| from      | float | The beginning of the input range                                                   |
| to        | float | The end of the input range                                                         |
| start     | float | The lowest possible output value, will be returned for values smaller than "from". |
| target    | float | The highest possible output value, will be returned for values larger than "to".   |

Returns float

## map (static public member function of math)
Maps a value from an input range to an output range

| Parameter | Type  | Description                                                                        |
| --------- | ----- | ---------------------------------------------------------------------------------- |
| progress  | float | The input value                                                                    |
| start     | float | The lowest possible output value, will be returned for values smaller than "from". |
| target    | float | The highest possible output value, will be returned for values larger than "to".   |

Returns float

## map (static public member function of math)
// Maps a value from an input range to an output range

| Parameter | Type         | Description                                                                        |
| --------- | ------------ | ---------------------------------------------------------------------------------- |
| progress  | float        | The input value                                                                    |
| from      | float        | The beginning of the input range                                                   |
| to        | float        | The end of the input range                                                         |
| start     | float        | The lowest possible output value, will be returned for values smaller than "from". |
| target    | float        | The highest possible output value, will be returned for values larger than "to".   |
| ease      | EaseFunction | The easing function to apply                                                       |

Returns float

## interpolate (global function)
| Parameter | Type  | Description                    |
| --------- | ----- | ------------------------------ |
| from      | float | Parameter of interpolate       |
| to        | float | Parameter of interpolate       |
| startTime | float | The start time in milliseconds |
| duration  | float | The duration in milliseconds   |

Returns float

## interpolate (global function)
| Parameter | Type  | Description                    |
| --------- | ----- | ------------------------------ |
| from      | Color | Parameter of interpolate       |
| to        | Color | Parameter of interpolate       |
| startTime | float | The start time in milliseconds |
| duration  | float | The duration in milliseconds   |

Returns Color

## init (static public member function of math)
Returns void

## initDefaultRandomGenerator (static public member function of math)
Returns void

## generateRandomSeed (static public member function of math)
Returns string

## setRandomSeed (static public member function of math)
| Parameter | Type   | Description                |
| --------- | ------ | -------------------------- |
| seed      | string | Parameter of setRandomSeed |

Returns void

## randomInteger (global function)
Generates a random integer

| Parameter | Type | Description                                     |
| --------- | ---- | ----------------------------------------------- |
| from      | int  | The inclusive lower bound of the random integer |
| to        | int  | The exclusive upper bound of the random integer |

Returns int

## randomInteger (global function)
| Parameter | Type | Description                                     |
| --------- | ---- | ----------------------------------------------- |
| to        | int  | The exclusive upper bound of the random integer |

Returns int

## randomFloat (global function)
Generates a random float

| Parameter | Type  | Description              |
| --------- | ----- | ------------------------ |
| from      | float | Parameter of randomFloat |
| to        | float | Parameter of randomFloat |

Returns int

## randomFloat (global function)
| Parameter | Type  | Description              |
| --------- | ----- | ------------------------ |
| to        | float | Parameter of randomFloat |

Returns int

---

# struct RollingList

## add (public member function of RollingList)
| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| value     | float | Parameter of add |

Returns void

## measure (public member function of RollingList)
| Parameter | Type   | Description          |
| --------- | ------ | -------------------- |
| do        | void() | Parameter of measure |

Returns void

## average (public member function of RollingList)
Returns float

## max (public member function of RollingList)
Returns float

## min (public member function of RollingList)
Returns float

## toString (public member function of RollingList)
Returns string

---

# class Range

## contains (public member function of Range)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| value     | int  | Parameter of contains |

Returns bool

## containsInclusively (public member function of Range)
| Parameter | Type | Description                      |
| --------- | ---- | -------------------------------- |
| value     | int  | Parameter of containsInclusively |

Returns bool

---

# class File

## objectUrl (public member function of File)
Returns string

---

# static class Loca

## languageName (static public member function of Loca)
Returns string

## setLanguage (static public member function of Loca)
| Parameter | Type     | Description              |
| --------- | -------- | ------------------------ |
| language  | Language | Parameter of setLanguage |
| locale    | string   | Parameter of setLanguage |

Returns void

## format (static public member function of Loca)
| Parameter | Type | Description         |
| --------- | ---- | ------------------- |
| id        | int  | Parameter of format |

Returns string

---

# class Buffer

## writeInt (public member function of Buffer)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| value     | int  | Parameter of writeInt |

Returns void

## readInt (public member function of Buffer)
Returns int

## writeUnsignedInt (public member function of Buffer)
| Parameter | Type | Description                   |
| --------- | ---- | ----------------------------- |
| value     | int  | Parameter of writeUnsignedInt |

Returns void

## readUnsignedInt (public member function of Buffer)
Returns int

## writeString (public member function of Buffer)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| value     | string | Parameter of writeString |

Returns void

## readString (public member function of Buffer)
Returns string

## setInt16 (public member function of Buffer)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| index     | int  | Parameter of setInt16 |
| value     | int  | Parameter of setInt16 |

Returns void

## writeInt8 (public member function of Buffer)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| value     | int  | Parameter of writeInt8 |

Returns void

## writeUnsignedInt8 (public member function of Buffer)
| Parameter | Type | Description                    |
| --------- | ---- | ------------------------------ |
| value     | int  | Parameter of writeUnsignedInt8 |

Returns void

## writeInt16 (public member function of Buffer)
| Parameter | Type | Description             |
| --------- | ---- | ----------------------- |
| value     | int  | Parameter of writeInt16 |

Returns void

## writeUnsignedInt16 (public member function of Buffer)
| Parameter | Type | Description                     |
| --------- | ---- | ------------------------------- |
| value     | int  | Parameter of writeUnsignedInt16 |

Returns void

## writeInt32 (public member function of Buffer)
| Parameter | Type | Description             |
| --------- | ---- | ----------------------- |
| value     | int  | Parameter of writeInt32 |

Returns void

## writeFloat32 (public member function of Buffer)
| Parameter | Type  | Description               |
| --------- | ----- | ------------------------- |
| value     | float | Parameter of writeFloat32 |

Returns void

## writeFloat64 (public member function of Buffer)
| Parameter | Type  | Description               |
| --------- | ----- | ------------------------- |
| value     | float | Parameter of writeFloat64 |

Returns void

## writeBool (public member function of Buffer)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| value     | bool | Parameter of writeBool |

Returns void

## writeBuffer (public member function of Buffer)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| source    | Buffer | Parameter of writeBuffer |

Returns void

## writeBuffer (public member function of Buffer)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| source    | Buffer | Parameter of writeBuffer |
| start     | int    | Parameter of writeBuffer |
| length    | int    | Parameter of writeBuffer |

Returns void

## insertArrayBuffer (public member function of Buffer)
Insert a raw array buffer at the writePos without writing its length

| Parameter         | Type | Description                    |
| ----------------- | ---- | ------------------------------ |
| sourceArrayBuffer | any  | Parameter of insertArrayBuffer |

Returns void

## copyFromBuffer (public member function of Buffer)
| Parameter | Type   | Description                 |
| --------- | ------ | --------------------------- |
| source    | Buffer | Parameter of copyFromBuffer |

Returns void

## set (public member function of Buffer)
| Parameter | Type   | Description      |
| --------- | ------ | ---------------- |
| source    | Buffer | Parameter of set |

Returns void

## peekInt8 (public member function of Buffer)
Returns int

## peekInt16 (public member function of Buffer)
Returns int

## peekInt32 (public member function of Buffer)
Returns int

## readInt8 (public member function of Buffer)
Returns int

## readUnsignedInt8 (public member function of Buffer)
Returns int

## readInt16 (public member function of Buffer)
Returns int

## readUnsignedInt16 (public member function of Buffer)
Returns int

## readInt32 (public member function of Buffer)
Returns int

## readFloat32 (public member function of Buffer)
Returns float

## readFloat64 (public member function of Buffer)
Returns float

## readBool (public member function of Buffer)
Returns bool

## readBuffer (public member function of Buffer)
| Parameter   | Type   | Description             |
| ----------- | ------ | ----------------------- |
| writeBuffer | Buffer | Parameter of readBuffer |
| writeStart  | int    | Parameter of readBuffer |

Returns int

## toString (public member function of Buffer)
Returns string

## toRangeString (public member function of Buffer)
| Parameter | Type | Description                |
| --------- | ---- | -------------------------- |
| start     | int  | Parameter of toRangeString |
| end       | int  | Parameter of toRangeString |

Returns string

## init (static public member function of Buffer)
Returns void

## canRead (public member function of Buffer)
Returns bool

## toByteArray (public member function of Buffer)
Returns object

## subArrayBuffer (public member function of Buffer)
| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| from      | int  | Parameter of subArrayBuffer |
| to        | int  | Parameter of subArrayBuffer |

Returns dynamic

## reset (public member function of Buffer)
Returns void

## rewind (public member function of Buffer)
Returns void

## checksum (public member function of Buffer)
Returns int

## listToChecksum (static public member function of Buffer)
| Parameter | Type  | Description                 |
| --------- | ----- | --------------------------- |
| list      | int[] | Parameter of listToChecksum |

Returns int

## toList (public member function of Buffer)
Returns int[]

---

# class TimeString

## now (static public member function of TimeString)
Returns TimeString

## fromTime (static public member function of TimeString)
| Parameter | Type  | Description           |
| --------- | ----- | --------------------- |
| value     | float | Parameter of fromTime |

Returns TimeString

## toBool (public member function of TimeString)
Returns bool

## toString (public member function of TimeString)
Returns string

## dayMonthString (public member function of TimeString)
(31.12.)

| Parameter | Type     | Description                 |
| --------- | -------- | --------------------------- |
| language  | Language | Parameter of dayMonthString |

Returns string

## dayMonthYearString (public member function of TimeString)
(31.12.2000)

| Parameter | Type     | Description                     |
| --------- | -------- | ------------------------------- |
| language  | Language | Parameter of dayMonthYearString |

Returns string

## dayMonthNameYearString (public member function of TimeString)
(31 December 2000)

| Parameter | Type     | Description                         |
| --------- | -------- | ----------------------------------- |
| language  | Language | Parameter of dayMonthNameYearString |

Returns string

## dayShortMonthNameString (public member function of TimeString)
(31 Dec)

| Parameter | Type     | Description                          |
| --------- | -------- | ------------------------------------ |
| language  | Language | Parameter of dayShortMonthNameString |

Returns string

## dayOfWeekDayMonthNameYearString (public member function of TimeString)
(31 December 2000)

| Parameter | Type     | Description                                  |
| --------- | -------- | -------------------------------------------- |
| language  | Language | Parameter of dayOfWeekDayMonthNameYearString |

Returns string

## dayOfWeekDayMonthString (public member function of TimeString)
(Monday, December 31)

| Parameter | Type     | Description                          |
| --------- | -------- | ------------------------------------ |
| language  | Language | Parameter of dayOfWeekDayMonthString |

Returns string

## dayOfWeekString (public member function of TimeString)
(Monday)

| Parameter | Type     | Description                  |
| --------- | -------- | ---------------------------- |
| language  | Language | Parameter of dayOfWeekString |

Returns string

## dayOfWeekShortString (public member function of TimeString)
(Monday)

| Parameter | Type     | Description                       |
| --------- | -------- | --------------------------------- |
| language  | Language | Parameter of dayOfWeekShortString |

Returns string

## hourMinuteString (public member function of TimeString)
(12:59 pm)

| Parameter | Type     | Description                   |
| --------- | -------- | ----------------------------- |
| language  | Language | Parameter of hourMinuteString |

Returns string

## dayOfWeekDayMonthAtHourMinuteString (public member function of TimeString)
(Monday, December 31 at 12:59 pm)

| Parameter | Type     | Description                                      |
| --------- | -------- | ------------------------------------------------ |
| language  | Language | Parameter of dayOfWeekDayMonthAtHourMinuteString |

Returns string

## dayOfWeekDayMonthYearHourMinuteString (public member function of TimeString)
(Monday, 31 December 2000, 12:59 pm)

| Parameter | Type     | Description                                        |
| --------- | -------- | -------------------------------------------------- |
| language  | Language | Parameter of dayOfWeekDayMonthYearHourMinuteString |

Returns string

---

# class PlainTimeString

## now (static public member function of PlainTimeString)
Returns PlainTimeString

## toBool (public member function of PlainTimeString)
Returns bool

## toString (public member function of PlainTimeString)
Returns string

## dayMonthString (public member function of PlainTimeString)
(31.12.)

| Parameter | Type     | Description                 |
| --------- | -------- | --------------------------- |
| language  | Language | Parameter of dayMonthString |

Returns string

## dayMonthYearString (public member function of PlainTimeString)
(31.12.2000)

| Parameter | Type     | Description                     |
| --------- | -------- | ------------------------------- |
| language  | Language | Parameter of dayMonthYearString |

Returns string

## dayMonthNameYearString (public member function of PlainTimeString)
(31 December 2000)

| Parameter | Type     | Description                         |
| --------- | -------- | ----------------------------------- |
| language  | Language | Parameter of dayMonthNameYearString |

Returns string

## dayShortMonthNameString (public member function of PlainTimeString)
(31 Dec)

| Parameter | Type     | Description                          |
| --------- | -------- | ------------------------------------ |
| language  | Language | Parameter of dayShortMonthNameString |

Returns string

## dayOfWeekDayMonthNameYearString (public member function of PlainTimeString)
(31 December 2000)

| Parameter | Type     | Description                                  |
| --------- | -------- | -------------------------------------------- |
| language  | Language | Parameter of dayOfWeekDayMonthNameYearString |

Returns string

## dayOfWeekDayMonthString (public member function of PlainTimeString)
(Monday, December 31)

| Parameter | Type     | Description                          |
| --------- | -------- | ------------------------------------ |
| language  | Language | Parameter of dayOfWeekDayMonthString |

Returns string

## dayOfWeekString (public member function of PlainTimeString)
(Monday)

| Parameter | Type     | Description                  |
| --------- | -------- | ---------------------------- |
| language  | Language | Parameter of dayOfWeekString |

Returns string

## dayOfWeekShortString (public member function of PlainTimeString)
(Monday)

| Parameter | Type     | Description                       |
| --------- | -------- | --------------------------------- |
| language  | Language | Parameter of dayOfWeekShortString |

Returns string

## hourMinuteString (public member function of PlainTimeString)
(12:59 pm)

| Parameter | Type     | Description                   |
| --------- | -------- | ----------------------------- |
| language  | Language | Parameter of hourMinuteString |

Returns string

## dayOfWeekDayMonthAtHourMinuteString (public member function of PlainTimeString)
(Monday, December 31 at 12:59 pm)

| Parameter | Type     | Description                                      |
| --------- | -------- | ------------------------------------------------ |
| language  | Language | Parameter of dayOfWeekDayMonthAtHourMinuteString |

Returns string

## dayOfWeekDayMonthYearHourMinuteString (public member function of PlainTimeString)
(Monday, 31 December 2000, 12:59 pm)

| Parameter | Type     | Description                                        |
| --------- | -------- | -------------------------------------------------- |
| language  | Language | Parameter of dayOfWeekDayMonthYearHourMinuteString |

Returns string

---

# class DateTime

## preciseTime (static public member function of DateTime)
Returns float

## twoDigitDay (public member function of DateTime)
Returns string

## twoDigitMonth (public member function of DateTime)
Returns string

## twoDigitHour (public member function of DateTime)
Returns string

## twoDigitMinute (public member function of DateTime)
Returns string

## twoDigitSecond (public member function of DateTime)
Returns string

## fromTimeInSeconds (static public member function of DateTime)
| Parameter      | Type  | Description                    |
| -------------- | ----- | ------------------------------ |
| timeInSeconds  | float | Parameter of fromTimeInSeconds |
| outputTimezone | int   | Parameter of fromTimeInSeconds |

Returns DateTime

## fromTime (static public member function of DateTime)
| Parameter      | Type  | Description           |
| -------------- | ----- | --------------------- |
| time           | float | Parameter of fromTime |
| outputTimezone | int   | Parameter of fromTime |

Returns DateTime

## fromValues (static public member function of DateTime)
| Parameter      | Type | Description             |
| -------------- | ---- | ----------------------- |
| year           | int  | Parameter of fromValues |
| month          | int  | Parameter of fromValues |
| day            | int  | Parameter of fromValues |
| hour           | int  | Parameter of fromValues |
| minute         | int  | Parameter of fromValues |
| second         | int  | Parameter of fromValues |
| milliseconds   | int  | Parameter of fromValues |
| inputTimezone  | int  | Parameter of fromValues |
| outputTimezone | int  | Parameter of fromValues |

Returns DateTime

## getDaysInMonth (static public member function of DateTime)
| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| month     | int  | Parameter of getDaysInMonth |
| year      | int  | Parameter of getDaysInMonth |

Returns int

## dayMonthString (public member function of DateTime)
(31.12.)

| Parameter | Type     | Description                 |
| --------- | -------- | --------------------------- |
| language  | Language | Parameter of dayMonthString |

Returns string

## dayMonthYearString (public member function of DateTime)
(31.12.2000)

| Parameter | Type     | Description                     |
| --------- | -------- | ------------------------------- |
| language  | Language | Parameter of dayMonthYearString |

Returns string

## dayMonthNameYearString (public member function of DateTime)
(31 December 2000)

| Parameter | Type     | Description                         |
| --------- | -------- | ----------------------------------- |
| language  | Language | Parameter of dayMonthNameYearString |

Returns string

## dayShortMonthNameString (public member function of DateTime)
(31 Dec)

| Parameter | Type     | Description                          |
| --------- | -------- | ------------------------------------ |
| language  | Language | Parameter of dayShortMonthNameString |

Returns string

## dayOfWeekDayMonthNameYearString (public member function of DateTime)
(31 December 2000)

| Parameter | Type     | Description                                  |
| --------- | -------- | -------------------------------------------- |
| language  | Language | Parameter of dayOfWeekDayMonthNameYearString |

Returns string

## dayOfWeekDayMonthString (public member function of DateTime)
(Monday, December 31)

| Parameter | Type     | Description                          |
| --------- | -------- | ------------------------------------ |
| language  | Language | Parameter of dayOfWeekDayMonthString |

Returns string

## dayOfWeekString (public member function of DateTime)
(Monday)

| Parameter | Type     | Description                  |
| --------- | -------- | ---------------------------- |
| language  | Language | Parameter of dayOfWeekString |

Returns string

## dayOfWeekShortString (public member function of DateTime)
(Monday)

| Parameter | Type     | Description                       |
| --------- | -------- | --------------------------------- |
| language  | Language | Parameter of dayOfWeekShortString |

Returns string

## hourMinuteString (public member function of DateTime)
(12:59 pm)

| Parameter | Type     | Description                   |
| --------- | -------- | ----------------------------- |
| language  | Language | Parameter of hourMinuteString |

Returns string

## dayOfWeekDayMonthAtHourMinuteString (public member function of DateTime)
(Monday, December 31 at 12:59 pm)

| Parameter | Type     | Description                                      |
| --------- | -------- | ------------------------------------------------ |
| language  | Language | Parameter of dayOfWeekDayMonthAtHourMinuteString |

Returns string

## dayOfWeekDayMonthYearHourMinuteString (public member function of DateTime)
(Monday, 31 December 2000, 12:59 pm)

| Parameter | Type     | Description                                        |
| --------- | -------- | -------------------------------------------------- |
| language  | Language | Parameter of dayOfWeekDayMonthYearHourMinuteString |

Returns string

## compactString (public member function of DateTime)
(20001231235959+02:00)

Returns string

## fromTimeString (static public member function of DateTime)
| Parameter  | Type       | Description                 |
| ---------- | ---------- | --------------------------- |
| timeString | TimeString | Parameter of fromTimeString |

Returns DateTime

## fromTimeString (static public member function of DateTime)
| Parameter  | Type            | Description                 |
| ---------- | --------------- | --------------------------- |
| timeString | PlainTimeString | Parameter of fromTimeString |

Returns DateTime

## fromIsoString (static public member function of DateTime)
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

| Parameter      | Type   | Description                |
| -------------- | ------ | -------------------------- |
| str            | string | Parameter of fromIsoString |
| outputTimezone | int    | Parameter of fromIsoString |

Returns DateTime

## toPlainTimeString (public member function of DateTime)
Returns PlainTimeString

## toTimeString (public member function of DateTime)
Returns TimeString

## measure (static public member function of DateTime)
| Parameter | Type   | Description          |
| --------- | ------ | -------------------- |
| do        | void() | Parameter of measure |

Returns float

## frame (static public member function of DateTime)
The current frame (by default, there are 30 frames per second)

Returns int

---

# class Date
Calculate dates using the JavaScript Date class

## now (static public member function of Date)
Returns Date

## year (public member function of Date)
Returns int

## month (public member function of Date)
Returns int

## day (public member function of Date)
Returns int

## dayOfWeek (public member function of Date)
Returns int

## hour (public member function of Date)
Returns int

## minute (public member function of Date)
Returns int

## second (public member function of Date)
Returns int

## millisecond (public member function of Date)
Returns int

## twoDigitMonth (public member function of Date)
Returns string

## twoDigitDay (public member function of Date)
Returns string

## twoDigitHour (public member function of Date)
Returns string

## twoDigitMinute (public member function of Date)
Returns string

## twoDigitSecond (public member function of Date)
Returns string

## timeOfDay (public member function of Date)
Returns float

## dayMonthString (public member function of Date)
(31.12.)

| Parameter | Type     | Description                 |
| --------- | -------- | --------------------------- |
| language  | Language | Parameter of dayMonthString |

Returns string

## dayMonthYearString (public member function of Date)
(31.12.2000)

| Parameter | Type     | Description                     |
| --------- | -------- | ------------------------------- |
| language  | Language | Parameter of dayMonthYearString |

Returns string

## dayLongMonthNameYearString (public member function of Date)
(31 December 2000)

| Parameter | Type     | Description                             |
| --------- | -------- | --------------------------------------- |
| language  | Language | Parameter of dayLongMonthNameYearString |

Returns string

## dayShortMonthNameYearString (public member function of Date)
(31 Dec 2000)

| Parameter | Type     | Description                              |
| --------- | -------- | ---------------------------------------- |
| language  | Language | Parameter of dayShortMonthNameYearString |

Returns string

## dayOfWeekString (public member function of Date)
(Monday)

| Parameter | Type     | Description                  |
| --------- | -------- | ---------------------------- |
| language  | Language | Parameter of dayOfWeekString |

Returns string

## shortDayOfWeekString (public member function of Date)
(Mon)

| Parameter | Type     | Description                       |
| --------- | -------- | --------------------------------- |
| language  | Language | Parameter of shortDayOfWeekString |

Returns string

## hourMinuteString (public member function of Date)
(23:59)

| Parameter | Type     | Description                   |
| --------- | -------- | ----------------------------- |
| language  | Language | Parameter of hourMinuteString |

Returns string

## hourMinuteSecondString (public member function of Date)
(23:59:59)

| Parameter | Type     | Description                         |
| --------- | -------- | ----------------------------------- |
| language  | Language | Parameter of hourMinuteSecondString |

Returns string

## hourMinuteSecondMillisecondString (public member function of Date)
(23:59:59.999)

| Parameter | Type     | Description                                    |
| --------- | -------- | ---------------------------------------------- |
| language  | Language | Parameter of hourMinuteSecondMillisecondString |

Returns string

## dayMonthYearHourMinuteString (public member function of Date)
(31.12.2000 23:59)

| Parameter | Type     | Description                               |
| --------- | -------- | ----------------------------------------- |
| language  | Language | Parameter of dayMonthYearHourMinuteString |

Returns string

## dayMonthYearHourMinuteSecondString (public member function of Date)
(31.12.2000 23:59:59)

| Parameter | Type     | Description                                     |
| --------- | -------- | ----------------------------------------------- |
| language  | Language | Parameter of dayMonthYearHourMinuteSecondString |

Returns string

## invariantDayMonthYearHourMinuteSecondString (public member function of Date)
(31-12-2000 23-59-59)

| Parameter | Type     | Description                                              |
| --------- | -------- | -------------------------------------------------------- |
| language  | Language | Parameter of invariantDayMonthYearHourMinuteSecondString |

Returns string

## time (public member function of Date)
The number of milliseconds elapsed since January 1, 1970

Returns float

## isoString (public member function of Date)
The data and time in ISO 8601 format, for example "2000-12-31T17:30:00.000Z"

Returns string

## fromTime (static public member function of Date)
| Parameter | Type  | Description           |
| --------- | ----- | --------------------- |
| time      | float | Parameter of fromTime |

Returns Date

## fromValues (static public member function of Date)
| Parameter | Type | Description             |
| --------- | ---- | ----------------------- |
| year      | int  | Parameter of fromValues |
| month     | int  | Parameter of fromValues |
| day       | int  | Parameter of fromValues |
| hour      | int  | Parameter of fromValues |
| minute    | int  | Parameter of fromValues |
| second    | int  | Parameter of fromValues |

Returns Date

## realtime (static public member function of Date)
Returns the real time, even during replay. Be careful: This can break the replay.

Returns Date

---

# static class fx

## add (static public member function of fx)
| Parameter | Type      | Description      |
| --------- | --------- | ---------------- |
| animation | Animation | Parameter of add |

Returns void

## removeForObject (static public member function of fx)
| Parameter | Type   | Description                  |
| --------- | ------ | ---------------------------- |
| object    | Object | Parameter of removeForObject |

Returns void

## endOfPrevAnimation (static public member function of fx)
| Parameter | Type   | Description                     |
| --------- | ------ | ------------------------------- |
| object    | Object | Parameter of endOfPrevAnimation |

Returns float

## delay (global function)
| Parameter | Type   | Description               |
| --------- | ------ | ------------------------- |
| time      | float  | The delay in milliseconds |
| do        | void() | Parameter of delay        |

Returns void

## delay (global function)
| Parameter | Type  | Description               |
| --------- | ----- | ------------------------- |
| time      | float | The delay in milliseconds |

Returns Promise<void>

## animate (global function)
Animate a variable to a target value over a given period of time

| Parameter | Type  | Description                                           |
| --------- | ----- | ----------------------------------------------------- |
| variable  | float | The variable to animate                               |
| to        | float | The target value to animate to                        |
| delay     | float | The delay before the animation starts in milliseconds |
| duration  | float | The duration of the animation in milliseconds         |

Returns void

## animate (global function)
Animate a variable to a target value over a given period of time

| Parameter | Type         | Description                                           |
| --------- | ------------ | ----------------------------------------------------- |
| variable  | float        | The variable to animate                               |
| to        | float        | The target value to animate to                        |
| delay     | float        | The delay before the animation starts in milliseconds |
| duration  | float        | The duration of the animation in milliseconds         |
| ease      | EaseFunction | The easing function to apply                          |

Returns void

## animate (global function)
Animate a variable to a target value over a given period of time

| Parameter | Type    | Description                                           |
| --------- | ------- | ----------------------------------------------------- |
| variable  | Vector2 | The variable to animate                               |
| to        | Vector2 | The target vector to animate to                       |
| delay     | float   | The delay before the animation starts in milliseconds |
| duration  | float   | The duration of the animation in milliseconds         |

Returns void

## animate (global function)
Animate a variable to a target value over a given period of time

| Parameter | Type         | Description                                           |
| --------- | ------------ | ----------------------------------------------------- |
| variable  | Vector2      | The variable to animate                               |
| to        | Vector2      | The target vector to animate to                       |
| delay     | float        | The delay before the animation starts in milliseconds |
| duration  | float        | The duration of the animation in milliseconds         |
| ease      | EaseFunction | The easing function to apply                          |

Returns void

## animate (global function)
Animate a variable to a target value over a given period of time

| Parameter | Type  | Description                                           |
| --------- | ----- | ----------------------------------------------------- |
| variable  | Color | The variable to animate                               |
| to        | Color | The target color to animate to                        |
| delay     | float | The delay before the animation starts in milliseconds |
| duration  | float | The duration of the animation in milliseconds         |

Returns void

## interpolate (static public member function of fx)
| Parameter | Type                 | Description                  |
| --------- | -------------------- | ---------------------------- |
| from      | float                | Parameter of interpolate     |
| to        | float                | Parameter of interpolate     |
| do        | void(float progress) | Parameter of interpolate     |
| delay     | float                | The delay in milliseconds    |
| duration  | float                | The duration in milliseconds |

Returns void

## interpolate (static public member function of fx)
| Parameter | Type                 | Description                  |
| --------- | -------------------- | ---------------------------- |
| from      | float                | Parameter of interpolate     |
| to        | float                | Parameter of interpolate     |
| do        | void(float progress) | Parameter of interpolate     |
| delay     | float                | The delay in milliseconds    |
| duration  | float                | The duration in milliseconds |
| ease      | EaseFunction         | Parameter of interpolate     |

Returns void

## interpolate (static public member function of fx)
| Parameter | Type                   | Description                  |
| --------- | ---------------------- | ---------------------------- |
| from      | Vector2                | Parameter of interpolate     |
| to        | Vector2                | Parameter of interpolate     |
| do        | void(Vector2 progress) | Parameter of interpolate     |
| delay     | float                  | The delay in milliseconds    |
| duration  | float                  | The duration in milliseconds |

Returns void

## interpolate (static public member function of fx)
| Parameter | Type                   | Description                  |
| --------- | ---------------------- | ---------------------------- |
| from      | Vector2                | Parameter of interpolate     |
| to        | Vector2                | Parameter of interpolate     |
| do        | void(Vector2 progress) | Parameter of interpolate     |
| delay     | float                  | The delay in milliseconds    |
| duration  | float                  | The duration in milliseconds |
| ease      | EaseFunction           | Parameter of interpolate     |

Returns void

## interpolate (static public member function of fx)
| Parameter | Type                 | Description                  |
| --------- | -------------------- | ---------------------------- |
| from      | Color                | Parameter of interpolate     |
| to        | Color                | Parameter of interpolate     |
| do        | void(Color progress) | Parameter of interpolate     |
| delay     | float                | The delay in milliseconds    |
| duration  | float                | The duration in milliseconds |

Returns void

## defer (global function)
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| do        | void() | Parameter of defer |

Returns void

---

# struct Vector2

## animateTo (public member function of Vector2)
Animate the vector to a target vector over a given period of time

| Parameter | Type    | Description                                           |
| --------- | ------- | ----------------------------------------------------- |
| target    | Vector2 | The target vector to animate to                       |
| delay     | float   | The delay before the animation starts in milliseconds |
| duration  | float   | The duration of the animation in milliseconds         |

Returns void

## animateTo (public member function of Vector2)
Animate the vector to a target vector over a given period of time

| Parameter | Type         | Description                                           |
| --------- | ------------ | ----------------------------------------------------- |
| target    | Vector2      | The target vector to animate to                       |
| delay     | float        | The delay before the animation starts in milliseconds |
| duration  | float        | The duration of the animation in milliseconds         |
| ease      | EaseFunction | The easing function to apply                          |

Returns void

## None (static public member function of Vector2)
Used to specify that the vector is not set or invalid

Returns Vector2

## MinValue (static public member function of Vector2)
{float.minValue, float.minValue}

Returns Vector2

## MaxValue (static public member function of Vector2)
{float.maxValue, float.maxValue}

Returns Vector2

## Zero (static public member function of Vector2)
{0,0}

Returns Vector2

## toString (public member function of Vector2)
A string representation of the vector

Returns string

## toBool (public member function of Vector2)
Returns true if the vector is not equal to Vector2.None

Returns bool

## clone (public member function of Vector2)
Creates a copy of the vector with the same values

Returns Vector2

## create (public member function of Vector2)
Create a new instance. Useful for data imported from json where the vector might be undefined

| Parameter | Type               | Description                              |
| --------- | ------------------ | ---------------------------------------- |
| x         | float              | The x-coordinate of the vector to create |
| y         | float              | The y-coordinate of the vector to create |
| location  | SourceCodeLocation | Parameter of create                      |

Returns Vector2

## create (public member function of Vector2)
Create a new instance. Useful for data imported from json where the vector might be undefined

| Parameter | Type    | Description                                               |
| --------- | ------- | --------------------------------------------------------- |
| value     | Vector2 | Create a new instance with the coordinated of this vector |

Returns Vector2

## assign (public member function of Vector2)
| Parameter | Type    | Description         |
| --------- | ------- | ------------------- |
| other     | Vector2 | Parameter of assign |

Returns Vector2

## length (public member function of Vector2)
The length of the vector

Returns float

## sign (public member function of Vector2)
The sign of each coordinate

Returns Vector2

## lengthSquared (public member function of Vector2)
The square of the length of the vector

Returns float

## orthogonal (public member function of Vector2)
Make the vector orthogonal to the existing vector

Returns Vector2

## invert (public member function of Vector2)
Flip the sign of each coordinate

Returns Vector2

## round (public member function of Vector2)
Round each coordinate to the closest integer value

Returns IntVector2

## floor (public member function of Vector2)
Round each coordinate down to an integer value

Returns IntVector2

## ceil (public member function of Vector2)
Round each coordinate up to an integer value

Returns IntVector2

## abs (public member function of Vector2)
Return a new vector with each coordinate positive

Returns Vector2

## max (public member function of Vector2)
The larger of the two coordinates

Returns float

## min (public member function of Vector2)
The smaller of the two coordinates

Returns float

## move (public member function of Vector2)
Move the vector

| Parameter | Type    | Description           |
| --------- | ------- | --------------------- |
| delta     | Vector2 | The vector to move by |

Returns Vector2

## move (public member function of Vector2)
Move the vector

| Parameter | Type  | Description                     |
| --------- | ----- | ------------------------------- |
| x         | float | Move horizontally by this value |
| y         | float | Move vertically by this value   |

Returns Vector2

## rotate (public member function of Vector2)
Rotate the vector by a given angle

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns Vector2

## distanceTo (public member function of Vector2)
The distance to another vector

| Parameter | Type    | Description       |
| --------- | ------- | ----------------- |
| value     | Vector2 | The second vector |

Returns float

## manhattanDistanceTo (public member function of Vector2)
The distance to another vector along axes at right angles

| Parameter | Type    | Description       |
| --------- | ------- | ----------------- |
| value     | Vector2 | The second vector |

Returns float

## angleTo (public member function of Vector2)
The angle to another vector in radians (one full rotation is 2*pi)

| Parameter | Type    | Description       |
| --------- | ------- | ----------------- |
| value     | Vector2 | The second vector |

Returns float

## normalize (public member function of Vector2)
Ensure the vector has a length of 1

Returns Vector2

## normalized (public member function of Vector2)
A vector that points in the same direction, but has a length of 1

Returns Vector2

## moveTowards (public member function of Vector2)
Moves the vector towards the given target by the given distance

| Parameter       | Type    | Description                |
| --------------- | ------- | -------------------------- |
| targetPosition  | Vector2 | The target to move towards |
| speed           | float   | The distance to move by    |
| onReachedTarget | void()  | Parameter of moveTowards   |

Returns void

## transform (public member function of Vector2)
Transforms the vector by a given matrix

| Parameter | Type     | Description                           |
| --------- | -------- | ------------------------------------- |
| matrix    | Matrix2D | The matrix to transform the vector by |

Returns Vector2

## transformed (public member function of Vector2)
Return a new vector that is transformed by a given matrix

| Parameter | Type     | Description                           |
| --------- | -------- | ------------------------------------- |
| matrix    | Matrix2D | The matrix to transform the vector by |

Returns Vector2

## getRelativeTo (public member function of Vector2)
A vector that is transformed by the inverse of the given matrix

| Parameter | Type     | Description                                                  |
| --------- | -------- | ------------------------------------------------------------ |
| matrix    | Matrix2D | The vector will be transformed by the inverse of this matrix |

Returns Vector2

## isInsideRectangle (public member function of Vector2)
Returns whether the vector is within a given rectangle

| Parameter | Type    | Description                 |
| --------- | ------- | --------------------------- |
| center    | Vector2 | The center of the rectangle |
| size      | Vector2 | The size of the rectangle   |

Returns bool

## isInsidePolygon (public member function of Vector2)
Returns whether the vector is within a given polygon

| Parameter | Type      | Description                               |
| --------- | --------- | ----------------------------------------- |
| poly      | Vector2[] | A list of points that make up the polygon |

Returns bool

## in (public member function of Vector2)
| Parameter | Type | Description     |
| --------- | ---- | --------------- |
| rectangle | Rect | Parameter of in |

Returns bool

## dot (public member function of Vector2)
The dot product

| Parameter | Type    | Description                                |
| --------- | ------- | ------------------------------------------ |
| value     | Vector2 | The value to calculate the dot procut with |

Returns float

## cross (public member function of Vector2)
The cross product

| Parameter | Type    | Description                                  |
| --------- | ------- | -------------------------------------------- |
| value     | Vector2 | The value to calculate the cross procut with |

Returns float

## serialize (public member function of Vector2)
| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| buffer    | Buffer | Parameter of serialize |

Returns void

## deserialize (public member function of Vector2)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| buffer    | Buffer | Parameter of deserialize |

Returns void

## getPathLength (static public member function of Vector2)
| Parameter | Type      | Description                |
| --------- | --------- | -------------------------- |
| path      | Vector2[] | Parameter of getPathLength |

Returns float

## getPositionAlongPath (static public member function of Vector2)
| Parameter | Type      | Description                       |
| --------- | --------- | --------------------------------- |
| path      | Vector2[] | Parameter of getPositionAlongPath |
| distance  | float     | Parameter of getPositionAlongPath |

Returns Vector2

## getPositionAndVectorAlongPath (static public member function of Vector2)
| Parameter | Type      | Description                                |
| --------- | --------- | ------------------------------------------ |
| path      | Vector2[] | Parameter of getPositionAndVectorAlongPath |
| distance  | float     | Parameter of getPositionAndVectorAlongPath |

Returns PositionAndVector

## interpolateTo (public member function of Vector2)
Interpolates to another vector

| Parameter | Type    | Description                                                                                  |
| --------- | ------- | -------------------------------------------------------------------------------------------- |
| target    | Vector2 | The target position to interpolate to                                                        |
| progress  | float   | The progress of the interpolation (0: return the start vector, 1: returns the target vector) |

Returns Vector2

## interpolateTo (public member function of Vector2)
Interpolates to another vector

| Parameter | Type    | Description                           |
| --------- | ------- | ------------------------------------- |
| target    | Vector2 | The target position to interpolate to |
| startTime | float   | The start time in milliseconds        |
| duration  | float   | The duration in milliseconds          |

Returns Vector2

## interpolateTo (public member function of Vector2)
Interpolates to another vector

| Parameter | Type         | Description                                                                                  |
| --------- | ------------ | -------------------------------------------------------------------------------------------- |
| target    | Vector2      | The target position to interpolate to                                                        |
| progress  | float        | The progress of the interpolation (0: return the start vector, 1: returns the target vector) |
| ease      | EaseFunction | Parameter of interpolateTo                                                                   |

Returns Vector2

## interpolateTo (public member function of Vector2)
Interpolates to another vector

| Parameter | Type         | Description                           |
| --------- | ------------ | ------------------------------------- |
| target    | Vector2      | The target position to interpolate to |
| startTime | float        | The start time in milliseconds        |
| duration  | float        | The duration in milliseconds          |
| ease      | EaseFunction | Parameter of interpolateTo            |

Returns Vector2

## interpolateTo (public member function of Vector2)
// Interpolates to another vector

| Parameter | Type    | Description                                                                                    |
| --------- | ------- | ---------------------------------------------------------------------------------------------- |
| target    | Vector2 | The target position to interpolate to                                                          |
| progress  | float   | Between "from" and "to" ("from" returns the start value, "to" returns the target value)        |
| from      | float   | The beginning of the input range, if "progress" is "from" or less, the start value is returned |
| to        | float   | The end of the input range, if "progress" is "to" or more, the target value is returned        |

Returns Vector2

## interpolateTo (public member function of Vector2)
// Interpolates to another vector

| Parameter | Type         | Description                                                                                    |
| --------- | ------------ | ---------------------------------------------------------------------------------------------- |
| target    | Vector2      | The target position to interpolate to                                                          |
| progress  | float        | Between "from" and "to" ("from" returns the start value, "to" returns the target value)        |
| from      | float        | The beginning of the input range, if "progress" is "from" or less, the start value is returned |
| to        | float        | The end of the input range, if "progress" is "to" or more, the target value is returned        |
| ease      | EaseFunction | The easing function to apply                                                                   |

Returns Vector2

---

# class Color

## animateTo (public member function of Color)
Animate the color to a target vector over a given period of time

| Parameter | Type  | Description                                           |
| --------- | ----- | ----------------------------------------------------- |
| target    | Color | The target color to animate to                        |
| delay     | float | The delay before the animation starts in milliseconds |
| duration  | float | The duration of the animation in milliseconds         |

Returns void

## toString (public member function of Color)
Returns string

## red (public member function of Color)
Returns int

## green (public member function of Color)
Returns int

## blue (public member function of Color)
Returns int

## withAlpha (public member function of Color)
| Parameter | Type  | Description            |
| --------- | ----- | ---------------------- |
| alpha     | float | Parameter of withAlpha |

Returns Color

## interpolateTo (public member function of Color)
Interpolates to another color

| Parameter | Type  | Description                |
| --------- | ----- | -------------------------- |
| target    | Color | Parameter of interpolateTo |
| progress  | float | Parameter of interpolateTo |

Returns Color

---

# static class audio
A collection of functions for playing audio

## playSound (global function)
| Parameter        | Type  | Description                                       |
| ---------------- | ----- | ------------------------------------------------- |
| sound            | Sound | Parameter of playSound                            |
| delay            | float | The delay before the sound starts in milliseconds |
| needsToBeCertain | bool  | Parameter of playSound                            |

Returns void

## playSound (global function)
| Parameter        | Type  | Description                                        |
| ---------------- | ----- | -------------------------------------------------- |
| sound            | Sound | Parameter of playSound                             |
| at               | float | The time at which the sound starts in milliseconds |
| needsToBeCertain | bool  | Parameter of playSound                             |

Returns void

## stop (static public member function of audio)
Returns void

## mute (static public member function of audio)
| Parameter | Type   | Description       |
| --------- | ------ | ----------------- |
| forPlayer | Player | Parameter of mute |

Returns void

## adjustVolume (static public member function of audio)
| Parameter | Type   | Description               |
| --------- | ------ | ------------------------- |
| delta     | int    | Parameter of adjustVolume |
| forPlayer | Player | Parameter of adjustVolume |

Returns void

---

# class Animation

## tick (public member function of Animation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class Path

## first (public member function of Path)
Returns Vector2

## last (public member function of Path)
Returns Vector2

## count (public member function of Path)
Returns int

## get (public member function of Path)
| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| index     | int  | Parameter of get |

Returns Vector2

## update (public member function of Path)
Returns void

## getPosition (public member function of Path)
| Parameter | Type  | Description              |
| --------- | ----- | ------------------------ |
| distance  | float | Parameter of getPosition |

Returns Vector2

## getPositionAndVector (public member function of Path)
| Parameter | Type  | Description                       |
| --------- | ----- | --------------------------------- |
| distance  | float | Parameter of getPositionAndVector |

Returns PositionAndVector

---

# struct IntVector2
A 2D vector comprised of an integer x and y coordinate

## None (static public member function of IntVector2)
Used to specify that the vector is not set or invalid

Returns IntVector2

## Zero (static public member function of IntVector2)
{0,0}

Returns IntVector2

## clone (public member function of IntVector2)
Creates a copy of the vector with the same values

Returns IntVector2

## toString (public member function of IntVector2)
A string representation of the vector

Returns string

## toBool (public member function of IntVector2)
Returns true if the vector is not equal to IntVector2.none

Returns bool

## toVector2 (public member function of IntVector2)
Returns Vector2

## assign (public member function of IntVector2)
| Parameter | Type       | Description         |
| --------- | ---------- | ------------------- |
| other     | IntVector2 | Parameter of assign |

Returns IntVector2

## length (public member function of IntVector2)
The length of the vector

Returns float

## orthogonal (public member function of IntVector2)
A vector that is orthogonal to the existing vector

Returns IntVector2

## inverse (public member function of IntVector2)
A vector with the sign of each coordinate flipped

Returns IntVector2

## abs (public member function of IntVector2)
A vector with the absolute value of each coordinate

Returns IntVector2

## max (public member function of IntVector2)
The larger of the two coordinates

Returns int

## min (public member function of IntVector2)
The smaller of the two coordinates

Returns int

## limit (public member function of IntVector2)
| Parameter | Type       | Description        |
| --------- | ---------- | ------------------ |
| min       | IntVector2 | Parameter of limit |
| max       | IntVector2 | Parameter of limit |

Returns IntVector2

## limit (public member function of IntVector2)
| Parameter | Type       | Description        |
| --------- | ---------- | ------------------ |
| max       | IntVector2 | Parameter of limit |

Returns IntVector2

## limit (public member function of IntVector2)
| Parameter | Type       | Description        |
| --------- | ---------- | ------------------ |
| min       | IntVector2 | Parameter of limit |

Returns IntVector2

## distanceTo (public member function of IntVector2)
The distance to another vector

| Parameter | Type       | Description       |
| --------- | ---------- | ----------------- |
| value     | IntVector2 | The second vector |

Returns float

## distanceTo (public member function of IntVector2)
The distance to another vector

| Parameter | Type    | Description       |
| --------- | ------- | ----------------- |
| value     | Vector2 | The second vector |

Returns float

## manhattanDistanceTo (public member function of IntVector2)
The distance to another vector along axes at right angles

| Parameter | Type       | Description       |
| --------- | ---------- | ----------------- |
| value     | IntVector2 | The second vector |

Returns int

## isInsideRectangle (public member function of IntVector2)
Returns whether the vector is within a given rectangle

| Parameter | Type       | Description                 |
| --------- | ---------- | --------------------------- |
| center    | IntVector2 | The center of the rectangle |
| size      | IntVector2 | The size of the rectangle   |

Returns bool

## angleTo (public member function of IntVector2)
The angle to another vector in radians (one full rotation is 2*pi)

| Parameter | Type       | Description       |
| --------- | ---------- | ----------------- |
| value     | IntVector2 | The second vector |

Returns float

## normalized (public member function of IntVector2)
A float vector that points in the same direction, but has a length of 1

Returns Vector2

## enumerate (static public member function of IntVector2)
| Parameter | Type                   | Description            |
| --------- | ---------------------- | ---------------------- |
| from      | IntVector2             | Parameter of enumerate |
| to        | IntVector2             | Parameter of enumerate |
| selector  | TResult(IntVector2 it) | Parameter of enumerate |

Returns TResult[]

## times (public member function of IntVector2)
| Parameter | Type                   | Description        |
| --------- | ---------------------- | ------------------ |
| selector  | TResult(IntVector2 it) | Parameter of times |

Returns TResult[]

---

# struct Matrix2D
A 3x2 matrix used to transform vectors in 2D space

## clear (public member function of Matrix2D)
Set the matrix to the identity matrix

Returns void

## set (public member function of Matrix2D)
Set the matrix to the given values

| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| m0        | float | Parameter of set |
| m1        | float | Parameter of set |
| m2        | float | Parameter of set |
| m3        | float | Parameter of set |
| m4        | float | Parameter of set |
| m5        | float | Parameter of set |

Returns void

## clone (public member function of Matrix2D)
Returns a copy of the matrix with the same values

Returns Matrix2D

## assign (public member function of Matrix2D)
| Parameter | Type     | Description         |
| --------- | -------- | ------------------- |
| other     | Matrix2D | Parameter of assign |

Returns Matrix2D

## translationVector (public member function of Matrix2D)
Returns the translation component of the matrix

Returns Vector2

## scaleVector (public member function of Matrix2D)
Return the scale component of the matrix

Returns Vector2

## toString (public member function of Matrix2D)
Returns a string representation of the matrix

Returns string

## toBool (public member function of Matrix2D)
Returns true if the matrix isn't the identity matrix

Returns bool

## move (public member function of Matrix2D)
Moves the matrix by a given vector

| Parameter | Type    | Description                             |
| --------- | ------- | --------------------------------------- |
| vector    | Vector2 | The matrix will be moved by this vector |

Returns Matrix2D

## rotate (public member function of Matrix2D)
Rotates the matrix by a given angle

| Parameter | Type  | Description                                      |
| --------- | ----- | ------------------------------------------------ |
| angle     | float | The angle in radians (one full rotation is 2*pi) |

Returns Matrix2D

## scale (public member function of Matrix2D)
Scales the matrix by a given vector

| Parameter | Type    | Description            |
| --------- | ------- | ---------------------- |
| vector    | Vector2 | The vector to scale by |

Returns Matrix2D

## multiplyRight (public member function of Matrix2D)
Return the current matrix multipied with the given matrix

| Parameter | Type     | Description                |
| --------- | -------- | -------------------------- |
| value     | Matrix2D | Parameter of multiplyRight |

Returns Matrix2D

## multiplyLeft (public member function of Matrix2D)
Returns the given matrix multiplied with the current matrix

| Parameter | Type     | Description               |
| --------- | -------- | ------------------------- |
| value     | Matrix2D | Parameter of multiplyLeft |

Returns Matrix2D

## multiply (static public member function of Matrix2D)
Multipies two matrices

| Parameter | Type     | Description           |
| --------- | -------- | --------------------- |
| left      | Matrix2D | Parameter of multiply |
| right     | Matrix2D | Parameter of multiply |
| result    | Matrix2D | Parameter of multiply |

Returns Matrix2D

---

# class IsometicGrid
Converts positions within an isomatic grid with the origin in the north
Tilt your head slighly to the right to visualize the directions
World space (northwest is up)

     Left   Top
          x               🡷 🡶
   Bottom   Right        y     x

Screen space (north is up)

         Top              🡺 x
    Left  +  Right      🡻
       Bottom            y


## getScreenPosition (public member function of IsometicGrid)
Convert world position (northwest is up) to screen position (north is up)

| Parameter | Type    | Description        |
| --------- | ------- | ------------------ |
| worldPos  | Vector2 | The world position |

Returns Vector2

## getWorldPosition (public member function of IsometicGrid)
Convert screen position (north is up) to world position (northwest is up)

| Parameter    | Type    | Description                   |
| ------------ | ------- | ----------------------------- |
| screenPos    | Vector2 | The screen position           |
| allowOutside | bool    | Parameter of getWorldPosition |

Returns Vector2

## getGridPosition (public member function of IsometicGrid)
Convert screen pos (north is up) to rounded world pos (northwest is up)

| Parameter    | Type    | Description                  |
| ------------ | ------- | ---------------------------- |
| screenPos    | Vector2 | The screen position          |
| allowOutside | bool    | Parameter of getGridPosition |

Returns IntVector2

## isValid (public member function of IsometicGrid)
| Parameter | Type       | Description          |
| --------- | ---------- | -------------------- |
| pos       | IntVector2 | Parameter of isValid |

Returns bool

## limitToInside (public member function of IsometicGrid)
| Parameter | Type       | Description                |
| --------- | ---------- | -------------------------- |
| position  | IntVector2 | Parameter of limitToInside |

Returns IntVector2

## getScreenVector (public member function of IsometicGrid)
| Parameter   | Type    | Description                  |
| ----------- | ------- | ---------------------------- |
| worldVector | Vector2 | Parameter of getScreenVector |

Returns Vector2

---

# class Line

## length (public member function of Line)
Returns float

## intersectionWith (public member function of Line)
| Parameter | Type | Description                   |
| --------- | ---- | ----------------------------- |
| other     | Line | Parameter of intersectionWith |

Returns Vector2

## toString (public member function of Line)
Returns string

---

# class Rect

## left (public member function of Rect)
Returns float

## right (public member function of Rect)
Returns float

## top (public member function of Rect)
Returns float

## bottom (public member function of Rect)
Returns float

## contains (public member function of Rect)
| Parameter | Type    | Description           |
| --------- | ------- | --------------------- |
| position  | Vector2 | Parameter of contains |

Returns bool

## intersectsWith (public member function of Rect)
| Parameter | Type    | Description                 |
| --------- | ------- | --------------------------- |
| position  | Vector2 | Parameter of intersectsWith |
| size      | Vector2 | Parameter of intersectsWith |

Returns bool

---

# class Grid

## get (public member function of Grid)
| Parameter | Type       | Description                      |
| --------- | ---------- | -------------------------------- |
| position  | IntVector2 | The vector to get the value from |

Returns T

## get (public member function of Grid)
| Parameter | Type | Description                      |
| --------- | ---- | -------------------------------- |
| x         | int  | The column to get the value from |
| y         | int  | The row to get the value from    |

Returns T

## set (public member function of Grid)
| Parameter | Type | Description                    |
| --------- | ---- | ------------------------------ |
| x         | int  | The column of the value to set |
| y         | int  | The row of the value to set    |
| value     | T    | The value to set               |

Returns void

## set (public member function of Grid)
| Parameter | Type       | Description                           |
| --------- | ---------- | ------------------------------------- |
| position  | IntVector2 | The grid position of the value to set |
| value     | T          | The value to set                      |

Returns void

## each (public member function of Grid)
Do something for each item in the grid

| Parameter | Type                              | Description                     |
| --------- | --------------------------------- | ------------------------------- |
| do        | void(T it, IntVector2 pos, int i) | Do this for each item in a list |

Returns void

## each (public member function of Grid)
| Parameter    | Type                              | Description                     |
| ------------ | --------------------------------- | ------------------------------- |
| includeEmpty | bool                              | Include items that are null     |
| do           | void(T it, IntVector2 pos, int i) | Do this for each item in a list |

Returns void

## select (public member function of Grid)
Return a list that contains the selected field or expression for each item

| Parameter | Type         | Description         |
| --------- | ------------ | ------------------- |
| selector  | TValue(T it) | Parameter of select |

Returns TValue[]

## flatten (public member function of Grid)
Get the selected field or expression for each item and flattens the result

| Parameter | Type           | Description          |
| --------- | -------------- | -------------------- |
| selector  | TValue[](T it) | Parameter of flatten |

Returns TValue[]

## all (public member function of Grid)
Returns true if the given condition is true for all items in the list

Returns bool

## all (public member function of Grid)
Returns true if the given condition is true for all items in the list

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| predicate | bool(T a) | The condition to check |

Returns bool

## any (public member function of Grid)
Returns true if the given condition is true for any item in the list

Returns bool

## any (public member function of Grid)
Returns true if the given condition is true for any item in the list

| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| predicate | bool(T a) | The condition to check |

Returns bool

## where (public member function of Grid)
| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| predicate | bool(T a) | The condition to check |

Returns T[]

## count (public member function of Grid)
| Parameter | Type      | Description            |
| --------- | --------- | ---------------------- |
| predicate | bool(T a) | The condition to check |

Returns int

## isValid (public member function of Grid)
| Parameter | Type       | Description          |
| --------- | ---------- | -------------------- |
| pos       | IntVector2 | Parameter of isValid |

Returns bool

## withMin (public member function of Grid)
| Parameter | Type       | Description          |
| --------- | ---------- | -------------------- |
| selector  | float(T a) | Parameter of withMin |
| threshold | float      | Parameter of withMin |

Returns T

---

# class Texture
A texture that can be loaded into video memory

## isAvailable (public member function of Texture)
Returns bool

## setSize (public member function of Texture)
| Parameter | Type    | Description          |
| --------- | ------- | -------------------- |
| size      | Vector2 | Parameter of setSize |

Returns void

## modify (public member function of Texture)
| Parameter  | Type     | Description                                                                        |
| ---------- | -------- | ---------------------------------------------------------------------------------- |
| visibleFor | Player[] | Only make any modification for this player or list of players                      |
| do         | void()   | This block of code will draw on the created image instead of drawing on the screen |

Returns void

---

# static class graphics
Draw on the screen

## setup (static public member function of graphics)
| Parameter     | Type    | Description        |
| ------------- | ------- | ------------------ |
| referenceSize | Vector2 | Parameter of setup |

Returns Promise<null>

## alignmentDescription (static public member function of graphics)
| Parameter | Type                | Description                       |
| --------- | ------------------- | --------------------------------- |
| align     | HorizontalAlignment | Parameter of alignmentDescription |
| valign    | VerticalAlignment   | Parameter of alignmentDescription |

Returns string

## drawImage (global function)
| Parameter  | Type                | Description                                                                                   |
| ---------- | ------------------- | --------------------------------------------------------------------------------------------- |
| image      | Image               | The image to draw. PNG images in the "media" folder will automatically show up here           |
| position   | Vector2             | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size       | Vector2             | A float scales the image to that width keeping the aspect ratio, a vector stretches the image |
| visibleFor | Player[]            | Only this player or list of players will see the image                                        |
| frame      | int                 | The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)       |
| layer      | int                 | Higher layers are drawn in front of lower layers                                              |
| alpha      | float               | The opacity of the image (0: fully transparent, 1: fully visible)                             |
| color      | Color               | Tint the image with this color                                                                |
| align      | HorizontalAlignment | The horizontal alignment of the image                                                         |
| valign     | VerticalAlignment   | The vertical alignment of the image                                                           |
| location   | SourceCodeLocation  | Parameter of drawImage                                                                        |

Returns void

## drawImage (global function)
Draw an image and rotate it or flip it vertially or horizontally.


Example: Draw the image "Idle" at the position {0,0} and rotate it by 45 degrees.
```
Player
    tick
        drawImage Idle, position:{0,0}, angle:45°
```

| Parameter  | Type               | Description                                                                                   |
| ---------- | ------------------ | --------------------------------------------------------------------------------------------- |
| image      | Image              | The image to draw. PNG images in the "media" folder will automatically show up here           |
| position   | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size       | Vector2            | A float scales the image to that width keeping the aspect ratio, a vector stretches the image |
| visibleFor | Player[]           | Only this player or list of players will see the image                                        |
| frame      | int                | The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)       |
| layer      | int                | Higher layers are drawn in front of lower layers                                              |
| alpha      | float              | The opacity of the image (0: fully transparent, 1: fully visible)                             |
| color      | Color              | Tint the image with this color                                                                |
| angle      | float              | Rotate the image by this angle in radians (one full rotation is 2*pi)                         |
| flipX      | bool               | Mirror the image horizontally                                                                 |
| flipY      | bool               | Mirror the image vertically                                                                   |
| location   | SourceCodeLocation | Parameter of drawImage                                                                        |

Returns void

## drawImage (global function)
Animate of sequence of images with a given number of frames per second.


Example: We place a sequence of images called "Walk0.png", "Walk1.png", "Walk2.png", etc... in the "media" folder. Then, we play this sequence with 10 frames per second.
```
Player
    tick
        drawImage Walk, position:{0,0}, framesPerSecond:10
```

| Parameter       | Type               | Description                                                                                   |
| --------------- | ------------------ | --------------------------------------------------------------------------------------------- |
| image           | Image              | The image to draw. PNG images in the "media" folder will automatically show up here           |
| position        | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size            | Vector2            | A float scales the image to that width keeping the aspect ratio, a vector stretches the image |
| visibleFor      | Player[]           | Only this player or list of players will see the image                                        |
| framesPerSecond | int                | Animate a sequence of images (for example "Walk0.png", "Walk1.png", ...)                      |
| layer           | int                | Higher layers are drawn in front of lower layers                                              |
| alpha           | float              | The opacity of the image (0: fully transparent, 1: fully visible)                             |
| color           | Color              | Tint the image with this color                                                                |
| location        | SourceCodeLocation | Parameter of drawImage                                                                        |

Returns void

## drawImage (global function)
Draw an image, animate it and flip it horizontally or vertically.


Example: We place a sequence of images called "Walk0.png", "Walk1.png", "Walk2.png", etc... in the "media" folder. Then, we play this sequence with 10 frames per second and flip each frame horizontally.
```
Player
    tick
        drawImage Walk, position:{0,0}, framesPerSecond:10, flipX:true
```

| Parameter       | Type               | Description                                                                                   |
| --------------- | ------------------ | --------------------------------------------------------------------------------------------- |
| image           | Image              | The image to draw. PNG images in the "media" folder will automatically show up here           |
| position        | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size            | Vector2            | A float scales the image to that width keeping the aspect ratio, a vector stretches the image |
| visibleFor      | Player[]           | Only this player or list of players will see the image                                        |
| framesPerSecond | int                | Animate a sequence of images (for example "Walk0.png", "Walk1.png", ...)                      |
| layer           | int                | Higher layers are drawn in front of lower layers                                              |
| alpha           | float              | The opacity of the image (0: fully transparent, 1: fully visible)                             |
| color           | Color              | Tint the image with this color                                                                |
| angle           | float              | Rotate the image by this angle in radians (one full rotation is 2*pi)                         |
| flipX           | bool               | Mirror the image horizontally                                                                 |
| flipY           | bool               | Mirror the image vertically                                                                   |
| location        | SourceCodeLocation | Parameter of drawImage                                                                        |

Returns void

## drawImage (global function)
| Parameter         | Type                | Description                                                                                   |
| ----------------- | ------------------- | --------------------------------------------------------------------------------------------- |
| image             | Image               | The image to draw. PNG images in the "media" folder will automatically show up here           |
| position          | Vector2             | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size              | Vector2             | A float scales the image to that width keeping the aspect ratio, a vector stretches the image |
| visibleFor        | Player[]            | Only this player or list of players will see the image                                        |
| clickableBy       | Player[]            | Only this player or list of players can touch or click the image                              |
| frame             | int                 | The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)       |
| layer             | int                 | Higher layers are drawn in front of lower layers                                              |
| alpha             | float               | The opacity of the image (0: fully transparent, 1: fully visible)                             |
| color             | Color               | Tint the image with this color                                                                |
| align             | HorizontalAlignment | The horizontal alignment of the image                                                         |
| valign            | VerticalAlignment   | The vertical alignment of the image                                                           |
| clickableMargin   | Vector2             | The margin around the image within which it is clickable                                      |
| showClickableArea | bool                | Highlight the clickable area for debugging                                                    |
| hotkey            | Key                 | This keyboard shortcut will execute the onClick handler                                       |
| onClick           | void(Touch touch)   | Execute this code when the user touches or clicks the image or presses the hotkey             |
| location          | SourceCodeLocation  | Parameter of drawImage                                                                        |

Returns void

## drawImage (global function)
Draw an image and execute code when the player touches or clicks the image.


Example: If the current player instance clicks the image or 16 pixels around it, we print the exact position that was clicked. If other players will click the image, nothing will happen.
```
Player
    tick
        drawImage Idle, position:{0,0}, clickableMargin:{16,16}, clickableBy:me
            print "The image was clicked at {touch.position}"
```

| Parameter         | Type               | Description                                                                                   |
| ----------------- | ------------------ | --------------------------------------------------------------------------------------------- |
| image             | Image              | The image to draw. PNG images in the "media" folder will automatically show up here           |
| position          | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size              | Vector2            | A float scales the image to that width keeping the aspect ratio, a vector stretches the image |
| visibleFor        | Player[]           | Only this player or list of players will see the image                                        |
| clickableBy       | Player[]           | Only this player or list of players can touch or click the image                              |
| frame             | int                | The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)       |
| layer             | int                | Higher layers are drawn in front of lower layers                                              |
| alpha             | float              | The opacity of the image (0: fully transparent, 1: fully visible)                             |
| color             | Color              | Tint the image with this color                                                                |
| angle             | float              | Rotate the image by this angle in radians (one full rotation is 2*pi)                         |
| flipX             | bool               | Mirror the image horizontally                                                                 |
| flipY             | bool               | Mirror the image vertically                                                                   |
| clickableMargin   | Vector2            | The margin around the image within which it is clickable                                      |
| showClickableArea | bool               | Highlight the clickable area for debugging                                                    |
| hotkey            | Key                | This keyboard shortcut will execute the onClick handler                                       |
| onClick           | void(Touch touch)  | Execute this code when the user touches or clicks the image or presses the hotkey             |
| location          | SourceCodeLocation | Parameter of drawImage                                                                        |

Returns void

## drawSlicedImage (global function)
| Parameter  | Type                | Description                           |
| ---------- | ------------------- | ------------------------------------- |
| image      | Image               | Parameter of drawSlicedImage          |
| position   | Vector2             | Parameter of drawSlicedImage          |
| size       | Vector2             | Parameter of drawSlicedImage          |
| visibleFor | Player[]            | Parameter of drawSlicedImage          |
| frame      | int                 | Parameter of drawSlicedImage          |
| layer      | int                 | Parameter of drawSlicedImage          |
| alpha      | float               | Parameter of drawSlicedImage          |
| color      | Color               | Parameter of drawSlicedImage          |
| leftSlice  | float               | Parameter of drawSlicedImage          |
| rightSlice | float               | Parameter of drawSlicedImage          |
| align      | HorizontalAlignment | The horizontal alignment of the image |
| valign     | VerticalAlignment   | The vertical alignment of the image   |
| location   | SourceCodeLocation  | Parameter of drawSlicedImage          |

Returns void

## drawText (global function)
Draw text on the screen.


Example: If the current player instance is the winner, we show "You've won!" to the current player instance. To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder and it will automatically be imported.
```
Player
    tick
        if winner == me
            drawText "You've won!", size:100, color:Black, font:OpenSans, visibleFor:me
```

| Parameter         | Type                | Description                                                                                    |
| ----------------- | ------------------- | ---------------------------------------------------------------------------------------------- |
| text              | string              | A string or anything that can be converted into a string (for example, an interger or a float) |
| position          | Vector2             | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right    |
| size              | Vector2             | The font size of the text                                                                      |
| color             | Color               | The color of the text                                                                          |
| align             | HorizontalAlignment | The horizontal alignment of the text                                                           |
| valign            | VerticalAlignment   | The vertical alignment of the text                                                             |
| style             | FontStyle           | Whether the text should be bold or normal style                                                |
| font              | Font                | To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder                |
| outlineColor      | Color               | The color of the outline around the text                                                       |
| outlineWidth      | int                 | The width of the outline around the text in pixels                                             |
| layer             | int                 | Higher layers are drawn in front of lower layers                                               |
| alpha             | float               | The opacity of the text (0: fully transparent, 1: fully visible)                               |
| angle             | float               | Rotate the image by this angle in radians (one full rotation is 2*pi)                          |
| visibleFor        | Player[]            | Only this player or list of players will see the text                                          |
| clickableBy       | Player[]            | Only this player or list of players can touch or click the text                                |
| clickableMargin   | Vector2             | The margin around the text within which it is clickable                                        |
| showClickableArea | bool                | Highlight the clickable area for debugging                                                     |
| hotkey            | Key                 | This keyboard shortcut will execute the onClick handler                                        |
| overflow          | TextOverflow        | Should text that exceeds the max width be hidden or wrapped?                                   |
| maxWidth          | float               | The maximum width of line when overflow is set 'Scale', 'Hidden' or 'Wrap'                     |
| lineHeight        | float               | The height of each line when overflow is set to 'Wrap'                                         |
| onClick           | void(Touch touch)   | Execute this code when the user touches or clicks the text or presses the hotkey               |
| location          | SourceCodeLocation  | Parameter of drawText                                                                          |

Returns float

## drawTextWithHighlight (global function)
Draw text with segments highlighted which are surrounded by given characters.


Example:
```
drawTextWithHighlight "Kate se «da vuelta».", position:{0,0}, highlights:[
    { "«"  to: "»"  color:White, backgroundColor:app.primaryColor, padding:{12,3}, cornerRadius:12 }
    { "\"" to: "\"" color:White, backgroundColor:app.helpingColor, padding:{12,3}, cornerRadius:12 }
]
```

| Parameter         | Type                | Description                                                                                    |
| ----------------- | ------------------- | ---------------------------------------------------------------------------------------------- |
| text              | string              | A string or anything that can be converted into a string (for example, an interger or a float) |
| position          | Vector2             | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right    |
| highlights        | TextHighlight[]     | Sepecifies which characters surround a sections and how it should be highlighted               |
| size              | Vector2             | The font size of the text                                                                      |
| color             | Color               | The color of the text                                                                          |
| align             | HorizontalAlignment | The horizontal alignment of the text                                                           |
| valign            | VerticalAlignment   | The vertical alignment of the text                                                             |
| style             | FontStyle           | Whether the text should be bold or normal style                                                |
| font              | Font                | To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder                |
| outlineColor      | Color               | The color of the outline around the text                                                       |
| outlineWidth      | int                 | The width of the outline around the text in pixels                                             |
| layer             | int                 | Higher layers are drawn in front of lower layers                                               |
| alpha             | float               | The opacity of the text (0: fully transparent, 1: fully visible)                               |
| angle             | float               | Rotate the image by this angle in radians (one full rotation is 2*pi)                          |
| visibleFor        | Player[]            | Only this player or list of players will see the text                                          |
| clickableBy       | Player[]            | Only this player or list of players can touch or click the text                                |
| clickableMargin   | Vector2             | The margin around the text within which it is clickable                                        |
| showClickableArea | bool                | Highlight the clickable area for debugging                                                     |
| hotkey            | Key                 | This keyboard shortcut will execute the onClick handler                                        |
| overflow          | TextOverflow        | Should text that exceeds the max width be hidden or wrapped?                                   |
| maxWidth          | float               | The maximum width of line when overflow is set 'Scale', 'Hidden' or 'Wrap'                     |
| lineHeight        | float               | The height of each line when overflow is set to 'Wrap'                                         |
| onClick           | void(Touch touch)   | Execute this code when the user touches or clicks the text or presses the hotkey               |
| location          | SourceCodeLocation  | Parameter of drawTextWithHighlight                                                             |

Returns float

## drawCircularText (global function)
Draw text around a circle.


Example: Draw text around a circular video
```
drawVideo me, position:pos, shape:Circle, size:radius*2-40
drawCircularText "Made up by", position:pos, size:30, radius, angle:-pi
```

| Parameter  | Type               | Description                                                                                    |
| ---------- | ------------------ | ---------------------------------------------------------------------------------------------- |
| text       | string             | A string or anything that can be converted into a string (for example, an interger or a float) |
| position   | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right    |
| size       | float              | The font size of the text                                                                      |
| color      | Color              | The color of the text                                                                          |
| font       | Font               | To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder                |
| layer      | int                | Higher layers are drawn in front of lower layers                                               |
| radius     | float              | The radius of the circle to draw the text around                                               |
| angle      | float              | The angle of the center of the text in turn (0: top, 0.25: right, 0.5: bottom, -0.25: left)    |
| spacing    | float              | The spacing between the letters of the text                                                    |
| visibleFor | Player[]           | Only this player or list of players will see the text                                          |
| location   | SourceCodeLocation | Parameter of drawCircularText                                                                  |

Returns void

## drawButton (global function)
Draw a button made up of an image and a text and execute code when its touched or clicked.


Example: If the current player instance touches or clicks the image or 16 pixels around it, we print the exact position that was touched. If other players will touch the image, nothing will happen.
```
Player
    bool done
    tick
        if not done
            drawButton "I'm done", image:Button, visibleFor:me
                done = true
```

| Parameter         | Type               | Description                                                                                   |
| ----------------- | ------------------ | --------------------------------------------------------------------------------------------- |
| image             | Image              | The image of the button. PNG images in the "media" folder will automatically show up here     |
| text              | string             | The text of the button                                                                        |
| position          | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size              | Vector2            | A float scales the image to that width keeping the aspect ratio, a vector stretches the image |
| frame             | int                | The frame from a sequence of images (for example "Button0.png", "Button1.png", ...)           |
| textColor         | Color              | The color of the text                                                                         |
| textSize          | int                | The font size in pixels                                                                       |
| textOffset        | Vector2            | Draw the text at this offset to the image                                                     |
| clickableMargin   | Vector2            | The margin around the button within which it is clickable                                     |
| showClickableArea | bool               | Highlight the clickable area for debugging                                                    |
| scaleOnHover      | float              | Scale the button by this factor when the mouse hovers over the button                         |
| frameOnHover      | int                | Draw this frame when the mouse hovers over the button                                         |
| textColorOnHover  | Color              | Draw the text in this color when the mouse hovers over the button                             |
| accentImage       | Image              | Draw this image tited with the accent color on top of the button                              |
| accentColor       | Color              | Tint the accent image with this color, defaults to the color of the local player              |
| visibleFor        | Player[]           | Only this player or list of players will see the button                                       |
| clickableBy       | Player[]           | Only this player or list of players can touch or click the button                             |
| hotkey            | Key                | This keyboard shortcut will execute the onClick handler                                       |
| layer             | int                | Higher layers are drawn in front of lower layers                                              |
| alpha             | float              | The opacity of the button (0: fully transparent, 1: fully visible)                            |
| enabled           | bool               | When not enabled, the button isn't clickable and is drawn transparently (50% by default)      |
| alphaWhenDisabled | float              | The opacity of the button will be multiplied with this factor when its disabled               |
| onClick           | void(Touch touch)  | Execute this code when the user touches or clicks the button or presses the hotkey            |
| location          | SourceCodeLocation | Parameter of drawButton                                                                       |

Returns void

## drawRectangle (global function)
Draw a rectangle on the screen.


Example: Draw a white rectangle with a black outline that is 8 pixels wide.
```
app
    tick
        drawRectangle size:{500,100}, color:White, outlineColor:Black, outlineWidth:8
```

| Parameter    | Type                | Description                                                                                 |
| ------------ | ------------------- | ------------------------------------------------------------------------------------------- |
| position     | Vector2             | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right |
| size         | Vector2             | The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle   |
| color        | Color               | The color of the area within the rectangle                                                  |
| outlineColor | Color               | The color of the outline around the rectangle                                               |
| outlineWidth | int                 | The width of the outline around the rectangle in pixels                                     |
| visibleFor   | Player[]            | Only this player or list of players will see the rectangle                                  |
| layer        | int                 | Higher layers are drawn in front of lower layers                                            |
| alpha        | float               | The opacity of the rectangle (0: fully transparent, 1: fully visible)                       |
| align        | HorizontalAlignment | The horizontal alignment of the rectangle                                                   |
| valign       | VerticalAlignment   | The vertical alignment of the rectangle                                                     |
| location     | SourceCodeLocation  | Parameter of drawRectangle                                                                  |

Returns void

## drawRoundedRectangle (global function)
Draw a rectangle with rounded corners on the screen.


Example: Draw a rounded rectangle at {500,100} with a black outline that is 8 pixels wide and has a corner radius of 20 pixels.
```
app
    tick
        drawRoundedRectangle size:{500,100}, outlineColor:Black, outlineWidth:8, radius:20
```

| Parameter    | Type                | Description                                                                                 |
| ------------ | ------------------- | ------------------------------------------------------------------------------------------- |
| position     | Vector2             | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right |
| size         | Vector2             | The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle   |
| radius       | int                 | The radius of the rounded corners                                                           |
| color        | Color               | The color of the area within the rectangle                                                  |
| outlineColor | Color               | The color of the outline around the rectangle                                               |
| outlineWidth | int                 | The width of the outline around the rectangle in pixels                                     |
| visibleFor   | Player[]            | Only this player or list of players will see the rectangle                                  |
| layer        | int                 | Higher layers are drawn in front of lower layers                                            |
| alpha        | float               | The opacity of the rectangle (0: fully transparent, 1: fully visible)                       |
| align        | HorizontalAlignment | The horizontal alignment of the rectangle                                                   |
| valign       | VerticalAlignment   | The vertical alignment of the rectangle                                                     |

Returns void

## drawCircle (global function)
Draw a circle on the screen.


Example: Draw a white circle with a blue outline and a diameter of 150 pixels.
```
app
    tick
        drawCircle color:White, outlineColor:#118ab2, outlineWidth:12, size:150
```


Example: Draw a white circle with a blue outline and a width of 200 pixels and a height of 100 pixels.
```
app
    tick
        drawCircle color:White, outlineColor:#118ab2, outlineWidth:12, size:{200, 100}
```


Example: Draw an arc of 180 degrees (half a circle) starting at an angle of 0 degrees.
```
app
    tick
        drawCircle outlineColor:#118ab2, outlineWidth:24, size:100, startAngle:0°, angle:180°
```

| Parameter    | Type               | Description                                                                                 |
| ------------ | ------------------ | ------------------------------------------------------------------------------------------- |
| position     | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right |
| size         | Vector2            | The size of the circle, use a float to draw a circle, use a vector draw an ellipse          |
| color        | Color              | The color of the area within the circle                                                     |
| outlineColor | Color              | The color of the outline around the circle                                                  |
| outlineWidth | int                | The width of the outline around the circle in pixels                                        |
| startAngle   | float              | Draw an arc with this start angle in radians, measured from the positive x-axis             |
| angle        | float              | Draw an arc with this angle in radians (one full rotation is 2*pi)                          |
| direction    | RotationDirection  | The circle is drawn in this direction                                                       |
| visibleFor   | Player[]           | Only this player or list of players will see the circle                                     |
| layer        | int                | Higher layers are drawn in front of lower layers                                            |
| alpha        | float              | The opacity of the circle (0: fully transparent, 1: fully visible)                          |
| location     | SourceCodeLocation | Parameter of drawCircle                                                                     |

Returns void

## drawLine (global function)
Draw a line on the screen.


Example: Draw a blue line from {-100,0} to {100,0}
```
app
    tick
        drawLine {-100,0} to {100,0} color:Blue
```

| Parameter  | Type     | Description                                                      |
| ---------- | -------- | ---------------------------------------------------------------- |
| from       | Vector2  | The point to start the line from                                 |
| to         | Vector2  | The point to draw the line to                                    |
| color      | Color    | The color of the line                                            |
| width      | int      | The width of the line in pixels                                  |
| visibleFor | Player[] | Only this player or list of players will see the line            |
| layer      | int      | Higher layers are drawn in front of lower layers                 |
| alpha      | float    | The opacity of the line (0: fully transparent, 1: fully visible) |

Returns void

## drawLines (global function)
Draw a continuous stroke of lines on the screen.


Example: Draw a blue stroke of lines through {-50,0}, {0,50} and {100,-50} with a width of 32 pixels
```
app
    tick
        drawLines [{-50,0}, {0,50}, {100,-50}] color:Blue width:32
```

| Parameter  | Type      | Description                                                       |
| ---------- | --------- | ----------------------------------------------------------------- |
| points     | Vector2[] | A list of points for the line                                     |
| position   | Vector2   | The position all points are relative to                           |
| color      | Color     | The color of the line                                             |
| width      | int       | The width of the line in pixels                                   |
| smooth     | bool      | Smooth the corners of the line                                    |
| visibleFor | Player[]  | Only this player or list of players will see the line             |
| layer      | int       | Higher layers are drawn in front of lower layers                  |
| alpha      | float     | The opacity of the lines (0: fully transparent, 1: fully visible) |

Returns void

## drawPolygon (global function)
Draw a polygon on the screen.


Example: Draw a white polygon with the corners {-50,50}, {0,-50} and {50,50} and a blue outline
```
app
    tick
        drawPolygon [{-50,50}, {0,-50}, {50,50}] color:White outlineColor:Blue
```

| Parameter    | Type      | Description                                                         |
| ------------ | --------- | ------------------------------------------------------------------- |
| points       | Vector2[] | A list of points for the polygon                                    |
| position     | Vector2   | The position all polygon points are relative to                     |
| color        | Color     | The color of the area within the polygon                            |
| outlineColor | Color     | The color of the outline around the polygon                         |
| outlineWidth | int       | The width of the outline around the polygon in pixels               |
| smooth       | bool      | Smooth the corners of the polygon                                   |
| visibleFor   | Player[]  | Only this player or list of players will see the polygon            |
| layer        | int       | Higher layers are drawn in front of lower layers                    |
| alpha        | float     | The opacity of the polygon (0: fully transparent, 1: fully visible) |

Returns void

## drawVideo (global function)
Draw the video feed showing the given player on the screen.


Example: Draw the video feed for the current player instance with a width of 200 pixels
```
Player
    tick
        drawVideo me, size:200
```

| Parameter  | Type               | Description                                                                                   |
| ---------- | ------------------ | --------------------------------------------------------------------------------------------- |
| player     | Player             | Draw the video showing this player                                                            |
| position   | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size       | Vector2            | A float scales the image to that width keeping the aspect ratio, a vector stretches the video |
| shape      | VideoShape         | Choose whether the video should be drawn as a rectangle, a square or a circle                 |
| visibleFor | Player[]           | Only this player or list of players will see the video                                        |
| location   | SourceCodeLocation | Parameter of drawVideo                                                                        |

Returns void

## drawPointer (global function)
Draw a pointer at the mouse position of the given player on the screen.


Example: Draw a pointer at the mouce position of the current player instance
```
Player
    tick
        drawPointer me
```

| Parameter | Type             | Description                                                                            |
| --------- | ---------------- | -------------------------------------------------------------------------------------- |
| player    | Player           | Show the mouse position of this player                                                 |
| mode      | ShowPointersMode | Choose whether you want to draw the pointers for local players, remote players or both |
| color     | Color            | The color of the pointer. If this is left out, the player color is used                |

Returns void

## drawTexture (global function)
Draw a texture which you can dynamically load from anywhere


Example: Dynamically load the file "Character.png" from the assets folder and draw it on the screen with a width of 100 pixels.
```
app
    Texture character = {"Character.png"}
    tick
        drawTexture character, size:100
```

| Parameter  | Type     | Description                                                                                   |
| ---------- | -------- | --------------------------------------------------------------------------------------------- |
| texture    | Texture  | The texture to draw                                                                           |
| position   | Vector2  | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right   |
| size       | Vector2  | A float scales the image to that width keeping the aspect ratio, a vector stretches the image |
| visibleFor | Player[] | Only this player or list of players will see the texture                                      |
| layer      | int      | Higher layers are drawn in front of lower layers                                              |
| alpha      | float    | The opacity of the texture (0: fully transparent, 1: fully visible)                           |
| color      | Color    | Tint the texture with this color                                                              |

Returns void

## drawTexture (global function)
Draw part of a texture which you can dynamically load from anywhere.


Example: Dynamically load the file "Character.png" from the assets folder, take a part of this texture with a size of {16,32} centered around {8,0} and draw it on the screen with a size of {100,200}.
```
app
    Texture character = {"Character.png"}
    tick
        drawTexture character, sourcePosition:{8,0}, sourceSize:{16,32}, size:{100,200}
```

| Parameter      | Type     | Description                                                         |
| -------------- | -------- | ------------------------------------------------------------------- |
| texture        | Texture  | The texture to draw                                                 |
| position       | Vector2  | The target position to draw to                                      |
| size           | Vector2  | The size of the target area to draw to                              |
| sourcePosition | Vector2  | The center of the area of the source texture to draw from           |
| sourceSize     | Vector2  | The size of the area of the source texture to draw from             |
| visibleFor     | Player[] | Only this player or list of players will see the texture            |
| layer          | int      | Higher layers are drawn in front of lower layers                    |
| alpha          | float    | The opacity of the texture (0: fully transparent, 1: fully visible) |
| color          | Color    | Tint the texture with this color                                    |

Returns void

## drawImageFromUrl (global function)
| Parameter      | Type     | Description                                                         |
| -------------- | -------- | ------------------------------------------------------------------- |
| url            | string   | The texture to draw                                                 |
| position       | Vector2  | The target position to draw to                                      |
| size           | Vector2  | The size of the target area to draw to                              |
| sourcePosition | Vector2  | The center of the area of the source texture to draw from           |
| sourceSize     | Vector2  | The size of the area of the source texture to draw from             |
| visibleFor     | Player[] | Only this player or list of players will see the texture            |
| layer          | int      | Higher layers are drawn in front of lower layers                    |
| alpha          | float    | The opacity of the texture (0: fully transparent, 1: fully visible) |
| color          | Color    | Tint the texture with this color                                    |

Returns void

## clearRectangle (global function)
Clear all pixels within a rectangle.


Example: Clear all pixels within a rectangle with a width of 100 pixels and a height of 100 pixels
```
app
    tick
        clearRectangle position:{0,0} size:{100,100}
```

| Parameter  | Type                | Description                                                                                 |
| ---------- | ------------------- | ------------------------------------------------------------------------------------------- |
| position   | Vector2             | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right |
| size       | Vector2             | The size of the rectangle, use a float to clear a square, use a vector to clear a rectangle |
| visibleFor | Player[]            | Only clear the rectangle for this player or list of players                                 |
| layer      | int                 | Higher layers are drawn in front of lower layers                                            |
| align      | HorizontalAlignment | The horizontal alignment of the rectangle                                                   |
| valign     | VerticalAlignment   | The vertical alignment of the rectangle                                                     |

Returns void

## move (static public member function of graphics)
Move all drawing operations in a block of code by a given vector.


Example: Move an image and a text 500 pixels to the right
```
app
    tick
        graphics.move {500,0}
            drawText "OK"
            drawImage Button
```

| Parameter | Type    | Description                                            |
| --------- | ------- | ------------------------------------------------------ |
| distance  | Vector2 | The distance to move                                   |
| code      | void()  | All drawing operations within this block will be moved |

Returns void

## rotate (static public member function of graphics)
Rotate all drawing operations in a block of code by a given angle


Example: Rotate an image and a text by 20 degrees.
```
app
    tick
        graphics.rotate 20°
            drawText "OK"
            drawImage Button
```

| Parameter | Type   | Description                                                      |
| --------- | ------ | ---------------------------------------------------------------- |
| angle     | float  | The angle in radians (one full rotation is 2*pi)                 |
| code      | void() | All drawing operations within this block of code will be rotated |

Returns void

## scale (static public member function of graphics)
Scale all drawing operations in a block of code by a given factor.


Example: Scale an image and a text by to twice their original size.
```
app
    tick
        graphics.scale 2
            drawText "OK"
            drawImage Button
```

| Parameter | Type   | Description                                                     |
| --------- | ------ | --------------------------------------------------------------- |
| factor    | float  | The factor to scale by                                          |
| code      | void() | All drawing operations within this block of code will be scaled |

Returns void

## transform (static public member function of graphics)
Move, rotate and scale all drawing operations in a block of code.


Example: Move an image an a text 500 pixels to the right, rotate them by 90 degrees and scale them to half their original size.
```
app
    tick
        graphics.transform move:{500,0} rotate:90° scale:.5
            drawText "OK"
            drawImage Button
```

| Parameter | Type    | Description                                                                        |
| --------- | ------- | ---------------------------------------------------------------------------------- |
| move      | Vector2 | The distance to move                                                               |
| rotate    | float   | The angle in radians (one full rotation is 2*pi)                                   |
| scale     | float   | The factor to scale by                                                             |
| code      | void()  | All drawing operations within this block of code will be moved, rotated and scaled |

Returns void

## applyMatrix (static public member function of graphics)
Apply a matrix to all drawing operations in a block of code.


Example: Apply the matrix {1 .3 .7 1 0 0} to a text and an image
```
app
    tick
        graphics.applyMatrix {1 .3 .7 1 0 0}
            drawText "OK"
            drawImage Button
```

| Parameter | Type     | Description                                                                   |
| --------- | -------- | ----------------------------------------------------------------------------- |
| matrix    | Matrix2D | The matrix to apply                                                           |
| code      | void()   | The matrix will be applied to all drawing operation within this block of code |

Returns void

## clip (static public member function of graphics)
For all drawing operations in a block of code, only pixels inside a given polygon are drawn.


Example: Draw three circles and clip all of them within the polygon with the corners {0,-80}, {-100,80}, {100,80}
```
app
    tick
        graphics.clip points:[{0,-80}, {-100,80}, {100,80}]
            drawCircle {   0, -80}, size:150, color:Blue
            drawCircle {-100,  80}, size:150, color:Blue
            drawCircle { 100,  80}, size:150, color:Blue
```


Example: Draw three circles and clip two of them within the polygon with the corners {0,-80}, {-100,80}, {100,80}
```
app
    tick
        graphics.clip points:[{0,-80}, {-100,80}, {100,80}]
            drawCircle {   0, -80}, size:150, color:Blue
            drawCircle {-100,  80}, size:150, color:Blue
        drawCircle { 100,  80}, size:150, color:Blue
```

| Parameter | Type      | Description                                                      |
| --------- | --------- | ---------------------------------------------------------------- |
| points    | Vector2[] | A list of points that define the clipping area                   |
| position  | Vector2   | The position all points are relative to                          |
| show      | bool      | Show the clipping area for debugging                             |
| code      | void()    | All drawing operations within this block of code will be clipped |

Returns void

## visibleFor (static public member function of graphics)
All drawing operations in a block of code will only be visible to certain players.


Example: Draw a button that is only visible to the current player instance
```
Player
    tick
        visibleFor me
            drawText "OK"
            drawImage Button
```

| Parameter | Type     | Description                                                                            |
| --------- | -------- | -------------------------------------------------------------------------------------- |
| player    | Player[] | Only this player or list of players will see the drawing operations                    |
| code      | void()   | All drawing operations in this block of code will only be visible to the given players |

Returns Player[]

## color (static public member function of graphics)
The default color for all drawing operations

Returns Color

## color (static public member function of graphics)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| color     | Color | Parameter of color |

Returns Color

## color (static public member function of graphics)
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| color     | Color  | Parameter of color |
| code      | void() | Parameter of color |

Returns Color

## font (static public member function of graphics)
The default font for all drawing operations

Returns Font

## font (static public member function of graphics)
| Parameter | Type | Description       |
| --------- | ---- | ----------------- |
| font      | Font | Parameter of font |

Returns Font

## font (static public member function of graphics)
| Parameter | Type   | Description       |
| --------- | ------ | ----------------- |
| font      | Font   | Parameter of font |
| code      | void() | Parameter of font |

Returns Font

## fontSize (static public member function of graphics)
The default font size for all drawing operations

Returns int

## fontSize (static public member function of graphics)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| fontSize  | int  | Parameter of fontSize |

Returns int

## fontSize (static public member function of graphics)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| fontSize  | int    | Parameter of fontSize |
| code      | void() | Parameter of fontSize |

Returns int

## lineWidth (static public member function of graphics)
The default line width for all drawing operations

Returns int

## lineWidth (static public member function of graphics)
| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| lineWidth | int  | Parameter of lineWidth |

Returns int

## lineWidth (static public member function of graphics)
| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| lineWidth | int    | Parameter of lineWidth |
| code      | void() | Parameter of lineWidth |

Returns int

## alpha (static public member function of graphics)
The default line width for all drawing operations

Returns float

## alpha (static public member function of graphics)
| Parameter | Type  | Description        |
| --------- | ----- | ------------------ |
| alpha     | float | Parameter of alpha |

Returns float

## alpha (static public member function of graphics)
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| alpha     | float  | Parameter of alpha |
| code      | void() | Parameter of alpha |

Returns float

## getTextWidth (global function)
Measures the width of a string in pixels

| Parameter | Type      | Description                                     |
| --------- | --------- | ----------------------------------------------- |
| text      | string    | The text to get the width of                    |
| size      | Vector2   | The font size of the text                       |
| font      | Font      | The font of the text                            |
| style     | FontStyle | Whether the text should be bold or normal style |

Returns int

## getAbsolutPosition (static public member function of graphics)
| Parameter | Type    | Description                     |
| --------- | ------- | ------------------------------- |
| position  | Vector2 | Parameter of getAbsolutPosition |

Returns Vector2

## getRelativePosition (static public member function of graphics)
| Parameter | Type    | Description                      |
| --------- | ------- | -------------------------------- |
| position  | Vector2 | Parameter of getRelativePosition |

Returns Vector2

## getPixelPosition (static public member function of graphics)
| Parameter | Type    | Description                   |
| --------- | ------- | ----------------------------- |
| position  | Vector2 | Parameter of getPixelPosition |

Returns Vector2

## getPixelSize (static public member function of graphics)
| Parameter | Type    | Description               |
| --------- | ------- | ------------------------- |
| size      | Vector2 | Parameter of getPixelSize |

Returns Vector2

## scaleImagesAsPointerGetsCloser (static public member function of graphics)
| Parameter | Type   | Description                                 |
| --------- | ------ | ------------------------------------------- |
| by        | Player | Parameter of scaleImagesAsPointerGetsCloser |
| factor    | float  | Parameter of scaleImagesAsPointerGetsCloser |
| radius    | float  | Parameter of scaleImagesAsPointerGetsCloser |
| do        | void() | Parameter of scaleImagesAsPointerGetsCloser |

Returns void

## createImage (static public member function of graphics)
Create an image to draw to

| Parameter | Type    | Description                                                                        |
| --------- | ------- | ---------------------------------------------------------------------------------- |
| size      | Vector2 | The size of the image                                                              |
| file      | string  | Save the image to a file with this filename                                        |
| code      | void()  | This block of code will draw on the created image instead of drawing on the screen |

Returns void

## copyScreenshotToClipboard (static public member function of graphics)
Returns void

## accessPixel (static public member function of graphics)
Directly manipulate the pixels on the screen or an image

| Parameter | Type               | Description                         |
| --------- | ------------------ | ----------------------------------- |
| code      | void(int[] pixels) | This code can manipulate the pixels |

Returns int[]

## drawTimer (static public member function of graphics)
| Parameter                       | Type   | Description            |
| ------------------------------- | ------ | ---------------------- |
| startTime                       | float  | Parameter of drawTimer |
| duration                        | float  | Parameter of drawTimer |
| completionSound                 | Sound  | Parameter of drawTimer |
| timeBeforeCompletionToPlaySound | float  | Parameter of drawTimer |
| onComplete                      | void() | Parameter of drawTimer |

Returns void

## setPlayerVideo (static public member function of graphics)
| Parameter | Type       | Description                 |
| --------- | ---------- | --------------------------- |
| player    | Player     | Parameter of setPlayerVideo |
| pos       | Vector2    | Parameter of setPlayerVideo |
| size      | Vector2    | Parameter of setPlayerVideo |
| shape     | VideoShape | Parameter of setPlayerVideo |

Returns void

## drawStandardButton (global function)
Draw a button with the default style.


Example: If the current player instance touches or clicks the image or 16 pixels around it, we print the exact position that was touched. If other players will touch the image, nothing will happen.
```
```
```
Player
bool done
tick
if not done
drawButton "I'm done", visibleFor:me
done = true
```

| Parameter   | Type               | Description                                                                                 |
| ----------- | ------------------ | ------------------------------------------------------------------------------------------- |
| text        | string             | The text of the button                                                                      |
| position    | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right |
| accentColor | Color              | Tint the accent image with this color, defaults to the color of the local player            |
| visibleFor  | Player[]           | Only this player or list of players will see the button                                     |
| clickableBy | Player[]           | Only this player or list of players can touch or click the button                           |
| hotkey      | Key                | This keyboard shortcut will execute the onClick handler                                     |
| layer       | int                | Higher layers are drawn in front of lower layers                                            |
| alpha       | float              | The opacity of the button (0: fully transparent, 1: fully visible)                          |
| enabled     | bool               | When not enabled, the button isn't clickable and is drawn transparently (50% by default)    |
| onClick     | void(Touch touch)  | Execute this code when the user touches or clicks the button or presses the hotkey          |
| location    | SourceCodeLocation | Parameter of drawStandardButton                                                             |

Returns void

## drawLargeButton (global function)
Draw a large button with the default style.


Example: If the current player instance touches or clicks the image or 16 pixels around it, we print the exact position that was touched. If other players will touch the image, nothing will happen.
```
```
```
Player
bool done
tick
if not done
drawButton "I'm done", visibleFor:me
done = true
```

| Parameter   | Type               | Description                                                                                 |
| ----------- | ------------------ | ------------------------------------------------------------------------------------------- |
| text        | string             | The text of the button                                                                      |
| position    | Vector2            | By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right |
| accentColor | Color              | Tint the accent image with this color, defaults to the color of the local player            |
| visibleFor  | Player[]           | Only this player or list of players will see the button                                     |
| clickableBy | Player[]           | Only this player or list of players can touch or click the button                           |
| hotkey      | Key                | This keyboard shortcut will execute the onClick handler                                     |
| layer       | int                | Higher layers are drawn in front of lower layers                                            |
| alpha       | float              | The opacity of the button (0: fully transparent, 1: fully visible)                          |
| textSize    | int                | Parameter of drawLargeButton                                                                |
| enabled     | bool               | When not enabled, the button isn't clickable and is drawn transparently (50% by default)    |
| onClick     | void(Touch touch)  | Execute this code when the user touches or clicks the button or presses the hotkey          |
| location    | SourceCodeLocation | Parameter of drawLargeButton                                                                |

Returns void

---

# static class gizmo

## clear (static public member function of gizmo)
Returns void

---

# static class awardScreen

## tick (static public member function of awardScreen)
Returns void

---

# class DisplayItem

## draw (public member function of DisplayItem)
Returns void

## startClipping (public member function of DisplayItem)
Returns void

## endClipping (public member function of DisplayItem)
Returns void

---

# static class Framework

## clear (static public member function of Framework)
| Parameter              | Type | Description        |
| ---------------------- | ---- | ------------------ |
| includingLockedObjects | bool | Parameter of clear |

Returns void

## clearAtEndOfFrame (static public member function of Framework)
Returns void

## removeWhere (static public member function of Framework)
| Parameter | Type               | Description              |
| --------- | ------------------ | ------------------------ |
| condition | bool(Object value) | Parameter of removeWhere |

Returns void

## tick (static public member function of Framework)
Returns void

## deselect (static public member function of Framework)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| player    | Player | Parameter of deselect |

Returns void

## debugString (static public member function of Framework)
Returns string

---

# class Object
Bug: Place the cursor in the following lines to get a "can't be a constructor parameter" error

## siblings (public member function of Object)
Returns Object[]

## removeImmediately (public member function of Object)
Returns void

## removeAtEndOfFrame (public member function of Object)
Returns void

## hide (public member function of Object)
Returns void

## show (public member function of Object)
Returns void

## moveToFront (public member function of Object)
Returns void

## moveToBack (public member function of Object)
Returns void

## moveTo (public member function of Object)
| Parameter | Type    | Description                                                                      |
| --------- | ------- | -------------------------------------------------------------------------------- |
| pos       | Vector2 | Parameter of moveTo                                                              |
| duration  | float   | After the this time in milliseconds, the object should reach the target position |
| delay     | float   | After this time in milliseconds, the object should start moving                  |

Returns Object

## moveTo (public member function of Object)
| Parameter | Type    | Description                                                     |
| --------- | ------- | --------------------------------------------------------------- |
| pos       | Vector2 | Parameter of moveTo                                             |
| speed     | float   | The speed in pixels per millisecond                             |
| delay     | float   | After this time in milliseconds, the object should start moving |

Returns Object

## moveAndScaleTo (public member function of Object)
| Parameter | Type    | Description                                                                                |
| --------- | ------- | ------------------------------------------------------------------------------------------ |
| position  | Vector2 | Parameter of moveAndScaleTo                                                                |
| size      | Vector2 | Parameter of moveAndScaleTo                                                                |
| duration  | float   | After the this time in milliseconds, the object should reach the target position and scale |
| delay     | float   | After this time in milliseconds, the object should start moving                            |

Returns Object

## moveAlongCurveTo (public member function of Object)
| Parameter      | Type    | Description                                                                                |
| -------------- | ------- | ------------------------------------------------------------------------------------------ |
| targetPosition | Vector2 | Parameter of moveAlongCurveTo                                                              |
| curvature      | float   | Parameter of moveAlongCurveTo                                                              |
| smoothness     | float   | Parameter of moveAlongCurveTo                                                              |
| targetSize     | Vector2 | Parameter of moveAlongCurveTo                                                              |
| duration       | float   | After the this time in milliseconds, the object should reach the target position and scale |
| delay          | float   | After this time in milliseconds, the object should start moving                            |
| removeWhenDone | bool    | Parameter of moveAlongCurveTo                                                              |

Returns Object

## fadeIn (public member function of Object)
| Parameter | Type  | Description                                                             |
| --------- | ----- | ----------------------------------------------------------------------- |
| duration  | float | After the this time in milliseconds, the object should be fully visible |
| delay     | float | After this time in milliseconds, the object should start fading in      |

Returns Object

## scaleTo (public member function of Object)
| Parameter | Type    | Description                                                                  |
| --------- | ------- | ---------------------------------------------------------------------------- |
| size      | Vector2 | Parameter of scaleTo                                                         |
| duration  | float   | After the this time in milliseconds, the object should reach the target size |
| delay     | float   | After this time in milliseconds, the object should start scaling             |

Returns Object

## do (public member function of Object)
| Parameter | Type                | Description                                            |
| --------- | ------------------- | ------------------------------------------------------ |
| do        | void(Object object) | Parameter of do                                        |
| delay     | float               | Execute the given code after this time in milliseconds |

Returns void

## playSound (public member function of Object)
| Parameter | Type  | Description                                   |
| --------- | ----- | --------------------------------------------- |
| sound     | Sound | Parameter of playSound                        |
| delay     | float | Play a spound after this time in milliseconds |

Returns void

## fadeAndScaleIn (public member function of Object)
| Parameter  | Type  | Description                                                                                       |
| ---------- | ----- | ------------------------------------------------------------------------------------------------- |
| startScale | float | Parameter of fadeAndScaleIn                                                                       |
| duration   | float | After the this time in milliseconds, the object should reach the target size and be fully visible |
| delay      | float | After this time in milliseconds, the object should start scaling and fading in                    |

Returns Object

## fadeScaleAndRotateIn (public member function of Object)
| Parameter  | Type  | Description                                                                                       |
| ---------- | ----- | ------------------------------------------------------------------------------------------------- |
| startScale | float | Parameter of fadeScaleAndRotateIn                                                                 |
| startAngle | float | Parameter of fadeScaleAndRotateIn                                                                 |
| endAngle   | float | Parameter of fadeScaleAndRotateIn                                                                 |
| duration   | float | After the this time in milliseconds, the object should reach the target size and be fully visible |
| delay      | float | After this time in milliseconds, the object should start scaling and fading in                    |

Returns Object

## removeAnimations (public member function of Object)
Returns void

---

# static class statistics

## scheduleSendIn (static public member function of statistics)
| Parameter | Type  | Description                 |
| --------- | ----- | --------------------------- |
| delay     | float | Parameter of scheduleSendIn |

Returns void

## tick (static public member function of statistics)
Returns void

## log (static public member function of statistics)
Log game events (like scores, playtimes, etc)

| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| value     | any  | Parameter of log |

Returns void

## add (static public member function of statistics)
| Parameter  | Type   | Description      |
| ---------- | ------ | ---------------- |
| label      | string | Parameter of add |
| userIndex  | int    | Parameter of add |
| value      | float  | Parameter of add |
| color      | Color  | Parameter of add |
| set        | int    | Parameter of add |
| isPerFrame | bool   | Parameter of add |

Returns void

## addInfo (static public member function of statistics)
| Parameter | Type   | Description          |
| --------- | ------ | -------------------- |
| name      | string | Parameter of addInfo |
| value     | float  | Parameter of addInfo |

Returns void

---

# static class file

## saveText (static public member function of file)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| filename  | string | Parameter of saveText |
| text      | string | Parameter of saveText |

Returns void

## saveBinary (static public member function of file)
| Parameter | Type   | Description             |
| --------- | ------ | ----------------------- |
| filename  | string | Parameter of saveBinary |
| buffer    | Buffer | Parameter of saveBinary |

Returns void

## openBinary (static public member function of file)
| Parameter | Type                | Description             |
| --------- | ------------------- | ----------------------- |
| then      | void(Buffer buffer) | Parameter of openBinary |
| else      | void(string error)  | Parameter of openBinary |

Returns void

---

# class HTMLElement

## tick (public member function of HTMLElement)
Returns void

## clear (static public member function of HTMLElement)
Returns void

---

# class IndexedDBStore

## put (public member function of IndexedDBStore)
| Parameter | Type              | Description      |
| --------- | ----------------- | ---------------- |
| data      | any               | Parameter of put |
| then      | void()            | Parameter of put |
| else      | void(Error error) | Parameter of put |

Returns void

## get (public member function of IndexedDBStore)
| Parameter | Type | Description      |
| --------- | ---- | ---------------- |
| id        | any  | Parameter of get |

Returns Promise<any>

## get (public member function of IndexedDBStore)
| Parameter | Type              | Description      |
| --------- | ----------------- | ---------------- |
| id        | any               | Parameter of get |
| then      | void(any result)  | Parameter of get |
| else      | void(Error error) | Parameter of get |

Returns void

## getAllFromIndex (public member function of IndexedDBStore)
| Parameter | Type   | Description                  |
| --------- | ------ | ---------------------------- |
| index     | string | Parameter of getAllFromIndex |
| query     | any    | Parameter of getAllFromIndex |

Returns Promise<any[]>

## getAllFromIndex (public member function of IndexedDBStore)
| Parameter | Type               | Description                  |
| --------- | ------------------ | ---------------------------- |
| index     | string             | Parameter of getAllFromIndex |
| query     | any                | Parameter of getAllFromIndex |
| then      | void(any[] result) | Parameter of getAllFromIndex |
| else      | void(Error error)  | Parameter of getAllFromIndex |

Returns void

---

# static class IndexedDB

## isReady (static public member function of IndexedDB)
Returns bool

## start (static public member function of IndexedDB)
| Parameter    | Type   | Description        |
| ------------ | ------ | ------------------ |
| databaseName | string | Parameter of start |
| version      | int    | Parameter of start |

Returns Promise<void>

## start (static public member function of IndexedDB)
| Parameter    | Type              | Description        |
| ------------ | ----------------- | ------------------ |
| databaseName | string            | Parameter of start |
| version      | int               | Parameter of start |
| success      | void()            | Parameter of start |
| else         | void(Error error) | Parameter of start |

Returns void

## open (static public member function of IndexedDB)
| Parameter | Type              | Description       |
| --------- | ----------------- | ----------------- |
| storeName | string            | Parameter of open |
| id        | string            | Parameter of open |
| then      | void(object data) | Parameter of open |
| else      | void()            | Parameter of open |

Returns void

## openBuffer (static public member function of IndexedDB)
| Parameter | Type                | Description             |
| --------- | ------------------- | ----------------------- |
| storeName | string              | Parameter of openBuffer |
| id        | string              | Parameter of openBuffer |
| then      | void(Buffer buffer) | Parameter of openBuffer |
| else      | void()              | Parameter of openBuffer |

Returns void

## save (static public member function of IndexedDB)
| Parameter | Type   | Description       |
| --------- | ------ | ----------------- |
| storeName | string | Parameter of save |
| data      | object | Parameter of save |
| then      | void() | Parameter of save |
| else      | void() | Parameter of save |

Returns void

## saveBuffer (static public member function of IndexedDB)
| Parameter | Type   | Description             |
| --------- | ------ | ----------------------- |
| storeName | string | Parameter of saveBuffer |
| id        | string | Parameter of saveBuffer |
| buffer    | Buffer | Parameter of saveBuffer |
| then      | void() | Parameter of saveBuffer |
| else      | void() | Parameter of saveBuffer |

Returns void

---

# static class core

## startConnected (static public member function of core)
| Parameter | Type | Description                 |
| --------- | ---- | --------------------------- |
| frame     | int  | Parameter of startConnected |

Returns void

## generateObjectId (static public member function of core)
Returns string

## startLocal (static public member function of core)
Returns void

## stop (static public member function of core)
Clear all inputs and reset the application to the first frame

Returns void

## record (static public member function of core)
Start recording (from the beginning or the middle of an existing event stream)
We remove all future inputs
This is called when the user clicks first clicks inside the app

Returns void

## reset (static public member function of core)
Keep inputs, call init functions, create the local players, reset read positions and start app
This is called on startup, after every code change and when going backwards in the timeline

Returns void

## restart (static public member function of core)
Keep event stream running, recreate players, call init function and start app
Called manually with the global "restart" function

Returns void

## goToFrame (static public member function of core)
Steps forward when going to a frame in the future
or replays from the beginning when going to a frame in the past
This is called after every code change with replayFromStart = true
to replay all inputs with the new code from the beginning,
and when stepping through the timeline with replayFromStart = false
to only replay from the beginning when going to a frame in the past

| Parameter       | Type | Description            |
| --------------- | ---- | ---------------------- |
| targetFrame     | int  | Parameter of goToFrame |
| replayFromStart | bool | Parameter of goToFrame |

Returns void

## smooth (static public member function of core)
Smooth out animations by only executing code when we received inputs from everybody

| Parameter | Type   | Description         |
| --------- | ------ | ------------------- |
| player    | Player | Parameter of smooth |
| do        | void() | Parameter of smooth |

Returns void

## log (static public member function of core)
Logs

| Parameter | Type   | Description      |
| --------- | ------ | ---------------- |
| text      | string | Parameter of log |

Returns void

## collectStatistics (static public member function of core)
Returns void

## connectionStates (static public member function of core)
Returns string

## switchSendInterval (static public member function of core)
| Parameter    | Type | Description                     |
| ------------ | ---- | ------------------------------- |
| sendInterval | int  | Parameter of switchSendInterval |

Returns void

## switchSendInputMode (static public member function of core)
| Parameter      | Type           | Description                      |
| -------------- | -------------- | -------------------------------- |
| sendInputsMode | SendInputsMode | Parameter of switchSendInputMode |

Returns void

## appTick (static public member function of core)
Returns void

## appDebugString (static public member function of core)
Returns string

## currentTime (static public member function of core)
Returns int

## startApp (static public member function of core)
Returns void

## adjustStartTimeIfNeeded (static public member function of core)
Returns void

## saveEventStreamAndLogs (static public member function of core)
Returns void

## saveEventStream (static public member function of core)
Returns void

## storeRoomToDB (static public member function of core)
Returns void

## storeInputsToDB (static public member function of core)
| Parameter | Type         | Description                  |
| --------- | ------------ | ---------------------------- |
| user      | InternalUser | Parameter of storeInputsToDB |

Returns void

## openFromDB (static public member function of core)
Returns Promise<void>

## openState (static public member function of core)
Returns void

## openEventStream (static public member function of core)
Returns void

## join (static public member function of core)
| Parameter  | Type   | Description       |
| ---------- | ------ | ----------------- |
| gameId     | string | Parameter of join |
| roomString | string | Parameter of join |
| userId     | int    | Parameter of join |

Returns Promise<void>

## onWrongChecksum (static public member function of core)
| Parameter | Type  | Description                  |
| --------- | ----- | ---------------------------- |
| frame     | int   | Parameter of onWrongChecksum |
| mine      | float | Parameter of onWrongChecksum |
| theirs    | float | Parameter of onWrongChecksum |

Returns void

## onError (static public member function of core)
| Parameter | Type  | Description          |
| --------- | ----- | -------------------- |
| error     | Error | Parameter of onError |

Returns void

---

# static class Snapshot

## serialize (static public member function of Snapshot)
| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| buffer    | Buffer | Parameter of serialize |

Returns string

## deserialize (static public member function of Snapshot)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| buffer    | Buffer | Parameter of deserialize |

Returns void

## serializeLog (static public member function of Snapshot)
Returns string

## toString (static public member function of Snapshot)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| value     | object | Parameter of toString |

Returns string

## fromString (static public member function of Snapshot)
| Parameter    | Type   | Description             |
| ------------ | ------ | ----------------------- |
| value        | object | Parameter of fromString |
| base64String | string | Parameter of fromString |

Returns void

## fromBase64 (static public member function of Snapshot)
| Parameter    | Type   | Description             |
| ------------ | ------ | ----------------------- |
| value        | object | Parameter of fromBase64 |
| base64String | string | Parameter of fromBase64 |

Returns void

## save (static public member function of Snapshot)
Returns Buffer

## restore (static public member function of Snapshot)
| Parameter | Type   | Description          |
| --------- | ------ | -------------------- |
| buffer    | Buffer | Parameter of restore |

Returns void

## autoSave (static public member function of Snapshot)
Returns void

---

# class StatisticsGraph

## lastValue (public member function of StatisticsGraph)
Returns float

## add (public member function of StatisticsGraph)
| Parameter | Type  | Description      |
| --------- | ----- | ---------------- |
| value     | float | Parameter of add |

Returns void

## addDirectly (public member function of StatisticsGraph)
| Parameter | Type  | Description              |
| --------- | ----- | ------------------------ |
| value     | float | Parameter of addDirectly |

Returns void

---

# static class debug

## start (static public member function of debug)
Returns void

## click (static public member function of debug)
| Parameter              | Type | Description        |
| ---------------------- | ---- | ------------------ |
| playerIndex            | int  | Parameter of click |
| x                      | int  | Parameter of click |
| y                      | int  | Parameter of click |
| framesToWaitAfterwards | int  | Parameter of click |

Returns void

## drag (static public member function of debug)
| Parameter   | Type | Description       |
| ----------- | ---- | ----------------- |
| playerIndex | int  | Parameter of drag |
| x           | int  | Parameter of drag |
| y           | int  | Parameter of drag |
| dragToX     | int  | Parameter of drag |
| dragToY     | int  | Parameter of drag |

Returns void

## wait (static public member function of debug)
| Parameter | Type | Description       |
| --------- | ---- | ----------------- |
| frames    | int  | Parameter of wait |

Returns void

## onWaitFinished (static public member function of debug)
Returns void

## evaluateExpression (static public member function of debug)
| Parameter  | Type   | Description                     |
| ---------- | ------ | ------------------------------- |
| expression | string | Parameter of evaluateExpression |

Returns void

## eval (static public member function of debug)
| Parameter  | Type   | Description       |
| ---------- | ------ | ----------------- |
| expression | string | Parameter of eval |

Returns string

## sendApplicationState (static public member function of debug)
Returns void

## sendCurrentlyOnScreen (static public member function of debug)
Returns void

---

# class BinaryHeap

## push (public member function of BinaryHeap)
| Parameter | Type      | Description       |
| --------- | --------- | ----------------- |
| element   | AStarNode | Parameter of push |

Returns void

## pop (public member function of BinaryHeap)
Returns AStarNode

## remove (public member function of BinaryHeap)
| Parameter | Type      | Description         |
| --------- | --------- | ------------------- |
| node      | AStarNode | Parameter of remove |

Returns void

## size (public member function of BinaryHeap)
Returns int

## rescoreElement (public member function of BinaryHeap)
| Parameter | Type      | Description                 |
| --------- | --------- | --------------------------- |
| node      | AStarNode | Parameter of rescoreElement |

Returns void

## sinkDown (public member function of BinaryHeap)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| number    | int  | Parameter of sinkDown |

Returns void

## bubbleUp (public member function of BinaryHeap)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| number    | int  | Parameter of bubbleUp |

Returns void

---

# static class algorithms

## findPath (static public member function of algorithms)
Finds the shortest path between two position using the astar algorithm

| Parameter    | Type                                          | Description           |
| ------------ | --------------------------------------------- | --------------------- |
| startPos     | IntVector2                                    | Parameter of findPath |
| endPos       | IntVector2                                    | Parameter of findPath |
| size         | IntVector2                                    | Parameter of findPath |
| getNeighbors | AStarNode[](AStarNode[][] grid, int x, int y) | Parameter of findPath |
| heuristic    | int(IntVector2 a, IntVector2 b)               | Parameter of findPath |

Returns AStarNode[]

## resolveCollision (static public member function of algorithms)
| Parameter      | Type          | Description                   |
| -------------- | ------------- | ----------------------------- |
| sourcePosition | Vector2       | Parameter of resolveCollision |
| targetPosition | Vector2       | Parameter of resolveCollision |
| colliders      | BoxCollider[] | Parameter of resolveCollision |
| radius         | float         | Parameter of resolveCollision |
| slideThreshold | float         | Parameter of resolveCollision |

Returns Vector2

---

# class PriorityQueue

## push (public member function of PriorityQueue)
| Parameter | Type            | Description       |
| --------- | --------------- | ----------------- |
| element   | PathfindingNode | Parameter of push |

Returns void

## pop (public member function of PriorityQueue)
Returns PathfindingNode

## remove (public member function of PriorityQueue)
| Parameter | Type            | Description         |
| --------- | --------------- | ------------------- |
| node      | PathfindingNode | Parameter of remove |

Returns void

## size (public member function of PriorityQueue)
Returns int

## rescoreElement (public member function of PriorityQueue)
| Parameter | Type            | Description                 |
| --------- | --------------- | --------------------------- |
| node      | PathfindingNode | Parameter of rescoreElement |

Returns void

## sinkDown (public member function of PriorityQueue)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| number    | int  | Parameter of sinkDown |

Returns void

## bubbleUp (public member function of PriorityQueue)
| Parameter | Type | Description           |
| --------- | ---- | --------------------- |
| number    | int  | Parameter of bubbleUp |

Returns void

---

# class PathfindingNode

## findPathTo (public member function of PathfindingNode)
| Parameter | Type            | Description             |
| --------- | --------------- | ----------------------- |
| target    | PathfindingNode | Parameter of findPathTo |

Returns PathfindingNode[]

---

# class InternalUser
The internal state of a user that isn't serialized and shoudn't be accessed by the app

## startInputFrame (public member function of InternalUser)
| Parameter | Type | Description                  |
| --------- | ---- | ---------------------------- |
| index     | int  | Parameter of startInputFrame |

Returns void

## clearEvent (public member function of InternalUser)
Returns void

## collectStatistics (public member function of InternalUser)
| Parameter | Type | Description                    |
| --------- | ---- | ------------------------------ |
| frame     | int  | Parameter of collectStatistics |

Returns void

## simulateRollback (public member function of InternalUser)
| Parameter | Type | Description                   |
| --------- | ---- | ----------------------------- |
| frame     | int  | Parameter of simulateRollback |

Returns void

---

# class Touch
A touch or a click

## position (public member function of Touch)
Returns Vector2

## startPosition (public member function of Touch)
Returns Vector2

## markAsHandled (public member function of Touch)
Returns void

---

# class ScrollEvent

## position (public member function of ScrollEvent)
Returns Vector2

## markAsHandled (public member function of ScrollEvent)
Returns void

---

# class DigitalButton

## down (public member function of DigitalButton)
Returns bool

## up (public member function of DigitalButton)
Returns bool

## toString (public member function of DigitalButton)
Returns string

---

# static class input
Collect user input

## everybody (global function)
Do something for every player

| Parameter | Type            | Description            |
| --------- | --------------- | ---------------------- |
| do        | void(Player it) | Parameter of everybody |

Returns void

## everybody (global function)
Returns true if the given condition is true for every player

| Parameter | Type            | Description            |
| --------- | --------------- | ---------------------- |
| predicate | bool(Player it) | Parameter of everybody |

Returns bool

## everybody (global function)
All players

Returns Player[]

## anybody (global function)
Returns true if the given condition is true for any player

| Parameter | Type            | Description          |
| --------- | --------------- | -------------------- |
| predicate | bool(Player it) | Parameter of anybody |

Returns bool

## nobody (global function)
Returns true if the given condition is true for no player

| Parameter | Type            | Description         |
| --------- | --------------- | ------------------- |
| predicate | bool(Player it) | Parameter of nobody |

Returns bool

## switchPerspectiveTo (static public member function of input)
Show the perspective of this player

| Parameter | Type   | Description                      |
| --------- | ------ | -------------------------------- |
| player    | Player | Parameter of switchPerspectiveTo |

Returns void

## textInput (static public member function of input)
Returns string

## removePlayer (static public member function of input)
| Parameter | Type   | Description               |
| --------- | ------ | ------------------------- |
| player    | Player | Parameter of removePlayer |

Returns void

## appOnTouchDownIfFunctionExists (static public member function of input)
| Parameter | Type  | Description                                 |
| --------- | ----- | ------------------------------------------- |
| touch     | Touch | Parameter of appOnTouchDownIfFunctionExists |

Returns void

## appOnTouchMoveIfFunctionExists (static public member function of input)
| Parameter | Type  | Description                                 |
| --------- | ----- | ------------------------------------------- |
| touch     | Touch | Parameter of appOnTouchMoveIfFunctionExists |

Returns void

## appOnTouchUpIfFunctionExists (static public member function of input)
| Parameter | Type  | Description                               |
| --------- | ----- | ----------------------------------------- |
| touch     | Touch | Parameter of appOnTouchUpIfFunctionExists |

Returns void

## onTouchDown (global function)
Do something when the player touches or clicks within a given area.


Example: Draw an OK button and print "Clicked OK" when the user touches it.
```
```
```
app
tick
drawText "OK", position:{0,0}, size:40, color:White
drawRoundedRectangle position:{0,0}, size:{300,100}, color:Blue

onTouchDown position:{0,0}, size:{300,100}
print "Clicked OK"
```

| Parameter         | Type                | Description                                                       |
| ----------------- | ------------------- | ----------------------------------------------------------------- |
| position          | Vector2             | The center of the touch area                                      |
| size              | Vector2             | The size of the rectangular touch area                            |
| by                | Player[]            | Only consider touches or clicks by this player or list of players |
| cursor            | Cursor              | Change the mouse cursor image when hovering over this area        |
| showClickableArea | bool                | Highlight the clickable area for debugging                        |
| markAsHandled     | bool                | Mark the touch as handled so it won't trigger more touch events   |
| align             | HorizontalAlignment | The horizontal alignment of the touch area                        |
| valign            | VerticalAlignment   | The vertical alignment of the touch area                          |
| do                | void(Touch touch)   | Do this for each touch or click                                   |

Returns void

## onTouchDown (global function)
Do something when the player touches or clicks within a given rotated rectangle.


Example: Draw a the image "Character" rotated by 45 degrees and print "Clicked character" when the player touches within its rotated rectangle.
```
```
```
app
tick
let pos = {0,0}
let size = {100,200}
let angle = 45°

drawImage Character, pos, size, angle
onTouchDown pos, size, angle
print "Clicked character"
```

| Parameter         | Type                | Description                                                       |
| ----------------- | ------------------- | ----------------------------------------------------------------- |
| position          | Vector2             | The center of the touch area                                      |
| size              | Vector2             | The size of the rectangular touch area                            |
| angle             | float               | Rotate the touch area by this angle                               |
| by                | Player[]            | Only consider touches or clicks by this player or list of players |
| cursor            | Cursor              | Change the mouse cursor image when hovering over this area        |
| showClickableArea | bool                | Highlight the clickable area for debugging                        |
| markAsHandled     | bool                | Mark the touch as handled so it won't trigger more touch events   |
| align             | HorizontalAlignment | The horizontal alignment of the touch area                        |
| valign            | VerticalAlignment   | The vertical alignment of the touch area                          |
| do                | void(Touch touch)   | Do this for each touch or click                                   |

Returns void

## onTouchDown (global function)
Do something when the player touches or clicks within a given circle.


Example: Draw the image "Ball" and print "Clicked ball" when the player touches it.
```
```
```
Ball
Vector2 pos
tick
drawImage Ball, pos, size:100
onTouchDown pos, radius:50
print "Clicked ball"
```

| Parameter         | Type              | Description                                                       |
| ----------------- | ----------------- | ----------------------------------------------------------------- |
| position          | Vector2           | The center of the circle                                          |
| radius            | float             | The radius of the circle                                          |
| by                | Player[]          | Only consider touches or clicks by this player or list of players |
| cursor            | Cursor            | Change the mouse cursor image when hovering over this circle      |
| showClickableArea | bool              | Highlight the clickable area for debugging                        |
| markAsHandled     | bool              | Mark the touch as handled so it won't trigger more touch events   |
| do                | void(Touch touch) | Do this for each touch or click                                   |

Returns void

## onTouchDown (global function)
Do something when the player touches or clicks within a given polygon.


Example: Draw a polygon and print "Clicked OK" when the player touches it.
```
```
```
app
tick
let polygon = [{-200,-50}, {-250,50}, {200,50}, {250,-50}]

drawText "OK", size:50
drawPolygon polygon, color:Blue

onTouchDown polygon
print "Clicked OK"
```

| Parameter         | Type              | Description                                                       |
| ----------------- | ----------------- | ----------------------------------------------------------------- |
| points            | Vector2[]         | The points that define the clickable polygon                      |
| position          | Vector2           | The position all polygon points are relative to                   |
| by                | Player[]          | Only consider touches or clicks by this player or list of players |
| cursor            | Cursor            | Change the mouse cursor image when hovering over this polygon     |
| showClickableArea | bool              | Highlight the clickable area for debugging                        |
| markAsHandled     | bool              | Mark the touch as handled so it won't trigger more touch events   |
| do                | void(Touch touch) | Do this for each touch or click                                   |

Returns void

## onTouchDown (global function)
Do something when the player touches or clicks anywhere on the screen.


Example: When the current player instance touches the screen, we print out the exact touch position.
```
```
```
Player
tick
onTouchDown by me
print "Click at {touch.position}"
```

| Parameter     | Type              | Description                                                       |
| ------------- | ----------------- | ----------------------------------------------------------------- |
| by            | Player[]          | Only consider touches or clicks by this player or list of players |
| markAsHandled | bool              | Mark the touch as handled so it won't trigger more touch events   |
| do            | void(Touch touch) | Do this for each touch or click                                   |

Returns void

## onTouchDownAny (global function)
Do something when the player touches or clicks, even if the event is already handled.


| Parameter | Type              | Description                                                                    |
| --------- | ----------------- | ------------------------------------------------------------------------------ |
| by        | Player[]          | Only consider touches or clicks by this player or list of players              |
| do        | void(Touch touch) | Do this for each touch or click, even those that are already marked as handled |

Returns void

## onTouchOver (global function)
Do something when the mouse moves over a given area.


Example: Draw a blue rectangle. When the current player instance hovers over the rectangle with the mouse, we draw a black outline around it.
```
```
```
Player
tick
let pos = {0,0}
let size = {200,100}

drawRectangle pos, size, color:Blue
onTouchOver pos, size, by:me
drawRectangle pos, size+{32,32}, outlineColor:Black, outlineWidth:8
```

| Parameter         | Type                | Description                                                     |
| ----------------- | ------------------- | --------------------------------------------------------------- |
| position          | Vector2             | The center of the touch area                                    |
| size              | Vector2             | The size of the rectangular touch area                          |
| by                | Player[]            | Only consider the mouse from this player                        |
| cursor            | Cursor              | Change the mouse cursor image when hovering over this area      |
| showClickableArea | bool                | Highlight the area for debugging                                |
| markAsHandled     | bool                | Mark the touch as handled so it won't trigger more touch events |
| align             | HorizontalAlignment | The horizontal alignment of the touch area                      |
| valign            | VerticalAlignment   | The vertical alignment of the touch area                        |
| do                | void(Touch touch)   | Do this for each mouse that is hovering over the given area     |

Returns void

## onTouchMove (global function)
Do something when a touch or click moves.

onTouchMove is commonly used to check what the pointer is hovering over and highlight it.
Since on touch screens we often don't get a touchMove event when the user touches something, we can set
triggeredOnTouchDown to "true" to ensure we always get a touchMove event right before the touchDown.

Example: The players can drag PuzzlePieces around with support for multi-touch and multiple players
```
```
```
PuzzlePiece
private Vector2 pos
private Vector2 moveOffset
private Touch moveTouch

tick
onTouchDown pos, app.pieceSize
moveTouch = touch
moveOffset = pos - touch.position

onTouchMove moveTouch
pos = touch.position + moveOffset

onTouchUp moveTouch
moveTouch = null
```

| Parameter            | Type              | Description                                                                |
| -------------------- | ----------------- | -------------------------------------------------------------------------- |
| touch                | Touch             | Only consider this particular touch or click                               |
| triggeredOnTouchDown | bool              | Ensure we also get a touchMove before the touchDown event on touch screens |
| do                   | void(Touch touch) | Do this for each touch or click                                            |

Returns void

## onTouchMove (global function)
Do something when a touch or click of the given player moves.


Example: Print the touch or mouse position of the current player instance everytime it moves
```
```
```
Player
trick
onTouchMove by me
print "Touch moved to {touch.position}"
```

| Parameter            | Type              | Description                                                                |
| -------------------- | ----------------- | -------------------------------------------------------------------------- |
| by                   | Player[]          | Only consider touches or clicks by this player or list of players          |
| triggeredOnTouchDown | bool              | Ensure we also get a touchMove before the touchDown event on touch screens |
| do                   | void(Touch touch) | Do this for each touch or click                                            |

Returns void

## onTouchUp (global function)
Do something when a touch or click ends.


Example: The players can drag PuzzlePieces around with support for multi-touch and multiple players
```
```
```
PuzzlePiece
private Vector2 pos
private Vector2 moveOffset
private Touch moveTouch

tick
onTouchDown pos, app.pieceSize
moveTouch = touch
moveOffset = pos - touch.position

onTouchMove moveTouch
pos = touch.position + moveOffset

onTouchUp moveTouch
moveTouch = null
```

| Parameter     | Type              | Description                                                     |
| ------------- | ----------------- | --------------------------------------------------------------- |
| touch         | Touch             | Only consider this particular touch or click                    |
| markAsHandled | bool              | Mark the touch as handled so it won't trigger more touch events |
| do            | void(Touch touch) | Do this for each touch or click                                 |

Returns void

## onTouchUp (global function)
Do something when a given player ends a touch or click.


Example: Print the touch or mouse position of the current player instance when the touch ends or the mouse button is released
```
```
```
Player
trick
onTouchUp by me
print "Touch ended at {touch.position}"
```

| Parameter     | Type              | Description                                                       |
| ------------- | ----------------- | ----------------------------------------------------------------- |
| by            | Player[]          | Only consider touches or clicks by this player or list of players |
| markAsHandled | bool              | Mark the touch as handled so it won't trigger more touch events   |
| do            | void(Touch touch) | Do this for each touch or click                                   |

Returns void

## onTouchUp (global function)
Do something when the player ends a touch or click within a given area


Example: Draw an OK button and print "Clicked OK" when the player ends a touch or releases the mouse button over this button
```
```
```
app
tick
drawText "OK", position:{0,0}, size:40, color:White
drawRoundedRectangle position:{0,0}, size:{300,100}, color:Blue

onTouchUp position:{0,0}, size:{300,100}
print "Clicked OK"
```

| Parameter         | Type              | Description                                                       |
| ----------------- | ----------------- | ----------------------------------------------------------------- |
| position          | Vector2           | The center of the touch area                                      |
| size              | Vector2           | The size of the rectangular touch area                            |
| by                | Player[]          | Only consider touches or clicks by this player or list of players |
| showClickableArea | bool              | Highlight the clickable area for debugging                        |
| markAsHandled     | bool              | Mark the touch as handled so it won't trigger more touch events   |
| do                | void(Touch touch) | Do this for each touch or click                                   |

Returns void

## onTouchUp (global function)
Do something when the player ends a touch or click within a given circle.


Example: Draw the image "Ball" and print "Clicked ball" when the player ends a touch or releases the mouse button over this button
```
```
```
Ball
Vector2 pos
tick
drawImage Ball, pos, size:100
onTouchUp pos, radius:50
print "Clicked ball"
```

| Parameter         | Type              | Description                                                       |
| ----------------- | ----------------- | ----------------------------------------------------------------- |
| position          | Vector2           | The center of the circle                                          |
| radius            | float             | The radius of the circle                                          |
| by                | Player[]          | Only consider touches or clicks by this player or list of players |
| cursor            | Cursor            | Change the mouse cursor image when hovering over this area        |
| showClickableArea | bool              | Highlight the clickable area for debugging                        |
| markAsHandled     | bool              | Mark the touch as handled so it won't trigger more touch events   |
| do                | void(Touch touch) | Do this for each touch or click                                   |

Returns void

## onScroll (global function)
Do something when a player scrolls with the touch pad or mouse wheel

| Parameter | Type                    | Description                                            |
| --------- | ----------------------- | ------------------------------------------------------ |
| by        | Player[]                | Only consider events by this player or list of players |
| do        | void(ScrollEvent event) | Do this for each event                                 |

Returns void

## onScrolllWithin (global function)
Do something when a player scrolls with the touch pad or mouse wheel over a rectangle

| Parameter         | Type                    | Description                                               |
| ----------------- | ----------------------- | --------------------------------------------------------- |
| position          | Vector2                 | The center of the rectangle                               |
| size              | Vector2                 | The size of the rectangle                                 |
| by                | Player[]                | Only consider events by this player or list of players    |
| showClickableArea | bool                    | Highlight the rectangle for debugging                     |
| markAsHandled     | bool                    | Mark the touch as handled so it won't trigger more events |
| do                | void(ScrollEvent event) | Do this for each event                                    |

Returns void

## startTextInput (static public member function of input)
| Parameter   | Type   | Description                 |
| ----------- | ------ | --------------------------- |
| initalValue | string | Parameter of startTextInput |
| forUser     | int    | Parameter of startTextInput |

Returns void

## stopTextInput (static public member function of input)
Returns void

## setTextInput (static public member function of input)
| Parameter | Type   | Description               |
| --------- | ------ | ------------------------- |
| value     | string | Parameter of setTextInput |

Returns void

## updateCursor (static public member function of input)
Returns void

## onTextComposition (static public member function of input)
| Parameter | Type                    | Description                    |
| --------- | ----------------------- | ------------------------------ |
| do        | void(string characters) | Parameter of onTextComposition |

Returns void

## onTextInput (static public member function of input)
| Parameter | Type                   | Description                                                  |
| --------- | ---------------------- | ------------------------------------------------------------ |
| by        | Player[]               | Only consider keys pressed by this player or list of players |
| do        | void(string textInput) | Do this for each key that is pressed                         |

Returns void

## onKeyDown (global function)
Do something when a player presses a key

| Parameter | Type                                                                  | Description                                                  |
| --------- | --------------------------------------------------------------------- | ------------------------------------------------------------ |
| modifier  | Key                                                                   | Parameter of onKeyDown                                       |
| key       | Key                                                                   | The key that will trigger the event                          |
| by        | Player[]                                                              | Only consider keys pressed by this player or list of players |
| do        | void(Key key, Player pressedBy, bool cmdOrCtrl, bool alt, bool shift) | Do this for each key that is pressed                         |

Returns void

## onKeyDown (global function)
Do something when a player presses a key

| Parameter | Type                                                                  | Description                                                  |
| --------- | --------------------------------------------------------------------- | ------------------------------------------------------------ |
| key       | Key                                                                   | The key that will trigger the event                          |
| cmdOrCtrl | bool                                                                  | Parameter of onKeyDown                                       |
| alt       | bool                                                                  | Parameter of onKeyDown                                       |
| shift     | bool                                                                  | Parameter of onKeyDown                                       |
| by        | Player[]                                                              | Only consider keys pressed by this player or list of players |
| do        | void(Key key, Player pressedBy, bool cmdOrCtrl, bool alt, bool shift) | Do this for each key that is pressed                         |

Returns void

## onKeyDown (global function)
Do something when a player presses a key

| Parameter | Type                                                                  | Description                                                  |
| --------- | --------------------------------------------------------------------- | ------------------------------------------------------------ |
| by        | Player[]                                                              | Only consider keys pressed by this player or list of players |
| do        | void(Key key, Player pressedBy, bool cmdOrCtrl, bool alt, bool shift) | Do this for each key that is pressed                         |

Returns void

## onKeyUp (global function)
Do something when a player releases a key

| Parameter | Type                            | Description                                                   |
| --------- | ------------------------------- | ------------------------------------------------------------- |
| by        | Player[]                        | Only consider keys released by this player or list of players |
| do        | void(Key key, Player pressedBy) | Do this for each key that is released                         |

Returns void

## onType (global function)
Do something when a player types a character

| Parameter | Type                                     | Description                                                      |
| --------- | ---------------------------------------- | ---------------------------------------------------------------- |
| by        | Player[]                                 | Only consider characters typed by this player or list of players |
| do        | void(string character, Player pressedBy) | Do this for each character that is typed                         |

Returns void

## isKeyDown (static public member function of input)
Returns true if a given key is currently held down

| Parameter | Type   | Description                               |
| --------- | ------ | ----------------------------------------- |
| key       | Key    | The key to check                          |
| by        | Player | Only consider keys pressed by this player |

Returns bool

## onNavigate (global function)
Do something when the user navigates back or forward in the browser

| Parameter | Type             | Description                                            |
| --------- | ---------------- | ------------------------------------------------------ |
| by        | Player[]         | Only consider events by this player or list of players |
| do        | void(string url) | Do this for each event                                 |

Returns void

---

# static class lobby

## show (static public member function of lobby)
Returns void

## tick (static public member function of lobby)
Returns void

## setupFields (static public member function of lobby)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| newHost   | Player | Parameter of setupFields |

Returns void

## switchFieldFocus (static public member function of lobby)
| Parameter | Type | Description                   |
| --------- | ---- | ----------------------------- |
| delta     | int  | Parameter of switchFieldFocus |

Returns void

## showName (static public member function of lobby)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| player    | Player | Parameter of showName |

Returns void

## createField (static public member function of lobby)
| Parameter  | Type     | Description              |
| ---------- | -------- | ------------------------ |
| player     | Player   | Parameter of createField |
| visibleFor | Player[] | Parameter of createField |

Returns LobbyTextField

## setPlayerName (static public member function of lobby)
| Parameter | Type   | Description                |
| --------- | ------ | -------------------------- |
| player    | Player | Parameter of setPlayerName |
| name      | string | Parameter of setPlayerName |

Returns void

## cyclePlayer (static public member function of lobby)
| Parameter | Type   | Description              |
| --------- | ------ | ------------------------ |
| player    | Player | Parameter of cyclePlayer |

Returns void

## tickSettings (static public member function of lobby)
Returns void

---

# static class networkData

## call (static public member function of networkData)
| Parameter | Type | Description       |
| --------- | ---- | ----------------- |
| id        | int  | Parameter of call |
| data      | any  | Parameter of call |

Returns void

## addCallback (static public member function of networkData)
| Parameter | Type           | Description              |
| --------- | -------------- | ------------------------ |
| do        | void(any data) | Parameter of addCallback |

Returns int

---

# static class storage

## set (static public member function of storage)
| Parameter | Type   | Description      |
| --------- | ------ | ---------------- |
| key       | string | Parameter of set |
| of        | Player | Parameter of set |
| value     | object | Parameter of set |

Returns void

## get (static public member function of storage)
| Parameter | Type           | Description      |
| --------- | -------------- | ---------------- |
| key       | string         | Parameter of get |
| of        | Player         | Parameter of get |
| do        | void(any data) | Parameter of get |

Returns void

---

# static class http

## encodeURIComponent (static public member function of http)
| Parameter | Type   | Description                     |
| --------- | ------ | ------------------------------- |
| str       | string | Parameter of encodeURIComponent |

Returns string

## get (static public member function of http)
Perform an http get request

| Parameter | Type             | Description      |
| --------- | ---------------- | ---------------- |
| url       | string           | Parameter of get |
| code      | void(any result) | Parameter of get |

Returns void

## getString (static public member function of http)
| Parameter                   | Type                | Description            |
| --------------------------- | ------------------- | ---------------------- |
| url                         | string              | Parameter of getString |
| storeForDeterministicReplay | bool                | Parameter of getString |
| code                        | void(string result) | Parameter of getString |

Returns void

## postStreamDirectly (static public member function of http)
| Parameter | Type                                          | Description                     |
| --------- | --------------------------------------------- | ------------------------------- |
| url       | string                                        | Parameter of postStreamDirectly |
| body      | dynamic                                       | Parameter of postStreamDirectly |
| headers   | dynamic                                       | Parameter of postStreamDirectly |
| onData    | void(string result, bool done, void() cancel) | Parameter of postStreamDirectly |
| onEnd     | void()                                        | Parameter of postStreamDirectly |

Returns Promise<void>

## post (static public member function of http)
Perform an http post request

| Parameter | Type             | Description       |
| --------- | ---------------- | ----------------- |
| url       | string           | Parameter of post |
| code      | void(any result) | Parameter of post |

Returns void

## post (static public member function of http)
Perform an http post request

| Parameter | Type             | Description       |
| --------- | ---------------- | ----------------- |
| url       | string           | Parameter of post |
| body      | any              | Parameter of post |
| code      | void(any result) | Parameter of post |

Returns void

## post (static public member function of http)
| Parameter | Type   | Description       |
| --------- | ------ | ----------------- |
| url       | string | Parameter of post |
| body      | any    | Parameter of post |

Returns void

## put (static public member function of http)
Perform an http put request

| Parameter | Type             | Description      |
| --------- | ---------------- | ---------------- |
| url       | string           | Parameter of put |
| code      | void(any result) | Parameter of put |

Returns void

## put (static public member function of http)
Perform an http put request

| Parameter | Type             | Description      |
| --------- | ---------------- | ---------------- |
| url       | string           | Parameter of put |
| body      | any              | Parameter of put |
| code      | void(any result) | Parameter of put |

Returns void

## delete (static public member function of http)
Perform an http delete request

| Parameter | Type             | Description         |
| --------- | ---------------- | ------------------- |
| url       | string           | Parameter of delete |
| code      | void(any result) | Parameter of delete |

Returns void

## delete (static public member function of http)
Perform an http delete request

| Parameter | Type             | Description         |
| --------- | ---------------- | ------------------- |
| url       | string           | Parameter of delete |
| body      | any              | Parameter of delete |
| code      | void(any result) | Parameter of delete |

Returns void

---

# static class PeerNetwork

## initiate (static public member function of PeerNetwork)
| Parameter | Type         | Description           |
| --------- | ------------ | --------------------- |
| user      | InternalUser | Parameter of initiate |

Returns void

## tick (static public member function of PeerNetwork)
Returns void

## onConnected (static public member function of PeerNetwork)
| Parameter | Type         | Description              |
| --------- | ------------ | ------------------------ |
| user      | InternalUser | Parameter of onConnected |

Returns void

## disconnect (static public member function of PeerNetwork)
| Parameter | Type         | Description             |
| --------- | ------------ | ----------------------- |
| user      | InternalUser | Parameter of disconnect |

Returns void

## setBitrate (static public member function of PeerNetwork)
| Parameter             | Type         | Description             |
| --------------------- | ------------ | ----------------------- |
| user                  | InternalUser | Parameter of setBitrate |
| scaleResolutionDownBy | float        | Parameter of setBitrate |
| maxBitrate            | float        | Parameter of setBitrate |

Returns void

## onReceivedOffer (static public member function of PeerNetwork)
| Parameter | Type         | Description                  |
| --------- | ------------ | ---------------------------- |
| user      | InternalUser | Parameter of onReceivedOffer |
| sdp       | string       | Parameter of onReceivedOffer |

Returns void

## sendInputs (static public member function of PeerNetwork)
| Parameter  | Type | Description             |
| ---------- | ---- | ----------------------- |
| inputFrame | int  | Parameter of sendInputs |

Returns void

## onReceivedAnswer (static public member function of PeerNetwork)
| Parameter | Type         | Description                   |
| --------- | ------------ | ----------------------------- |
| user      | InternalUser | Parameter of onReceivedAnswer |
| sdp       | string       | Parameter of onReceivedAnswer |

Returns void

## onIce (static public member function of PeerNetwork)
| Parameter | Type         | Description        |
| --------- | ------------ | ------------------ |
| user      | InternalUser | Parameter of onIce |
| candidate | string       | Parameter of onIce |

Returns void

## ping (static public member function of PeerNetwork)
Returns void

## sendChecksum (static public member function of PeerNetwork)
| Parameter   | Type  | Description               |
| ----------- | ----- | ------------------------- |
| checksumFor | int   | Parameter of sendChecksum |
| checksum    | float | Parameter of sendChecksum |

Returns void

## onChecksum (static public member function of PeerNetwork)
| Parameter | Type         | Description             |
| --------- | ------------ | ----------------------- |
| user      | InternalUser | Parameter of onChecksum |
| buffer    | Buffer       | Parameter of onChecksum |

Returns void

## setupLocalMedia (static public member function of PeerNetwork)
| Parameter   | Type | Description                  |
| ----------- | ---- | ---------------------------- |
| enableVideo | bool | Parameter of setupLocalMedia |
| enableAudio | bool | Parameter of setupLocalMedia |

Returns Promise<void>

## setVideoInput (static public member function of PeerNetwork)
| Parameter    | Type   | Description                |
| ------------ | ------ | -------------------------- |
| videoInputId | string | Parameter of setVideoInput |
| player       | Player | Parameter of setVideoInput |

Returns void

## setAudioInput (static public member function of PeerNetwork)
| Parameter    | Type   | Description                |
| ------------ | ------ | -------------------------- |
| audioInputId | string | Parameter of setAudioInput |
| player       | Player | Parameter of setAudioInput |

Returns void

## setAudioOutput (static public member function of PeerNetwork)
| Parameter     | Type   | Description                 |
| ------------- | ------ | --------------------------- |
| audioOutputId | string | Parameter of setAudioOutput |
| player        | Player | Parameter of setAudioOutput |

Returns void

## createVideoElement (static public member function of PeerNetwork)
| Parameter | Type   | Description                     |
| --------- | ------ | ------------------------------- |
| stream    | object | Parameter of createVideoElement |
| local     | bool   | Parameter of createVideoElement |

Returns object

## removeVideoElement (static public member function of PeerNetwork)
| Parameter    | Type   | Description                     |
| ------------ | ------ | ------------------------------- |
| videoElement | object | Parameter of removeVideoElement |

Returns void

## updateVideoElement (static public member function of PeerNetwork)
| Parameter    | Type   | Description                     |
| ------------ | ------ | ------------------------------- |
| videoElement | object | Parameter of updateVideoElement |
| x            | float  | Parameter of updateVideoElement |
| y            | float  | Parameter of updateVideoElement |
| sizeX        | float  | Parameter of updateVideoElement |
| sizeY        | float  | Parameter of updateVideoElement |
| radius       | float  | Parameter of updateVideoElement |

Returns void

## setAudioMuted (static public member function of PeerNetwork)
| Parameter    | Type   | Description                |
| ------------ | ------ | -------------------------- |
| audioElement | object | Parameter of setAudioMuted |
| muted        | bool   | Parameter of setAudioMuted |

Returns void

---

# static class Physics

## start (static public member function of Physics)
Returns Promise<void>

## step (static public member function of Physics)
Returns void

## destroy (static public member function of Physics)
| Parameter | Type        | Description          |
| --------- | ----------- | -------------------- |
| body      | PhysicsBody | Parameter of destroy |

Returns void

## createCircle (static public member function of Physics)
| Parameter | Type     | Description               |
| --------- | -------- | ------------------------- |
| pos       | Vector2  | Parameter of createCircle |
| radius    | float    | Parameter of createCircle |
| type      | BodyType | Parameter of createCircle |

Returns PhysicsBody

## createRectangle (static public member function of Physics)
| Parameter | Type     | Description                  |
| --------- | -------- | ---------------------------- |
| pos       | Vector2  | Parameter of createRectangle |
| size      | Vector2  | Parameter of createRectangle |
| type      | BodyType | Parameter of createRectangle |

Returns PhysicsBody

## createPolygon (static public member function of Physics)
| Parameter | Type      | Description                |
| --------- | --------- | -------------------------- |
| pos       | Vector2   | Parameter of createPolygon |
| vertices  | Vector2[] | Parameter of createPolygon |
| closed    | bool      | Parameter of createPolygon |
| type      | BodyType  | Parameter of createPolygon |

Returns PhysicsBody

---

# class PhysicsBody

## position (public member function of PhysicsBody)
Returns Vector2

---

# static class ServerNetwork

## tick (static public member function of ServerNetwork)
Returns void

## setup (static public member function of ServerNetwork)
Returns void

## bufferedAmount (static public member function of ServerNetwork)
Returns int

## sendSignal (static public member function of ServerNetwork)
| Parameter  | Type   | Description             |
| ---------- | ------ | ----------------------- |
| receiverId | int    | Parameter of sendSignal |
| type       | string | Parameter of sendSignal |
| sdp        | string | Parameter of sendSignal |

Returns void

## sendIce (static public member function of ServerNetwork)
| Parameter  | Type   | Description          |
| ---------- | ------ | -------------------- |
| receiverId | int    | Parameter of sendIce |
| candidate  | string | Parameter of sendIce |

Returns void

## sendInputs (static public member function of ServerNetwork)
| Parameter  | Type | Description             |
| ---------- | ---- | ----------------------- |
| inputFrame | int  | Parameter of sendInputs |

Returns void

## sendSwitch (static public member function of ServerNetwork)
| Parameter    | Type           | Description             |
| ------------ | -------------- | ----------------------- |
| mode         | SendInputsMode | Parameter of sendSwitch |
| sendInterval | int            | Parameter of sendSwitch |

Returns void

## onSwitch (static public member function of ServerNetwork)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| buffer    | Buffer | Parameter of onSwitch |

Returns void

## sendReload (static public member function of ServerNetwork)
| Parameter  | Type | Description             |
| ---------- | ---- | ----------------------- |
| newRoom    | bool | Parameter of sendReload |
| newUserId  | bool | Parameter of sendReload |
| keepMaster | bool | Parameter of sendReload |

Returns void

## onReload (static public member function of ServerNetwork)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| buffer    | Buffer | Parameter of onReload |

Returns void

---

# static class snapshot

## compress (static public member function of snapshot)
| Parameter | Type    | Description           |
| --------- | ------- | --------------------- |
| input     | dynamic | Parameter of compress |

Returns string

## decompress (static public member function of snapshot)
| Parameter  | Type   | Description             |
| ---------- | ------ | ----------------------- |
| compressed | string | Parameter of decompress |

Returns dynamic

## testCompression (static public member function of snapshot)
Returns void

---

# class Sound
A sound

## open (public member function of Sound)
Returns void

## volume (public member function of Sound)
| Parameter | Type  | Description         |
| --------- | ----- | ------------------- |
| value     | float | Parameter of volume |

Returns void

## updateVolume (public member function of Sound)
Returns void

## stop (public member function of Sound)
Returns void

## play (public member function of Sound)
| Parameter        | Type | Description       |
| ---------------- | ---- | ----------------- |
| needsToBeCertain | bool | Parameter of play |

Returns void

## currentTime (public member function of Sound)
| Parameter | Type  | Description              |
| --------- | ----- | ------------------------ |
| value     | float | Parameter of currentTime |

Returns void

## isPlaying (public member function of Sound)
Returns bool

## fadeOut (public member function of Sound)
| Parameter | Type  | Description                                          |
| --------- | ----- | ---------------------------------------------------- |
| duration  | float | The duration of the fade out in milliseconds         |
| delay     | float | The delay before the fade out starts in milliseconds |

Returns Sound

---

# static class speech

## getVoices (static public member function of speech)
Returns SpeechSynthesisVoice[]

## nextVoice (static public member function of speech)
Returns void

## setup (static public member function of speech)
| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| language  | string | Parameter of setup |
| rate      | float  | Parameter of setup |

Returns void

## getVoice (static public member function of speech)
| Parameter | Type   | Description           |
| --------- | ------ | --------------------- |
| language  | string | Parameter of getVoice |

Returns VoicePreference

## say (static public member function of speech)
| Parameter | Type   | Description      |
| --------- | ------ | ---------------- |
| value     | string | Parameter of say |
| language  | string | Parameter of say |
| rate      | float  | Parameter of say |
| title     | string | Parameter of say |
| artist    | string | Parameter of say |
| position  | float  | Parameter of say |
| duration  | float  | Parameter of say |

Returns Promise<Promise>

## stop (static public member function of speech)
Returns void

## isSpeaking (static public member function of speech)
Returns bool

---

# class FadeAnimation

## tick (public member function of FadeAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class MoveAnimation

## tick (public member function of MoveAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class ScaleAnimation

## tick (public member function of ScaleAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class RotateAnimation

## tick (public member function of RotateAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class FadeSoundAnimation

## tick (public member function of FadeSoundAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class PlaySoundAnimation

## tick (public member function of PlaySoundAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class DelayAnimation

## tick (public member function of DelayAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class InterpolateAnimation

## tick (public member function of InterpolateAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

---

# class BezierAnimation

## tick (public member function of BezierAnimation)
| Parameter | Type  | Description       |
| --------- | ----- | ----------------- |
| progress  | float | Parameter of tick |

Returns void

## getPointOnBezierCurve (static public member function of BezierAnimation)
| Parameter  | Type      | Description                        |
| ---------- | --------- | ---------------------------------- |
| points     | Vector2[] | Parameter of getPointOnBezierCurve |
| progress   | float     | Parameter of getPointOnBezierCurve |
| smoothness | float     | Parameter of getPointOnBezierCurve |

Returns Vector2

---

# class DisplayImage

## draw (public member function of DisplayImage)
Returns void

---

# class DisplayText

## draw (public member function of DisplayText)
Returns void

---

# class DisplayTextWithHighlights

## draw (public member function of DisplayTextWithHighlights)
Returns void

---

# class DisplayRectangle

## draw (public member function of DisplayRectangle)
Returns void

---

# class DisplayRoundedRectangle

## draw (public member function of DisplayRoundedRectangle)
Returns void

---

# class DisplayPolygon

## draw (public member function of DisplayPolygon)
Returns void

---

# class DisplayCircle

## draw (public member function of DisplayCircle)
Returns void

---

# class DisplayLine

## draw (public member function of DisplayLine)
Returns void

---

# class DisplayVideo

## draw (public member function of DisplayVideo)
Returns void

---

# class HTMLInput

## remove (public member function of HTMLInput)
Returns void

## focus (public member function of HTMLInput)
Returns void

---

# class LobbyTextField

## clear (public member function of LobbyTextField)
Returns void

## focus (public member function of LobbyTextField)
| Parameter | Type | Description        |
| --------- | ---- | ------------------ |
| isFocused | bool | Parameter of focus |

Returns void

## tick (public member function of LobbyTextField)
Returns void

