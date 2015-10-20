import Foundation
import SQLite

class DBHelper {
	static let VERSION:Int = 3
	static let UUID_PROPERTY = "UUID"
	
	let TABLE_LITTLE_PERSON = Table("littleperson")
	let TABLE_RELATIONSHIP = Table("relationship")
	let TABLE_MEDIA = Table("media")
	let TABLE_TAGS = Table("tags")
    let TABLE_PROPERTIES = Table("properties")
	let TABLE_SYNCQ = Table("syncq")
	
	let COL_ID = Expression<Int>("id")
	let COL_NAME = Expression<String?>("name")
	let COL_GIVEN_NAME = Expression<String?>("givenName")
	let COL_FAMILY_SEARCH_ID = Expression<String>("familySearchId")
	let COL_PHOTO_PATH = Expression<String?>("photopath")
	let COL_BIRTH_DATE = Expression<Int64?>("birthDate")
	let COL_AGE = Expression<Int?>("age")
	let COL_GENDER = Expression<String?>("gender")
    let COL_ALIVE = Expression<Bool?>("alive")
	let COL_ID1 = Expression<Int?>("id1")
	let COL_ID2 = Expression<Int?>("id2")
	let COL_TYPE = Expression<Int?>("type")
	let COL_MEDIA_TYPE = Expression<String?>("type")
	let COL_LOCAL_PATH = Expression<String?>("localpath")
    let COL_MEDIA_ID = Expression<Int?>("media_id")
    let COL_LEFT = Expression<Int?>("left")
    let COL_TOP = Expression<Int?>("top")
    let COL_RIGHT = Expression<Int?>("right")
    let COL_BOTTOM = Expression<Int?>("bottom")
    let COL_PERSON_ID = Expression<Int?>("person_id")
    let COL_LAST_SYNC = Expression<Int?>("last_sync")
    let COL_ACTIVE = Expression<Bool?>("active")
    let COL_BIRTH_PLACE = Expression<String?>("birthPlace")
    let COL_NATIONALITY = Expression<String?>("nationality")
    let COL_HAS_PARENTS = Expression<Bool?>("hasParents")
	let COL_HAS_CHILDREN = Expression<Bool?>("hasChildren")
	let COL_HAS_SPOUSES = Expression<Bool?>("hasSpouses")
	let COL_HAS_MEDIA = Expression<Bool?>("hasMedia")
	let COL_TREE_LEVEL = Expression<Int?>("treeLevel")
	let COL_PROPERTY = Expression<String>("property")
	let COL_VALUE = Expression<String>("value")
	
	private static let instance:DBHelper?
	
	static func getInstance()-> DBHelper {
		if instance == nil {
			instance = DBHelper()
		}
		return instance
	}
	
	var lftdb:Connection?
	var dbversion:Int32?
	
	func init() {
		let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
		lftdb = try Connection("\(path)/lftdb.sqlite3")
		
		dbversion = try? lftdb.scalar("PRAGMA user_version") as! Int32
		if dbversion==nil || dbversion < VERSION {
			createTables()
		}
	}
	
	func createTables() {
		try lftdb.run(TABLE_LITTLE_PERSON.create { t in
			t.column(COL_ID, primaryKey: true)
			t.column(COL_GIVEN_NAME)
			t.column(COL_NAME)
			t.column(COL_FAMILY_SEARCH_ID, unique: true)
			t.column(COL_PHOTO_PATH)
			t.column(COL_BIRTH_DATE)
			t.column(COL_BIRTH_PLACE)
			t.column(COL_NATIONALITY)
			t.column(COL_AGE)
			t.column(COL_GENDER)
			t.column(COL_ALIVE)
			t.column(COL_HAS_PARENTS)
			t.column(COL_HAS_CHILDREN)
			t.column(COL_HAS_SPOUSES)
			t.column(COL_HAS_MEDIA)
			t.column(COL_ACTIVE)
			t.column(COL_LAST_SYNC)
			t.column((COL_TREE_LEVEL)
		})
		
		try lftdb.run(TABLE_RELATIONSHIP.create { t in
			t.column(COL_ID, primaryKey: true)
			t.column(COL_ID1)
			t.column(COL_ID2)
			t.column(COL_TYPE)
			t.foreignKey(COL_ID1, references: TABLE_LITTLE_PERSON, COL_ID)
			t.foreignKey(COL_ID2, references: TABLE_LITTLE_PERSON, COL_ID)
		})
		
		try lftdb.run(TABLE_MEDIA.create { t in 
			t.column(COL_ID, primaryKey: true)
			t.column(COL_FAMILY_SEARCH_ID)
			t.column(COL_MEDIA_TYPE)
			t.column(COL_LOCAL_PATH)
		})
		
		try lftdb.run(TABLE_TAGS.create { t in
			t.column(COL_ID, primaryKey: true)
			t.column(COL_MEDIA_ID)
			t.column(COL_PERSON_ID)
			t.column(COL_LEFT)
			t.column(COL_TOP)
			t.column(COL_RIGHT)
			t.column(COL_BOTTOM)
			t.foreignKey(COL_MEDIA_ID, references: TABLE_MEDIA, COL_ID)
			t.foreignKey(COL_PERSON_ID, references: TABLE_LITTLE_PERSON, COL_ID)
		})
		
		try lftdb.run(TABLE_PROPERTIES.create { t in 
			t.column(COL_PROPERTY, primaryKey: true)
			t.column(COL_VALUE)
			t.column(COL_LAST_SYNC)
		})
		
		try lftdb.run(TABLE_PROPERTIES.insert(COL_PROPERTY <- UUID_PROPERTY, COL_VALUE <- NSUUID().UUIDString))
		
		try lftdb.run(TABLE_SYNCQ.create { t in 
			t.column(COL_ID)
		})
		
		try lftdb.execute("PRAGMA user_version = \(VERSION);")
	}
	
	func persistLittlePerson(person:LittlePerson) {
		if person.id == nil || person.id == 0 {
			let existing = getPersonByFamilySearchId(person.familySearchId)
			if existing != nil {
				person.id = existing.id
			}
		}
		
		var gender = "U"
		if person.gender == GenderType.MALE {
			gender = "M"
		} else if person.gender == GenderType.FEMALE {	
			gender = "F"
		}
		
		if person.id? > 0 {
			let personRow = TABLE_LITTLE_PERSON.filter(COL_ID == person.id)
			try db.run(personRow.update(
				COL_NAME <- person.name,
				COL_GIVEN_NAME <- person.givenName,
				COL_GENDER <- gender,
				COL_PHOTO_PATH <- person.photoPath,
				COL_AGE <- person.age,
				COL_BIRTH_DATE <- person.birthDate?.timeIntervalSince1970,
				COL_FAMILY_SEARCH_ID <- person.familySearchId,
				COL_LAST_SYNC <- person.lastSync?.timeIntervalSince1970,
				COL_ALIVE <- person.alive,
				COL_ACTIVE <- person.active,
				COL_BIRTH_PLACE <- person.birthPlace,
				COL_NATIONALITY <- person.nationality,
				COL_HAS_PARENTS <- person.hasParents,
				COL_HAS_CHILDREN <- person.hasChildren,
				COL_HAS_SPOUSES <- person.hasSpouses,
				COL_HAS_MEDIA <- person.hasMedia,
				COL_TREE_LEVEL <- person.treeLevel
			))
		}
		else {
			let rowid = try db.run(TABLE_LITTLE_PERSON.insert(
				COL_NAME <- person.name,
				COL_GIVEN_NAME <- person.givenName,
				COL_GENDER <- gender,
				COL_PHOTO_PATH <- person.photoPath,
				COL_AGE <- person.age,
				COL_BIRTH_DATE <- person.birthDate?.timeIntervalSince1970,
				COL_FAMILY_SEARCH_ID <- person.familySearchId,
				COL_LAST_SYNC <- person.lastSync?.timeIntervalSince1970,
				COL_ALIVE <- person.alive,
				COL_ACTIVE <- person.active,
				COL_BIRTH_PLACE <- person.birthPlace,
				COL_NATIONALITY <- person.nationality,
				COL_HAS_PARENTS <- person.hasParents,
				COL_HAS_CHILDREN <- person.hasChildren,
				COL_HAS_SPOUSES <- person.hasSpouses,
				COL_HAS_MEDIA <- person.hasMedia,
				COL_TREE_LEVEL <- person.treeLevel
			))
			person.id = rowid
		}
	}
	
	func getPersonById(id:Int) -> LittlePerson? {
		var person:LittlePerson?
		for c in try lftdb.prepare(TABLE_LITTLE_PERSON.filter(COL_ID == id)) {
			person = personFromCursor(c)
		}
		return person
	}
	
	func getPersonByFamilySearchId(fsid:String) -> LittlePerson? {
		var person:LittlePerson?
		for c in try lftdb.prepare(TABLE_LITTLE_PERSON.filter(COL_FAMILY_SEARCH_ID == fsid)) {
			person = personFromCursor(c)
		}
		return person
	}
	
	func deletePersonById(id:Int) {
		let personRow = TABLE_LITTLE_PERSON.filter(COL_ID == id)
		try lftdb.run(personRow.delete()) {
	}
	
	func getRandomPersonWithMedia() -> LittlePerson? {
		var person:LittlePerson?
		let stmt = try lftdb.prepare("select p.* from littleperson p join tags t on t.person_id=p.id"+
			" where p.active='Y' order by RANDOM() LIMIT 1")
		for c in stmt {
			person = personFromCursor(c)
		}
		return person
	}
	
	func personFromCursor(c:[]) -> LittlePerson {
		var person = LittlePerson()
		person.id = c[COL_ID]
		if c[COL_BIRTH_DATE] != nil {
			person.birthDate = NSDate(c[COL_BIRTH_DATE])
		}
		person.birthPlace = c[COL_BIRTH_PLACE]?
		person.nationality = c[COL_NATIONALITY]?
		person.familySearchId = c[COL_FAMILY_SEARCH_ID]
		if c[COL_GENDER] != nil {
			if c[COL_GENDER] == "M" {
				person.gender = GenderType.MALE
			}
			else if c[COL_GENDER] == "F" {
				person.gender = GenderType.FEMALE
			}
			else {
				person.gender = GenderType.UNKNOWN
			}
		}
		person.age = c[COL_AGE]?
		person.givenName = c[COL_GIVEN_NAME]?
		person.name = c[COL_NAME]?
		person.photoPath = c[COL_PHOTO_PATH]?
		if c[COL_LAST_SYNC] != nil {
			person.lastSync = NSDate(c[COL_LAST_SYNC])
		}
		person.alive = c[COL_ALIVE]
		person.active = c[COL_ACTIVE]
		person.hasParents = c[COL_HAS_PARENTS]?
		person.hasChildren = c[COL_HAS_CHILDREN]?
		person.hasSpouses = c[COL_HAS_SPOUSES]?
		person.hasMedia = c[COL_HAS_MEDIA]?
		person.treeLevel = c[COL_TREE_LEVEL]?
		person.updateAge()
		return person
	}
	
	func getRelativesForPerson(id:Int, followSpouse:Bool) -> [LittlePerson]? {
		let query = TABLE_LITTLE_PERSON.join(TABLE_RELATIONSHIP, on: TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID1] || TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID2])
			.filter(TABLE_RELATIONSHIP[COL_ID] == id)
			.select(TABLE_LITTLE_PERSON[*])
		var persons = [LittlePerson]()
		for c in query {
			let person = personFromCursor(c)
			persons.append(person)
		}
		return persons
	}
}
