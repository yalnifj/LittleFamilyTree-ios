import Foundation

class SourceCitation : HypermediaEnabledData {
	var lang:NSString?
	var value:NSString?
	var citationTemplate:ResourceReference?
	var fields = [CitationFields]()
}