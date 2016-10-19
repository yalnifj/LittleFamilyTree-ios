import Foundation

class DisplayProperties {
  var name:NSString?
  var gender:NSString?
  var lifespan:NSString?
  var birthDate:NSString?
  var birthPlace:NSString?
  var deathDate:NSString?
  var deathPlace:NSString?
  var ascendancyNumber:NSString?
  var descendancyNumber:NSString?
  
  static func convertJsonToDisplayProperties(_ json:JSON) -> DisplayProperties {
	let dp = DisplayProperties()
	if json["name"] != JSON.null {
		dp.name = json["name"].description as NSString?
	}
	if json["lifespan"] != JSON.null {
		dp.lifespan = json["lifespan"].description as NSString?
	}
	if json["birthDate"] != JSON.null {
		dp.birthDate = json["birthDate"].description as NSString?
	}
	if json["birthPlace"] != JSON.null {
		dp.birthPlace = json["birthPlace"].description as NSString?
	}
	if json["deathDate"] != JSON.null {
		dp.deathDate = json["deathDate"].description as NSString?
	}
	if json["deathPlace"] != JSON.null {
		dp.deathPlace = json["deathPlace"].description as NSString?
	}
	if json["ascendancyNumber"] != JSON.null {
		dp.ascendancyNumber = json["ascendancyNumber"].description as NSString?
	}
	if json["descendancyNumber"] != JSON.null {
		dp.descendancyNumber = json["descendancyNumber"].description as NSString?
	}
	return dp
  }
}
