//
//  Song.swift
//  Little Family Tree
//
//  Created by Melissa on 2/25/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

class Song {
    var pianoTrack:String?
    var drumTrack:String?
    var fluteTrack:String?
    var violinTrack:String?
    var voiceTrack:String?
    var words:String?
    
    var danceTimings = [Int64]()
    var wordTimings = [Int64]()
    var attributor:SongPersonAttribute?
    var instruments = [String]()
}