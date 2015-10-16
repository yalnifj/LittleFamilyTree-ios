import Foundation

class HypermediaEnabledData : ExtensibleData {
	var links = [Link]()
	
	func addLinksFromJson(json:JSON) {
		if json["links"] != nil && json["links"].count > 0 {
			for (rel, lson) in json["links"] {
				let link = Link.convertJsonToLink(rel, lson: lson);
				self.links.append(link)
			}
		}
	}
}