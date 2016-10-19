import Foundation

class PlaceHelper {
    static var UNKNOWN = "Unknown"
    static var usStates = [ "alabama", "alaska", "arizona", "arkansas", "british america",
        "british colonial america", "california","colonial america", "colorado", "connecticut",
        "delaware","florida","georgia","hawaii","idaho","illinois","indiana","iowa","kansas",
        "kentucky","louisiana","maine","maryland","massachusetts","michigan","minnesota",
        "mississippi","missouri","montana","nebraska","nevada","new hampshire","new jersey",
        "new mexico","new york","north carolina","north dakota","ohio","oklahoma","oregon",
        "pennsylvania","rhode island", "south carolina","south dakota","tennessee","texas",
        "utah","vermont","virginia","washington","west virginia","wisconsin","wyoming" ]
    
    static var abbvStates = [ "ak","al", "ala","alaska","ar","ariz","ark","az","ca","calif","co","colo","con","conn",
        "ct","de","del","fl","fla","ga","hawaii","hi","ia","id","idaho",
        "il","ill","in","ind","iowa","kans","ks","ky","la","ma","maine","md","me","mass","mi",
        "mich","minn","miss","mn","mo","ms","mt","mont","n.h","n.j","n.m","n.y","n.c","n.d",
        "ne","nebr","nev","nc","nd","nh","nj","nm","nv","ny","oh","ohio","ok","okla","or","ore",
        "pa","penn","r.i","ri","s.c","s.d","sc","sd","tenn","tn","tex","tx","ut","utah","vt",
        "va","wa","wash","w.va","wi","wis","wv","wy","wyo" ]
    
    static var canadaStates = [ "alberta","british columbia","manitoba","new brunswick","newfoundland",
        "newfoundland and labrador","nova scotia","ontario","prince edward island","quebec","saskatchewan" ]
		
	static var synonyms = ["holland":"Netherlands", "prussia":"Germany", "eng":"England", "great britain":"England", "gb":"England", 
					"northern ireland":"Ireland" ]
    
	static func countPlaceLevels(_ place:String) -> Int {
		let parts = place.split("[ ,]+")
		return parts.count
	}
    
    static func getTopPlace(_ place:String?) -> String? {
        if place == nil {
            return nil
        }
        let parts = place!.split("[,\\\\/]+")
        return parts[parts.count-1].trim().replaceAll("[<>\\[\\]\\(\\)\\.\"]+", replace: "")
    }
    
    static func getTopPlace(_ place:String?, level:Int) -> String? {
        if place == nil {
            return nil
        }
        let parts = place!.split("[,\\\\/]+");
        if (parts.count >= level) {
            return parts[parts.count - level].trim().replaceAll("[<>\\[\\]\\(\\)\\.\"]+", replace: "");
        }
        return parts[parts.count - 1].trim().replaceAll("[<>\\[\\]\\(\\)\\.\"]+", replace: "");
    }
    
    static func isInUS(_ place:String) -> Bool {
        var tempPlace = place.lowercased()
        tempPlace = tempPlace.replaceAll("territory", replace: "").replaceAll("nation", replace: "").trim()
        if (tempPlace == "united states") {
            return true;
        }
        if (tempPlace == "united states of america") { return true; }
        if (tempPlace == "us") { return true; }
        if (tempPlace == "usa") { return true; }
		if (tempPlace == "new england") { return true }
        if (tempPlace == "american colonies") { return true }
        var i = usStates.index(of: tempPlace)
        if (i != nil) { return true; }
        i = abbvStates.index(of: tempPlace);
        if (i != nil) { return true; }
        let parts = tempPlace.split(" ");
        if (parts.count == 1) { return false; }
        for p in parts {
            i = usStates.index(of: p);
            if (i != nil) { return true; }
            i = abbvStates.index(of: p);
            if (i != nil) { return true; }
        }
        return false;
    }
	
    static func getPlaceCountry(_ p:String?) -> String {
        var place = PlaceHelper.getTopPlace(p);
        if (place == nil) {
            return UNKNOWN
        }
		
		if (place!.caseInsensitiveCompare("United States") != ComparisonResult.orderedSame
            && PlaceHelper.isInUS(place!)) {
                return "United States"
        }
		
        if (place!.caseInsensitiveCompare("United Kingdom") == ComparisonResult.orderedSame) {
            place = getTopPlace(p, level: 2);
        }
        
        if (canadaStates.index(of: place!.lowercased()) != nil) {
            return "Canada"
        }
		
		if (place!.lowercased().hasSuffix("england")) {
            return "England"
        }
		
		if synonyms[place!.lowercased()] != nil {
			place = synonyms[place!.lowercased()]
		}
		
        return place!
    }
	
	static func getPersonCountry(_ person:LittlePerson) -> String {
		var place = PlaceHelper.getPlaceCountry(person.birthPlace as String?);
        //-- sometimes people use nationality as a note, try to ignore those
        if (person.nationality != nil && person.nationality!.length < 80) {
			place = person.nationality! as String
		}
		return place
	}
}
