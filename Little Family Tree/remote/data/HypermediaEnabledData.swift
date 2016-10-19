import Foundation

class HypermediaEnabledData : ExtensibleData {
	var links = [Link]()
	
	func addLink(_ rel:String, href:String) {
		let link = Link()
		link.rel = rel as NSString?
		link.href = href as NSString?
		links.append(link)
	}
	
	func addLinksFromJson(_ json:JSON) {
		if json["links"] != JSON.null && json["links"].count > 0 {
			for (rel, lson) in json["links"] {
				let link = Link.convertJsonToLink(rel as NSString, lson: lson);
				self.links.append(link)
			}
		}
	}
}
