struct float
	// (31.12.)
	inline string toDayMonthString(language = Loca.language) DateTime.fromTime(this).dayMonthString(language)
		
	// (31.12.2000)
	inline string toDayMonthYearString(language = Loca.language) DateTime.fromTime(this).dayMonthYearString(language)
	
	// (31 December 2000)
	inline string toDayMonthNameYearString(language = Loca.language) DateTime.fromTime(this).dayMonthNameYearString(language)
	
	// (Monday, December 31)
	inline string toDayOfWeekDayMonthString(language = Loca.language) DateTime.fromTime(this).dayOfWeekDayMonthString(language)
	
	// (Monday)
	inline string toDayOfWeekString(language = Loca.language) DateTime.fromTime(this).dayOfWeekString(language)
	
	// (Monday, December 31 at 12:59 pm)
	inline string toDayOfWeekDayMonthAtHourMinuteString(language = Loca.language) DateTime.fromTime(this).dayOfWeekDayMonthAtHourMinuteString(language)
	
	// (23:59) The time is assumed to be local time, doesn't account for timezone offset
	// inline string toHourMinuteString(language = Loca.language) DateTime.toHourMinuteString(this, language)
		
	// // (23:59) The time is assumed to be local time, doesn't account for timezone offset
	// static string toHourMinuteString: float value, language = Loca.language
	// 	let hour = math.floor (value mod 86400000) / 3600000
	// 	let minute = math.floor (value mod 3600000) / 60000
	// 	if language == English: return ""+((hour-1) mod 12+1)+":"+(minute < 10 ? "0":"")+minute+(hour < 12 ? " am":" pm")
	// 	else                    return ""+hour+":"+(minute < 10 ? "0":"")+minute
	
 	// (59:59) The time is assumed to be local time, doesn't account for timezone offset
	inline js string toMinuteSecondString() (Math.floor((this mod 3600000) / 60000) + (this mod 60000 < 10000 ? ":0":":") + Math.floor((this mod 60000) / 1000))
	
	// (23:59:59)
	inline js string toHourMinuteSecondString(language = Loca.language) new Date(this).hourMinuteSecondString(language)
	
	// (31.12.2000 23:59)
	inline js string toDayMonthYearHourMinuteString(language = Loca.language) new Date(this).dayMonthYearHourMinuteString(language)
	
	// (31.12.2000 23:59:59)
	inline js string toDayMonthYearHourMinuteSecondString(language = Loca.language) new Date(this).dayMonthYearHourMinuteSecondString(language)
	
	// (31-12-2000 23-59-59)
	inline js string toInvariantDayMonthYearHourMinuteSecondString() new Date(this).invariantDayMonthYearHourMinuteSecondString()
			
	// (20001231235959+02:00)
	inline js string toCompactTimeString() DateTime.fromTime(this).compactString()
		
	// (7 weeks)
	// inline string toMinutesHoursDaysOrWeeksString(showWeeksAfterDays = 31) toMinutesHoursDaysOrWeeksString(this, showWeeksAfterDays)
	
	static float fromTimeString(string timeString)
		if !timeString: return 0 milliseconds
		float value = 0
		int colon1 = timeString.indexOf(":")
		if(colon1 == -1)
			value += int(timeString)*3600000
		else
			value += int(timeString.substring(0, colon1))*3600000
			int colon2 = timeString.indexOf(":", colon1+1)
			if(colon2 == -1)
				value += int(timeString.substring(colon1+1))*60000
			else
				value += int(timeString.substring(colon1+1, colon2))*60000
				value += int(timeString.substring(colon2+1))*1000
		return value
		
	static inline js float fromIsoString: string isoString
		new Date(isoString).getTime()
		
	// static inline js float fromValues(int year, int month=1, int day=1, int hour = 0, int minute = 0, int second = 0) new Date(year, (month)-1, day, hour, minute, second).getTime()
		
	inline js int timeMilliseconds := Math.floor((this mod    1000)          ) 
	inline js int timeSeconds      := Math.floor((this mod   60000) /    1000) 
	inline js int timeMinutes      := Math.floor((this mod 3600000) /   60000) 
	inline js int timeHours        := Math.floor((this            ) / 3600000)
		
	inline js int totalSeconds      := Math.floor(this /      1000) 
	inline js int totalMinutes      := Math.floor(this /     60000) 
	inline js int totalHours        := Math.floor(this /   3600000)
	inline js int totalDays         := Math.floor(this /  86400000)
	inline js int totalWeeks        := Math.floor(this / 604800000)
		
	private static string toMinutesHoursDaysOrWeeksString: float time, showWeeksAfterDays = 31
		if time < 2 minutes: return "1 minute"
		if time < 1 hours:   return "{time.totalMinutes} minutes"
		if time < 2 hours:   return "1 hour"
		if time < 1 days:    return "{time.totalHours} hours"
		if time < 2 days:    return "1 day"
		if time < showWeeksAfterDays days: return "{time.totalDays} days"
		if time < 2 weeks:   return "1 week"
		                     return "{time.totalWeeks} weeks"

	js static void startTimer() window._timerStart = performance.now()
	js static void printTimer(string text) log(text+": "+(performance.now()-window._timerStart))
	static inline js float preciseTime := performance.now()
		
string TimeString
	static TimeString now := cast DateTime.fromTime(Time.now, outputTimezone:0).toTimeString
	static TimeString fromTime(float value) := cast DateTime.fromTime(value, outputTimezone:0).toTimeString
	
	inline js bool toBool := this
	inline string toString() this
	
	// (31.12.)
	inline string dayMonthString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthYearHourMinuteString()
		
	// (31.12.2000)
	inline string dayMonthYearString: language = Loca.language
		DateTime.fromTimeString(this)?.dayMonthYearString
		
	// (31 December 2000)
	inline string dayMonthNameYearString: language = Loca.language
		DateTime.fromTimeString(this)?.dayMonthNameYearString
		
	// (31 Dec)
	inline string dayShortMonthNameString: language = Loca.language
		DateTime.fromTimeString(this)?.dayShortMonthNameString
		
	// (31 December 2000)
	inline string dayOfWeekDayMonthNameYearString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthNameYearString
		
	// (Monday, December 31)
	inline string dayOfWeekDayMonthString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthString
		
	// (Monday)
	inline string dayOfWeekString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekString
		
	// (Monday)
	inline string dayOfWeekShortString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekShortString
		
	// (12:59 pm)
	inline string hourMinuteString: language = Loca.language
		DateTime.fromTimeString(this)?.hourMinuteString
		
	// (Monday, December 31 at 12:59 pm)
	inline string dayOfWeekDayMonthAtHourMinuteString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthAtHourMinuteString
		
	// (Monday, 31 December 2000, 12:59 pm)
	inline string dayOfWeekDayMonthYearHourMinuteString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthYearHourMinuteString
	
string PlainTimeString
	static PlainTimeString now := DateTime.fromTime(Time.now - DateTime.localTimezoneOffset, outputTimezone:0).toPlainTimeString
	
	inline js bool toBool := this
	inline string toString() this
	
	// (31.12.)
	inline string dayMonthString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthYearHourMinuteString()
		
	// (31.12.2000)
	inline string dayMonthYearString: language = Loca.language
		DateTime.fromTimeString(this)?.dayMonthYearString
		
	// (31 December 2000)
	inline string dayMonthNameYearString: language = Loca.language
		DateTime.fromTimeString(this)?.dayMonthNameYearString
		
	// (31 Dec)
	inline string dayShortMonthNameString: language = Loca.language
		DateTime.fromTimeString(this)?.dayShortMonthNameString
		
	// (31 December 2000)
	inline string dayOfWeekDayMonthNameYearString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthNameYearString
		
	// (Monday, December 31)
	inline string dayOfWeekDayMonthString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthString
		
	// (Monday)
	inline string dayOfWeekString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekString
		
	// (Monday)
	inline string dayOfWeekShortString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekShortString
		
	// (12:59 pm)
	inline string hourMinuteString: language = Loca.language
		DateTime.fromTimeString(this)?.hourMinuteString
		
	// (Monday, December 31 at 12:59 pm)
	inline string dayOfWeekDayMonthAtHourMinuteString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthAtHourMinuteString
		
	// (Monday, 31 December 2000, 12:59 pm)
	inline string dayOfWeekDayMonthYearHourMinuteString: language = Loca.language
		DateTime.fromTimeString(this)?.dayOfWeekDayMonthYearHourMinuteString
		
class string
	implicit inline PlainTimeString toPlainTimeString := this
	implicit inline TimeString toTimeString := this

struct float
	inline DateTime toDateTime() DateTime.fromTime(this)
	inline DateTime toDateTimeWithoutTimezone() DateTime.fromTime(this, outputTimezone:0)

class string
	inline DateTime toDateTime() DateTime.fromString(this)
	inline DateTime toDateTimeWithoutTimezone() DateTime.fromString(this, inputTimezone:0, outputTimezone:0)

// Calculate dates using pure math for better performance without using the Date class
immutable skipInit class DateTime
	static inline js float preciseTime := performance.now()

	static internal inline js float realTime := Date.now()

	static int localTimezoneOffset, defaultTimezoneOffset

	init
		initTimezoneOffsets

	static js void initTimezoneOffsets
		DateTime.localTimezoneOffset = DateTime.defaultTimezoneOffset = new Date().getTimezoneOffset() * 60000

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

	static inline DateTime current() DateTime.fromTime(Time.now)
		
	static DateTime fromTimeInSeconds: float timeInSeconds
		                               int outputTimezone = DateTime.defaultTimezoneOffset
		return fromTime(timeInSeconds*1000, outputTimezone)
		
	static DateTime fromTime: float time
		                      int outputTimezone = DateTime.defaultTimezoneOffset
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
	
	// Create a DateTime object from a string like "2026-12-31 23:59:59" or "2026-12-31 23.59.59.999"
	static DateTime fromString: string timeString
		                        int inputTimezone = DateTime.defaultTimezoneOffset
		                        int outputTimezone = DateTime.defaultTimezoneOffset
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

	static DateTime fromValues: int year = 1970
		                        int month = 1
		                        int day = 1
		                        int hour = 0
		                        int minute = 0
		                        int second = 0
		                        int milliseconds = 0
		                        int inputTimezone = DateTime.defaultTimezoneOffset
		                        int outputTimezone = DateTime.defaultTimezoneOffset
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
			return DateTime.fromTime(milliseconds + inputTimezone, outputTimezone)

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

	static DateTime fromTimeString: TimeString timeString
		return fromIsoString(cast timeString)
	
	static DateTime fromTimeString: PlainTimeString timeString
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
	static DateTime fromIsoString: string str
		                           int outputTimezone = DateTime.defaultTimezoneOffset
		if not str or str.length < 19: return null
		let hasMilliseconds = str[19] == "."
		let timezoneIndex = hasMilliseconds ? 24 : 20
		let timezoneSign = str[timezoneIndex-1]
		return DateTime.fromValues(
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
	
	implicit TimeString toTimeString
		return cast "{year}-{twoDigitMonth}-{twoDigitDay} {twoDigitHour}:{twoDigitMinute}:{twoDigitSecond}.{threeDigitMilliseconds}Z"
	
	static measure: void() do
		let startTime = preciseTime
		do
		return preciseTime - startTime
		
// Calculate dates using the JavaScript Date class
js(Date) internal transient class Date
	inline js Date() new Date()
	static inline js Date now := new Date()
		
	const dayStrings = [
		["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
	]
		
	const shortDayStrings = [
		["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
	]
	
	inline js int year := this.getFullYear()
	inline js int month := (this.getMonth()+1)
	inline js int day := this.getDate()
	inline js int dayOfWeek := this.getDay()
		
	inline js int hour := this.getHours()
	inline js int minute := this.getMinutes()
	inline js int second := this.getSeconds()
	inline js int millisecond := this.getMilliseconds()
		
	inline js string twoDigitMonth := (this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitDay := this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitHour := this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitMinute := this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitSecond := this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
		
	inline js float timeOfDay := this.getHours()*3600000 + this.getMinutes()*60000
	
	private static string toTwoDigitString: int value
		return value < 10 ? "0"+value.toString : value.toString
	
	// (31.12.)
	js string dayMonthString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."
	
	// (31.12.2000)
	js string dayMonthYearString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()
	
	// (31 December 2000)
	js string dayLongMonthNameYearString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+" "+this.toLocaleString('en-US', {month: 'long'})+" "+this.getFullYear()
	
	// (31 Dec 2000)
	js string dayShortMonthNameYearString: language = Loca.language
		return this.getDate()+" "+this.toLocaleString('en-US', {month: 'short'})+" "+this.getFullYear()
	
	// (Monday)
	string dayOfWeekString: language = Loca.language
		return dayStrings[language][dayOfWeek]
	
	// (Mon)
	string shortDayOfWeekString: language = Loca.language
		return shortDayStrings[language][dayOfWeek]
	
	// (23:59)
	string hourMinuteString: language = Loca.language
		if language == English
			let h = hour
			return ""+(((h-1) mod 12)+ 1)+":"+toTwoDigitString(minute)+(h < 12 ? " am":" pm")
		else
			return ""+hour+":"+toTwoDigitString(minute)
	
	// (23:59:59)
	string hourMinuteSecondString: language = Loca.language
		if language == English
			let h = hour
			return ""+(((h-1) mod 12)+1)+":"+toTwoDigitString(minute)+":"+toTwoDigitString(second)+(h < 12 ? " am":" pm")
		else
			return ""+hour+":"+toTwoDigitString(minute)+":"+toTwoDigitString(second)
	
	// (23:59:59.999)
	string hourMinuteSecondMillisecondString: language = Loca.language
		return ""+hour+":"+toTwoDigitString(minute)+":"+toTwoDigitString(second)+"."+millisecond
	
	// (31.12.2000 23:59)
	js string dayMonthYearHourMinuteString: language = Loca.language
		if(language == 1000) return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
		else                 return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// (31.12.2000 23:59:59)
	js string dayMonthYearHourMinuteSecondString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// (31-12-2000 23-59-59)
	js string invariantDayMonthYearHourMinuteSecondString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// In LiveTime, the term "time" always means the number of milliseconds since 1 January 1970
	inline js float time := this.getTime()
		
	// The data and time in ISO 8601 format, for example "2000-12-31T17:30:00.000Z"
	js string isoString()
		let tzo = -this.getTimezoneOffset()
		let dif = tzo >= 0 ? '+' : '-'
		
		function pad (num) {
			return (num < 10 ? '0' : '') + num;
		}
		
		return this.getFullYear() +
			"-" + pad(this.getMonth() + 1) +
			"-" + pad(this.getDate()) +
			"T" + pad(this.getHours()) +
			":" + pad(this.getMinutes()) +
			":" + pad(this.getSeconds()) +
			dif + pad(Math.floor(Math.abs(tzo) / 60)) +
			":" + pad(Math.abs(tzo) % 60);

	static inline js Date fromTime(float time) new Date(time)
	static inline js Date fromValues(int year, int month=1, int day=1, int hour = 0, int minute = 0, int second = 0) new Date(year, (month)-1, day, hour, minute, second)
	
	// Returns the real time, even during replay. Be careful: This can break the replay.
	static inline js Date realtime := new Date()
