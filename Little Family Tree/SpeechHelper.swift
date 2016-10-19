//
//  SpeechHelper.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import AVFoundation

class SpeechHelper {
    fileprivate static var instance = SpeechHelper()
    
    static func getInstance() -> SpeechHelper {
        return instance
    }
    
    var speechSynthesizer:AVSpeechSynthesizer
    
    fileprivate init() {
        speechSynthesizer = AVSpeechSynthesizer()
    }
    
    func speak(_ message:String) {
        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        if quietMode == nil || quietMode == "false" {
            if speechSynthesizer.isSpeaking {
                speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.word)
            }
            let speechUtterance = AVSpeechUtterance(string: message)
            
            speechSynthesizer.speak(speechUtterance)
        }
    }
    
    func stop() {
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
}
