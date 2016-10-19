//
//  CupcakeSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 11/14/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CupcakeSprite: SKSpriteNode {
    var person:LittlePerson? {
        didSet {
            if photoSprite != nil {
                photoSprite?.removeFromParent()
            }
            let photo = TextureHelper.getPortraitTexture(self.person!)
            photoSprite = SKSpriteNode(texture: photo)
            photoSprite?.position = CGPoint(x: 0, y: 0)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.width = self.size.width / 2.0
            photoSprite?.size.height = (self.size.width / 2.0) / ratio
            photoSprite?.zPosition = 2
            self.addChild(photoSprite!)
            
            let num = 1 + arc4random_uniform(UInt32(3))
            flame = SKSpriteNode(imageNamed: "flame\(num).png")
            flame?.position = CGPoint(x: 0, y: self.size.height/1.8)
            let fr = flame!.size.width / flame!.size.height
            flame?.size = CGSize(width: self.size.width / 6, height: (self.size.width / 6) / fr)
            flame?.zPosition = 1
            var textures = [SKTexture(imageNamed: "flame2.png"), SKTexture(imageNamed: "flame3.png"), SKTexture(imageNamed: "flame2.png"), SKTexture(imageNamed: "flame1.png")]
            for _ in 0..<num {
                textures.append(textures.removeFirst())
            }
            let action = SKAction.animate(with: textures, timePerFrame: 0.15)
            flame?.run(SKAction.repeatForever(action))
            self.addChild(flame!)
            
            addLabels()
        }
    }
    var flame:SKSpriteNode? = nil
    var photoSprite:SKSpriteNode? = nil
    var nameLabel:SKLabelNode? = nil
	var birthDateLabel:SKLabelNode? = nil
	var ageLabel:SKLabelNode? = nil
    var topic:String?
    
    func addLabels() {
        if nameLabel != nil {
            nameLabel?.removeFromParent()
        }
        var name = person!.name as! String
        let parts = name.split(" ")
        if parts.count > 3 {
            name = "\(parts[0])"
            for n in parts.count - 2 ..< parts.count {
                name = name + " \(parts[n])"
            }
        }
        nameLabel = SKLabelNode(text: name)
        nameLabel?.fontSize = self.size.width / 10
        nameLabel?.fontColor = UIColor.black
        nameLabel?.position = CGPoint(x: 0, y: nameLabel!.fontSize * -4)
        if nameLabel?.frame.width > self.size.width * 1.1 {
            nameLabel?.fontSize = nameLabel!.fontSize * 0.75
        }
        nameLabel?.zPosition = 3
        self.addChild(nameLabel!)
		
		if birthDateLabel != nil {
            birthDateLabel?.removeFromParent()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = formatter.string(from: person!.birthDate! as Date)

        birthDateLabel = SKLabelNode(text: dateString)
        birthDateLabel?.fontSize = nameLabel!.fontSize
        birthDateLabel?.fontColor = UIColor.black
        birthDateLabel?.position = CGPoint(x: 0, y: nameLabel!.position.y - birthDateLabel!.fontSize)
        birthDateLabel?.zPosition = 3
        self.addChild(birthDateLabel!)
		
		if ageLabel != nil {
            ageLabel?.removeFromParent()
        }
        
        let ageComponents = (Calendar.current as NSCalendar).components([.month, .day],
                                                                     from: person!.birthDate! as Date)
        let month = ageComponents.month
        let day = ageComponents.day
        
        let ageComponentsNow = (Calendar.current as NSCalendar).components([.month, .day],
                                                                    from: Foundation.Date())
        var age = person!.age!
        let monthN = ageComponentsNow.month
        let dayN = ageComponentsNow.day
        if month > monthN || (month==monthN && day > dayN) {
            age += 1
        }
        
        ageLabel = SKLabelNode(text: "Age \(age)")
        ageLabel?.fontSize = nameLabel!.fontSize
        ageLabel?.fontColor = UIColor.black
        ageLabel?.position = CGPoint(x: 0, y: birthDateLabel!.position.y - ageLabel!.fontSize)
        ageLabel?.zPosition = 3
        self.addChild(ageLabel!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if topic != nil {
            EventHandler.getInstance().publish(topic!, data: person)
        }
    }

}
