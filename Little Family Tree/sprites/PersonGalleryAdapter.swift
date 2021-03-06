//
//  PersonGalleryAdapter.swift
//  Little Family Tree
//
//  Created by Melissa on 3/14/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PersonGalleryAdapter: GalleryPageAdapter {
    var nodeTopic:String!
    var people:[LittlePerson] {
        didSet {
            if gallery != nil {
                gallery!.adapterDidChange()
            }
        }
    }
    var gallery:Gallery?
    
    init(people:[LittlePerson], topic: String) {
        self.people = people
        self.nodeTopic = topic
    }
    
    func setGallery(_ gallery: Gallery) {
        self.gallery = gallery
    }
    
    func size() -> Int {
        return people.count
    }
    
    func getNodeAtPosition(_ position:Int) -> SKSpriteNode {
        let person = people[position]
        let node = PersonNameSprite()
        node.fullName = true
        node.size = CGSize(width: gallery!.size.height * 0.75, height: gallery!.size.height * 0.75)
        node.person = person
        node.topic = nodeTopic
        return node
    }
}
