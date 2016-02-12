import Foundation

class FamilyHolder {
	var id:String?
	var facts = [Fact]()
	var relationships = [Relationship]()
	var media = [SourceReference]()
	var parents = [Link]()
	var children = [Link]()
}