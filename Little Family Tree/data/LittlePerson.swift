import Foundation

class LittlePerson {
	var id : Int = 0;
	var name : NSString = nil;
	var givenName : NSString = nil;
	var relationship : NSString = nil;
	var familySearchId : NSString = nil;
	var photoPath : NSString = nil;
	var gender : GenderType!;
	var birthDate : NSDate = nil;
	var birthPlace : NSString = nil;
	var age : Int = 0;
	var alive : Bool = nil;
	var lastSync : NSDate = nil;
	var active : Bool = true;
	var nationality : NSString = nil;
	
	var hasParents : Bool = nil;
	var hasChildren : Bool = nil;
	var hasSpouses : Bool = nil;
	var hasMedia : Bool = nil;
	var treeLevel : Int = nil;
	
	func updateAge() {
		if (birthDate != nil) {
			let flags: NSCalendarUnit = .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit
			let todayDate = NSDate()
			let birthCal = NSCalendar.currentCalendar().components(flags, fromDate: birthDate)
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