import Foundation

class SourceDescription : HypermediaEnabledData {
	var citations = [SourceCitation]()
	var mediaType:NSString?
	var about:NSString?
	var mediator:ResourceReference?
	var sources = [SourceReference]()
	var analysis:ResourceReference?
	var componentOf:SourceReference?
	var titles = [TextValue]()
	var notes = [Note]()
	var attribution:Attribution?
	var resourceType:NSString?
	var sortKey:NSString?
	var description = [TextValue]()
	var identifiers = [Identifier]()
	var created:Date?
	var modified:Date?
	var coverage = [Coverage]()
	var repository:ResourceReference?
	var descriptorRef:ResourceReference?
	
}