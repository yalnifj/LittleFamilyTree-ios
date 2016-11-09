import Foundation

class Subject : Conclusion {
	var extracted:Bool?
	var identifiers = [Identifier]()
	var media = [SourceReference]()
	var evidence = [EvidenceReference]()
	
    func addIdentifiersFromJson(_ pson:JSON) {
		if pson["identifiers"] != JSON.null {
			for (type, ids) in pson["identifiers"] {
				let typeIds = Identifier.convertJsonToIdentifier(type, json: ids)
				for id in typeIds {
					self.identifiers.append(id)
				}
			}
		}
	}
}
