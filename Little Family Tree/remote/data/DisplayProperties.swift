import Foundation

class DisplayProperties {
  var name:String?
  var gender:String?
  var lifespan:String?
  var birthDate:String?
  var birthPlace:String?
  var deathDate:String?
  var deathPlace:String?
  var ascendancyNumber:String?
  var descendancyNumber:String?
  
  static func convertJsonToDisplayProperties(_ json:JSON) -> DisplayProperties {
	let dp = DisplayProperties()
	if json["name"] != JSON.null {
		dp.name = json["name"].description
	}
	if json["lifespan"] != JSON.null {
		dp.lifespan = json["lifespan"].description
	}
	if json["birthDate"] != JSON.null {
		dp.birthDate = json["birthDate"].description
	}
	if json["birthPlace"] != JSON.null {
		dp.birthPlace = json["birthPlace"].description
	}
	if json["deathDate"] != JSON.null {
		dp.deathDate = json["deathDate"].description
	}
	if json["deathPlace"] != JSON.null {
		dp.deathPlace = json["deathPlace"].description
	}
	if json["ascendancyNumber"] != JSON.null {
		dp.ascendancyNumber = json["ascendancyNumber"].description
	}
	if json["descendancyNumber"] != JSON.null {
		dp.descendancyNumber = json["descendancyNumber"].description
	}
	return dp
  }
}
