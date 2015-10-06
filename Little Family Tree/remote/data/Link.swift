import Foundation

class Link {
	var rel : NSString?
	var href : NSString?
	var template : NSString?
	var type :NSString?
	var accept : NSString?
	var allow : NSString?
	var hreflang : NSString?
	var title : NSString?
	
	static func convertJsonToLink(rel:NSString, lson : JSON) -> Link {
		var link = Link()
		link.rel = rel
		link.href = lson["href"]
		return link
	}
}