import Foundation

class LittlePerson : NSObject {
	var id : Int64?
	var name : NSString?
	var givenName : NSString?
	var gender : GenderType?
	var relationship : NSString?
	var familySearchId : NSString?
	var photoPath : NSString?
	var birthDate : Foundation.Date?
	var birthPlace : NSString?
	var age : Int?
	var alive : Bool?
	var lastSync : Foundation.Date?
	var active : Bool = true;
	var nationality : NSString?
	
	var hasParents : Bool?
	var hasChildren : Bool?
	var hasSpouses : Bool?
	var hasMedia : Bool?
	var treeLevel : Int?
	
	var occupation: NSString?
    
    var givenNameAudioPath: NSString?
	
	func updateAge() {
		if (birthDate != nil) {
			let todayDate = Foundation.Date()
			let ageComponents = (Calendar.current as NSCalendar).components(.year,
				from: birthDate!,
				to: todayDate,
				options: [])
			age = ageComponents.year
		}
	}
    
    override func isEqual(_ object: Any?) -> Bool {
        if let person = object as? LittlePerson {
            return person.id == self.id
        }
        return false
    }
}
func ==(lhs: LittlePerson, rhs: LittlePerson) -> Bool {
    return lhs.id == rhs.id
}
