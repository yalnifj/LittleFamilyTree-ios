import Foundation

class Subject : Conclusion {
	var extracted:Bool?
	var identifiers = [Identifier]()
	var media = [SourceReference]()
	var evidence = [EvidenceReference]()
	
    func addIdentifiersFromJson(pson:JSON) {
		if pson["identifiers"] != nil {
			for (type, ids) in pson["identifiers"] {
				var typeIds = Identifiers.convertJsonToIdentifier(type: type, json: ids)
				for id in typeIds {
					self.identifiers.append(id)
				}
			}
		}
	}
}