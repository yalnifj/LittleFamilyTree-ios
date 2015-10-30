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
	
	init() {
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
	
	func getFirstPerson() -> LittlePerson? {
		var person:LittlePerson?
		let stmt = try lftdb.prepare("select p.* from littleperson p where p.active='Y' order by id LIMIT 1")
		for c in stmt {
			person = personFromCursor(c)
		}
		return person
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
			.filter((TABLE_RELATIONSHIP[COL_ID1] == id || TABLE_RELATIONSHIP[COL_ID2] == id) && TABLE_LITTLE_PERSON[COL_ACTIVE])
			.select(TABLE_LITTLE_PERSON[*])
		var persons = [LittlePerson]()
		for c in query {
			let person = personFromCursor(c)
			persons.append(person)
		}
		
		if followSpouse {
			var spouses = getSpousesForPerson(id)
			for spouse in spouses {
				var speople = getRelativesForPerson(spouse.id, false)
				for sp in speople {
					if !persons.contains(sp) {
						persons.append(sp)
					}
				}
			}
		}
		
		return persons
	}
	
	func getParentsForPerson(id:Int) -> [LittlePerson]? {
		let query = TABLE_LITTLE_PERSON.join(TABLE_RELATIONSHIP, on: TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID1])
			.filter(TABLE_RELATIONSHIP[COL_ID2] == id && TABLE_RELATIONSHIP[COL_TYPE] == RelationshipType.PARENTCHILD && TABLE_LITTLE_PERSON[COL_ACTIVE])
			.select(TABLE_LITTLE_PERSON[*])
		var persons = [LittlePerson]()
		for c in query {
			let person = personFromCursor(c)
			persons.append(person)
		}
		return persons
	}
	
	func getChildrenForPerson(id:Int) -> [LittlePerson]? {
		let query = TABLE_LITTLE_PERSON.join(TABLE_RELATIONSHIP, on: TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID2])
			.filter(TABLE_RELATIONSHIP[COL_ID1] == id && TABLE_RELATIONSHIP[COL_TYPE] == RelationshipType.PARENTCHILD && TABLE_LITTLE_PERSON[COL_ACTIVE])
			.select(TABLE_LITTLE_PERSON[*])
		var persons = [LittlePerson]()
		for c in query {
			let person = personFromCursor(c)
			persons.append(person)
		}
		return persons
	}
	
	func getSpousesForPerson(id:Int) -> [LittlePerson]? {
		let query = TABLE_LITTLE_PERSON.join(TABLE_RELATIONSHIP, on: TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID1] || TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID2])
			.filter((TABLE_RELATIONSHIP[COL_ID1] == id || TABLE_RELATIONSHIP[COL_ID2] == id) && TABLE_RELATIONSHIP[COL_TYPE] == RelationshipType.SPOUSE && TABLE_LITTLE_PERSON[COL_ACTIVE])
			.select(TABLE_LITTLE_PERSON[*])
		var persons = [LittlePerson]()
		for c in query {
			if (c[COL_ID]!=id) {
				let person = personFromCursor(c)
				persons.append(person)
			}
		}
		return persons
	}
	
	func persistRelationship(r:Relationship) -> Int64 {
		var rowid:Int64 = 0
		
		if r.id == nil || r.id == 0 {
			var old = getRelationship(r.id1, r.id2, r.type)
			if old != nil {
				if old.type != r.type || old.id1 != r.id1 || old.id2 != r.id2 {
					deleteRelationship(old.id)
				} else {
					r.id = old.id;
					return old.id;
				}
			}
		}
		
		rowid = try db.run(TABLE_RELATIONSHIP.insert(
			COL_ID1 <- r.id1
			COL_ID2 <- r.id2
			COL_type <- r.type
		))
		r.id = rowid
		
		return rowid
	}
	
	func getRelationship(id1:Int, id2:Int, type:RelationshipType) -> Relationship? {
		var rel:Relationship?
		let query = TABLE_RELATIONSHIP.filter(COL_ID1==id1 && COL_ID2==id2 && COL_TYPE=type)
		for r in try lftdb.run(query) {
			rel = relationshipFromCursor(r)
		}
		return rel
	}
	
	func getRelationshipsForPerson(id:Int) -> [Relationship]? {
		var rels = [Relationship]()
		let query = TABLE_RELATIONSHIP.filter(COL_ID1==id || COL_ID2==id)
		for r in try lftdb.run(query) {
			rel = relationshipFromCursor(r)
			rels.append(rel)
		}
		return rels
	}
	
	func relationshipFromCursor(c:[]) -> Relationship {
		let r = Relationship()
		r.id1 = c[COL_ID1]
		r.id2 = c[COL_ID2]
		r.type = c[COL_TYPE]
		r.id = c[COL_ID]
		return r
	}
	
	func deleteRelationshipById(id:Int) {
		let row = TABLE_RELATIONSHIP.filter(COL_ID==id)
		try lftdb.run(row.delete())
	}
	
	func persistMedia(media:Media) {
		if media.id == nil || media.id == 0 {
			var existing = getMediaByFamilySearchId(media.familySearchId)
			if existing != nil {
				media.id = existing.id
			} else {
				let rowid = try lftdb.run(TABLE_MEDIA.insert(
					COL_FAMILY_SEARCH_ID <- media.familySearchId
					COL_TYPE <- media.type
					COL_LOCAL_PATH <- media.localPath
				))
				media.id = rowid
				return
			}
		}
		
	
		let mediaRow = TABLE_MEDIA.filter(COL_ID=media.id)
		try lftdb.run(mediaRow.update(
			COL_FAMILY_SEARCH_ID <- media.familySearchId,
			COL_TYPE <- media.type
			COL_LOCAL_PATH <- media.localPath
		))
	}
	
	func getMediaByFamilySearchId(fsid:String) -> Media? {
		var media:Media? = nil
		let query = TABLE_MEDIA.filter(COL_FAMILY_SEARCH_ID == fsid)
		for m in try lftdb.run(query) {
			media = mediaFromCursor(m)
		}
		return media
	}
	
	func getMediaForPerson(id:Int) -> [Media]? {
		var media = [Media]()
		let query = TABLE_MEDIA.join(TABLE_TAGS, on: TABLE_MEDIA[COL_ID] == TABLE_TAGS[COL_MEDIA_ID])
			.filter(TABLE_TAGS[COL_PERSON_ID] == id)
			.select(TABLE_MEDIA[*])
		for m in try lftdb.run(query) {
			let med = mediaFromCursor(m)
			media.append(med)
		}
		return media
	}
	
	func deleteMediaById(id:Int) {
		let mediaRow = TABLE_MEDIA.filter(COL_ID=media.id)
		try lftdb.run(mediaRow.delete())
	}
	
	func mediaFromCursor(m:[]) -> Media {
		let media = Media()
		media.id = m[COL_ID]
		media.familySearchId = m[COL_FAMILY_SEARCH_ID]
		media.type = m[COL_TYPE]
		media.localPath = m[COL_LOCAL_PATH]
		return media
	}
	
	public getMediaCount() -> Int64 {
		let countm = try lftdb.scalar(TABLE_MEDIA.count)
		let countp = try lftdb.scalar(TABLE_LITTLE_PERSON.filter(COL_PHOTO_PATH != nil).count)
		return countm + countp
	}
	
	func persistTag(tag:Tag) {
		if tag.id == nil || tag.id == 0 {
			var existing = getTagForPersonMedia(tag.personId, tag.mediaId)
			if existing != nil {
				tag.id = existing.id
			} else {
				let rowid = try lftdb.run(TABLE_TAG.insert(
					COL_PERSON_ID <- tag.personId
					COL_MEDIA_ID <- tag.mediaId
					COL_LEFT <- tag.left
					COL_RIGHT <- tag.right
					COL_TOP <- tag.top
					COL_BOTTOM <- tag.bottom
				))
				tag.id = rowid
				return
			}
		}
		
		let tagRow = TABLE_TAG.filter(COL_ID=tag.id)
		try lftdb.run(tagRow.update(
			COL_PERSON_ID <- tag.personId,
			COL_MEDIA_ID <- tag.mediaId,
			COL_LEFT <- tag.left,
			COL_RIGHT <- tag.right,
			COL_TOP <- tag.top,
			COL_BOTTOM <- tag.bottom
		))
		
	}
	
	func getTagForPersonMedia(personId:Int, mediaId:Int) -> Tag {
		var tag:Tag? = nil
		let query = TABLE_TAGS.filter(COL_PERSON_ID == personId && COL_MEDIA_ID==mediaRow)
		for t in try lftdb.run(query) {
			tag = Tag()
			tag.id = t[COL_ID]
			tag.mediaId = t[COL_MEDIA_ID]
			tag.personId = t[COL_PERSON_ID]
			tag.left = t[COL_LEFT]
			tag.right = t[COL_RIGHT]
			tag.top = t[COL_TOP]
			tag.bottom = t[COL_BOTTOM]
		}
		return tag
	}
	
	func saveProperty(property:NSString, value:NSString) {
		let existing = getProperty(property)
		if existing != nil {
			var query = TABLE_PROPERTIES.filter(COL_PROPERTY == property)
			try lftdb.run(query.update(
				COL_VALUE <- value
			))
		} else {
			try lftdb.run(TABLE_PROPERTIES.insert(
				COL_PROPERTY <- property
				COL_VALUE <- value
			))
		}
	}
	
	func getProperty(property:NSString) -> NSString? {
		var query = TABLE_PROPERTIES.filter(COL_PROPERTY == property)
		var value:NSString? = nil
		for t in try lftdb.run(query) {
			value = t[COL_VALUE]
		}
		return value
	}
	
	func addToSyncQ(id:Int) {
		var query = TABLE_SYNCQ.filter(COL_ID == id)
		let count = try lftdb.scalar(query.count)
		if count==0 {
			try lftdb.run(TABLE_SYNCQ.insert(COL_ID <- id))
		}
	}
	
	func removeFromSyncQ(id:Int) {
		var query = TABLE_SYNCQ.filter(COL_ID == id)
		let count = try lftdb.scalar(query.count)
		if count > 0 {
			try lftdb.run(query.delete())
		}
	}
	
	func getSyncQ() -> [Int] {
		var list = [Int]()
		for i in try lftdb.prepare(TABLE_SYNCQ) {
			list.append(i)
		}
		return list
	}
}