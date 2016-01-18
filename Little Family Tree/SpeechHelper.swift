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
    private static var instance = SpeechHelper()
    
    static func getInstance() -> SpeechHelper {
        return instance
    }
    
    var speechSynthesizer:AVSpeechSynthesizer
    
    private init() {
        speechSynthesizer = AVSpeechSynthesizer()
    }
    
    func speak(message:String) {
        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        if quietMode == nil || quietMode == "false" {
            if speechSynthesizer.speaking {
                speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
            }
            let speechUtterance = AVSpeechUtterance(string: message)
            
            speechSynthesizer.speakUtterance(speechUtterance)
        }
    }
}