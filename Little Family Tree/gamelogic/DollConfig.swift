//
//  DollConfig.swift
//  Little Family Tree
//
//  Created by Melissa on 12/5/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class DollConfig {
    var folderName:String?
    var boygirl:String = "boy"
    var originalPlace:String? {
        didSet {
            if self.originalPlace != nil {
                self.originalPlace = self.originalPlace!.capitalizedString
            }
        }
    }
    var boyclothing:[DollClothing]?
    var girlclothing:[DollClothing]?
    
    func getThumbnail() -> String {
        return "dolls/\(folderName)/\(boygirl)_thumb.png";
    }
    
    func getDoll() -> String {
        return "dolls/\(boygirl).png";
    }
    
    func getClothing() -> [DollClothing]? {
        if (boyclothing == nil) {
            guard let path = NSBundle.mainBundle().pathForResource("dolls/\(folderName)/clothing.dat", ofType: nil) else {
                return nil
            }
            do {
                let content = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                let parts = content.split("\\s")
                let boycount =  Int(parts[0])
                boyclothing = [DollClothing]()
                var c = 1
                for _ in 0..<boycount! {
                    let clothingname = parts[c++]
                    let left = Int(parts[c++])
                    let top = Int(parts[c++])
                    let filename = "dolls/\(folderName)/\(clothingname).png"
                    let dc = DollClothing()
                    dc.filename = filename
                    dc.snapX = left!
                    dc.snapY = top!
                    boyclothing!.append(dc)
                }
                let girlcount =  Int(parts[c++])
                girlclothing = [DollClothing]()
                for _ in 0..<girlcount! {
                    let clothingname = parts[c++]
                    let left = Int(parts[c++])
                    let top = Int(parts[c++])
                    let filename = "dolls/\(folderName)/\(clothingname).png"
                    let dc = DollClothing()
                    dc.filename = filename
                    dc.snapX = left!
                    dc.snapY = top!
                    girlclothing!.append(dc)
                }
            } catch {
                return nil
            }
        }
        if ("boy" == boygirl) {
            return boyclothing;
        } else {
            return girlclothing;
        }
    }
}
