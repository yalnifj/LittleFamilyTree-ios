import Foundation
import SQLite

class DBHelper {
	static let VERSION:Int32? = 5
	static let UUID_PROPERTY = "UUID"
	
	let TABLE_LITTLE_PERSON = Table("littleperson")
	let TABLE_RELATIONSHIP = Table("relationship")
	let TABLE_MEDIA = Table("media")
	let TABLE_TAGS = Table("tags")
    let TABLE_PROPERTIES = Table("properties")
	let TABLE_SYNCQ = Table("syncq")
	let TABLE_LOCAL_RESOURCES = Table("localresources")
	
	let COL_ID = Expression<Int64>("id")
	let COL_NAME = Expression<String?>("name")
	let COL_GIVEN_NAME = Expression<String?>("givenName")
	let COL_FAMILY_SEARCH_ID = Expression<String>("familySearchId")
	let COL_PHOTO_PATH = Expression<String?>("photopath")
	let COL_BIRTH_DATE = Expression<NSDate?>("birthDate")
	let COL_AGE = Expression<Int?>("age")
	let COL_GENDER = Expression<String?>("gender")
    let COL_ALIVE = Expression<Bool?>("alive")
	let COL_ID1 = Expression<Int64>("id1")
	let COL_ID2 = Expression<Int64>("id2")
	let COL_TYPE = Expression<Int>("type")
	let COL_MEDIA_TYPE = Expression<String?>("type")
	let COL_LOCAL_PATH = Expression<String?>("localpath")
    let COL_MEDIA_ID = Expression<Int64?>("media_id")
    let COL_LEFT = Expression<Int?>("left")
    let COL_TOP = Expression<Int?>("top")
    let COL_RIGHT = Expression<Int?>("right")
    let COL_BOTTOM = Expression<Int?>("bottom")
    let COL_PERSON_ID = Expression<Int64?>("person_id")
    let COL_LAST_SYNC = Expression<NSDate?>("last_sync")
    let COL_ACTIVE = Expression<Bool?>("active")
    let COL_BIRTH_PLACE = Expression<String?>("birthPlace")
    let COL_NATIONALITY = Expression<String?>("nationality")
    let COL_HAS_PARENTS = Expression<Bool?>("hasParents")
	let COL_HAS_CHILDREN = Expression<Bool?>("hasChildren")
	let COL_HAS_SPOUSES = Expression<Bool?>("hasSpouses")
	let COL_HAS_MEDIA = Expression<Bool?>("hasMedia")
	let COL_TREE_LEVEL = Expression<Int?>("treeLevel")
	let COL_OCCUPATION = Expression<String?>("occupation")
	let COL_PROPERTY = Expression<String>("property")
	let COL_VALUE = Expression<String>("value")
	
    static var instance:DBHelper?
	
	static func getInstance() -> DBHelper {
		if instance == nil {
			instance = DBHelper()
            let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
            instance!.lftdb = try? Connection("\(path)/lftdb.sqlite3")
            // public func trace(callback: (String -> Void)?) {
            //instance!.lftdb?.trace({ (string) in
            //    print(string)
            //})
            //instance!.dbversion = instance!.lftdb?.scalar("PRAGMA user_version") as? Int32
            if instance!.tableExists("properties") == true {
                let dbstr = instance!.getProperty("VERSION")
                if dbstr != nil {
                    instance!.dbversion = Int32(dbstr!)
                }
                print("DBVersion is \(instance!.dbversion)")
            }
            if ((instance?.dbversion == nil) || (instance!.dbversion < 4)) {
                do {
                    try instance!.createTables()
                    instance?.saveProperty("VERSION", value: (DBHelper.VERSION?.description)!)
                    instance!.saveProperty(DBHelper.UUID_PROPERTY, value: NSUUID().UUIDString)
                } catch let error as NSError {
                    print("Error creating tables \(error.localizedDescription)")
                }
            } else if instance!.dbversion < 5 {
				do {
                    try instance!.createTables()
					instance?.saveProperty("VERSION", value: (DBHelper.VERSION?.description)!)
                } catch let error as NSError {
                    print("Error creating tables \(error.localizedDescription)")
                }
			}
		}
		return instance!
	}
	
	var lftdb:Connection?
	var dbversion:Int32?

	
	func createTables() throws {
        do {
            try lftdb?.run(TABLE_LITTLE_PERSON.create(ifNotExists: true) { t in
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
                t.column(COL_TREE_LEVEL)
				t.column(COL_OCCUPATION)
                })
        } catch let error as NSError {
            print("Error creating table little person \(error)")
        }
		
        do {
            try lftdb?.run(TABLE_RELATIONSHIP.create(ifNotExists: true) { t in
                t.column(COL_ID, primaryKey: true)
                t.column(COL_ID1)
                t.column(COL_ID2)
                t.column(COL_TYPE)
                t.foreignKey(COL_ID1, references: TABLE_LITTLE_PERSON, COL_ID)
                t.foreignKey(COL_ID2, references: TABLE_LITTLE_PERSON, COL_ID)
            })
        } catch let error as NSError {
            print("Error creating table relationship \(error)")
        }
		
        do {
            try lftdb?.run(TABLE_MEDIA.create(ifNotExists: true) { t in
                t.column(COL_ID, primaryKey: true)
                t.column(COL_FAMILY_SEARCH_ID)
                t.column(COL_MEDIA_TYPE)
                t.column(COL_LOCAL_PATH)
            })
        } catch let error as NSError {
            print("Error creating table media \(error)")
        }
		
		try lftdb?.run(TABLE_TAGS.create(ifNotExists: true) { t in
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
		
		try lftdb?.run(TABLE_PROPERTIES.create(ifNotExists: true) { t in
			t.column(COL_PROPERTY, primaryKey: true)
			t.column(COL_VALUE)
			t.column(COL_LAST_SYNC)
		})
        
        try lftdb?.run(TABLE_SYNCQ.create(ifNotExists: true) { t in
            t.column(COL_ID)
        })

		do {
            try lftdb?.run(TABLE_LOCAL_RESOURCES.create(ifNotExists: true) { t in
                t.column(COL_ID, primaryKey: true)
                t.column(COL_PERSON_ID)
                t.column(COL_MEDIA_TYPE)
                t.column(COL_LOCAL_PATH)
				t.foreignKey(COL_PERSON_ID, references: TABLE_LITTLE_PERSON, COL_ID)
            })
        } catch let error as NSError {
            print("Error creating table localresources \(error)")
        }
	}
	
	func persistLittlePerson(person:LittlePerson) throws {
		if person.id == nil || person.id == 0 {
			let existing = self.getPersonByFamilySearchId(person.familySearchId as! String)
			if existing != nil {
				person.id = existing!.id
			}
		}
		
		var gender = "U"
		if person.gender == GenderType.MALE {
			gender = "M"
		} else if person.gender == GenderType.FEMALE {	
			gender = "F"
		}
		
		if person.id > 0 {
			let personRow = TABLE_LITTLE_PERSON.filter(COL_ID == person.id!)
			try lftdb?.run(personRow.update(
				COL_NAME <- (person.name as String?),
				COL_GIVEN_NAME <- (person.givenName as String?),
				COL_GENDER <- gender,
				COL_PHOTO_PATH <- (person.photoPath as String?),
				COL_AGE <- person.age,
				COL_BIRTH_DATE <- person.birthDate,
				COL_FAMILY_SEARCH_ID <- (person.familySearchId as! String),
				COL_LAST_SYNC <- person.lastSync,
				COL_ALIVE <- person.alive,
				COL_ACTIVE <- person.active,
				COL_BIRTH_PLACE <- (person.birthPlace as String?),
				COL_NATIONALITY <- (person.nationality as String?),
				COL_HAS_PARENTS <- person.hasParents,
				COL_HAS_CHILDREN <- person.hasChildren,
				COL_HAS_SPOUSES <- person.hasSpouses,
				COL_HAS_MEDIA <- person.hasMedia,
				COL_TREE_LEVEL <- person.treeLevel,
				COL_OCCUPATION <- (person.occupation as String?)
			))
            print("Updated little person \(person.id!)")
		}
		else {
			let rowid = try lftdb?.run(TABLE_LITTLE_PERSON.insert(
				COL_NAME <- (person.name as String?),
				COL_GIVEN_NAME <- (person.givenName as String?),
				COL_GENDER <- gender,
				COL_PHOTO_PATH <- (person.photoPath as String?),
				COL_AGE <- person.age,
				COL_BIRTH_DATE <- person.birthDate,
				COL_FAMILY_SEARCH_ID <- (person.familySearchId as! String),
				COL_LAST_SYNC <- person.lastSync,
				COL_ALIVE <- person.alive,
				COL_ACTIVE <- person.active,
				COL_BIRTH_PLACE <- (person.birthPlace as String?),
				COL_NATIONALITY <- (person.nationality as String?),
				COL_HAS_PARENTS <- person.hasParents,
				COL_HAS_CHILDREN <- person.hasChildren,
				COL_HAS_SPOUSES <- person.hasSpouses,
				COL_HAS_MEDIA <- person.hasMedia,
				COL_TREE_LEVEL <- person.treeLevel,
				COL_OCCUPATION <- (person.occupation as String?)
			))
			person.id = rowid
            print("Inserted new little person \(person.id!) \(person.name)")
		}
	}
	
	func getPersonById(id:Int64) -> LittlePerson? {
		var person:LittlePerson
        do {
            let stmt = try lftdb?.prepare(TABLE_LITTLE_PERSON.filter(COL_ID == id))
            for c in stmt! {
                person = buildLittlePerson(c)
                person.id = c[COL_ID]
                return person
            }
        } catch {
            print("Error getting person by id \(id)")
        }
		return nil
	}
	
	func getPersonByFamilySearchId(fsid:String) -> LittlePerson? {
		var person:LittlePerson
        do {
            let stmt = try lftdb?.prepare(TABLE_LITTLE_PERSON.filter(COL_FAMILY_SEARCH_ID == fsid))
            for c in stmt! {
                person = buildLittlePerson(c)
                person.id = c[COL_ID]
                return person
            }
        } catch {
            print("Error getting person by fsid \(fsid)")
        }
		return nil
	}
	
	func deletePersonById(id:Int64) throws {
		let personRow = TABLE_LITTLE_PERSON.filter(COL_ID == id)
		try lftdb?.run( personRow.delete() )
	}
	
	func getFirstPerson() -> LittlePerson? {
		var person:LittlePerson
        do {
            let query = TABLE_LITTLE_PERSON.filter(COL_ACTIVE == true).order(COL_ID).limit(1)
            let stmt = try lftdb?.prepare(query)
            for c in stmt! {
                person = buildLittlePerson(c)
                person.id = c[COL_ID]
                return person
            }
        } catch {
            print("Error getting first person")
        }
		return nil
	}
    
    func search(given:String?, surname:String?, remoteid:String?) -> [LittlePerson] {
        var people = [LittlePerson]()
        
        if given != nil || surname != nil || remoteid != nil {
            do {
                var query = TABLE_LITTLE_PERSON.order(COL_NAME, COL_ID)
                if given != nil {
                    query = query.filter(COL_GIVEN_NAME.like(given! + "%"))
                }
                if surname != nil {
                    query = query.filter(COL_NAME.like("%\(surname!)%") )
                }
                if remoteid != nil {
                    query = query.filter(COL_FAMILY_SEARCH_ID.like(remoteid! + "%"))
                }
                let stmt = try lftdb?.prepare(query)
                for c in stmt! {
                    let person = buildLittlePerson(c)
                    person.id = c[COL_ID]
                    people.append(person)
                }
            } catch {
                print("Error getting searching people")
            }
        }
        return people;
    }

	
	func getRandomPersonWithMedia() -> LittlePerson? {
		var person:LittlePerson?
        do {
		let stmt = try lftdb?.prepare("select p.id, p.birthDate, p.birthPlace, p.nationality, p.familySearchId, p.gender, p.age, "
            + " p.givenName, p.name, p.photopath, p.last_sync, p.alive, p.active, p.hasParents, p.hasChildren, p.hasSpouses, "
            + " p.hasMedia, p.treeLevel, p.occupation "
            + " from littleperson p join tags t on t.person_id=p.id" +
			" where p.active=1 order by RANDOM() LIMIT 1")
        print(stmt)
		for c in stmt! {
            person = LittlePerson()
            person!.id = (c[0] as! Int64)
            if c[1] != nil {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let parts = (c[1] as! String).split("T")
                let birthDate = formatter.dateFromString(parts[0])
                person!.birthDate = birthDate
            }
            if c[2] != nil { person!.birthPlace = (c[2] as! String) }
            if c[3] != nil { person!.nationality = (c[3] as! String?) }
            if c[4] != nil { person!.familySearchId = (c[4] as! String) }
            let gender = (c[5] as? String?)
            
            if gender != nil {
                if gender! == "M" {
                    person!.gender = GenderType.MALE
                }
                else if gender! == "F" {
                    person!.gender = GenderType.FEMALE
                }
                else {
                    person!.gender = GenderType.UNKNOWN
                }
            }
            person!.age = Int(c[6] as! Int64)
            if c[7] != nil { person!.givenName = (c[7] as! String?) }
            if c[8] != nil { person!.name = (c[8] as! String?) }
            if c[9] != nil { person!.photoPath = (c[9] as! String?) }
            if c[10] != nil {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
                let parts = (c[10] as! String).split(".")
                let syncDate = formatter.dateFromString(parts[0])
                person!.lastSync = syncDate
            }
            
            person!.alive = (c[11] as! Int64 == 1)
            person!.active = (c[12] as! Int64 == 1)
            if c[13] != nil { person!.hasParents = (c[13] as! Int64 == 1) }
            if c[14] != nil { person!.hasChildren = (c[14] as! Int64 == 1) }
            if c[15] != nil { person!.hasSpouses = (c[15] as! Int64 == 1) }
            if c[16] != nil { person!.hasMedia = (c[16] as! Int64 == 1) }
            if c[17] != nil { person!.treeLevel = Int(c[17] as! Int64) }
			if c[18] != nil { person!.occupation = (c[18] as! String?) }
            person!.updateAge()

		}
        } catch {
            print("Error getting random person")
        }
		return person
	}
	
	func getNextBirthdays(maxNumber:Int, maxLevel:Int) -> [LittlePerson] {
		var people = [LittlePerson]()
        do {
            //let sql = "select a.* from (select p.id, p.birthDate, p.birthPlace, p.nationality, p.familySearchId, p.gender, p.age, p.givenName, p.name, p.photopath, p.last_sync, p.alive, p.active, p.hasParents, p.hasChildren, p.hasSpouses, p.hasMedia, p.treeLevel, p.occupation, strftime('%s','now') as todaysecs, cast(cast(((strftime('%s','now') - (604800 + strftime('%s', p.birthDate))) / 31557600) as int) as string) as yeardiff from littleperson p where p.active='Y' and p.birthDate is not null and p.treeLevel < \(maxLevel) ) a order by strftime('%s', a.birthDate) + (a.yeardiff * 31557600) + (86400 * 5 * a.treeLevel) LIMIT \(maxNumber)"
            let sql = "select p.id, p.birthDate, p.birthPlace, p.nationality, p.familySearchId, p.gender, p.age, p.givenName, p.name, p.photopath, p.last_sync, p.alive, p.active, p.hasParents, p.hasChildren, p.hasSpouses, p.hasMedia, p.treeLevel, p.occupation, (strftime('%s','now') - (604800 + strftime('%s', p.birthDate))) / 31557600 as yeardiff from littleperson p where p.active=1 and p.birthDate is not null and p.treeLevel < \(maxLevel) order by strftime('%s', p.birthDate) + (yeardiff * 31557600) + (86400 * 5 * p.treeLevel) LIMIT \(maxNumber)"
            
		let stmt = try lftdb?.prepare( sql )
        print(sql)
		for c in stmt! {
            print("name=\(c[8]) birth=\(c[1]) yeardiff=\(c[19])")
            let person = LittlePerson()
            person.id = (c[0] as! Int64)
            if c[1] != nil {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let parts = (c[1] as! String).split("T")
                let birthDate = formatter.dateFromString(parts[0])
                person.birthDate = birthDate
            }
            if c[2] != nil { person.birthPlace = (c[2] as! String) }
            if c[3] != nil { person.nationality = (c[3] as! String?) }
            if c[4] != nil { person.familySearchId = (c[4] as! String) }
            let gender = (c[5] as? String?)
            
            if gender != nil {
                if gender! == "M" {
                    person.gender = GenderType.MALE
                }
                else if gender! == "F" {
                    person.gender = GenderType.FEMALE
                }
                else {
                    person.gender = GenderType.UNKNOWN
                }
            }
            person.age = Int(c[6] as! Int64)
            if c[7] != nil { person.givenName = (c[7] as! String?) }
            if c[8] != nil { person.name = (c[8] as! String?) }
            if c[9] != nil { person.photoPath = (c[9] as! String?) }
            if c[10] != nil {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
                let parts = (c[10] as! String).split(".")
                let syncDate = formatter.dateFromString(parts[0])
                person.lastSync = syncDate
            }
            
            person.alive = (c[11] as! Int64 == 1)
            person.active = (c[12] as! Int64 == 1)
            if c[13] != nil { person.hasParents = (c[13] as! Int64 == 1) }
            if c[14] != nil { person.hasChildren = (c[14] as! Int64 == 1) }
            if c[15] != nil { person.hasSpouses = (c[15] as! Int64 == 1) }
            if c[16] != nil { person.hasMedia = (c[16] as! Int64 == 1) }
            if c[17] != nil { person.treeLevel = Int(c[17] as! Int64) }
			if c[18] != nil { person.occupation = (c[18] as! String?) }
            person.updateAge()
			people.append(person)
		}
        } catch {
            print("Error getting next birthdays")
        }
		return people
	}

	func getRelativesForPerson(id:Int64, followSpouse:Bool) -> [LittlePerson]? {
        var persons = [LittlePerson]()
        do {
            let query = TABLE_LITTLE_PERSON.join(TABLE_RELATIONSHIP, on: TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID1] || TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID2])
                .filter((TABLE_RELATIONSHIP[COL_ID1] == id || TABLE_RELATIONSHIP[COL_ID2] == id) && TABLE_LITTLE_PERSON[COL_ACTIVE])

            let stmt = try lftdb?.prepare(query)
            for c in stmt! {
                let person = buildLittlePerson(c)
                person.id = c[TABLE_LITTLE_PERSON[COL_ID]]
                if !persons.contains(person) {
                    persons.append(person)
                }
            }
            
            if followSpouse {
                let spouses = getSpousesForPerson(id)
                for spouse in spouses! {
                    let speople = getRelativesForPerson(spouse.id!, followSpouse: false)
                    for sp in speople! {
                        if !persons.contains(sp) {
                            persons.append(sp)
                        }
                    }
                }
            }
        } catch {
            print("Error getting person relatives by id \(id)")
        }
		
		return persons
	}
	
	func getParentsForPerson(id:Int64) -> [LittlePerson]? {
		let query = TABLE_LITTLE_PERSON.join(TABLE_RELATIONSHIP, on: TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID1])
			.filter(TABLE_RELATIONSHIP[COL_ID2] == id && TABLE_RELATIONSHIP[COL_TYPE] == RelationshipType.PARENTCHILD.hashValue && TABLE_LITTLE_PERSON[COL_ACTIVE])

		var persons = [LittlePerson]()
        do {
            let stmt = try lftdb?.prepare(query)
            for c in stmt! {
                let person = buildLittlePerson(c)
                person.id = c[TABLE_LITTLE_PERSON[COL_ID]]
                persons.append(person)
            }
        } catch {
            print("Error getting person parents by id \(id)")
        }
		return persons
	}
	
	func getChildrenForPerson(id:Int64) -> [LittlePerson]? {
		let query = TABLE_LITTLE_PERSON.join(TABLE_RELATIONSHIP, on: TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID2])
			.filter(TABLE_RELATIONSHIP[COL_ID1] == id && TABLE_RELATIONSHIP[COL_TYPE] == RelationshipType.PARENTCHILD.hashValue && TABLE_LITTLE_PERSON[COL_ACTIVE])

		var persons = [LittlePerson]()
        do {
            let stmt = try lftdb?.prepare(query)
            for c in stmt! {
                let person = buildLittlePerson(c)
                person.id = c[TABLE_LITTLE_PERSON[COL_ID]]
                persons.append(person)
            }
        } catch {
            print("Error getting person children by id \(id)")
        }
		return persons
	}
	
	func getSpousesForPerson(id:Int64) -> [LittlePerson]? {
		let query = TABLE_LITTLE_PERSON.join(TABLE_RELATIONSHIP, on: TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID1] || TABLE_LITTLE_PERSON[COL_ID] == TABLE_RELATIONSHIP[COL_ID2])
			.filter((TABLE_RELATIONSHIP[COL_ID1] == id || TABLE_RELATIONSHIP[COL_ID2] == id) && TABLE_RELATIONSHIP[COL_TYPE] == RelationshipType.SPOUSE.rawValue && TABLE_LITTLE_PERSON[COL_ACTIVE])

		var persons = [LittlePerson]()
        do {
            let stmt = try lftdb?.prepare(query)
            for c in stmt! {
                if (c[TABLE_LITTLE_PERSON[COL_ID]] != id) {
                    let person = buildLittlePerson(c)
                    person.id = c[TABLE_LITTLE_PERSON[COL_ID]]
                    persons.append(person)
                }
            }
        } catch {
            print("Error getting person spouses by id \(id)")
        }
		return persons
	}
    
    func buildLittlePerson(c: Row) -> LittlePerson {
        let person = LittlePerson()
        if c[COL_BIRTH_DATE] != nil {
            person.birthDate = c[COL_BIRTH_DATE]
        }
        if c[COL_BIRTH_PLACE] != nil {
            person.birthPlace = NSString(UTF8String: c[COL_BIRTH_PLACE]!)
        }
        if c[COL_NATIONALITY] != nil {
            person.nationality = NSString(UTF8String: c[COL_NATIONALITY]!)
        }
        person.familySearchId = NSString(UTF8String: c[COL_FAMILY_SEARCH_ID])
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
        if c[COL_AGE] != nil { person.age = c[COL_AGE]! }
        if c[COL_GIVEN_NAME] != nil { person.givenName = NSString(UTF8String: c[COL_GIVEN_NAME]!) }
        if c[COL_NAME] != nil { person.name = NSString(UTF8String: c[COL_NAME]!) }
        if c[COL_PHOTO_PATH] != nil {
            person.photoPath = NSString(UTF8String: c[COL_PHOTO_PATH]!)
        }
        if c[COL_LAST_SYNC] != nil {
            person.lastSync = c[COL_LAST_SYNC]
        }
        person.alive = c[COL_ALIVE]
        if c[COL_ACTIVE] != nil {
            person.active = c[COL_ACTIVE]!
        }
        person.hasParents = c[COL_HAS_PARENTS]
        person.hasChildren = c[COL_HAS_CHILDREN]
        person.hasSpouses = c[COL_HAS_SPOUSES]
        person.hasMedia = c[COL_HAS_MEDIA]
        person.treeLevel = c[COL_TREE_LEVEL]
		person.occupation = c[COL_OCCUPATION]
        person.updateAge()

        return person
    }
	
	func persistRelationship(r:LocalRelationship) -> Int64 {
		var rowid:Int64? = 0
		
		if r.id == nil || r.id == 0 {
            let old = getRelationship(r.id1, id2:r.id2, type:r.type)
			if old != nil {
				if old!.type != r.type || old!.id1 != r.id1 || old!.id2 != r.id2 {
					deleteRelationshipById(old!.id)
				} else {
					r.id = old!.id;
					return old!.id;
				}
			}
		}
		
        do {
            rowid = try lftdb?.run(TABLE_RELATIONSHIP.insert(
                COL_ID1 <- r.id1,
                COL_ID2 <- r.id2,
                COL_TYPE <- r.type.rawValue
            ))
            r.id = rowid
        } catch {
            print("Error peristing relationship")
        }
		return rowid!
	}
	
	func getRelationship(id1:Int64, id2:Int64, type:RelationshipType) -> LocalRelationship? {
		var rel:LocalRelationship? = nil
        do {
            let query = TABLE_RELATIONSHIP.filter(COL_ID1==id1 && COL_ID2==id2 && COL_TYPE==type.hashValue)
            let stmt = try lftdb?.prepare(query)
            for r in stmt! {
                rel = LocalRelationship()
                rel?.id1 = r[COL_ID1]
                rel?.id2 = r[COL_ID2]
                rel?.type = RelationshipType(rawValue: r[COL_TYPE])
                rel?.id = r[COL_ID]
            }
        } catch {
            print("Error getting relationship by id \(id1) \(id2) \(type)")
        }
		return rel
	}
	
	func getRelationshipsForPerson(id:Int64) -> [LocalRelationship]? {
		var rels = [LocalRelationship]()
            do {
            let query = TABLE_RELATIONSHIP.filter(COL_ID1==id || COL_ID2==id)
            let stmt = try lftdb?.prepare(query)
            for r in stmt! {
                let rel = LocalRelationship()
                rel.id1 = r[COL_ID1]
                rel.id2 = r[COL_ID2]
                rel.type = RelationshipType(rawValue: r[COL_TYPE])
                rel.id = r[COL_ID]
                rels.append(rel)
            }
        } catch {
            print("error getting relationships for person with id \(id)")
        }
		return rels
	}
	
	func deleteRelationshipById(id:Int64) {
		let row = TABLE_RELATIONSHIP.filter(COL_ID == id)
        do {
            try lftdb?.run(row.delete())
        } catch {
            print("Error deleting relationship by id \(id)")
        }
	}
	
	func persistMedia(media:Media) {
		if media.id == nil || media.id == 0 {
			let existing = getMediaByFamilySearchId(media.familySearchId as! String)
			if existing != nil {
				media.id = existing!.id
			} else {
                do {
				let rowid = try lftdb?.run(self.TABLE_MEDIA.insert(
					self.COL_FAMILY_SEARCH_ID <- (media.familySearchId as! String),
					self.COL_MEDIA_TYPE <- (media.type as String?),
					self.COL_LOCAL_PATH <- (media.localPath as String?)
				))
				media.id = rowid
                } catch {
                    print("Unable to insert media")
                }
			}
		}
        else {
            let mediaRow = TABLE_MEDIA.filter(COL_ID == media.id)
            do {
            try lftdb?.run(mediaRow.update(
                COL_FAMILY_SEARCH_ID <- (media.familySearchId as! String),
                COL_MEDIA_TYPE <- (media.type as String?),
                COL_LOCAL_PATH <- (media.localPath as String?)
            ))
            } catch {
                print("Unable to update media with id \(media.id)")
            }
        }
	}
	
	func getMediaByFamilySearchId(fsid:String) -> Media? {
		var media:Media? = nil
        do {
            let query = TABLE_MEDIA.filter(COL_FAMILY_SEARCH_ID == fsid)
            let stmt = try lftdb?.prepare(query)
            for m in stmt! {
                media = Media()
                media?.id = m[COL_ID]
                media?.familySearchId = m[COL_FAMILY_SEARCH_ID]
                media?.type = m[COL_MEDIA_TYPE]
                media?.localPath = m[COL_LOCAL_PATH]
            }
        } catch {
            print("Error getting media by fsid \(fsid)")
        }
		return media
	}
	
	func getMediaForPerson(id:Int64) -> [Media] {
		var media = [Media]()
        do {
            let query = TABLE_MEDIA.join(TABLE_TAGS, on: TABLE_MEDIA[COL_ID] == TABLE_TAGS[COL_MEDIA_ID])
                .filter(TABLE_TAGS[COL_PERSON_ID] == id)
            let stmt = try lftdb?.prepare(query)
            for m in stmt! {
                let med = Media()
                med.id = m[TABLE_MEDIA[COL_ID]]
                med.familySearchId = m[COL_FAMILY_SEARCH_ID]
                med.type = m[COL_MEDIA_TYPE]
                med.localPath = m[COL_LOCAL_PATH]
                media.append(med)
            }
        } catch {
            print ("Error getting media for person \(id)")
        }
		return media
	}
	
	func deleteMediaById(id:Int64) {
		let mediaRow = TABLE_MEDIA.filter(COL_ID == id)
        do {
            try lftdb?.run(mediaRow.delete())
        } catch {
            print("Error deleting media \(id)")
        }
	}
	
	func getMediaCount() -> Int64 {
		let countm = lftdb?.scalar(TABLE_MEDIA.count)
		let countp = lftdb?.scalar(TABLE_LITTLE_PERSON.filter(COL_PHOTO_PATH != nil).count)
		return Int64(countm! + countp!)
	}
	
	func persistTag(tag:Tag) throws {
		if tag.id == 0 {
			let existing = getTagForPersonMedia(tag.personId, mediaId: tag.mediaId)
			if existing != nil {
				tag.id = existing!.id
			} else {
				let rowid = try lftdb?.run(TABLE_TAGS.insert(
					COL_PERSON_ID <- tag.personId,
					COL_MEDIA_ID <- tag.mediaId,
					COL_LEFT <- tag.left,
					COL_RIGHT <- tag.right,
					COL_TOP <- tag.top,
					COL_BOTTOM <- tag.bottom
				))
				tag.id = rowid!
				return
			}
		}
		
		let tagRow = TABLE_TAGS.filter(COL_ID == tag.id)
		try lftdb?.run(tagRow.update(
			COL_PERSON_ID <- tag.personId,
			COL_MEDIA_ID <- tag.mediaId,
			COL_LEFT <- tag.left,
			COL_RIGHT <- tag.right,
			COL_TOP <- tag.top,
			COL_BOTTOM <- tag.bottom
		))
		
	}
	
	func getTagForPersonMedia(personId:Int64, mediaId:Int64) -> Tag? {
		var tag:Tag? = nil
        do {
            let query = TABLE_TAGS.filter(COL_PERSON_ID == personId && COL_MEDIA_ID==mediaId)
            let stmt = try lftdb?.prepare(query)
            for t in stmt! {
                tag = Tag()
                tag!.id = t[COL_ID]
                tag!.mediaId = t[COL_MEDIA_ID]!
                tag!.personId = t[COL_PERSON_ID]!
                tag!.left = t[COL_LEFT]
                tag!.right = t[COL_RIGHT]
                tag!.top = t[COL_TOP]
                tag!.bottom = t[COL_BOTTOM]
            }
        } catch {
            print("Error getting tag for person \(personId)")
        }
		return tag
	}
	
	func persistLocalResource(media:LocalResource) {
		if media.id == nil || media.id == 0 {
			let existing = getLocalResource(media.personId, type: media.type! as String)
			if existing != nil {
				media.id = existing!.id
			} else {
                do {
					let rowid = try lftdb?.run(self.TABLE_MEDIA.insert(
						self.COL_PERSON_ID <- media.personId,
						self.COL_MEDIA_TYPE <- (media.type as String?),
						self.COL_LOCAL_PATH <- (media.localPath as String?)
					))
					media.id = rowid
                } catch {
                    print("Unable to insert media")
                }
				return
			}
		}
        
		let mediaRow = TABLE_MEDIA.filter(COL_ID == media.id)
		do {
		try lftdb?.run(mediaRow.update(
			COL_PERSON_ID <- media.personId,
			COL_MEDIA_TYPE <- (media.type as String?),
			COL_LOCAL_PATH <- (media.localPath as String?)
		))
		} catch {
			print("Unable to update localresource with id \(media.id)")
		}
        
	}
	
	func getLocalResource(personId:Int64, type:String) -> LocalResource? {
		var lr:LocalResource? = nil
        do {
            let query = TABLE_LOCAL_RESOURCES.filter(COL_PERSON_ID == personId && COL_MEDIA_TYPE==type)
            let stmt = try lftdb?.prepare(query)
            for t in stmt! {
                lr = LocalResource()
                lr!.id = t[COL_ID]
                lr!.personId = t[COL_PERSON_ID]!
                lr!.type = t[COL_MEDIA_TYPE]
                lr!.localPath = t[COL_LOCAL_PATH]
            }
        } catch {
            print("Error getting local resource for person \(personId) \(type)")
        }
		return lr
	}
	
	func getLocalResourcesForPerson(id:Int64) -> [LocalResource] {
		var media = [LocalResource]()
        do {
            let query = TABLE_LOCAL_RESOURCES.filter(COL_PERSON_ID == id)
            let stmt = try lftdb?.prepare(query)
            for m in stmt! {
                let med = LocalResource()
                med.id = m[COL_ID]
                med.type = m[COL_MEDIA_TYPE]
                med.localPath = m[COL_LOCAL_PATH]
                media.append(med)
            }
        } catch {
            print ("Error getting localresources for person \(id)")
        }
		return media
	}
	
	func deleteLocalResourceById(id:Int64) {
		let mediaRow = TABLE_LOCAL_RESOURCES.filter(COL_ID == id)
        do {
            try lftdb?.run(mediaRow.delete())
        } catch {
            print("Error deleting Local Resource \(id)")
        }
	}
	
	func saveProperty(property:String, value:String) {
        do {
		let existing = getProperty(property)
		if existing != nil {
			let query = TABLE_PROPERTIES.filter(COL_PROPERTY == property)
			try lftdb?.run(query.update(
                COL_VALUE <- value,
                COL_LAST_SYNC <- NSDate()
			))
		} else {
			try lftdb?.run(TABLE_PROPERTIES.insert(
				COL_PROPERTY <- property,
				COL_VALUE <- value,
                COL_LAST_SYNC <- NSDate()
			))
		}
        } catch {
            print("Unable to insert property \(property)")
        }
	}
	
	func getProperty(property:String) -> String? {
		let query = TABLE_PROPERTIES.filter(COL_PROPERTY == property)
		var value:String? = nil
        do {
            let stmt = try lftdb?.prepare(query)
            for t in stmt! {
                value = t[COL_VALUE]
            }
        }catch {
            print("Error getting value for property \(property)")
        }
		return value
	}
	
	func addToSyncQ(id:Int64) {
		let query = TABLE_SYNCQ.filter(COL_ID == id)
		let count = lftdb?.scalar(query.count)
		if count==0 {
            do {
                try lftdb?.run(TABLE_SYNCQ.insert(COL_ID <- id))
            } catch {
                print("Unable to add to syncq table \(id)")
            }
		}
	}
	
	func removeFromSyncQ(id:Int64) {
		let query = TABLE_SYNCQ.filter(COL_ID == id)
		let count = lftdb?.scalar(query.count)
		if count > 0 {
            do {
                try lftdb?.run(query.delete())
            } catch {
                print("Unable to remove from syncq table \(id)")
            }
		}
	}
	
	func getSyncQ() -> [Int64] {
		var list = [Int64]()
        do {
            let stmt = try lftdb?.prepare(TABLE_SYNCQ)
            for i in stmt! {
                list.append(i[COL_ID])
            }
        } catch {
            print("Error getting syncQ")
        }
		return list
	}
    
    func tableExists(tableName: String) -> Bool {
        let val = lftdb?.scalar(
            "SELECT EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = ?)",
            tableName
            ) as! Int64
        if val > 0 {
            return true
        }
        return false
    }
}