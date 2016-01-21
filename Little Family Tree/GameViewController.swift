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

extension UIColor {
    public convenience init(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.startIndex.advancedBy(1)
            let hexColor = hexString.substringFromIndex(start)
            
            if hexColor.characters.count == 8 {
                let scanner = NSScanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexLongLong(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        self.init()
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
        if let scene = SplashScene.unarchiveFromFile("SplashScene") as? SplashScene {
            // Configure the view.
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
