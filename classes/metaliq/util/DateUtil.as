

package metaliq.util {
	import metaliq.util.NumberUtil;
	public class DateUtil {
	////////////////////////////////////////////////////////////////////////////
	//
	// Properties
	//
	////////////////////////////////////////////////////////////////////////////
		// @property
		static private var $monthNames : Array = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
		static private var $monthShortNames : Array = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
		
		static private var $dayNames : Array = new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
		static private var $dayShortNames : Array = new Array("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
		
	////////////////////////////////////////////////////////////////////////////
	//
	//	Constructor
	//	
	////////////////////////////////////////////////////////////////////////////
		public function DateUtil() {
		}
		static public function getMonthName(p_date:Date):String {
			var month : Number = p_date.getMonth();
			return DateUtil.$monthNames[month];
		}
		static public function getMonthShortName(p_date:Date):String {
			var month : Number = p_date.getMonth();
			return DateUtil.$monthShortNames[month];
		}
		static public function getDayName(p_date:Date):String {
			var day : Number = p_date.getDay();
			return DateUtil.$dayNames[day];
		}
		static public function getDayShortName(p_date:Date):String {
			var day : Number = p_date.getDay();
			return DateUtil.$dayShortNames[day];
		}
		static public function isSameDay(p_date:Date,p_date2:Date) : Boolean {
			var isSameDay : Boolean = p_date.getFullYear() == p_date2.getFullYear() && p_date.getMonth() == p_date2.getMonth() && p_date.getDate() == p_date2.getDate();
			return isSameDay;
		}
		static public function getDifference(p_date1:Date,p_date2:Date,p_format:String) : Number {
			//trace("getDifference " + DateUtil.getDayStamp(p_date1) + " to " + DateUtil.getDayStamp(p_date2)); 
			var time1 : Number = p_date1.getTime();
			var time2 : Number = p_date2.getTime();
			var delta : Number =  time2 - time1;
			var seconds  : Number = Math.floor(delta/1000);
			var minutes : Number  = Math.floor(seconds/60);
			var hours : Number  = Math.floor(minutes/60);
			var days : Number  = Math.floor(hours/24) +1;
			switch(p_format) {
				case "d":
					if(Math.abs(delta) > 86400000 ) {
						delta = days;
					} else {
						delta = p_date2.getDate() - p_date1.getDate();
					}
					break;
				case "w":
					delta = days;
					var day1 : Number = p_date1.getDay();
					var day2: Number = p_date2.getDay();
					if(Math.abs(delta) > day2) {
						delta = Math.floor(delta/7);
					} else {
						delta = 0;
					}
					break;
				case "m":
					if(p_date1.getFullYear() == p_date2.getFullYear() ) {
						delta = p_date2.getMonth() - p_date1.getMonth();
					}
					break;
			}
			return delta;
		}
		//20060824T184154Z
		static public function parseICalStamp(p_timeStamp:String) : Date {
			var year : Number = Number(p_timeStamp.substr(0,4));
			var month : Number = Number(p_timeStamp.substr(4,2)) -1 ;
			var date : Number = Number(p_timeStamp.substr(6,2)) ;
			var hour : Number = Number(p_timeStamp.substr(9,2)) ;
			var minute : Number = Number(p_timeStamp.substr(11,2)) ;
			var second : Number = Number(p_timeStamp.substr(13,2)) ;
			var d : Date = new Date(year,month,date,hour,minute,second);
			return d;
		}
		static public function getICalStamp(p_date:Date): String {
			var output:String = getTimeStamp(p_date,"Ymd") + "T" + getTimeStamp(p_date,"His") + "Z";
			return output;
			
		}
		/*
	d	Day of the month, 2 digits with leading zeros	01 to 31
	D	A textual representation of a day, three letters	Mon through Sun
	j	Day of the month without leading zeros	1 to 31
	l (lowercase 'L')	A full textual representation of the day of the week	Sunday through Saturday
	N	ISO-8601 numeric representation of the day of the week (added in PHP 5.1.0)	1 (for Monday) through 7 (for Sunday)
	S	English ordinal suffix for the day of the month, 2 characters	st, nd, rd or th. Works well with j
	w	Numeric representation of the day of the week	0 (for Sunday) through 6 (for Saturday)
	z	The day of the year (starting from 0)	0 through 365
	Week	---	---
	W	ISO-8601 week number of year, weeks starting on Monday (added in PHP 4.1.0)	Example: 42 (the 42nd week in the year)
	Month	---	---
	F	A full textual representation of a month, such as January or March	January through December
	m	Numeric representation of a month, with leading zeros	01 through 12
	M	A short textual representation of a month, three letters	Jan through Dec
	n	Numeric representation of a month, without leading zeros	1 through 12
	t	Number of days in the given month	28 through 31
	Year	---	---
	L	Whether it's a leap year	1 if it is a leap year, 0 otherwise.
	o	ISO-8601 year number. This has the same value as Y, except that if the ISO week number (W) belongs to the previous or next year, that year is used instead. (added in PHP 5.1.0)	Examples: 1999 or 2003
	Y	A full numeric representation of a year, 4 digits	Examples: 1999 or 2003
	y	A two digit representation of a year	Examples: 99 or 03
	Time	---	---
	a	Lowercase Ante meridiem and Post meridiem	am or pm
	A	Uppercase Ante meridiem and Post meridiem	AM or PM
	B	Swatch Internet time	000 through 999
	g	12-hour format of an hour without leading zeros	1 through 12
	G	24-hour format of an hour without leading zeros	0 through 23
	h	12-hour format of an hour with leading zeros	01 through 12
	H	24-hour format of an hour with leading zeros	00 through 23
	i	Minutes with leading zeros	00 to 59
	s Seconds, with leading zeros	00 through 59
	 * 
	 */
		
		static public function getTimeStamp(p_date : Date ,p_format:String) : String {
			var timeStamp : String = "";
			
			var tokens : Array = p_format.split("");
			var length : Number = tokens.length;
			var token : String;
			var hours:Number;
			for (var i : Number = 0; i < length; i++) {
				token = tokens[i];
				switch (token) {
					case "d":
						timeStamp += NumberUtil.pad(p_date.getDate(),2);
						break;
					case "D":
						timeStamp += DateUtil.$dayShortNames[p_date.getDay()];
						break;
					case "j":
						timeStamp += p_date.getDate().toString();
						break;
					case "l":
						timeStamp += DateUtil.$dayNames[p_date.getDay()];
						break;
					case "F":
						timeStamp += DateUtil.$monthNames[p_date.getMonth()];
						break;
					case "m":
						timeStamp += NumberUtil.pad(p_date.getMonth()+1,2);
						break;
					case "M":
						timeStamp += DateUtil.$monthShortNames[p_date.getMonth()];
						break;
					case "n":
						timeStamp += (p_date.getMonth()+1).toString();
						break;
					case "a":
						timeStamp += p_date.getHours() < 12 ? "am" : "pm";
						break;
					case "A":
						timeStamp += p_date.getHours() < 12 ? "AM" : "PM";
						break;
					case "g":
						hours  = p_date.getHours();
						if(hours > 0 ) {
							timeStamp += (hours > 12 ? hours  - 12 : hours).toString();
						} else {
							timeStamp+= "12";
						}
							
						break;
					case "G":
						timeStamp += (p_date.getHours()).toString();
						break;
					case "h":
						hours  = p_date.getHours();
						if(hours > 0 ) {
							timeStamp += NumberUtil.pad((hours > 12 ? hours  - 12 : hours),2);
						}  else {
							timeStamp+= "12";
						}
						
						break;
					case "H":
						timeStamp += NumberUtil.pad(p_date.getHours(),2);
						break;
					case "Y":
						timeStamp += p_date.getFullYear().toString();
						break;
					case "y":
						timeStamp += p_date.getFullYear().toString().substr(2,2);
						break;
					case "i":
						timeStamp += NumberUtil.pad(p_date.getMinutes(),2);
						break;
					case "s":
						timeStamp += NumberUtil.pad(p_date.getSeconds(),2);
						break;
					default :
						timeStamp += token;
				}
			}
			
			return timeStamp;
		}
		
	 	static public  function getDayStamp(p_date:Date) : String {
			return getTimeStamp(p_date,"Y:m:d");
		}
		static public function getRandomDate():Date {
			var d:Date = new Date();
			var t:Number = d.getTime();
			// 31536000000 is 1 year in milliseconds
			t = t + NumberUtil.randomRange(-31536000000,31536000000);
			d = new Date(t);
			return d;
		}
	}
}