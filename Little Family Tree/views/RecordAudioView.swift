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
            } else {
                playButton.enabled = false
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
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                    try audioSession.setActive(true)
                    getSoundFile()
                    print(soundFileURL!.description)
                    try audioPlayer = AVAudioPlayer(contentsOfURL: soundFileURL!)

                    audioPlayer?.delegate = self
                    audioPlayer?.volume = 1.5
                    print("duration=\(audioPlayer?.duration)")
                    if audioPlayer?.duration > 0 {
                        audioPlayer?.prepareToPlay()
                        audioPlayer?.play()
                    } else {
                        playing = false
                    }
                } catch {
					print("audioPlayer error: \(error)")
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
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(AVAudioSessionCategoryRecord)
                    try audioSession.setActive(true)
                    prepareRecorder()
                    person?.givenNameAudioPath = localResource!.localPath
                    audioRecorder?.delegate = self
                    audioRecorder?.recordForDuration(2.0)
                    recording = true
                } catch {
                    print("Error setting audio session category \(error)")
                }
            }
            updateButtonStates()
        }
    }
    
    func getSoundFile() {
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let folderUrl = url.URLByAppendingPathComponent(person!.familySearchId! as String)
        soundFileURL = folderUrl!.URLByAppendingPathComponent("givenName.caf")
        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(soundFileURL!.path!)
            let fileSize = fileAttributes[NSFileSize]
            print("fileSize=\(fileSize)")
        } catch {
            print("Error setting audio session category \(error)")
        }
    }
	
	func prepareRecorder() {
        let recordSettings:[String : AnyObject] =
			[AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
                    AVFormatIDKey:Int(kAudioFormatAppleIMA4),
					AVEncoderBitRateKey: 16,
					AVNumberOfChannelsKey: 1,
					AVSampleRateKey: 44100.0]

        do {
            getSoundFile()
            try audioRecorder = AVAudioRecorder(URL: soundFileURL!,
					settings: recordSettings )
            audioRecorder?.prepareToRecord()
        }
		catch {
			print("audioSession error:  \(error)")
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
			print("Error deleting local resource \(localResource!.id)  \(error)")
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
        print("Audio Play finished")
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
        print("Audio Record finished")
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
