	
string PlainTimeString
	static PlainTimeString now := PlainDate.fromTime(Time.now - PlainDate.localTimezoneOffset, outputTimezone:0).toPlainTimeString
	
	inline js bool toBool := this
	inline string toString() this
	
	// (31.12.)
	inline string dayMonthString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayOfWeekDayMonthYearHourMinuteString()
		
	// (31.12.2000)
	inline string dayMonthYearString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayMonthYearString
		
	// (31 December 2000)
	inline string dayMonthNameYearString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayMonthNameYearString
		
	// (31 Dec)
	inline string dayShortMonthNameString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayShortMonthNameString
		
	// (31 December 2000)
	inline string dayOfWeekDayMonthNameYearString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayOfWeekDayMonthNameYearString
		
	// (Monday, December 31)
	inline string dayOfWeekDayMonthString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayOfWeekDayMonthString
		
	// (Monday)
	inline string dayOfWeekString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayOfWeekString
		
	// (Monday)
	inline string dayOfWeekShortString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayOfWeekShortString
		
	// (12:59 pm)
	inline string hourMinuteString: language = Loca.language
		PlainDate.fromTimeString(this)?.hourMinuteString
		
	// (Monday, December 31 at 12:59 pm)
	inline string dayOfWeekDayMonthAtHourMinuteString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayOfWeekDayMonthAtHourMinuteString
		
	// (Monday, 31 December 2000, 12:59 pm)
	inline string dayOfWeekDayMonthYearHourMinuteString: language = Loca.language
		PlainDate.fromTimeString(this)?.dayOfWeekDayMonthYearHourMinuteString

class string
	implicit inline PlainTimeString toPlainTimeString() this
		
// Calculate dates using pure math for better performance than the Date class.
// It does not handle the transition to and from daylight saving time and only has rudimentary timezone support.
immutable skipInit class PlainDate
	static inline js float preciseTime := performance.now()

	static internal inline js float realTime := Date.now()

	static int localTimezoneOffset, defaultTimezoneOffset

	init
		initTimezoneOffsets

	static js void initTimezoneOffsets
		PlainDate.localTimezoneOffset = PlainDate.defaultTimezoneOffset = new Date().getTimezoneOffset() * 60000

	const dayNames = [
		["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
	]
	const shortDayNames = [
		["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
	]
	const monthNames = [
		["","January","February","March","April","May","June","July","August","September","October","November","December"]
		["","Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
	]
	const shortMonthNames = [
		["","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
		["","Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
	]
	const atString = [" at ", " um "]
	const timeSuffixString = ["", " Uhr"]
	
	const daysInMonthCommon = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	const daysInMonthLeap = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

	float	time
	int	year
	int	month
	int	day
	int	dayOfWeek
	int	hour
	int	minute
	int	second
	int	milliseconds
	int	timezoneOffset
	
	string twoDigitDay	:= (this.day < 10 ? "0"+this.day : this.day.toString())
	string twoDigitMonth	:= (this.month < 10 ? "0"+this.month : this.month.toString())
	string twoDigitHour	:= (this.hour < 10 ? "0"+this.hour : this.hour.toString())
	string twoDigitMinute	:= (this.minute < 10 ? "0"+this.minute : this.minute.toString())
	string twoDigitSecond	:= (this.second < 10 ? "0"+this.second : this.second.toString())
	string threeDigitMilliseconds	:= (this.milliseconds < 10 ? "00"+this.milliseconds : this.milliseconds < 100 ? "0"+this.milliseconds : this.milliseconds.toString())

	static inline PlainDate current() PlainDate.fromTime(Time.now)
		
	static PlainDate fromTimeInSeconds: float timeInSeconds
		                               int outputTimezone = PlainDate.defaultTimezoneOffset
		return fromTime(timeInSeconds*1000, outputTimezone)
		
	static PlainDate fromTime: float time
		                      int outputTimezone = PlainDate.defaultTimezoneOffset
		if not time: return {0, 1970, 1, 1, 4, 0, 0, 0}
		const outputTime = time - outputTimezone
		const daysSinceEpoch = math.floor(outputTime / 86400000)
		
		// Year
		let currentYear = 1970;
		let daysLeft = daysSinceEpoch;
		
		loop
			let daysInYear = ((currentYear remainder 4) == 0 && (currentYear remainder 100) != 0) || (currentYear remainder 400 == 0) ? 366 : 365;
			if daysLeft < daysInYear: break
			daysLeft -= daysInYear
			currentYear++
		
		// Month and Day
		let daysInMonth = ((currentYear remainder 4) == 0 && (currentYear remainder 100) != 0) || (currentYear remainder 400 == 0) ? daysInMonthLeap : daysInMonthCommon
		let currentMonth = 0
		
		while daysLeft >= daysInMonth[currentMonth]
			daysLeft -= daysInMonth[currentMonth]
			currentMonth++
		
		return {
			time
			day: daysLeft + 1
			month: currentMonth + 1
			year: currentYear
			dayOfWeek: (daysSinceEpoch + 4) mod 7 // January 1, 1970 was a Thursday
			hour: math.floor (outputTime mod 86400000) / 3600000
			minute: math.floor (outputTime mod 3600000) / 60000
			second: math.floor (outputTime mod 60000) / 1000
			milliseconds: math.floor (outputTime mod 1000)
			timezoneOffset: outputTimezone
		}
	
	// Create a PlainDate object from a string like "2026-12-31 23:59:59" or "2026-12-31 23.59.59.999"
	static PlainDate fromString: string timeString
		                        int inputTimezone = PlainDate.defaultTimezoneOffset
		                        int outputTimezone = PlainDate.defaultTimezoneOffset
		return fromValues(
			year: (cast timeString[0..4]) or 1970
			month: (cast timeString[5..7]) or 1
			day: (cast timeString[8..10]) or 1
			hour: (cast timeString[11..13]) or 0
			minute: (cast timeString[14..16]) or 0
			second: (cast timeString[17..19]) or 0
			milliseconds: (cast timeString[20..23]) or 0
			inputTimezone: inputTimezone
			outputTimezone: outputTimezone
		)

	static PlainDate fromValues: int year = 1970
		                        int month = 1
		                        int day = 1
		                        int hour = 0
		                        int minute = 0
		                        int second = 0
		                        int milliseconds = 0
		                        int inputTimezone = PlainDate.defaultTimezoneOffset
		                        int outputTimezone = PlainDate.defaultTimezoneOffset
		const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
		
		// Calculate the number of days since the epoch for full years
		let days = 0;
		for 1970 to year
		    days += (.remainder(4) == 0 && .remainder(100) != 0) || (.remainder(400) == 0) ? 366 : 365;
		
		// Add days for the months of the current year
		for month - 1
		    days += daysInMonth[.]
		
		// Add a day if the current year is a leap year and month is after February
		if (month > 2 && (year mod 4 == 0 && year mod 100 != 0) || (year mod 400 == 0))
		    days += 1;
		
		// Add the days for the current month
		days += day - 1; // subtract 1 because we want "full days" before the current day
		
		// Convert the full days to milliseconds
		milliseconds += days * 24 * 60 * 60 * 1000;
		
		// Add hours, minutes, and seconds in milliseconds
		milliseconds += hour * 60 * 60 * 1000;
		milliseconds += minute * 60 * 1000;
		milliseconds += second * 1000;
		
		if inputTimezone == outputTimezone
			return {time: milliseconds + inputTimezone, year, month, day, dayOfWeek: (days + 4).remainder(7), hour, minute, second, timezoneOffset:outputTimezone}
		else
			return PlainDate.fromTime(milliseconds + inputTimezone, outputTimezone)

	static getDaysInMonth: int month, int year
		let daysInMonth = ((year remainder 4) == 0 && (year remainder 100) != 0) || (year remainder 400 == 0) ? daysInMonthLeap : daysInMonthCommon
		return daysInMonth[month-1]

	// (31.12.)
	dayMonthString: language = Loca.language
		if language == German return "{day}.{month}."
		else                  return "{month}-{day}"
		
	// (31.12.2000)
	dayMonthYearString: language = Loca.language
		if language == German return "{twoDigitDay}.{twoDigitMonth}.{year}"
		else                  return "{year}-{twoDigitMonth}-{twoDigitDay}"
	
	// (31 December 2000)
	dayMonthNameYearString: language = Loca.language
		return "{day} {monthNames[language][month]} {year}"
		
	// (31 Dec)
	dayShortMonthNameString: language = Loca.language
		return "{day} {shortMonthNames[language][month]}"
		
	// (31 December 2000)
	dayOfWeekDayMonthNameYearString: language = Loca.language
		return "{dayNames[language][dayOfWeek]}, {day} {monthNames[language][month]} {year}"
		
	// (Monday, December 31)
	dayOfWeekDayMonthString: language = Loca.language
		if language == German return "{dayNames[language][dayOfWeek]}, {day}. {monthNames[language][month]}"
		else                  return "{dayNames[language][dayOfWeek]}, {day} {monthNames[language][month]}"
			
	// (Monday)
	dayOfWeekString: language = Loca.language
		return dayNames[language][dayOfWeek]
		
	// (Monday)
	dayOfWeekShortString: language = Loca.language
		return shortDayNames[language][dayOfWeek]
		
	// (12:59 pm)
	hourMinuteString: language = Loca.language
		if language == German: return ""+hour+":"+(minute < 10 ? "0":"")+minute+" Uhr"
		else                   return ""+(((hour-1) mod 12)+ 1)+":"+(minute < 10 ? "0":"")+minute+(hour < 12 ? " am":" pm")
		
	// (Monday, December 31 at 12:59 pm)
	dayOfWeekDayMonthAtHourMinuteString: language = Loca.language
		return dayOfWeekDayMonthString(language) + atString[language] + hourMinuteString(language) + timeSuffixString[language]
		
	// (Monday, 31 December 2000, 12:59 pm)
	dayOfWeekDayMonthYearHourMinuteString: language = Loca.language
		return dayOfWeekDayMonthNameYearString(language) + ", " + hourMinuteString(language)
		
	// (20001231235959+02:00)
	compactString
		return "{year}{twoDigitMonth}{twoDigitDay}T{twoDigitHour}{twoDigitMinute}{twoDigitSecond}+02:00"

	static PlainDate fromTimeString: TimeString timeString
		return fromIsoString(cast timeString)
	
	static PlainDate fromTimeString: PlainTimeString timeString
		return fromIsoString(cast timeString, outputTimezone:0)
	
	// With Milliseconds		
	//            1  1  1  2   2. 2
	// 0    5  8  1  4  7  0   4  7           	
	// 2024-10-17 15:23:30.504+02:00
	// 2024-10-17 15:23:30.504Z
	// 
	// Without Milliseconds
	//            1  1  1  2  2
	// 0    5  8  1  4  7  0  3
	// 2024-10-17 15:23:30+02:00
	// 2024-10-17 15:23:30Z
	static PlainDate fromIsoString: string str
		                           int outputTimezone = PlainDate.defaultTimezoneOffset
		if not str or str.length < 19: return null
		let hasMilliseconds = str[19] == "."
		let timezoneIndex = hasMilliseconds ? 24 : 20
		let timezoneSign = str[timezoneIndex-1]
		return PlainDate.fromValues(
			year:	cast str[ 0.. 4]
			month:	cast str[ 5.. 7]
			day:	cast str[ 8..10]
			hour:	cast str[11..13]
			minute:	cast str[14..16]
			second:	cast str[17..19]
			milliseconds:	hasMilliseconds ? cast str[20..23] : 0
			inputTimezone:	timezoneSign == "Z" ? 0 : (cast str[timezoneIndex..timezoneIndex+2])*3600000*(timezoneSign == "-" ? 1:-1)
			outputTimezone
		)
		
	implicit PlainTimeString toPlainTimeString
		return cast "{year}-{twoDigitMonth}-{twoDigitDay} {twoDigitHour}:{twoDigitMinute}:{twoDigitSecond}.{threeDigitMilliseconds}Z"
		
	static measure: void() do
		let startTime = preciseTime
		do
		return preciseTime - startTime
	