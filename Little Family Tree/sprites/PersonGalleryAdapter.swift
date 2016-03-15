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
    var people:[LittlePerson] {
        didSet {
            if gallery != nil {
                gallery!.adapterDidChange()
            }
        }
    }
    var gallery:Gallery? {
        get { return self.gallery }
        set {}
    }
    
    init(people:[LittlePerson]) {
        self.people = people
    }
    
    func size() -> Int {
        return people.count
    }
    
    func getNodeAtPosition(position:Int) -> SKSpriteNode {
        let person = people[position]
        let node = PersonNameSprite()
        node.size = CGSizeMake(gallery!.size.height, gallery!.size.height)
        node.person = person
        return node
    }
}