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
	
	static func convertJsonToSourceDescriptions(_ json:JSON) -> [SourceDescription] {
		var sds = [SourceDescription]()
		
        if json["sourceDescriptions"] != JSON.null {
            for sson in json["sourceDescriptions"].array! {
                let sd = SourceDescription()
                sd.id = sson["id"].description as NSString?
                sd.mediaType = sson["mediaType"].description as NSString?
                sd.about = sson["about"].description as NSString?
                sd.resourceType = sson["resourceType"].description as NSString?
                sd.addLinksFromJson(sson)
                
                // -- TODO add other attributes for non-media sourceDescriptions
                
                sds.append(sd)
            }
        }
		
		return sds
	}
}
