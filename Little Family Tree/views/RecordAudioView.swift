//
//  RecordAudioView.swift
//  Little Family Tree
//
//  Created by Melissa on 4/27/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudioView: UIView {


    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var playing = false
    var recording = false
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    var person:LittlePerson?
    
    var view:UIView!
    
    var openingScene:LittleFamilyScene?
    
    var listener:PersonDetailsCloseListener?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "RecordAudioView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func showPerson(person:LittlePerson) {
        self.person = person
        navBar.topItem?.title = "Record Given Name Audio"
        nameLabel.text = person.name as String?
        updateButtonStates()
    }
    
    func updateButtonStates() {
        if person?.givenNameAudioPath != nil {
            playButton.enabled = true
            deleteButton.hidden = false
        } else {
            playButton.enabled = false
            deleteButton.hidden = true
        }
        
        if playing {
            playButton.setImage(UIImage(named: "media_pause"), forState: .Normal)
        } else {
            playButton.setImage(UIImage(named: "media_play"), forState: .Normal)
        }
        
        if recording {
            recordButton.setImage(UIImage(named: "media_pause"), forState: .Normal)
        } else {
            recordButton.setImage(UIImage(named: "mic_icon"), forState: .Normal)
        }
    }

    @IBAction func PlayButtonClicked(sender: AnyObject) {
        if !recording {
            if playing {
                playing = false
            } else {
                playing = true
            }
            updateButtonStates()
        }
    }

    @IBAction func RecordButtonClicked(sender: AnyObject) {
        if !playing {
            if recording {
                recording = false
            } else {
                recording = true
            }
            updateButtonStates()
        }
    }
    
    @IBAction func DeleteButtonClicked(sender: AnyObject) {
        
    }
    
    @IBAction func BackButtonClicked(sender: AnyObject) {
        self.view.removeFromSuperview()
        openingScene!.showPersonDetails(person!, listener: listener!)
    }
    

}
