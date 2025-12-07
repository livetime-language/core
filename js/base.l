// A number stored as a 32-bit integer
immutable struct int
	// Returns the absolute value of the integer
	// Example:
	//     int value = -10
	//     print value.abs 
	// Output:
	//     10
	importance:3 inline js
	int abs
		Math.abs(this)

	// Clamp the value to a specific range
	// Example: Ensure the player's health is between 0 and 100
	//     Player
	//         int health
	//         changeHealth: int delta
	//             health = (health + delta) clamp 0 to 100
	importance:4 inline js 
	int clamp: int from // The inclusive minimum value
		       int to   // The inclusive maximum value
		(this < from ? from : this > to ? to : this)
		
	// Make sure the value never falls below a minimum value
	// Example: Make sure the score is at least 0
	//     score = score atLeast 0
	importance:4 inline js 
	int atLeast: int value
		(this < value ? value : this)
	
	inline js 
	float atLeast: float value
		(this < value ? value : this)
	
	// Make sure the value never exceets a maximum value
	// Example: Make sure the percentage is at most 100
	//     percentage = percentage atMost 100
	importance:4 inline js 
	int atMost: int value
		(this > value ? value : this)

	// Format the integer as a string
	// Example: Format the integer as a string with the given minimum number of digits
	//     int number = 7
	//     print number.format(minIntegerDigits:3)
	// Output:
	//     007
	importance:4 inline js 
	string format: int minIntegerDigits = 1 // A value with a smaller number of integer digits than this number will be left-padded with zeros to the specified length
	               bool grouping = false    // Whether to use grouping separators, such as thousands separators
		this.toLocaleString("en-US", {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
			
	// ------------------------------------------- Operators -------------------------------------------

	inline int + int value
	inline float + float value
	
	inline int - int value
	inline float - float value
	
	inline int * int value
	inline float * float value
	
	inline float / int value
	inline float / float value
	
	inline int += int value
	inline int -= int value
	inline int *= int value

	inline int ++
	inline int --
	
	inline js int ** int value
		Math.pow(this, value)
		
	// The largest possible integer value
	const importance:5 maxValue = 2147483647
	
	// The smallest possible integer value
	const importance:5 minValue = -2147483648
	
	// The true modulo operator, like it's used in mathematics or Python, useful for wrapping around values. 
	// It returns the remainder after a floored division, always producing a result with the same sign as the divisor. 
	// In other words: A negative number modulo a positive value will always be positive. 
	// If you want the behaviour of the % operator of C, C++, C#, Java or JavaScript, use the remainder function instead.
	// Example:
	//     int a = 107 mod 100 // a =  7
	//     int b =  -1 mod 100 // b = 99
	importance:5 inline js 
	int mod: ensureSingleExecution int divisor // Returns the remainder of a floored division by this value
		(((this % divisor) + divisor) % divisor)
		
	// Returns the remainder after a truncated division, like the % operator in C, C++, C#, Java or JavaScript.
	// If you want the behaviour of the modulo operator of mathematics or Python, use the mod function instead.
	// Example:
	//     int a = 107 remainder 100 // a =  7
	//     int b =  -1 remainder 100 // b = -1
	importance:5 inline js 
	int remainder: int divisor // Returns the remainder of a truncated division by this value
		(this % divisor)
		
	// Returns true if the integer is not zero
	inline js bool toBool := this
	
	importance:4 inline js string toString := this?.toString()
		
	inline js int fromHex(string value) parseInt(value, 16)
		
	inline js string formatWithSpaces := this.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
		
	// Shift the bits of the int to the left. Excess bits shifted off to the left are discarded
	importance:3  inline js int shiftLeft: int count // The amount of bits to shift 
		(this << count)
	
	// Shift the bits of the int to the right. Excess bits shifted off to the right are discarded
	importance:3  inline js int shiftRight: int count // The amount of bits to shift 
		(this >> count)
		
	// Perform a bitwise "or" operation
	importance:3  inline js int bitwiseOr: implicit int value // The value to perform the bitwise "or" with
		(this | value)
	
	// Perform a bitwise "and" operation
	importance:3  inline js int bitwiseAnd: implicit int value // The value to perform the bitwise "and" with
		(this & value)
	
	// Check if a certain bit it set
	inline js bool isSet: implicit int value // The value of the bits to check (for example 1, 2, 4, 8, 16, ...)
		(this & value)
	
	// Check if a certain bit it not set
	inline js bool isNotSet: implicit int value // The value of the bits to check (for example 1, 2, 4, 8, 16, ...)
		!(this & value)
	
	// Set a specific bit of the integer
	inline js int setFlag: implicit int bitIndex // The index of the bit to set
		(this |= (1 << bitIndex))
	
	// Clear a specific bit of the integer
	inline js int clearFlag: implicit int bitIndex // The index of the bit to clear
		(this &= ~(1 << bitIndex))
		
	inline js int setIfLarger: int newValue
		(this = Math.max(newValue, this))
		
	inline js int incrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
		(this = (((this+1) % max) + max) % max)
	
	inline js int decrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
		(this = (((this-1) % max) + max) % max)
	
	inline js int incrementUpTo: int max
		(this < max ? ++this : max)
		
	inline js int incrementUpToExclusive: int max
		(this < max-1 ? ++this : max-1)
		
	inline js int incrementBy: int value
		                       int upTo
		(this+value < upTo ? (this += value) : upTo)
		
	inline js int decrementDownTo: int min
		(this > min ? --this : min)
		
	inline js int decrementDownToExclusive: int min
		(this > min+1 ? --this : min+1)
		
	inline js bool within: Range range
		(this >= range.from && this < range.to)
		
	inline js bool withinInclusively: Range range
		(this >= range.from && this <= range.to)
		
	inline js int assignIfGreater: int value
		(value > this ? this = value : this)
		
	static internal js TResult[] enumerate: int from, int to, TResult(int i) selector
		let result = []
		for(let i=from; i < to; ++i)
			result.push(selector(i))
		return result
		
	static internal js TResult[] enumerate: int from, int to, int step, TResult(int i) selector
		let result = []
		if(to > from && step > 0) {
			for(let i=from; i < to; i += step)
				result.push(selector(i))
		} else if(to < from && step < 0) {
			for(let i=from; i > to; i += step)
				result.push(selector(i))
		} 
		return result
		
	inline js TResult[] times: TResult(int i) selector
		int.enumerate(0, this, selector)

	// Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)
	const inline js int undefined := undefined
	
// A number stored as a double precision 64-bit floating point value
immutable struct float
	importance:3 inline js
	bool isNaN() isNaN(this)

	// Checks if the float is not NaN (Not a Number). If you convert a string to a float, it will be NaN if the string is not a valid number. 
	// Dividing by 0, or taking the square root of a negative number will also result in NaN.
	// Example:
	//     convertToFloat: string stringValue, float defaultValue = 0
	//         float floatValue = stringValue.toFloat
	//         return floatValue.isValidNumber ? floatValue : defaultValue
	importance:5 inline js
	bool isValidNumber() (!isNaN(this))

	// Returns the absolute value of the float
	// Example:
	//     float value = -3.14
	//     print value.abs 
	// Output:
	//     3.14
	importance:3 inline js int abs
		Math.abs(this)

	// Clamp the value to a specific range
	// Example: Ensure the player's health is between 0 and 100
	//     Player
	//         float health
	//         changeHealth: float delta
	//             health = (health + delta) clamp 0 to 100
	importance:4 inline js float clamp: float from // The inclusive minimum value
		                           float to   // The inclusive maximum value
		(this < from ? from : this > to ? to : this)
		
	// Make sure the value never falls below a minimum value
	// Example: Make sure the score is at least 0
	//     score = score atLeast 0
	importance:4 inline js float atLeast: float value
		(this < value ? value : this)
	
	// Make sure the value never exceets a maximum value
	// Example: Make sure the percentage is at most 100
	//     percentage = percentage atMost 100
	importance:4 inline js float atMost: float value
		(this > value ? value : this)

	importance:4 inline js string format: int fractionDigits, int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString("en-US", {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	inline js string format: int fractionDigits, bool grouping = false
		this.toLocaleString("en-US", {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, useGrouping:grouping})
		
	inline js string format: int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString("en-US", {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
				
	// Returns -1, 0, or 1 depending on the sign of the value
	importance:4 inline js float sign
		Math.sign(this)
		
	// Returns the smallest integer greater than or equal to the given value 
	importance:4 inline js int ceil
		Math.ceil(this)
		
	// Returns the largest integer less than or equal to the given value
	importance:4 inline js int floor
		Math.floor(this)
		
	// Returns the given value rounded to the nearest integer
	importance:4 inline js int round
		Math.round(this)
	
	importance:4 inline js bool isApproximately: float value
		                            float epsilon = 0.00001
		(Math.abs(this - value) < epsilon)
		
	// ------------------------------------------- Time -------------------------------------------
		
	// This is used to make it clear that a time is in milliseconds. All time values in LiveTime should be stored in milliseconds.
	// Example:
	//     float time = 500 milliseconds
	importance:3 inline js 
	float milliseconds := this
	
	// Convenience function to convert a time from seconds to milliseconds, since all time values in LiveTime should be stored in milliseconds.
	// Example:
	//     float time = 7 seconds
	//     print "Time in milliseconds: {time}"
	// Output:
	//     Time in milliseconds: 7000
	importance:3 inline js
	float seconds := (this*1000)
		
	// Convenience function to convert a time from minutes to milliseconds, since all time values in LiveTime should be stored in milliseconds.
	// Example:
	//     float time = 2 minutes
	//     print "Time in milliseconds: {time}"
	// Output:
	//     Time in milliseconds: 120000
	importance:3 inline js
	float minutes := (this*60000)
		
	// Convenience function to convert a time from hours to milliseconds, since all time values in LiveTime should be stored in milliseconds.
	// Example:
	//     float time = 2 hours
	//     print "Time in milliseconds: {time}"
	// Output:
	//     Time in milliseconds: 7200000
	importance:3 inline js
	float hours := (this*3600000)
	
	// Convenience function to convert a time from days to milliseconds, since all time values in LiveTime should be stored in milliseconds.
	// Example:
	//     float time = 2 days
	//     print "Time in milliseconds: {time}"
	// Output:
	//     Time in milliseconds: 172800000
	importance:3 inline js
	float days := (this*86400000)
	
	// Convenience function to convert a time from weeks to milliseconds, since all time values in LiveTime should be stored in milliseconds.
	// Example:
	//     float time = 2 weeks
	//     print "Time in milliseconds: {time}"
	// Output:
	//     Time in milliseconds: 1209600000
	importance:3 inline js
	float weeks := (this*604800000)
	
	// ------------------------------------------- Operators -------------------------------------------

	inline float + float value
	inline float - float value
	inline float / float value
	inline float * float value
	
	inline float += float value
	inline float -= float value
	inline float /= float value
	inline float *= float value
	
	inline bool < float value
	inline bool <= float value
	inline bool > float value
	inline bool >= float value

	inline bool !
	
	inline js float ** float value
		Math.pow(this, value)
		
	// The largest possible floating point value
	const importance:4 inline js
	float maxValue := Number.MAX_VALUE
	
	// The smallest possible floating point value
	const importance:4 inline js
	float minValue := -Number.MAX_VALUE
	
	// Positiv infinity
	const importance:4 inline js
	float infinity := Number.POSITIVE_INFINITY
	
	const inline js float epsilon := Number.EPSILON
	
	inline js float ** (float a, float b) 
		Math.pow(a,b)
		
	// The true modulo operator, like it's used in mathematics, useful for wrapping around values. 
	// It returns the remainder after a floored division, always producing a result with the same sign as the divisor. 
	// In other words: A number modulo a positive value will always be positive. 
	// This is different from the % operator in C, C++, C#, Java or JavaScript, which returns the remainder after a truncated division.
	// Example:
	//     float bufferSize = 100.0
	//     float a = 107.5 mod bufferSize // a =  7.5
	//     float b =  -0.5 mod bufferSize // b = 99.5
	importance:5 inline js 
	float mod: ensureSingleExecution float divisor // Returns the remainder of a floored division by this value
		(((this % divisor) + divisor) % divisor)
		
	// Returns the remainder after a truncated division, like the % operator in C, C++, C#, Java or JavaScript.
	// Example:
	//     float bufferSize = 100.0
	//     float a = 107.5 mod bufferSize // a =  7.5
	//     float b =  -0.5 mod bufferSize // b = -0.5
	// Output:
	//     7
	//     -1	
	importance:5 inline js 
	float remainder: float divisor // Returns the remainder of a truncated division by this value
		(this % divisor)
		
	inline js int toInt := Math.floor(this)
		
	// Returns true if the floot is not zero
	inline js bool toBool := this
	
	importance:4 inline js string toString := this.toString()
		
	importance:3 inline js float moveTowards: float value
		                         float speed = 1
		(this < value ? (this + speed < value ? (this += speed) : (this = value)) : (this - speed > value ? (this -= speed) : (this = value)))
		
	inline js float moveTowardsAndEaseOut: float value
		                                   float speed
		(this < value ? (this + speed * (value-this) < value ? (this += speed * (value-this)) : (this = value)) : (this - speed * (this-value) > value ? (this -= speed * (this-value)) : (this = value)))
		
	inline js float incrementBy: float value
		                         nocolon float to
		(this+value < to ? (this += value) : to)

	inline js string toOrdinalString() (this.toString() + (this % 10 == 1 && this % 100 != 11 ? "st" : this % 10 == 2 && this % 100 != 12 ? "nd" : this % 10 == 3 && this % 100 != 13 ? "rd" : "th"))
		
	// Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)
	const inline js int undefined := undefined
	
	
// A sequence of characters
js String
immutable class string
	// Returns the number of characters in the string
	importance:5 inline js int length := this.length
	
	// Returns a string with each character converted to uppercase
	importance:5 inline js string toUpperCase := this.toUpperCase()
		
	// Returns a string with each character converted to lowercase
	importance:5 inline js string toLowerCase := this.toLowerCase()
	
	// Returns true if the string is not null and not empty	
	inline js bool toBool := this
	inline js string toString() this
	importance:5 inline js int toInt := parseInt(this)
	importance:5 inline js int toFloat := parseFloat(this)
	
	importance:5 inline js dynamic parseJson() JSON.parse(this)
	importance:5 inline js dynamic parseYaml() yaml.parse(this)
		
	importance:4 inline js int parseInt(int radix) parseInt(this, radix)
	
	// Indicates that the variable isn't defined at all, useful for imported data (e.g. from JSON)
	const inline js string undefined := undefined
	
	// Splits the string at the given character into a list of substrings
	importance:5 inline js
	string[] split: string seperator = "," // Separate the string at this character
		this.split(seperator)
		
	string[] splitByLine: string seperator = "\n" // Separate the string at this character
		string[] result
		int start
		while start < this.length
			int end = this.indexOf(seperator, start)
			if end == -1: break
			if end > start+1: result.add this[start to end]
			start = end+1
		return result
		
	// Splits the string and return a list with the selected field or expression for each item
	inline js TValue[] splitToList: TValue(string it) selector // Selects a field or expression for each item
		                            string seperator = ","     // Separate the string at this character
		this.split(seperator).map(selector)
		
	// Splits the string, passes a list of strings to a function and returns its return value
	js TValue splitToObject: TValue(string[] it) selector // This functions gets a list of strings and should create an object from it
		                     string seperator = ","       // Separate the string at this character
		return selector(this.split(seperator))
		
	importance:5 inline js bool startsWith(string str) this.startsWith(str)
	importance:5 inline js bool endsWith(string str) this.endsWith(str)
		
	importance:5 inline js int indexOf(string str) this.indexOf(str)
	importance:5 inline js int indexOf(string str, int startPos) this.indexOf(str, startPos)
		
	importance:5 inline js int lastIndexOf(string str) this.lastIndexOf(str)
	importance:5 inline js int lastIndexOf(string str, int startPos) this.lastIndexOf(str, startPos)
		
	importance:5 inline js bool contains(string str) this.includes(str)

	importance:5 js bool isEmail() 
		// RFC 5322 compliant email validation
		// Check basic structure first
		if (!this || this.length > 254) return false;
		
		// Split into local and domain parts
		const atIndex = this.lastIndexOf('@');
		if (atIndex === -1 || atIndex === 0 || atIndex === this.length - 1) return false;
		
		const local = this.substring(0, atIndex);
		const domain = this.substring(atIndex + 1);
		
		// Validate local part (before @)
		// - Length: 1-64 characters
		// - Cannot start or end with a dot
		// - No consecutive dots
		// - Allowed characters: a-z, A-Z, 0-9, and .!#$%&'*+-/=?^_`{|}~
		if (local.length === 0 || local.length > 64) return false;
		if (local[0] === '.' || local[local.length - 1] === '.') return false;
		if (local.includes('..')) return false;
		if (!/^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+$/.test(local)) return false;
		
		// Validate domain part (after @)
		// - Length: 1-253 characters
		// - Must contain at least one dot
		// - Cannot start or end with a dot or hyphen
		// - No consecutive dots
		// - Each label (part between dots) must be 1-63 characters
		// - Labels can only contain a-z, A-Z, 0-9, and hyphens (not at start/end)
		if (domain.length === 0 || domain.length > 253) return false;
		if (!domain.includes('.')) return false;
		if (domain[0] === '.' || domain[domain.length - 1] === '.') return false;
		if (domain[0] === '-' || domain[domain.length - 1] === '-') return false;
		if (domain.includes('..')) return false;
		
		const labels = domain.split('.');
		for (let i = 0; i < labels.length; i++) {
			const label = labels[i];
			if (label.length === 0 || label.length > 63) return false;
			if (label[0] === '-' || label[label.length - 1] === '-') return false;
			if (!/^[a-zA-Z0-9-]+$/.test(label)) return false;
		}
		
		// Check that TLD is at least 2 characters and alphabetic
		const tld = labels[labels.length - 1];
		if (tld.length < 2 || !/^[a-zA-Z]+$/.test(tld)) return false;
		
		return true;
		
	inline js int getCharCodeAt(int index) this.charCodeAt(index)
		
	static inline js string fromCharCode(int charCode) String.fromCharCode(charCode)
		
	importance:5 inline js string substring: int from
		this.substring(from)
		
	importance:5 inline js 
	string substring: int from = 0
		              int to
		this.substring(from, to)
		
	js string getUntil: string value
		                int start = 0
		let index = this.indexOf(value, start)
		if(index != -1) return this.substring(start, index);
		if(start > 0)   return this.substring(start);
		                return this
		
	js string getUntilUnescaped: string character
		                         int start = 0
								 string escapeCharacter = "\\"
		for(let i=start; i<this.length; i++) {
			if(this[i] == character && (i==0 || this[i-1] != escapeCharacter)) {
				return this.substring(start, i); 
			}
		}
		return start > 0 ? this.substring(start) : this
		
	js string getUntilLast: string value
		                    int start = 0
		let index = this.lastIndexOf(value, start)
		if(index != -1) return this.substring(start, index);
		if(start > 0)   return this.substring(start);
		                return this
		
	js string getAfter: string value
		                int start = 0
		let index = this.indexOf(value, start)
		if(index == -1) return ""
		return this.substring(index+value.length)
		
	js string getBetween: string from
		                  string to
		                  int start = 0
		let index = this.indexOf(from, start)
		if(index == -1) return ""
		let startIndex = index + from.length
		let endIndex = this.indexOf(to, startIndex)
		if(endIndex == -1) return this.substring(startIndex)
		return this.substring(startIndex, endIndex)
		
	js string getBetweenLast: string from
		                      string to
		let index = this.lastIndexOf(from)
		let startIndex = index + from.length
		let endIndex = this.indexOf(to, startIndex)
		if(endIndex == -1) return this.substring(startIndex)
		return this.substring(startIndex, endIndex)
		
	// Returns 0 for an exact match, 1 if first is larger, -1 if second is larger
	inline js int compareTo: string value // The string to compare to
		this.localeCompare(value)
		
	importance:5 inline js string trim
		this.trim()
		
	importance:5 inline js string trimStart
		this.trimStart()
		
	importance:5 inline js string trimEnd
		this.trimEnd()
		
	js string trimQuotes
		return this.substring(this[0] == '"' ? 1 : 0, this[this.length-1] == '"' ? this.length-1 : this.length)
		
	js string trimTabs
		let lines = this.split("\n")
		if(lines.length < 2) return this
		let firstLine = lines[1]
		let tabs=0;
		while(tabs < firstLine.length-1 && firstLine[tabs] == "\t") tabs++;
		let result = ""
		for(let i=1; i<lines.length; i++) {
			let line = lines[i]
			if(line.length > tabs) {
				result += lines[i].substring(tabs) + "\n"
			}
		}
		return result
	
	js string getExtension
		let dot = this.lastIndexOf(".")
		if(dot != -1) return this.substring(dot+1)
		else          return ""
		
	inline js string interleaveWith: int charCode
		this.split("").join(String.fromCharCode(charCode))
		
	// Replace all occurrences of a string with another string
	importance:5 inline js
	string replaceAll: string occurrencesOf // Search for all occurrences of this string
		               nocolon string with  // Replace them with this string
		this.replaceAll(occurrencesOf, $with)
		
	inline js string padStart: int targetLength
		                       string padString = " "
		this.padStart(targetLength, padString)
		
	inline js string padEnd: int targetLength
		                     string padString = " "
		this.padEnd(targetLength, padString)
		
	inline js string get: int index
		this[index]
	
	inline js string get: int from = 0
		                  int to
		this.substring(from, to >= 0 ? to : to + this.length)
		
	inline js string get: int from = 0
		this.substring(from)
		
	js string capitalize
		return this.length > 0 ? this[0].toUpperCase() + this.substring(1) : this
		
	string capitalizeWords
		let result = ""
		let prevChar = " "
		for this
			if prevChar == " " and ("a" <= . <= "z"): result += .toUpperCase
			else                                      result += .
			prevChar = .
		return result
		
	string onlyLetters
		let result = ""
		for this
			if "a" <= . <= "z" or "A" <= . <= "Z"
				result += .
		return result
		
	string onlyNumbers
		let result = ""
		for this
			if "0" <= . <= "9"
				result += .
		return result
		
	inline string backspace
		(this.length ? this = this[0 to this.length-1] : this)
		
	bool isLetter
		return this.toLowerCase != this.toUpperCase

	// ------------------------------------------- Operators -------------------------------------------

	inline string + string value
	inline string += string value
	
	inline string < string value
	inline string <= string value
	inline string > string value
	inline string >= string value

	inline bool !
	
// A logical data type that can have the value true or false
enum bool: false, true
		
enum SortingOrder: Ascending, Descending
enum EachDistinctSortBy: DoNotSort = 0, SortByInteger = 1, SortByString = 2
	
// An array that grows and shrinks in size as needed
js Array
class List<T>
	// Do something for each item in a list
	inline js void each -> inline void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let i=0, _subject=this, _len=_subject.length; i<_len; ++i) do(_subject[i], i)
		
	inline js void each <- inline void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let _subject=this, i=_subject.length-1; i>=0; --i) do(_subject[i], i)
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	inline js void eachChangable -> inline void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let i=0, _subject=[...this], _len=_subject.length; i<_len; ++i) do(_subject[i], i)
		
	inline js void eachChangable <- inline void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let _subject=[...this], i=_subject.length-1; i>=0; --i) do(_subject[i], i)
			
	js void eachDistinct: TKey(T it) selector
		                  void(
		                      TKey it,
		                      T[] items,
		                      int i
		                  ) do
		if(this.length > 0) {
			let _subject = this
			let keys = _subject.map(selector);
			let distinctKeys = new Set(keys).values();
			let index = 0
			for(let key of distinctKeys) {
				let items = []
				for(let i=0; i<_subject.length; ++i) {
					if(keys[i] == key) items.push(_subject[i])
				}
				do(key, items, index++)
			}
		}
			
	// Add an item to the end of the list
	importance:5 inline js void add: T item // The item to add
		this.push(item)
		
	inline js void add: T item  // The item to add
		                T item2 // The second item to add
		this.push(item, item2)
		
	inline js void add: T item  // The item to add
		                T item2 // The second item to add
		                T item3 // The third item to add
		this.push(item, item2, item3)
		
	inline js void add: T item  // The item to add
		                T item2 // The second item to add
		                T item3 // The third item to add
		                T item4 // The fourth item to add
		this.push(item, item2, item3, item4)
		
	inline js void add: T item  // The item to add
		                T item2 // The second item to add
		                T item3 // The third item to add
		                T item4 // The fourth item to add
		                T item5 // The fifth item to add
		this.push(item, item2, item3, item4, item5)
		
	// Add an item and remove a item from the beginning if the length exceeds a maximum value
	inline js void add: T item        // The item to add
		                int maxLength // If the list gets longer than this maximum length, remove an item from the beginning
		this.push(item)
		if(this.length > maxLength) this.splice(0, 1)
			
	// Add an list of item to the end of the list
	inline js void add: T[] items // The list of items to add
		this.push(...items)
			
	// Add an list of items to the end of the list
	importance:5 inline js
	void addRange: T[] items // The list of items to add
		this.push(...items)
			
	// Insert an item at a given index
	importance:5 inline js
	void insert: T item    // The item to insert
		         index = 0 // Insert the item at this index
		this.splice(index, 0, item)
		
	// Insert an item at a given index
	importance:5 inline js 
	void insert: T item    // The item to insert
		         T after
		this.splice(this.indexOf(after)+1, 0, item)
		
	// Remove an item from the list
	// Example: Remove the current player instrance from the list of playeres when they died
	//     Player
    //         die
    //             alivePlayers.remove this
	importance:5 js 
	void remove: T item // The item to remove
		var index = this.indexOf(item);
		if(index > -1) this.splice(index, 1);
			
	js void remove: T item  // The first item to remove
		            T item2 // The second item to remove
		var index = this.indexOf(item);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item2);
		if(index > -1) this.splice(index, 1);
			
	js void remove: T item  // The first item to remove
		            T item2 // The second item to remove
		            T item3 // The third item to remove
		var index = this.indexOf(item);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item2);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item3);
		if(index > -1) this.splice(index, 1);
			
	js void remove: T item  // The first item to remove
		            T item2 // The second item to remove
		            T item3 // The third item to remove
		            T item4 // The forth item to remove
		var index = this.indexOf(item);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item2);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item3);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item4);
		if(index > -1) this.splice(index, 1);
			
	js void remove: T item  // The first item to remove
		            T item2 // The second item to remove
		            T item3 // The third item to remove
		            T item4 // The forth item to remove
		            T item5 // The fifth item to remove
		var index = this.indexOf(item);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item2);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item3);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item4);
		if(index > -1) this.splice(index, 1);
		var index = this.indexOf(item5);
		if(index > -1) this.splice(index, 1);
			
	// Remove a list of items from the list
	js void remove: T[] items // The items to remove
		for(let item of items) {
			var index = this.indexOf(item);
			if(index > -1) this.splice(index, 1);
		}
		
	// Remove the item at the given index from the list
	importance:5 inline js void removeAt: int index // The index of the item to remove
		this.splice(index, 1)
			
	// Remove a range of items from the list
	// Example: Remove the first 3 players from the list
	//     players.removeRange 0 to 3
	importance:5 inline js
	void removeRange: int from = 0   // Remove items starting from this index
		              nocolon int to // Remove items up to (but not including) this index
		this.splice(from, to-from)
			
	// Remove all item the meet a specific condition
	// Example: Remove all players that have died.
	//     Player
    //         bool hasDied
	//      app
    //          gameOver
    //              players.removeWhere.hasDied
	importance:5 removeWhere: bool(T a) condition // The condition to check
		for this <-
			if condition(.)
				removeAt i
		
	// Remove the first item the meet a specific condition
	// Example: Remove the first player with a health smaller than 10.
	//     Player
    //         int health
	//     app
    //         gameOver
    //             players.removeFirstWhere.health < 10
	importance:5 T removeFirstWhere: bool(T a) condition // The condition to check
		for this
			if condition(.)
				removeAt i
				return .
		return null
	
	// Add an item to the list if it isn't already in there
	importance:5 js void ensure: T item // The item to add
		if(!this.includes(item))
			this.push(item)
		
	// Add each item from a list if it isn't already in there
	importance:5 js void ensure: T[] items // The list of items to add
		for(let it of items)
			if(!this.includes(it))
				this.push(it)
		
	js void toggle: T item // The item to add
		let index = this.indexOf(item)
		if(index != -1) this.splice(index, 1)
		else            this.push(item)
		
	// Returns whether the list contains the given item
	importance:5 inline js bool contains: ensureSingleExecution T item // Check if the list contains this item
		(typeof(item) == "object" && item.equal ? this.some(a => item.equal(a)) : this.includes(item))
		
	importance:3 bool containsAny: T[] list
		for list
			if this contains .
				return true
		return false
		
	importance:3 bool containsNone: T[] list
		for list
			if this contains .
				return false
		return true
		
	// The index of an item in the list
	importance:5 inline js
	int indexOf: ensureSingleExecution T item // Get the index of this item
		(typeof(item) == "object" && item?.equal ? this.findIndex(a => item.equal(a)) : this.indexOf(item))
		
	inline js void setList: T[] list
		this.splice(0, this.length, ...list)
		
	void setFilteredList: T[] list
		                  bool(T a) condition
		clear
		for list: if condition(.): add .
		
	void setFilteredList: T[] list
		                  bool(T a) condition
		                  int maxCount
		clear
		int count = 0
		for list
			if condition .
				add .
				if ++count >= maxCount: break
		
	// Remove the last item from the list and return it
	// Example: Print and remove "Orange" from the list
	//     let fruits = ["Apple", "Lemon", "Orange"]
	//     print fruits.pop
	//     print fruits
	// Output:
	//     Orange
	//     [Apple, Lemon]
	importance:4 inline js T pop := this.pop()
		
	// Remove an item at a specific index from the list and return it
	// Example: Print and remove "Lemon" from the list
	//     let fruits = ["Apple", "Lemon", "Orange"]
	//     print fruits.popAt 1
	// Output:
	//     Lemon
	//     [Apple, Orange]
	importance:4 inline js T popAt: int index
		this.splice(index, 1)[0]
		
	// Remove a range of items from the list and return a new list containing the removed items
	// Example: Remote "Lemon" and "Orange" from the list of fruits a create a new list with those fruits 
	//     let fruits = ["Apple", "Pear", "Lemon", "Orange"]
	//     let citrusFruit  = fruits.popRange 2 to 4
	//     print citrusFruit
	// Output:
	//     [Apple, Pear]
	inline js T[] popRange: int from
		                    nocolon int to
		this.splice(from, to-from)
		
	// Remove the first item that meet a given condition and return it
	// Exmaple: Remove the first player with a health below 10
	//     let firstActivePlayer = players.popWhere.health < 10
	importance:2 T popWhere: bool(T a) condition // The condition for the item to meet
		for length()
			let item = get(i)
			if condition(item)
				removeAt i
				return item
		return null
	
	// Remove the first item from the list and return it
	// Example: Print and remove "Apple" from the list
	//     let fruits = ["Apple", "Lemon", "Orange"]
	//     print fruits.popFirst
	//     print fruits
	// Output:
	//     Apple
	//     [Lemon, Orange]
	importance:5 inline js T popFirst
		this.shift()
	
	// Gets the number of items in the list
	importance:5 inline js int length() this.length
	
	// Truncated or expands the list the given number of items
	js int setLength: int length // The new length of the list
		this.length = length
	
	// Removes all items from the list
	importance:5 inline js void clear := this.length = 0
	
	// Create a shallow clone of the list
	inline js T[] clone() [...this]
	
	// Create a string representation of the list
	js string toString()
		let result = "";
		for(let item of this) {
			if(result) result += ", ";
			result += item;
		}
		return "["+result+"]"
		
	// Gets a random item from the list
	importance:5 T random()
		let randomInteger = math.randomInteger(length)
		return get(randomInteger)
		
	importance:3 T randomWhere: bool(T a) condition
		let filteredList = this.where(condition)
		int index = math.randomInteger(filteredList.length)
		T item = filteredList[index]
		return item
	
	// Remove a random item from the list and return it
	importance:3 T popRandom()
		if length == 0: return null
		int index = math.randomInteger(length)
		T item = get(index)
		this.removeAt(index)
		return item
		
	importance:3 T popRandomWhere: bool(T a) condition
		let filteredList = this.where(condition)
		int index = math.randomInteger(filteredList.length)
		T item = filteredList[index]
		this.remove(item)
		return item
		
	T next: T currentItem
		int index = indexOf(currentItem)
		return this.get((index+1) mod length)
		
	T previous: T currentItem
		int index = indexOf(currentItem)
		return this.get((index-1) mod length)
		
	T next: T currentItem
		    label bool(T item) where
		int baseIndex = indexOf(currentItem)
		for this.length
			let item = this.get((baseIndex+i+1) mod length)
			if(where(item)) return item
		return null
		
	T prev: T currentItem
		int index = indexOf(currentItem)
		return index != -1 ? this.get((index-1) mod length) : this.get(length-1)
		
	T pickWithinRangeOrClosest: float(T a) selector
		                        float min = -float.infinity
		                        float max = float.infinity
		float closestDistance = float.infinity
		int closestIndex = -1
		T closestItem = null
		for this
			let value = selector(.)
			float distance
			if value > max: distance = value - max; else
			if value < min: distance = min - value; else
				            this.removeAt(i); return .
				
			if distance < closestDistance
				closestDistance = distance
				closestIndex = i
				closestItem = .
		
		if(closestIndex != -1) this.removeAt(closestIndex)
		return closestItem
			
	// Returns true if the list is not null and not empty	
	inline js bool toBool := (this != null && this.length != 0) 
	
	// Reverses the order of the items of the list in place
	importance:4 inline js T[] reverse() this.reverse()
		
	inline js T[] reversed() [...this].reverse()
		
	// Return a list with all unique items of the original list
	inline js T[] distinct() [...new Set(this)]
	
	// Moves an item to the end of the list
	importance:3 js void moveToBack: T item // The item to move to the end of the list
		var index = this.indexOf(item);
		if(index != -1) {
			let endIndex = this.length-1;
			for(let i=index; i<endIndex; ++i) {
				this[i] = this[i+1]
			}
			this[endIndex] = item
		}
		
	// Moves an item to the end of the list
	importance:3 js void moveToFront: T item // The item to move to the end of the list
		var index = this.indexOf(item);
		if(index != -1) {
			for(let i=index; i>0; --i) {
				this[i] = this[i-1]
			}
			this[0] = item
		}
		
	// Sort the list
	inline js T[] sort
		this.sort((a,b) => a - b)
	
	inline js T[] sort: float(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
		this.sort(comparer)
	
	// Sort the list by a given expression
	importance:5 T[] orderBy: float(T a) expression // First order by this expression
		return this.sort(expression(a) - expression(b))
		
	T[] orderBy: float(T it) expression           // First order by this expression
		         label nocolon float(T it) thenBy // Then order by this expression
		return this.sort(expression(a) - expression(b) || thenBy(a) - thenBy(b))
		
	importance:5 T[] orderBy: float(T it) expression            // First order by this expression
		         label nocolon string(T it) thenBy // Then order by this expression
		return this.sort(expression(a) - expression(b) || thenBy(a) compareTo thenBy(b))
		
	T[] orderBy: string(T it) expression           // First order by this expression
		         label nocolon float(T it) thenBy // Then order by this expression
		return this.sort(expression(a) compareTo expression(b) || thenBy(a) - thenBy(b))
		
	T[] orderBy: string(T a) expression // First order by this expression
		return this.sort(expression(a) compareTo expression(b))
		
	// Sort the list by a given expression
	importance:5 T[] orderBy: float(T a) expression // First order by this expression
		         SortingOrder order    // Specifies if you want to sort in ascending or descending order
		if order == Ascending: return this.sort(expression(a) - expression(b))
		else                   return this.sort(expression(b) - expression(a))
				
	// Returns true if the given condition is true for dynamic item in the list
	importance:4 inline js bool any: bool(T a) predicate // The condition to check
		this.some(predicate)
		
	importance:4 inline js bool none: bool(T a) predicate // The condition to check
		!this.some(predicate)
		
	// Returns true if the given condition is true for all items in the list
	importance:4 inline js bool all: bool(T a) predicate // The condition to check
		this.every(predicate)
		
	// Return a list that contains the selected field or expression for each item
	importance:4 inline js TValue[] select: TValue(
		                           T it,  // The current item of the list
		                           int i  // The index of the current item of the list
		                       ) selector // Selects a field or expression for each item
		this.map(selector)
		
	// Get the selected field or expression for each item and flattens the result
	inline js TValue[] flatten: TValue[](T it) selector
		this.flatMap(selector)
		
	// Find an item the meets the given condition
	// Example: Find a player with a specific id
	//     app
	//         getPlayerById: int id
	//             return players.find.id == id
	importance:5 inline js T find: bool(T a) condition // The condition to check
		this.find(condition)
		
	inline js T find: backwards bool(T a) condition // The condition to check
		this.findLast(condition)
		
	inline js T find: bool(T a) condition // The condition to check
		              int startIndex      // Start searching at this index
		Array.findStartingAtIndex(this, condition, startIndex)
		
	inline js T find: backwards bool(T a) condition // The condition to check
		              int startIndex                // Start searching at this index
		Array.findLastStartingAtIndex(this, condition, startIndex)
		
	private static T findStartingAtIndex: T[] list            // The list to search
		                                  bool(T a) condition // The condition to check
		                                  int startIndex = 0  // Start searching at this index
		for startIndex to list.length
			let it = list[.]
			if condition(it)
				return it
		return null
	
	private static T findLastStartingAtIndex: T[] list            // The list to search
		                                      bool(T a) condition // The condition to check
		                                      int startIndex = 0  // Start searching at this index
		for startIndex+1 backwards
			let it = list[.]
			if condition(it)
				return it
		return null
	
	// Execute a selector for each item and if it returns a value that isn't null, return this value
	// Example: Find object that is nested within another object
	//     transport.routes.findIn.trips.find.id == tripId
	TValue findIn: TValue(T it) selector
		for this
			let value = selector(it)
			if value != null: return value
		return null
		
	// Does the list have an item that meets the given condition?
	bool has: bool(T a) condition // The condition to check
		      int startIndex = 0  // Start searching at this index
		for startIndex to length
			if condition(this[.])
				return true
		return false
		
	// Find the index of the item the meets the given condition
	importance:3 int indexWhere: bool(T a) condition // The condition to check
		            int startIndex = 0  // Start searching at this index
		for startIndex to length
			if condition(this[.])
				return i
		return -1
		
	// Find the index of the item the meets the given condition
	int indexWhere: <- bool(T a) condition // The condition to check
		            int startIndex = 0     // Start searching at this index
		for length - startIndex <-
			if condition(this[.])
				return i
		return -1
		
	// Seaching backwards, find the last index of the item the meets the given condition
	int lastIndexWhere: bool(T a) condition // The condition to check
		                int startIndex = 0  // Start searching at this index
		for length - startIndex <-
			if condition(this[.])
				return i
		return -1
		
	importance:4 inline js T[] where: bool(T a) condition // The condition to check
		this.filter(condition)
		
	T[] except: T item 
		T[] result
		for this 
			if . != item
				result.add .
		return result
		
	importance:3 inline js T[] take: int count
		this.slice(0, count)
		
	importance:2 int total: int(T it) selector
		let sum = 0
		for this: sum += selector(.)
		return sum
		
	int total: int(T it) selector
		       label bool(T a) where
		let sum = 0
		for this: if where(.): sum += selector(.)
		return sum
		
	float total: float(T it) selector
		let sum = 0.0
		for this: sum += selector(.)
		return sum
		
	js int sum
		let sum = 0;
		for(let i=0; i<this.length; i++)
			sum += this[i];
		return sum;
	
	js float average
		return this.length > 0 ? this.sum() / this.length : 0
		
	string joinToString: string(T a) selector
		                 string separator = ", "
		let result = ""
		for this
			if result: result += separator
			result += selector(.)
		return result
		
	importance:5 shuffle
		for 1 to length <- i
			var j = math.floor(math.randomFloat * (i + 1))
			var temp = this.get(i)
			this.set(i, this.get(j))
			this.set(j, temp)
		return this
		
	shuffled := this.clone.shuffle
		
	private static transient T[] temporaryCopy = null
		
	js T percentile: int value
		if(this.length == 0) return 0
		if(this.length == 1) return this[0]
		if(!Array.temporaryCopy) Array.temporaryCopy = []
		const len = Array.temporaryCopy.length = this.length
		for(let i=0; i<len; ++i) Array.temporaryCopy[i] = this[i] 
		Array.temporaryCopy.sort((a,b) => a - b)
		return Array.temporaryCopy[Math.round((Array.temporaryCopy.length-1) * value / 100)]
		
	min: int(T a) selector 
		 int threshold = int.maxValue
		 int default = 0
		int resultValue = threshold
		for this
			let value = selector(.)
			if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	min: float(T a) selector 
		 float threshold = float.maxValue
		 float default = 0
		float resultValue = threshold
		for this
			let value = selector(.)
			if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	min: int(T a) selector 
		 int threshold = int.maxValue
		 int default = 0
		 label bool(T a) where
		int resultValue = threshold
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	min: float(T a) selector 
		 float threshold = float.maxValue
		 float default = 0
		 label bool(T a) where
		float resultValue = threshold
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: int(T a) selector
		 int threshold = int.minValue
		 int default = 0
		int resultValue = threshold
		for this
			let value = selector(.)
			if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: float(T a) selector
		 float threshold = float.minValue
		 float default = 0
		float resultValue = threshold
		for this
			let value = selector(.)
			if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: int(T a) selector
		 int threshold = int.minValue
		 int default = 0
		 label bool(T a) where
		int resultValue = threshold
		for this 
			if where(.)
				let value = selector(.)
				if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: float(T a) selector
		 float threshold = float.minValue
		 float default = 0
		 label bool(T a) where
		float resultValue = threshold
		for this
			if where(.)
				let value = selector(.)
				if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	maxUnique: int(T a) selector
		       int threshold = int.minValue
		       int default = 0
		int resultValue = threshold
		for this
			let value = selector(.)
			if value > resultValue:  resultValue = value; else
			if value == resultValue: resultValue = threshold
		return resultValue != threshold ? resultValue : default
		
	minIndex: float(T a) selector
		      int startIndex = 0
		      float threshold = float.maxValue
		float resultValue = threshold
		int index = -1
		for startIndex to length
			let value = selector(this[.])
			if value < resultValue
				resultValue = value
				index = i
		return index
		
	maxIndex: float(T a) selector
		      int startIndex = 0
		      float threshold = float.minValue
		float resultValue = threshold
		int index = -1
		for startIndex to length
			let value = selector(this[.])
			if value > resultValue
				resultValue = value
				index = i
		return index
		
	withMin: int(T a) selector
		     int threshold = int.maxValue
		int resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value < resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMin: float(T a) selector
		     float threshold = float.maxValue
		float resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value < resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMin: int(T a) selector
		     int threshold = int.maxValue
		     label bool(T a) where
		int resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMin: float(T a) selector
		     float threshold = float.maxValue
		     label bool(T a) where
		float resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
				
	withMax: int(T a) selector
		     int threshold = int.minValue
		int resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMax: float(T a) selector
		     float threshold = float.minValue
		float resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	popMax: int(T a) selector
		    int threshold = int.minValue
		int resultValue = threshold
		T resultItem = null
		int resultIndex = -1
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
				resultIndex = i
				
		if resultIndex != -1: removeAt resultIndex
		return resultItem
		
	popMax: int(T a) selector
		    float threshold = float.minValue
		float resultValue = threshold
		T resultItem = null
		int resultIndex = -1
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
				resultIndex = i
				
		if resultIndex != -1: removeAt resultIndex
		return resultItem
		
	withMax: int(T a) selector
		     int threshold = int.minValue
		     label bool(T a) where
		int resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value > resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMax: float(T a) selector
		     float threshold = float.minValue
		     label bool(T a) where
		float resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value > resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
		
	count: bool(T a) predicate
		int count = 0
		for this
			if predicate(.)
				count++
		return count
		
	countNot: bool(T a) predicate
		int count = 0
		for this
			if !predicate(.)
				count++
		return count
		
	rotate
		insert pop
		
	rotate: int count
		for count: insert pop
		
	js T[] intersectWith: T[] other
		const a = this || []
		const b = other || []
		const result = [];
		const dictionary = {};
		for (let i = 0, length = b.length; i < length; ++i) {
			dictionary[b[i]] = true;
		}
		for (let i = 0, length = a.length; i < length; ++i) {
			if (a[i] in dictionary) result.push(a[i]);
		}
		return result;
		
	// The first item of the list
	inline js T first() this[0]
	
	// The second item of the list
	inline js T second() this[1]
	
	// The last item of the list
	inline js T last() this[this.length-1]
		
	// Get an item from the list
	inline js T get: implicit int index // The index of the item to get
		this[index]
		
	// Get a new list that is a subset of this list
	inline js T[] get: int from = 0 // Return a new list starting from this index, a negative index will start from the end of the list
		               int to       // Return a new list up to (but not including) this index, a negative index is counted from the end
		this.slice(from, to)
	
	// Get a new list that is a subset of this list
	inline js T[] get: int from // Return a new list starting from this index, a negative index will start from the end of the list
		this.slice(from)
	
	// Set the item at a given index
	inline js T set: int index // The index of the item to set
		             T value   // The new value to set
		this[index] = value
		
	// Tries to get an item from the list. If it doesn't exist, it sets it.
	// TODO: Support index with side effect (e.g. list[index++] ?= 0)
	inline js T getOrSet: int index
		                  T value
		(this.hasOwnProperty(index) ? this[index] : this[index] = value)
		
	// Add a value to an item of the list
	inline js T addToItem: int index // The index of the item to change
		                   T value   // The value to add to the item
		this[index] += value
		
	// Subtract a value from an item of the list
	inline js T subtractFromItem: int index // The index of the item to change
		                          T value   // The value to subtract from the item
		this[index] -= value
		
	// Multiply an item of the list by a value
	inline js T multiplyItem: int index // The index of the item to change
		                      T value   // The value to multiply the item by
		this[index] *= value
		
	// Divide an item of the list by a value
	inline js T divideItem: int index // The index of the item to change
		                    T value   // The value to divide the item by
		this[index] /= value
		
	// Add 1 to item of the list
	inline js T incrementItem: int index // The index of the item to change
		this[index]++
	
	// Subtract 1 from an item of the list
	inline js T decrementItem: int index // The index of the item to change
		this[index]--
		
immutable ImmutableList<T>
	T[] list
	
	inline T get: implicit int index // The index of the item to get
		list[index]
		
// A hashtable that maps keys to values
js Map
class Dictionary<TKey, TValue>
	// Get the item assosiated with the given key
	inline js TValue get: TKey key  // The key of the item to get from the dictionary
		this.get(key)
	
	// Set the item for the given key
	inline js void set: TKey key     // The key of the item to add to the dictionary
		                TValue value // The item to add to the dictionary
		this.set(key, value)
		
	private js TValue setAndReturn: TKey key     // The key of the item to add to the dictionary
		                            TValue value // The item to add to the dictionary
		this.set(key, value);
		return value;
		
	inline js TValue getOrSet: TKey key
		                       TValue value
		(this.get(key) || this.setAndReturn(key, value))
		
	// Add a value to an item of the list
	js T addToItem: TKey key // The key of the item to add to the dictionary
		            TValue value   // The item to add to the dictionary
		let item = this.get(key)
		if(item) this.set(key, item + value)
		else     this.set(key, value)
		
	// Add 1 to item of the dictionary
	inline js T incrementItem: TKey key
		this.set(key, this.get(key)+1)
		
	// Subtract 1 to item of the dictionary
	inline js T decrementItem: TKey key
		this.set(key, this.get(key)-1)
		
	// Remove the item assosiated with the given key
	importance:5 inline js void remove: TKey key  // The key of the item to remove from the dictionary
		this.delete(key)
		
	// Does the dictionary have an item with a specific key?
	importance:5 inline js bool has: TKey key // The key of the item to check
		this.has(key)
		
	// Remove all items from the dictionary
	importance:5 inline js void clear
		this.clear()
		
	importance:5 inline js int length() this.size
		
	importance:3 js void removeWhere: bool(TValue it) condition // The condition to check
		for(var pair of this) {
			if(condition(pair[1])) {
				this.delete(pair[0]);
			}
		}

// A data container that stores unique values of a given type
js Set
class Set<T>
	inline js Set() new Set()
	inline js Set(T[] list) new Set(list)
	
	// Return a boolean indicating whether an element with the specified value exists in this set
	inline js bool get: T value // The value to check
		this.has(value)
	
	// Add a new element to this set, if there isn't already an element with the same value
	importance:5 inline js void add: T value // The value to add
		this.add(value)

	// Remove a value from the set
	importance:5 inline js void remove: T value // The value to remove
		this.delete(value)
		
	// Is a certain value in the set?
	importance:5 inline js bool has: T value // The value to check
		this.has(value)
	inline js T[] toList() [...this]
		
	// Remove all items from the set
	importance:5 inline js void clear
		this.clear()
		
	// Return the number of items in the set
	importance:5 inline js int length() this.size

// Specifies that a function doesn't return a value
immutable struct void
	
// Denotes a type that can be null
struct Nullable<T>
	
// A dynamic type. Useful for representing json and yaml data.
interface dynamic

// The base class for all classes
interface object
	static inline js dynamic undefined() undefined
	inline bool !
	
	inline js bool toBool() (this != null)
	inline js string toJson() JSON.stringify(this)
	// inline js string toString() object_stringify(this, 3)
	static inline js bool isEqualAndSameType(dynamic a, dynamic b) (a === b)
		
	static internal js string stringify: object subject, int depth = 0 
		switch(typeof subject)
		{
			case "object":
				if(subject === null) return "null"
				let result = ""
				if(subject.constructor) result += "_type: " + subject.constructor.name
				if(depth > 0) {
					for(let name in subject) {
						let item = object.stringify(subject[name], depth-1)
						if(item != "") {
							if(result) result += ", "
							result += name + ": " + item
						}
					}
				}
				return "\{" + result + "\}"
				
			case "string":
				return "\"" + subject + "\""
				
			case "undefined":
				return "\"undefined\""
				
			case "function":
				return ""
				
			default:
				return subject.toString()
		}

skipInit global unit Platform
	string libUrl
	global inline js async dynamic import: string file
		import((Platform.libUrl || _basePath || location.origin+"/")+file)

json
	importance:5 inline js dynamic parse: string value
		JSON.parse(value)
	importance:5 inline js string stringify: dynamic value
		JSON.stringify(value)

yaml
	dynamic lib
	setup
		if yaml.lib == null: yaml.lib = await Platform.import("lib/js-yaml.js")
	dynamic parse: string value
		return yaml.lib.load(value)

class Reference<T>
	dynamic container
	string key
	assign: T value
		container[key] = value
	implicit T toT
		return container[key]
	T value
		return container[key]
	inline bool toBool
		(this != null and this.container and this.container[this.key])
	inline bool ! 
		(this == null or this.container == null or !this.container[this.key])

struct Type<T>
	inline js string toString() this
		
// This struct is automatically filled with the source code location
internal transient immutable SourceCodeLocation
	string file
	int start
	int end
	SourceCodeLocation left
	SourceCodeLocation right
	
	inline js bool toBool() (this != null)
	inline js string toString() (this.file+":"+this.start)
			
	SourceCodeLocation find: string file, int pos
		if this.file and this.file == file and pos >= this.start and pos <= this.end
			return this
		if left != null
			let result = left.find file, pos
			if result != null: return result
		if right != null
			let result = right.find file, pos
			if result != null: return result
		return null
			
	SourceCodeLocation find: SourceCodeLocation location
		if file == location.file and start == location.start and end == location.end
			return this
		if left != null
			let result = left.find location
			if result != null: return result
		if right != null
			let result = right.find location
			if result != null: return result
		return null
		
	SourceCodeLocation leaf
		if file: return this
		if right
			let result = right.leaf
			if result: return result
		if left
			let result = left.leaf
			if result: return result
		return null
		
js Error
immutable Error
	string message
	string stack
	implicit inline js string toString := this.stack
	
// A collection of basic system functions
global transient priority unit System
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition // The condition to check
		                      inline void() then      // Do this if the condition is true
		if(condition) then()
			
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition          // The condition to check
		                      inline void() then               // Do this if the condition is true
		                      inline label nocolon void() else // Do this if the condition is false
		if(condition) then() @else else()
			
	global inline js T if: implicit bool condition
		                   T then
		                   label nocolon T else
		(condition ? then : else)
			
	// Executes code as long as a given condition is true
	global inline js void while: implicit bool condition // The condition to check
		                         inline void() do        // Do this while to condition is true
		while(condition) do()
			
	global inline js void loop: inline void() do
		for(;;) do()
	
	global inline js void do: inline void() do            // Do this while to condition is true
		                      nocolon implicit bool while // The condition to check
		@do do() 
		@while(while)
		
	global inline js Promise<T> promise: void(void(T a) resolve) resolve
		new Promise(resolve)
		
	inline js void doNotSerialize: dynamic object
		_constCache.push(object)
	
	// Do something a given number of times or for each item in a list
	global inline js void for: T[] subject    // The list to iterate over
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) do(_subject[i], i)
		
	// Do something a given number of times or for each item in a list
	global inline js void for: T[] subject    // The list to iterate over
		                       <- inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) do(_subject[i], i)
		
	// Do something a given number of times or for each item in a list
	global inline js void for: TValue[TKey] subject // The list to iterate over
		                       -> inline void(
		                           TValue it,       // The current item of the dictionary we are iterating over with the for-loop
		                           TKey key         // The current key of the dictionary we are iterating over with the for-loop
		                       ) do                 // Do this for each item in a list
		for(let _pair of subject) do(_pair[1], _pair[0])
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline js void forChangeable: T[] subject // The list to iterate over
		                       -> inline void(
		                           T it,             // The current item of the list we are iterating over with the for-loop
		                           int i             // The index of the current item of the list we are iterating over with the for-loop
		                       ) do                  // Do this for each item in a list
		for(let i=0, _subject=[...subject], _len=_subject.length; i<_len; ++i) do(_subject[i], i)
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline js void forChangeable: T[] subject // The list to iterate over
		                       <- inline void(
		                           T it,             // The current item of the list we are iterating over with the for-loop
		                           int i             // The index of the current item of the list we are iterating over with the for-loop
		                       ) do                  // Do this for each item in a list
		for(let _subject=[...subject], i=_subject.length-1; i>=0; --i) do(_subject[i], i)
		
	global inline js void for: int from       // The integer to start iterating from (for exmaple "for 2 to 5: print ." prints 2, 3, 4)
		                       -> inline void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       label int to   // The exclusive upper bound to iterate towards (for exmaple "for 3: print ." prints 0, 1, 2)
		for(let i=from; i<to; ++i) do(i)
		
	global inline js void for: int from       // The integer to start iterating from
		                       <- inline void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       label int to   // The exclusive upper bound to iterate towards
		for(let i=to-1; i>=from; --i) do(i)
		
	global inline js void for: int to         // The exclusive upper bound to iterate towards
		                       -> inline void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(let i=0; i<to; ++i) do(i)
		
	global inline js void for: int to         // The exclusive upper bound to iterate towards
		                       <- inline void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(let i=to-1; i>=0; --i) do(i)
		
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:null)
	global inline js void forLookAhead: T[] subject        // The list to iterate over
		                                    -> inline void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=_subject.length, i=0; i<_len; ++i) do(_subject[i], i+1<_len ? _subject[i+1] : null, i)
		
	global inline js void forLookAhead: T[] subject        // The list to iterate over
		                                    <- inline void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) do(_subject[i], i>0 ? _subject[i-1] : null, i)
		
	// [a,b,c] -> (prev:null, a), (prev:a, b), (prev:b, c)
	global inline js void forLookBack: T[] subject         // The list to iterate over
		                                    -> inline void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, i=0, _len=_subject.length; i<_len; ++i) do(_subject[i], i>0 ? _subject[i-1] : null, i)
		
	global inline js void forLookBack: T[] subject         // The list to iterate over
		                                    <- inline void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=subject.length, i=_len-1; i>=0; --i) do(_subject[i], i+1<_len ? _subject[i+1] : null, i)
		
	// [a,b,c] -> (prev:null, a, next:b), (prev:a, b, next:c), (prev:b, c, next:null)
	global inline js void forLookAheadAndBack: T[] subject // The list to iterate over
		                              -> inline void(
		                                  T it,            // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,          // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,          // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i            // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do                 // Do this for each triple in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) do(_subject[i], i>0 ? _subject[i-1] : null, i+1<_len ? _subject[i+1] : null, i)
		
	global inline js void forLookAheadAndBack: T[] subject // The list to iterate over
		                              <- inline void(
		                                  T it,            // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,          // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,          // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i            // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do                 // Do this for each triple in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) do(_subject[i], i+1<_len ? _subject[i+1] : null, i>0 ? _subject[i-1] : null, i)
		
	// [a,b,c] -> (a, next:b), (b, next:c)
	global inline js void forPairs: T[] subject  // The list to iterate over
		                            -> inline void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(let i=0, _subject=subject, _len=_subject.length-1; i<_len; ++i) do(_subject[i], _subject[i+1], i)
		
	global inline js void forPairs: T[] subject  // The list to iterate over
		                            <- inline void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(let _subject=subject, i=_subject.length-1; i>0; --i) do(_subject[i], _subject[i-1], i)
		
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:a) 
	global inline js void forWrappingPairs: T[] subject   // The list to iterate over
		                                   -> inline void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, i=0, _len=_subject.length; i<_len; ++i) do(_subject[i], _subject[(i+1)%_len], i)
		
	global inline js void forWrappingPairs: T[] subject   // The list to iterate over
		                                   <- inline void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) do(_subject[i], _subject[(((i-1)%_len)+_len)%_len], i)
		
	// [a,b,c] -> (prev:a, b, next:c)
	global inline js void forTriples: T[] subject  // The list to iterate over
		                              -> inline void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(let i=1, _subject=subject, _len=_subject.length-1; i<_len; ++i) do(_subject[i], _subject[i-1], _subject[i+1], i)
		
	global inline js void forTriples: T[] subject  // The list to iterate over
		                              <- inline void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(let _subject=subject, i=_subject.length-2; i>=1; --i) do(_subject[i], _subject[i+1], _subject[i-1], i)
		
	// [a,b,c] -> (prev:c, a, next:b), (prev:a, b, next:c), (prev:b, c, next:a)
	global inline js void forWrappingTriples: T[] subject // The list to iterate over
		                                     -> inline void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) do(_subject[i], _subject[(((i-1)%_len)+_len)%_len], _subject[(i+1)%_len], i)
		
	global inline js void forWrappingTriples: T[] subject // The list to iterate over
		                                     <- inline void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) do(_subject[i], _subject[(i+1)%_len], _subject[(((i-1)%_len)+_len)%_len], i)

	// Prints a message to the console with date
	// global js void print: logstring text // The text, variables or expressions to print
	// 	                  SourceCodeLocation location
	// 	let now = new Date()
	// 	let time = now.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(now.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+now.getFullYear()+" "+now.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+now.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+now.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+now.getMilliseconds().toLocaleString('en-US', {minimumIntegerDigits:3});
	// 	(location ? log(time + " " +text, location.start, location.file) : log(time + " " +text))
		
	// js void log: dynamic value
	// 	console.log(value)
	
	inline js void log: dynamic value
		console.log(value)
	
	inline js void log: dynamic value, dynamic value2
		console.log(value, value2)

	inline js void log: dynamic value, dynamic value2, dynamic value3
		console.log(value, value2, value3)
	
	// Display a message in the timeline
	global js void watch: logstring text // The text, variables or expressions to watch
		                  SourceCodeLocation sourceCodeLocation
		if(Platform.isDebug && core.frame >= core.frameWithNewWatches && sourceCodeLocation) {
			Platform.sendWatch(core.frame, text, sourceCodeLocation.start, sourceCodeLocation.file)
		}
		
	// Shows a dialog box with a given message
	global inline js void alert: implicit string message // The message to show
		alert(message)

	global inline js void alert: implicit string message // The message to show
	                             float delay             // Show the message after this delay in milliseconds
		setTimeout(() => alert(message), delay)
		
	global inline js void break() break
	global inline js void continue() continue
		
	global inline js void try: inline void() code
		                       inline nocolon void(Error error) catch
		try code() @catch(error) catch(error)
		
	global inline js void try: inline void() code
		                       inline nocolon void(Error error) catch
		                       inline nocolon void() finally
		try code() @catch(error) catch(error) @finally finally()
		
	global inline js void try: inline void() code
		                       inline nocolon void() finally
		try code() @finally finally()

	// Return an object that contains all global variables and functions
	global inline js dynamic globals() window
		
global transient priority low unit System		
	global inline js void for: string subject // Iterate over every character of this string
		                       -> inline void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) do(_subject[i], i)
	
	global inline js void for: string subject // Iterate over every character of this string
		                       <- inline void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) do(_subject[i], i)
				
	// Do something a given number of times or for each item in a list
	global inline js void forDynamic: dynamic subject // The list to iterate over
		                              -> inline void(
		                                  dynamic it, // The current item of the dynamic we are iterating over with the for-loop
		                                  string key  // The current key of the dynamic we are iterating over with the for-loop
		                              ) do            // Do this for each item in a list
		{let _subject=subject; for(let key in _subject) do(_subject[key], key)}
		
	// Creates a new list populated with the results of calling a function on every element of the list
	global inline js TResult[] for: T[] subject // The list to iterate over
		                       -> TResult(
		                           T it         // The current item of the list we are iterating over with the for-loop
		                       ) do             // Select the field or expression to be included in the result
		subject.map(do)
		
	// Creates a new list populated with the results of calling a function on every element of the list
	global inline js TResult[] for: T[] subject // The list to iterate over
		                       <- TResult(
		                           T it         // The current item of the list we are iterating over with the for-loop
		                       ) do             // Select the field or expression to be included in the result
		subject.map(do).reverse()
	
	global inline js TResult[] for: int to,    // The exclusive upper bound to iterate towards
		                            TResult(
		                                int i  // The iteration variable of the for-loop
		                            ) do       // Select the field or expression to be included in the result
		int.enumerate(0, to, do)
		
	global inline js TResult[] for: int from,    // The integer to start iterating from
		                            TResult(
		                                int i    // The iteration variable of the for-loop
		                            ) do         // Select the field or expression to be included in the result
		                            label int to // The exclusive upper bound to iterate towards
		                            nocolon label int step = 1
		int.enumerate2(from, to, step, do)
		
// A collection of mathematical functions and constants
global skipInit unit math
	// Returns the absolute value
	inline js int abs: int value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns the absolute value
	importance:5 inline js float abs: float value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns -1, 0, or 1 depending on the sign of the value
	importance:5 inline js float sign: float value
		Math.sign(value)
		
	// Returns the positive square root of the given value
	importance:5 inline js float sqrt: float value // The value to return the square root of
		Math.sqrt(value)
		
	inline js float hypot: float a
		                   float b
		Math.hypot(a, b)
		
	importance:3 moveTowards: float value
		         float targetValue
		         float speed = 1
		if targetValue > value: return math.min(value + speed, targetValue) else
		if targetValue < value: return math.max(value - speed, targetValue)
		
	// ------------------------------------------------------- floor, ceil, round -------------------------------------------------------
		
	// Returns the largest integer less than or equal to the given value
	importance:5 inline js int floor: float value // The value to round down
		Math.floor(value)
				
	// Returns the smallest integer greater than or equal to the given value 
	importance:5 inline js int ceil: float value // The value to round up
		Math.ceil(value)
		
	// Returns the given value rounded to the nearest integer
	importance:5 inline js int round: float value // The value to round
		Math.round(value)
				
	// ------------------------------------------------------- min, max -------------------------------------------------------
	
	inline js int min: int a // The first value
		               int b // The second value
		Math.min(a, b)
		
	// Returns the smallest of the given values
	importance:5 inline js float min: float a // The first value
		                              float b // The second value
		Math.min(a, b)
		
	// Returns the largest of the given values
	inline js int max: int a // The first value
		               int b // The second value
		Math.max(a, b)
		
	// Returns the largest of the given values
	importance:5 inline js float max: float a // The first value
		                              float b // The second value
		Math.max(a, b)
		
	// ------------------------------------------------------- Trigonometry -------------------------------------------------------
	
	// The angle of a half rotation (the ratio of a circle's circumference to its diameter)
	global const float pi = 3.141592653589793

	// The angle of a half rotation (pi)
	const float halfCircle = 3.141592653589793
	
	// The angle of a full rotation (the ratio of a circle's radius to its diameter)
	const float twoPi = 6.283185307179586

	// The angle of a full rotation (2*pi)
	const float fullCircle = 6.283185307179586

	// The angle of a quarter rotation
	const float halfPi = 1.5707963267948966

	// The angle of a quarter rotation (pi/2)
	const float quarterCircle = 1.5707963267948966
	
	// The angle of a eighth rotation
	const float quarterPi = 0.7853981633974483

	moveTowardsAngle: float value
		              float targetValue
		              float speed = 10
		if targetValue > value: return math.min(value + speed, targetValue) else
		if targetValue < value: return math.max(value - speed, targetValue)
	
	// Returns the sine of an angle in radians
	importance:5 float sin: float angle // The angle in radians (one full rotation is 2*pi)
		// Range reduction to [-pi, pi] using true modulo for stability
		float x = angle mod math.twoPi
		if x > math.pi: x -= math.twoPi
		
		// Use symmetries to fold into [-pi/2, pi/2]
		bool negate = false
		if x < 0
			negate = true
			x = -x
		if x > math.halfPi
			x = math.pi - x
		
		// 7th-order Taylor-like polynomial on [-pi/2, pi/2] in Horner form
		// sin(x) ≈ x * (1 + x^2*(-1/6 + x^2*(1/120 + x^2*(-1/5040))))
		float x2 = x * x
		float s = x * (1 + x2 * (-0.16666666666666666 + x2 * (0.008333333333333333 + x2 * (-0.0001984126984126984))))
		return negate ? -s : s

	// Returns the cosine of an angle in radians
	importance:5 float cos: float angle // The angle in radians (one full rotation is 2*pi)
		// Range reduction to [-pi, pi]
		float x = angle mod math.twoPi
		if x > math.pi: x -= math.twoPi
		
		// Use even symmetry and fold to [0, pi/2]
		x = math.abs(x)
		bool negate = false
		if x > math.halfPi
			x = math.pi - x
			negate = true
		
		// 8th-order polynomial (Taylor-like) on [0, pi/2]
		// cos(x) ≈ 1 + x^2*(-1/2 + x^2*(1/24 + x^2*(-1/720 + x^2*(1/40320))))
		float x2 = x * x
		float c = 1 + x2 * (-0.5 + x2 * (0.041666666666666664 + x2 * (-0.001388888888888889 + x2 * (0.000024801587301587304))))
		return negate ? -c : c
	
	// Returns the tangent of an angle in radians
	importance:5 float tan: float angle // The angle in radians (one full rotation is 2*pi)
		return sin(angle) / cos(angle)
			
	float atan: float x
		float absX = math.abs(x)
		// Use range reduction for better accuracy
		// For |x| > 1, use identity: atan(x) = π/2 - atan(1/x)
		bool useReduction = absX > 1
		if useReduction
			absX = 1 / absX
		
		// Polynomial approximation for range [0, 1]
		// More accurate minimax polynomial
		float x2 = absX * absX
		float result = absX * (0.99997726 + x2 * (-0.33262347 + x2 * (0.19354346 + x2 * (-0.04432514))))
		
		// Apply range reduction
		if useReduction
			result = math.pi / 2 - result
		
		return x < 0 ? -result : result
		
	float atan2: float y
	             float x
		if (x >= 0) { // -pi/2 .. pi/2
			if (y >= 0) { // 0 .. pi/2
				if (y < x) { // 0 .. pi/4
					return atan(y / x);
				} else { // pi/4 .. pi/2
					return math.halfPi - atan(x / y);
				}
			} else {
				if (-y < x) { // -pi/4 .. 0
					return atan(y / x);
				} else { // -pi/2 .. -pi/4
					return -math.halfPi - atan(x / y);
				}
			}
		} else { // -pi..-pi/2, pi/2..pi
			if (y >= 0) { // pi/2 .. pi
				if (y < -x) { // pi*3/4 .. pi
					return atan(y / x) + math.pi;
				} else { // pi/2 .. pi*3/4
					return math.halfPi - atan(x / y);
				}
			} else { // -pi .. -pi/2
				if (-y < -x) { // -pi .. -pi*3/4
					return atan(y / x) - math.pi;
				} else { // -pi*3/4 .. -pi/2
					return -math.halfPi - atan(x / y);
				}
			}
		}
		
	// ------------------------------------------------------- log, pow, exp -------------------------------------------------------
	
	// e raised to which power resuls in the given value?
	importance:5 inline js float log: float value
		Math.log(value)
		
	// 2 raised to which power resuls in the given value?
	importance:5 inline js float log2: float value
		Math.log2(value)
		
	// 10 raised to which power resuls in the given value?
	importance:5 inline js float log10: float value
		Math.log10(value)
		
	// Return the given base raised to the power of the given exponent
	importance:5 inline js float pow: float base
		                 float exponent
		Math.pow(base, exponent)
		
	// Returns e raised to the power of a given number
	importance:5 inline js float exp: float exponent
		Math.exp(exponent)
		
	// ------------------------------------------------------- Bit shifts -------------------------------------------------------
	
	inline js int shiftLeft: int value
		                     int count
		(value << count)
	
	inline js int shiftRight: int value
		                      int count
		(value >> count)
			
	// ------------------------------------------------------- Clamp -------------------------------------------------------
	
	clamp: int value
		   int min
		   int max
		if value < min: return min
		if value > max: return max
			            return value
	
	clamp: int value
		   int max
		if value > max: return max
			            return value
	
	clamp: int value
		   int min
		if value < min: return min
			            return value
	
	clamp: float value
		   float min
		   float max
		if value < min: return min
		if value > max: return max
			            return value
	
	clamp: float value
		   float max
		if value > max: return max
			            return value
			
	clamp: float value
		   float min
		if value < min: return min
			            return value
	
	// ------------------------------------------------------- Random -------------------------------------------------------
			
	static randomString: int length = 16
		string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		string token
		for length: token += chars[math.randomInteger chars.length-1]
		return token
		

struct RollingList
	int length = 30
	int fractionDigits = 1
	
	private float[] values
	private int index
	
	add: float value
		values[(index++ mod length)] = value
		
	measure: void() do
		let startTime = DateTime.preciseTime
		do
		values[index++ mod length] = DateTime.preciseTime - startTime
	
	average
		if values.length == 0: return 0.0
		float total
		for values: total += .
		return total / (values.length atMost length)
	
	max
		if values.length == 0: return 0.0
		float max = float.minValue
		for values: if . > max: max = .
		return max
	
	min
		if values.length == 0: return 0.0
		float min = float.maxValue
		for values: if . < min: min = .
		return min
	
	implicit string toString()
		return average.format(fractionDigits)

immutable Range
	int from // The start of the range
	int to   // The end of the range
	
	Range: int from       // The start of the range
		   nocolon int to // The end of the range
	
	inline js bool contains: int value
		(value >= this.from && value < this.from)
	
	inline js bool containsInclusively: int value
		(value >= this.from && value <= this.from)
		
class File
	float lastModified // The time the file was last modified in milliseconds
	string lastModifiedDate
	string name
	string path
	int size
	string type
	
	inline js string objectUrl() URL.createObjectURL(this)

enum Language: English, German, Spanish, French, Italian, Portuguese, Japanese, Chinese, Korean, Dutch, Turkish, Polish, Russian, Hindi, Arabic, Bengali, Urdu, Indonesian, Invariant = 1000

unit Loca
	private const string[] defaultLocaleForLanguage = ["en-001", "de-DE", "es-ES", "fr-FR", "it-IT", "pt-PT", "ja-JP", "zh-Hans-CN", "ko-KR", "nl-NL", "tr-TR", "pl-PL", "ru-RU", "hi-IN", "ar-001", "bn-BD", "ur-IN", "id-ID"]
	private const string[] languageNames = ["English", "German", "Spanish", "French", "Italian", "Portuguese", "Japanese", "Chinese", "Korean", "Dutch", "Turkish", "Polish", "Russian", "Hindi", "Arabic", "Bengali", "Urdu", "Indonesian", "Invariant"]
	
	visible Language[] supportedLanguages = [English, German]
	visible Language language = English
	visible string locale = defaultLocaleForLanguage[language]
	string languageName := languageNames[language]
	
	internal init
		setLanguage English
	
	js void setLanguage: Language language
		                 string locale = null
		Loca.language = language
		Loca.locale = locale || Loca.defaultLocaleForLanguage[language]
		
	js string format: int id
		let entry = _strings[Loca.language][id]
		if(!entry || entry.s.length == 0) return "##########"
		let strings = entry.s
		let result = strings[0]
		let stringIndex = 1
		for(let placeholderNumber of entry.p) {
			if(placeholderNumber >= 0) {
				// Placeholder
				//     "Step {currentStep}"                           {s:["Step "],p:[0]}
				//            ^                                           ^           ^
				let placeholderValue = arguments[placeholderNumber+1]
				result += placeholderValue
				if(stringIndex < strings.length) {
					let str = strings[stringIndex++]
					if(str) result += str
				}
			} else {
				// Placeholder with pluralization
				//     "Waiting for {playerCount} player[s]"          {s:["Waiting for ", " player.", " players."],p:[-1]}
				//                   ^                                                    ^           ^               ^
				// If the placeholder value is 1, we take the first string (sigular version), otherwise the second (plural version)
				let placeholderValue = arguments[-placeholderNumber]
				result += placeholderValue
				let str = strings[placeholderValue == 1 ? stringIndex : stringIndex+1]
				if(str) result += str
				stringIndex += 2
			}
		}
		return result
	
enum lowercase string NumberFormatLocaleMatcher
	lookup // The locale matching algorithm to use.
	bestFit = "best fit" // The locale matching algorithm to use.

enum lowercase string NumberFormatStyle
	decimal // For plain number formatting (default)
	currency // For currency formatting
	percent // For percent formatting.
	unit // For unit formatting.

enum lowercase string NumberFormatCurrencyDisplay
	code // Use the ISO currency code.
	symbol // Use a localized currency symbol such as €. (default)
	narrowSymbol // Use a narrow format symbol ("$100" rather than "US$100").
	name // Use a localized currency name such as "dollar".

enum lowercase string NumberFormatCurrencySign
	standard // Use standard minus sign for negative numbers. (default)
	accounting // Wrap the number with parentheses instead of appending a minus sign.

enum lowercase string NumberFormatUnitDisplay
	short // E.g., 16 l. (default)
	narrow // E.g., 16l.
	long // E.g., 16 litres.

enum lowercase string NumberFormatRoundingPriority
	auto // The result from the significant digits property is used. (default)
	morePrecision // The result from the property that results in more precision is used.
	lessPrecision // The result from the property that results in less precision is used.

enum lowercase string NumberFormatRoundingMode
	ceil // Round toward +∞. Positive values round up. Negative values round "more positive".
	floor // Round toward -∞. Positive values round down. Negative values round "more negative".
	expand // Round away from 0. The magnitude of the value is always increased by rounding.
	trunc // Round toward 0. This magnitude of the value is always reduced by rounding.
	halfCeil // Ties toward +∞. Values above the half-increment round like "ceil", and below like "floor".
	halfFloor // Ties toward -∞. Values above the half-increment round like "ceil", and below like "floor".
	halfExpand // Ties away from 0. Values above the half-increment round like "expand", and below like "trunc". (default)
	halfTrunc // Ties toward 0. Values above the half-increment round like "expand", and below like "trunc".
	halfEven // Ties towards the nearest even integer.

enum lowercase string NumberFormatTrailingZeroDisplay
	auto // Keep trailing zeros according to minimumFractionDigits and minimumSignificantDigits. (default)
	stripIfInteger // Remove the fraction digits if they are all zero.

enum lowercase string NumberFormatNotation
	standard // Plain number formatting. (default)
	scientific // Return the order-of-magnitude for formatted number.
	engineering // Return the exponent of ten when divisible by three.
	compact // String representing exponent; defaults to using the "short" form.

enum lowercase string NumberFormatCompactDisplay
	short // E.g., 1K. (default)
	long // E.g., 1 thousand.

enum lowercase string NumberFormatSignDisplay
	auto // Sign display for negative numbers only, including negative zero. (default)
	always // Always display sign.
	exceptZero // Sign display for positive and negative numbers, but not zero.
	negative // Sign display for negative numbers only, excluding negative zero.
	never // Never display sign.

enum lowercase string NumberFormatUseGrouping
	always // Display grouping separators even if the locale prefers otherwise.
	auto // Display grouping separators based on the locale preference.
	min2 // Display grouping separators when there are at least 2 digits in a group.
	false = "false" // Display no grouping separators.

dynamic NumberFormatOptions
	NumberFormatLocaleMatcher localeMatcher // The locale matching algorithm to use. Possible values are "lookup" and "best fit"; the default is "best fit".
	string numberingSystem // The numbering system to use for number formatting, such as "arab", "hans", "mathsans", and so on.
	NumberFormatStyle style // The formatting style to use.
	string currency // The currency to use in currency formatting. Possible values are the ISO 4217 currency codes, such as "USD" for the US dollar, "EUR" for the euro, or "CNY" for the Chinese RMB.
	NumberFormatCurrencyDisplay currencyDisplay // How to display the currency in currency formatting.
	NumberFormatCurrencySign currencySign // In many locales, accounting format means to wrap the number with parentheses instead of appending a minus sign.
	string unit // The unit to use in unit formatting. Possible values: "acre", "bit", "byte", "celsius", "centimeter", "day", "degree", "fahrenheit", "fluid-ounce", "foot", "gallon", "gigabit", "gigabyte", "gram", "hectare", "hour", "inch", "kilobit", "kilobyte", "kilogram", "kilometer", "liter", "megabit", "megabyte", "meter", "mile", "mile-scandinavian", "milliliter", "millimeter", "millisecond", "minute", "month", "ounce", "percent", "petabyte", "pound", "second", "stone", "terabit", "terabyte", "week", "yard", "year". Pairs of simple units can be concatenated with "-per-".
	NumberFormatUnitDisplay unitDisplay // The unit formatting style to use in unit formatting.
	int minimumIntegerDigits // The minimum number of integer digits to use. Possible values are from 1 to 21; the default is 1.
	int minimumFractionDigits // The minimum number of fraction digits to use. Possible values are from 0 to 100.
	int maximumFractionDigits // The maximum number of fraction digits to use. Possible values are from 0 to 100.
	int minimumSignificantDigits // The minimum number of significant digits to use. Possible values are from 1 to 21; the default is 1.
	int maximumSignificantDigits // The maximum number of significant digits to use. Possible values are from 1 to 21; the default is 21.
	NumberFormatRoundingPriority roundingPriority // Specify how rounding conflicts will be resolved if both "FractionDigits" and "SignificantDigits" are specified.
	int roundingIncrement // Indicates the increment at which rounding should take place relative to the calculated rounding magnitude. Possible values: 1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000, 2000, 2500, 5000.
	NumberFormatRoundingMode roundingMode // How decimals should be rounded.
	NumberFormatTrailingZeroDisplay trailingZeroDisplay // The strategy for displaying trailing zeros on whole numbers.
	NumberFormatNotation notation // The formatting that should be displayed for the number.
	NumberFormatCompactDisplay compactDisplay // Only used when notation is "compact".
	NumberFormatUseGrouping useGrouping // Whether to use grouping separators, such as thousands separators or thousand/lakh/crore separators.
	NumberFormatSignDisplay signDisplay // When to display the sign for the number.

js Intl.NumberFormat
NumberFormat
	inline js NumberFormat(string locale, NumberFormatOptions options) new Intl.NumberFormat(locale, options)
	inline js string format(float value) this.format(value)
