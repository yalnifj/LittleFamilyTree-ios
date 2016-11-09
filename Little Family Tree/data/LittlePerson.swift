import Foundation

class LittlePerson : NSObject {
	var id : Int64?
	var name : String?
	var givenName : String?
	var gender : GenderType?
	var relationship : String?
	var familySearchId : String?
	var photoPath : String?
	var birthDate : Foundation.Date?
	var birthPlace : String?
	var age : Int?
	var alive : Bool?
	var lastSync : Foundation.Date?
	var active : Bool = true;
	var nationality : String?
	
	var hasParents : Bool?
	var hasChildren : Bool?
	var hasSpouses : Bool?
	var hasMedia : Bool?
	var treeLevel : Int?
	
	var occupation: String?
    
    var givenNameAudioPath: String?
	
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
