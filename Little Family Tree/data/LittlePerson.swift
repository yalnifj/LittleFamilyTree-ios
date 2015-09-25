import Foundation

class LittlePerson {
	var id : Int?;
	var name : NSString?;
	var givenName : NSString?;
	var relationship : NSString?;
	var familySearchId : NSString?
	var photoPath : NSString?
	var birthDate : NSDate?;
	var birthPlace : NSString?
	var age : Int = 0;
	var alive : Bool?
	var lastSync : NSDate?
	var active : Bool = true;
	var nationality : NSString?
	
	var hasParents : Bool?
	var hasChildren : Bool?
	var hasSpouses : Bool?
	var hasMedia : Bool?
	var treeLevel : Int?
	
	func updateAge() {
		if (birthDate != nil) {
			let flags: NSCalendarUnit = .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit
			let todayDate = NSDate()
			let birthCal = NSCalendar.currentCalendar().components(flags, fromDate: birthDate!)
			let today = NSCalendar.currentCalendar().components(flags, fromDate: todayDate)
			age = today.year - birthCal.year;
            if (today.month < birthCal.month) {
				age--;
            } else {
				if (today.month == birthCal.month && today.day < birthCal.day) {
					age--;
				}
			}
		}
	}
}
