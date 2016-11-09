import Foundation

class Link {
	var rel : String?
	var href : String?
	var template : String?
	var type :String?
	var accept : String?
	var allow : String?
	var hreflang : String?
	var title : String?
	
	static func convertJsonToLink(_ rel : String, lson : JSON) -> Link {
		let link = Link()
		link.rel = rel
		link.href = lson["href"].description
		return link
	}
}
