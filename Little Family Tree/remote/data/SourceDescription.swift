import Foundation

class SourceDescription : HypermediaEnabledData {
	var citations = [SourceCitation]()
	var mediaType:String?
	var about:String?
	var mediator:ResourceReference?
	var sources = [SourceReference]()
	var analysis:ResourceReference?
	var componentOf:SourceReference?
	var titles = [TextValue]()
	var notes = [Note]()
	var attribution:Attribution?
	var resourceType:String?
	var sortKey:String?
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
                sd.id = sson["id"].description
                sd.mediaType = sson["mediaType"].description
                sd.about = sson["about"].description
                sd.resourceType = sson["resourceType"].description
                sd.addLinksFromJson(sson)
                
                // -- TODO add other attributes for non-media sourceDescriptions
                
                sds.append(sd)
            }
        }
		
		return sds
	}
}
