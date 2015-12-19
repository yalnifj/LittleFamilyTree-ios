//
//  GameViewController.swift
//  Little Family Tree
//
//  Created by Melissa on 9/12/15.
//  Copyright (c) 2015 Melissa. All rights reserved.
//

import UIKit
import SpriteKit

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    mutating func removeObject(object:Self.Generator.Element) {
        if let found = self.indexOf(object) {
            self.removeAtIndex(found)
        }
    }
}

extension String {
    func split(splitter: String) -> Array<String> {
        let regEx = try? NSRegularExpression(pattern: splitter, options: [])
        let stop = "-=-=-"
        let modifiedString = regEx!.stringByReplacingMatchesInString(self, options: NSMatchingOptions(),
            range: NSMakeRange(0, self.characters.count),
            withTemplate:stop)
        return modifiedString.componentsSeparatedByString(stop)
    }
    
    func replaceAll(regex:String, replace:String) -> String {
        let regEx = try? NSRegularExpression(pattern: regex, options: [])
        let modifiedString = regEx!.stringByReplacingMatchesInString(self, options: NSMatchingOptions(),
            range: NSMakeRange(0, self.characters.count),
            withTemplate:replace)
        return modifiedString
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            do {
                let sceneData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                //var sceneData = NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)!
                let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
                archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! SplashScene
                archiver.finishDecoding()
                return scene
            } catch _ as NSError {
            }
        }
        return nil
        
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
        if let scene = SplashScene.unarchiveFromFile("SplashScene") as? SplashScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.Portrait.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
