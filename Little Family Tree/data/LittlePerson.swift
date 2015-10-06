import Foundation

class LittlePerson {
	var id : Int?
	var name : NSString?
	var givenName : NSString?
	var gender : GenderType?
	var relationship : NSString?
	var familySearchId : NSString?
	var photoPath : NSString?
	var birthDate : NSDate?;
	var birthPlace : NSString?
	var age : Int = 0
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
			let todayDate = NSDate()
			let ageComponents = NSCalendar.currentCalendar().components(.Year,
				fromDate: birthDate!,
				toDate: todayDate,
				options: [])
			age = ageComponents.year
		}
	}
}
