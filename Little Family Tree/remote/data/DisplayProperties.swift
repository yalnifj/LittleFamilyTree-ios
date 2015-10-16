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
  
  static func convertJsonToDisplayProperties(json:JSON) -> DisplayProperties {
	let dp = DisplayProperties()
	if json["name"] != nil {
		dp.name = json["name"].description
	}
	if json["lifespan"] != nil {
		dp.lifespan = json["lifespan"].description
	}
	if json["birthDate"] != nil {
		dp.birthDate = json["birthDate"].description
	}
	if json["birthPlace"] != nil {
		dp.birthPlace = json["birthPlace"].description
	}
	if json["deathDate"] != nil {
		dp.deathDate = json["deathDate"].description
	}
	if json["deathPlace"] != nil {
		dp.deathPlace = json["deathPlace"].description
	}
	if json["ascendancyNumber"] != nil {
		dp.ascendancyNumber = json["ascendancyNumber"].description
	}
	if json["descendancyNumber"] != nil {
		dp.descendancyNumber = json["descendancyNumber"].description
	}
	return dp
  }
}