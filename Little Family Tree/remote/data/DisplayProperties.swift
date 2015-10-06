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
	var dp = DisplayProperties()
	if json["name"] != nil {
		dp.name = json["name"]
	}
	if json["lifespan"] != nil {
		dp.lifespan = json["lifespan"]
	}
	if json["birthDate"] != nil {
		dp.birthDate = json["birthDate"]
	}
	if json["birthPlace"] != nil {
		dp.birthPlace = json["birthPlace"]
	}
	if json["deathDate"] != nil {
		dp.deathDate = json["deathDate"]
	}
	if json["deathPlace"] != nil {
		dp.deathPlace = json["deathPlace"]
	}
	if json["ascendancyNumber"] != nil {
		dp.ascendancyNumber = json["ascendancyNumber"]
	}
	if json["descendancyNumber"] != nil {
		dp.descendancyNumber = json["descendancyNumber"]
	}
	return dp
  }
}