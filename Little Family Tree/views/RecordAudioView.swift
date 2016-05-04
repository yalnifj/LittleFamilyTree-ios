//
//  RecordAudioView.swift
//  Little Family Tree
//
//  Created by Melissa on 4/27/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudioView: UIView, AVAudioPlayerDelegate, AVAudioRecorderDelegate {


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
	
	var soundFileURL: NSURL?
	var localResource:LocalResource?
    
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
		
		localResource = DBHelper.getInstance().getLocalResource(person.id!, type: "givenName")
		if localResource == nil {
			localResource = LocalResource()
			localResource!.personId = person.id!
            localResource!.type = "givenName"
            localResource!.localPath = "\(person.familySearchId!)/givenName.caf"
		}
		
        updateButtonStates()
		prepareRecorder()
    }
    
    func updateButtonStates() {
        if person?.givenNameAudioPath != nil {
            deleteButton.hidden = false
        } else {
            deleteButton.hidden = true
        }
        
        if playing {
            playButton.setImage(UIImage(named: "media_pause"), forState: .Normal)
        } else {
            playButton.setImage(UIImage(named: "media_play"), forState: .Normal)
        }
        
        if recording {
            recordButton.setImage(UIImage(named: "media_pause"), forState: .Normal)
			if person?.givenNameAudioPath != nil {
				playButton.enabled = false
			}
        } else {
            recordButton.setImage(UIImage(named: "mic_icon"), forState: .Normal)
			if person?.givenNameAudioPath != nil {
				playButton.enabled = true
			}
        }
    }

    @IBAction func PlayButtonClicked(sender: AnyObject) {
        if !recording {
            if playing {
				audioPlayer?.stop()
                playing = false
            } else {
                playing = true
				
                do {
                    try audioPlayer = AVAudioPlayer(contentsOfURL: soundFileURL!)

                    audioPlayer?.delegate = self
                    audioPlayer?.play()
                } catch {
					print("audioPlayer error:")
				}
            }
            updateButtonStates()
        }
    }

    @IBAction func RecordButtonClicked(sender: AnyObject) {
        if !playing {
            if recording {
				audioRecorder?.stop()
				DBHelper.getInstance().persistLocalResource(localResource!)
                recording = false
            } else {
				if audioRecorder == nil {
					prepareRecorder()
				}
				person?.givenNameAudioPath = localResource!.localPath
				audioRecorder?.record()
				recording = true
            }
            updateButtonStates()
        }
    }
	
	func prepareRecorder() {
		let fileManager = NSFileManager.defaultManager()
		let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
		let folderUrl = url.URLByAppendingPathComponent(person!.familySearchId! as String)
		soundFileURL = folderUrl.URLByAppendingPathComponent("givenName.caf")
        let recordSettings:[String : AnyObject] =
			[AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
					AVEncoderBitRateKey: 16,
					AVNumberOfChannelsKey: 2,
					AVSampleRateKey: 44100.0]

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)

            try audioRecorder = AVAudioRecorder(URL: soundFileURL!,
					settings: recordSettings )
            audioRecorder?.prepareToRecord()
        }
		catch {
			print("audioSession error:")
		}
	}
    
    @IBAction func DeleteButtonClicked(sender: AnyObject) {
		do {
            let fileManager = NSFileManager.defaultManager()
            if soundFileURL != nil {
                try fileManager.removeItemAtURL(soundFileURL!)
            }
			DBHelper.getInstance().deleteLocalResourceById(localResource!.id!)
		} catch {
			print("Error deleting local resource \(localResource!.id)")
		}
		localResource!.id = nil
		person?.givenNameAudioPath = nil
		updateButtonStates()
    }
    
    @IBAction func BackButtonClicked(sender: AnyObject) {
        self.view.removeFromSuperview()
        openingScene!.showPersonDetails(person!, listener: listener!)
    }
    
	func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
		playing = false
		recording = false
		updateButtonStates()
	}

	func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer) {
		print("Audio Play Decode Error")
		playing = false
		recording = false
		updateButtonStates()
	}

	func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
		playing = false
		recording = false
		updateButtonStates()
	}

	func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder) {
		print("Audio Record Encode Error")
		playing = false
		recording = false
		updateButtonStates()
	}
	
	
}
