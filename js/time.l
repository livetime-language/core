enum string DateTimeFormatWeekday
	long	// Thursday
	short	// Thu
	narrow	// T

enum string DateTimeFormatEra
	long	// Anno Domini
	short	// AD
	narrow	// A

enum string DateTimeFormatYear
	numeric	// 2026
	twoDigit = "2-digit"	// 26

enum string DateTimeFormatMonth
	numeric	// 3
	twoDigit = "2-digit"	// 03
	long	// March
	short	// Mar
	narrow	// M

enum string DateTimeFormatDay
	numeric	// 20
	twoDigit = "2-digit"	// 20

enum string DateTimeFormatDayPeriod
	narrow	// at night
	short	// at night
	long	// at night

enum string DateTimeFormatHour
	numeric	// 1
	twoDigit = "2-digit"	// 01

enum string DateTimeFormatMinute
	numeric	// 5
	twoDigit = "2-digit"	// 05

enum string DateTimeFormatSecond
	numeric	// 7
	twoDigit = "2-digit"	// 07

enum string DateTimeFormatTimeZoneName
	short	// PST
	long	// Pacific Standard Time
	shortOffset	// GMT-8
	longOffset	// GMT-08:00
	shortGeneric	// PT
	longGeneric	// Pacific Time

enum string DateTimeFormatLocaleMatcher
	lookup	// locale matching algorithm
	bestFit = "best fit"	// locale matching algorithm (default)

enum string DateTimeFormatHourCycle
	h11	// 0-11 hour cycle
	h12	// 1-12 hour cycle
	h23	// 0-23 hour cycle
	h24	// 1-24 hour cycle

enum string DateTimeFormatDateStyle
	full	// Sunday, 20 December 2020
	long	// December 20, 2020
	medium	// Dec 20, 2020
	short	// 12/20/2020

enum string DateTimeFormatTimeStyle
	full	// 2:23:16 PM GMT+11
	long	// 2:23:16 PM GMT+11
	medium	// 2:23:16 PM
	short	// 2:23 PM

dynamic DateTimeFormatOptions
	DateTimeFormatLocaleMatcher	localeMatcher	// Algorithm to use for locale matching
	string	calendar	// "chinese", "gregory", "persian", etc.
	string	numberingSystem	// "arab", "hans", "mathsans", etc.
	bool	hour12	// true: 12-hour time, false: 24-hour time
	DateTimeFormatHourCycle	hourCycle	// h11, h12, h23, or h24
	string	timeZone	// IANA time zone name, e.g. "UTC", "America/New_York", "Europe/Berlin"
	DateTimeFormatWeekday	weekday	// long: Thursday, short: Thu, narrow: T
	DateTimeFormatEra	era	// long: Anno Domini, short: AD, narrow: A
	DateTimeFormatYear	year	// numeric: 2026, 2-digit: 26
	DateTimeFormatMonth	month	// numeric: 3, 2-digit: 03, long: March, short: Mar, narrow: M
	DateTimeFormatDay	day	// numeric: 20, 2-digit: 20
	DateTimeFormatDayPeriod	dayPeriod	// Only works with 12-hour clock. narrow/short: at night, long: at night
	DateTimeFormatHour	hour	// numeric: 1, 2-digit: 01
	DateTimeFormatMinute	minute	// numeric: 5, 2-digit: 05
	DateTimeFormatSecond	second	// numeric: 7, 2-digit: 07
	int	fractionalSecondDigits	// 1, 2, or 3 digits for fractional seconds
	DateTimeFormatTimeZoneName	timeZoneName	// short: PST, long: Pacific Standard Time, shortOffset: GMT-8, etc.
	DateTimeFormatDateStyle	dateStyle	// Shortcut for date formatting: full, long, medium, short
	DateTimeFormatTimeStyle	timeStyle	// Shortcut for time formatting: full, long, medium, short

// Formats a date and time according to language, locale, and time zone.
// This is quite complex, because the start of daylight saving time is different in every country and changes every year.
js(Intl.DateTimeFormat) class DateTimeFormat
	inline js DateTimeFormat: DateTimeFormatOptions options
		new Intl.DateTimeFormat(Loca.locale, options)

	inline js string format: TimeString timeString
		this.format(new Date(timeString))

	inline js string format: Date date
		this.format(date)

	inline js string locale() this?.resolvedOptions().locale

static skipInit class Time
	string timerLogs
	js static void startTimer()
		Time.timerLogs = ""
		window._timerStart = performance.now()

	js static void printTimer(string text) 
		let now = performance.now()
		let message = text+": "+(now-window._timerStart)
		console.log(message)
		Time.timerLogs += message + "\n"
		window._timerStart = now

	static inline js float preciseTime => performance.now()
	
struct float	
	inline js int timeMilliseconds => Math.floor((this %    1000)          ) 
	inline js int timeSeconds      => Math.floor((this %   60000) /    1000) 
	inline js int timeMinutes      => Math.floor((this % 3600000) /   60000) 
	inline js int timeHours        => Math.floor((this            ) / 3600000)
		
	inline js int totalSeconds      => Math.floor(this /      1000) 
	inline js int totalMinutes      => Math.floor(this /     60000) 
	inline js int totalHours        => Math.floor(this /   3600000)
	inline js int totalDays         => Math.floor(this /  86400000)
	inline js int totalWeeks        => Math.floor(this / 604800000)
		
	private static string toMinutesHoursDaysOrWeeksString: float time, showWeeksAfterDays = 31
		if time < 2 minutes	then return "1 minute"
		if time < 1 hours	then return "{time.totalMinutes} minutes"
		if time < 2 hours	then return "1 hour"
		if time < 1 days	then return "{time.totalHours} hours"
		if time < 2 days	then return "1 day"
		if time < showWeeksAfterDays days	then return "{time.totalDays} days"
		if time < 2 weeks	then return "1 week"
		                                         return "{time.totalWeeks} weeks"

	// (31.12.)
	inline string dayMonthString
		(dayMonthFormat?.locale == Loca.locale ? dayMonthFormat : (dayMonthFormat = {options:{day:twoDigit, month:twoDigit}})).format(new Date(this))
	private static DateTimeFormat dayMonthFormat
		
	// (31.12.2000)
	inline string dayMonthYearString
		(dayMonthYearFormat?.locale == Loca.locale ? dayMonthYearFormat : (dayMonthYearFormat = {options:{day:twoDigit, month:twoDigit, year:numeric}})).format(new Date(this))
	private static DateTimeFormat dayMonthYearFormat
		
	// (31 December 2000)
	inline string dayMonthNameYearString
		(dayMonthNameYearFormat?.locale == Loca.locale ? dayMonthNameYearFormat : (dayMonthNameYearFormat = {options:{day:numeric, month:long, year:numeric}})).format(new Date(this))
	private static DateTimeFormat dayMonthNameYearFormat
		
	// (31 Dec)
	inline string dayShortMonthNameString
		(dayShortMonthNameFormat?.locale == Loca.locale ? dayShortMonthNameFormat : (dayShortMonthNameFormat = {options:{day:numeric, month:short}})).format(new Date(this))
	private static DateTimeFormat dayShortMonthNameFormat
		
	// (Thursday, 31 December 2000)
	inline string dayOfWeekDayMonthNameYearString
		(dayOfWeekDayMonthNameYearFormat?.locale == Loca.locale ? dayOfWeekDayMonthNameYearFormat : (dayOfWeekDayMonthNameYearFormat = {options:{weekday:long, day:numeric, month:long, year:numeric}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekDayMonthNameYearFormat
		
	// (Monday, December 31)
	inline string dayOfWeekDayMonthString
		(dayOfWeekDayMonthFormat?.locale == Loca.locale ? dayOfWeekDayMonthFormat : (dayOfWeekDayMonthFormat = {options:{weekday:long, month:long, day:numeric}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekDayMonthFormat
		
	// (Monday)
	inline string dayOfWeekString
		(dayOfWeekFormat?.locale == Loca.locale ? dayOfWeekFormat : (dayOfWeekFormat = {options:{weekday:long}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekFormat
		
	// (Mon)
	inline string dayOfWeekShortString
		(dayOfWeekShortFormat?.locale == Loca.locale ? dayOfWeekShortFormat : (dayOfWeekShortFormat = {options:{weekday:short}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekShortFormat
		
	// (12:59 pm)
	inline string hourMinuteString
		(hourMinuteFormat?.locale == Loca.locale ? hourMinuteFormat : (hourMinuteFormat = {options:{hour:numeric, minute:twoDigit}})).format(new Date(this))
	private static DateTimeFormat hourMinuteFormat

	// (1:59)
	inline string minuteSecondString
		"{this.timeMinutes}:{this.timeSeconds.toString.padStart(2, '0')}"
		
	// (Monday, December 31 at 12:59 pm)
	inline string dayOfWeekDayMonthAtHourMinuteString
		(dayOfWeekDayMonthAtHourMinuteFormat?.locale == Loca.locale ? dayOfWeekDayMonthAtHourMinuteFormat : (dayOfWeekDayMonthAtHourMinuteFormat = {options:{weekday:long, month:long, day:numeric, hour:numeric, minute:twoDigit}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekDayMonthAtHourMinuteFormat
		
	// (Monday, 31 December 2000, 12:59 pm)
	inline string dayOfWeekDayMonthYearHourMinuteString
		(dayOfWeekDayMonthYearHourMinuteFormat?.locale == Loca.locale ? dayOfWeekDayMonthYearHourMinuteFormat : (dayOfWeekDayMonthYearHourMinuteFormat = {options:{weekday:long, day:numeric, month:long, year:numeric, hour:numeric, minute:twoDigit}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekDayMonthYearHourMinuteFormat

class string
	implicit inline TimeString toTimeString() this

// A string representation of a date and time in the ISO 8601 format, for example "2000-12-31 17:30:00.000Z".
// It uses DateTimeFormat for formatting to handle the transition to and from daylight saving time well.
string TimeString
	static TimeString now => Date.fromTime(Time.now).utcString
	static TimeString fromTime(float value) => Date.fromTime(value).utcString
	
	inline js bool toBool => this
	inline string toString() this
	
	// (31.12.)
	inline string dayMonthString
		(dayMonthFormat?.locale == Loca.locale ? dayMonthFormat : (dayMonthFormat = {options:{day:twoDigit, month:twoDigit}})).format(new Date(this))
	private static DateTimeFormat dayMonthFormat
		
	// (31.12.2000)
	inline string dayMonthYearString
		(dayMonthYearFormat?.locale == Loca.locale ? dayMonthYearFormat : (dayMonthYearFormat = {options:{day:twoDigit, month:twoDigit, year:numeric}})).format(new Date(this))
	private static DateTimeFormat dayMonthYearFormat
		
	// (31 December 2000)
	inline string dayMonthNameYearString
		(dayMonthNameYearFormat?.locale == Loca.locale ? dayMonthNameYearFormat : (dayMonthNameYearFormat = {options:{day:numeric, month:long, year:numeric}})).format(new Date(this))
	private static DateTimeFormat dayMonthNameYearFormat
		
	// (31 Dec)
	inline string dayShortMonthNameString
		(dayShortMonthNameFormat?.locale == Loca.locale ? dayShortMonthNameFormat : (dayShortMonthNameFormat = {options:{day:numeric, month:short}})).format(new Date(this))
	private static DateTimeFormat dayShortMonthNameFormat
		
	// (Thursday, 31 December 2000)
	inline string dayOfWeekDayMonthNameYearString
		(dayOfWeekDayMonthNameYearFormat?.locale == Loca.locale ? dayOfWeekDayMonthNameYearFormat : (dayOfWeekDayMonthNameYearFormat = {options:{weekday:long, day:numeric, month:long, year:numeric}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekDayMonthNameYearFormat
		
	// (Monday, December 31)
	inline string dayOfWeekDayMonthString
		(dayOfWeekDayMonthFormat?.locale == Loca.locale ? dayOfWeekDayMonthFormat : (dayOfWeekDayMonthFormat = {options:{weekday:long, month:long, day:numeric}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekDayMonthFormat
		
	// (Monday)
	inline string dayOfWeekString
		(dayOfWeekFormat?.locale == Loca.locale ? dayOfWeekFormat : (dayOfWeekFormat = {options:{weekday:long}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekFormat
		
	// (Mon)
	inline string dayOfWeekShortString
		(dayOfWeekShortFormat?.locale == Loca.locale ? dayOfWeekShortFormat : (dayOfWeekShortFormat = {options:{weekday:short}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekShortFormat
		
	// (12:59 pm)
	inline string hourMinuteString
		(hourMinuteFormat?.locale == Loca.locale ? hourMinuteFormat : (hourMinuteFormat = {options:{hour:numeric, minute:twoDigit}})).format(new Date(this))
	private static DateTimeFormat hourMinuteFormat
		
	// (Monday, December 31 at 12:59 pm)
	inline string dayOfWeekDayMonthAtHourMinuteString
		(dayOfWeekDayMonthAtHourMinuteFormat?.locale == Loca.locale ? dayOfWeekDayMonthAtHourMinuteFormat : (dayOfWeekDayMonthAtHourMinuteFormat = {options:{weekday:long, month:long, day:numeric, hour:numeric, minute:twoDigit}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekDayMonthAtHourMinuteFormat
		
	// (Monday, 31 December 2000, 12:59 pm)
	inline string dayOfWeekDayMonthYearHourMinuteString
		(dayOfWeekDayMonthYearHourMinuteFormat?.locale == Loca.locale ? dayOfWeekDayMonthYearHourMinuteFormat : (dayOfWeekDayMonthYearHourMinuteFormat = {options:{weekday:long, day:numeric, month:long, year:numeric, hour:numeric, minute:twoDigit}})).format(new Date(this))
	private static DateTimeFormat dayOfWeekDayMonthYearHourMinuteFormat
	
// Represents a point in time using the JavaScript Date class.
// It uses DateTimeFormat for formatting to handle the transition to and from daylight saving time well.
js(Date) internal transient class Date
	inline js Date(float time) new Date(time)
	inline js Date(TimeString timeString) new Date(timeString)
	inline js Date(int year, int month, int day, int hour, int minute, int second, int milliseconds) new Date(year, month-1, day, hour, minute, second, milliseconds)
	
	static inline js Date fromTime(float time) new Date(time)
	static inline js Date fromString(string timeString) new Date(timeString)
	static inline js Date fromValues(int year, int month=1, int day=1, int hour = 0, int minute = 0, int second = 0) new Date(year, (month)-1, day, hour, minute, second)
	
	// Returns the real time, even during replay. Be careful: This can break the replay.
	static inline js Date realtime => new Date()
	
	static inline js Date now	=> new Date()
	inline js int year	=> this.getFullYear()
	inline js int month	=> (this.getMonth()+1)
	inline js int day	=> this.getDate()
	inline js int dayOfWeek		=> this.getDay()
		
	inline js int hour	=> this.getHours()
	inline js int minute	=> this.getMinutes()
	inline js int second	=> this.getSeconds()
	inline js int millisecond	=> this.getMilliseconds()
		
	inline js string twoDigitMonth	=> (this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitDay	=> this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitHour	=> this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitMinute	=> this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitSecond	=> this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})		
	inline js float timeOfDay	=> this.getHours()*3600000 + this.getMinutes()*60000
	
	private static string toTwoDigitString: int value
		return value < 10 ? "0"+value.toString : value.toString
			
	// In LiveTime, the term "time" always means the number of milliseconds since 1 January 1970
	inline js float time => this.getTime()
		
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

	inline js TimeString utcString() this.toISOString()

	Date + float delta 
		return Date.fromTime(this.time + delta)
	Date - float delta 
		return Date.fromTime(this.time - delta)

		// (31.12.)
	inline string dayMonthString
		(dayMonthFormat?.locale == Loca.locale ? dayMonthFormat : (dayMonthFormat = {options:{day:twoDigit, month:twoDigit}})).format(this)
	private static DateTimeFormat dayMonthFormat
		
	// (31.12.2000)
	inline string dayMonthYearString
		(dayMonthYearFormat?.locale == Loca.locale ? dayMonthYearFormat : (dayMonthYearFormat = {options:{day:twoDigit, month:twoDigit, year:numeric}})).format(this)
	private static DateTimeFormat dayMonthYearFormat
		
	// (31 December 2000)
	inline string dayMonthNameYearString
		(dayMonthNameYearFormat?.locale == Loca.locale ? dayMonthNameYearFormat : (dayMonthNameYearFormat = {options:{day:numeric, month:long, year:numeric}})).format(this)
	private static DateTimeFormat dayMonthNameYearFormat
		
	// (31 Dec 2000)
	inline string dayShortMonthNameYearString
		(dayShortMonthNameYearFormat?.locale == Loca.locale ? dayShortMonthNameYearFormat : (dayShortMonthNameYearFormat = {options:{day:numeric, month:short, year:numeric}})).format(this)
	private static DateTimeFormat dayShortMonthNameYearFormat
		
	// (31 Dec)
	inline string dayShortMonthNameString
		(dayShortMonthNameFormat?.locale == Loca.locale ? dayShortMonthNameFormat : (dayShortMonthNameFormat = {options:{day:numeric, month:short}})).format(this)
	private static DateTimeFormat dayShortMonthNameFormat
		
	// (Thursday, 31 December 2000)
	inline string dayOfWeekDayMonthNameYearString
		(dayOfWeekDayMonthNameYearFormat?.locale == Loca.locale ? dayOfWeekDayMonthNameYearFormat : (dayOfWeekDayMonthNameYearFormat = {options:{weekday:long, day:numeric, month:long, year:numeric}})).format(this)
	private static DateTimeFormat dayOfWeekDayMonthNameYearFormat
		
	// (Monday, December 31)
	inline string dayOfWeekDayMonthString
		(dayOfWeekDayMonthFormat?.locale == Loca.locale ? dayOfWeekDayMonthFormat : (dayOfWeekDayMonthFormat = {options:{weekday:long, month:long, day:numeric}})).format(this)
	private static DateTimeFormat dayOfWeekDayMonthFormat
		
	// (Monday)
	inline string dayOfWeekString
		(dayOfWeekFormat?.locale == Loca.locale ? dayOfWeekFormat : (dayOfWeekFormat = {options:{weekday:long}})).format(this)
	private static DateTimeFormat dayOfWeekFormat
		
	// (Mon)
	inline string dayOfWeekShortString
		(dayOfWeekShortFormat?.locale == Loca.locale ? dayOfWeekShortFormat : (dayOfWeekShortFormat = {options:{weekday:short}})).format(this)
	private static DateTimeFormat dayOfWeekShortFormat
		
	// (12:59 pm)
	inline string hourMinuteString
		(hourMinuteFormat?.locale == Loca.locale ? hourMinuteFormat : (hourMinuteFormat = {options:{hour:numeric, minute:twoDigit}})).format(this)
	private static DateTimeFormat hourMinuteFormat
		
	// (12:59:00 pm)
	inline string hourMinuteSecondString
		(hourMinuteSecondFormat?.locale == Loca.locale ? hourMinuteSecondFormat : (hourMinuteSecondFormat = {options:{hour:numeric, minute:twoDigit, second:twoDigit}})).format(this)
	private static DateTimeFormat hourMinuteSecondFormat
		
	// (12:59:00.999 pm)
	inline string hourMinuteSecondMillisecondString
		(hourMinuteSecondMillisecondFormat?.locale == Loca.locale ? hourMinuteSecondMillisecondFormat : (hourMinuteSecondMillisecondFormat = {options:{hour:numeric, minute:twoDigit, second:twoDigit, fractionalSecondDigits:3}})).format(this)
	private static DateTimeFormat hourMinuteSecondMillisecondFormat
		
	// (Monday, December 31 at 12:59 pm)
	inline string dayOfWeekDayMonthAtHourMinuteString
		(dayOfWeekDayMonthAtHourMinuteFormat?.locale == Loca.locale ? dayOfWeekDayMonthAtHourMinuteFormat : (dayOfWeekDayMonthAtHourMinuteFormat = {options:{weekday:long, month:long, day:numeric, hour:numeric, minute:twoDigit}})).format(this)
	private static DateTimeFormat dayOfWeekDayMonthAtHourMinuteFormat
		
	// (Monday, 31 December 2000, 12:59 pm)
	inline string dayOfWeekDayMonthYearHourMinuteString
		(dayOfWeekDayMonthYearHourMinuteFormat?.locale == Loca.locale ? dayOfWeekDayMonthYearHourMinuteFormat : (dayOfWeekDayMonthYearHourMinuteFormat = {options:{weekday:long, day:numeric, month:long, year:numeric, hour:numeric, minute:twoDigit}})).format(this)
	private static DateTimeFormat dayOfWeekDayMonthYearHourMinuteFormat

	
