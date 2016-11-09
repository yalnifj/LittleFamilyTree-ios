import Foundation

class SourceCitation : HypermediaEnabledData {
	var lang:String?
	var value:String?
	var citationTemplate:ResourceReference?
	var fields = [CitationField]()
}
