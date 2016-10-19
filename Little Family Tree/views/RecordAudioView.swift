//
//  RecordAudioView.swift
//  Little Family Tree
//
//  Created by Melissa on 4/27/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit
import AVFoundation
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
	
	var soundFileURL: URL?
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
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "RecordAudioView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func showPerson(_ person:LittlePerson) {
        self.person = person
        navBar.topItem?.title = "Record Given Name Audio"
        nameLabel.text = person.name as String?
		
		localResource = DBHelper.getInstance().getLocalResource(person.id!, type: "givenName")
		if localResource == nil {
			localResource = LocalResource()
			localResource!.personId = person.id!
            localResource!.type = "givenName"
            localResource!.localPath = "\(person.familySearchId!)/givenName.caf" as NSString?
		}
		
        updateButtonStates()
    }
    
    func updateButtonStates() {
        if person?.givenNameAudioPath != nil {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
        
        if playing {
            playButton.setImage(UIImage(named: "media_pause"), for: UIControlState())
        } else {
            playButton.setImage(UIImage(named: "media_play"), for: UIControlState())
        }
        
        if recording {
            recordButton.setImage(UIImage(named: "media_pause"), for: UIControlState())
			if person?.givenNameAudioPath != nil {
				playButton.isEnabled = false
			}
        } else {
            recordButton.setImage(UIImage(named: "mic_icon"), for: UIControlState())
			if person?.givenNameAudioPath != nil {
				playButton.isEnabled = true
            } else {
                playButton.isEnabled = false
            }
        }
    }

    @IBAction func PlayButtonClicked(_ sender: AnyObject) {
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
                    try audioPlayer = AVAudioPlayer(contentsOf: soundFileURL!)

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

    @IBAction func RecordButtonClicked(_ sender: AnyObject) {
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
                    audioRecorder?.record(forDuration: 2.0)
                    recording = true
                } catch {
                    print("Error setting audio session category \(error)")
                }
            }
            updateButtonStates()
        }
    }
    
    func getSoundFile() {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderUrl = url.appendingPathComponent(person!.familySearchId! as String)
        soundFileURL = folderUrl.appendingPathComponent("givenName.caf")
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: soundFileURL!.path)
            let fileSize = fileAttributes[FileAttributeKey.size]
            print("fileSize=\(fileSize)")
        } catch {
            print("Error setting audio session category \(error)")
        }
    }
	
	func prepareRecorder() {
        let recordSettings:[String : AnyObject] =
			[AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue as AnyObject,
                    AVFormatIDKey:Int(kAudioFormatAppleIMA4) as AnyObject,
					AVEncoderBitRateKey: 16 as AnyObject,
					AVNumberOfChannelsKey: 1 as AnyObject,
					AVSampleRateKey: 44100.0 as AnyObject]

        do {
            getSoundFile()
            try audioRecorder = AVAudioRecorder(url: soundFileURL!,
					settings: recordSettings )
            audioRecorder?.prepareToRecord()
        }
		catch {
			print("audioSession error:  \(error)")
		}
	}
    
    @IBAction func DeleteButtonClicked(_ sender: AnyObject) {
		do {
            let fileManager = FileManager.default
            if soundFileURL != nil {
                try fileManager.removeItem(at: soundFileURL!)
            }
			DBHelper.getInstance().deleteLocalResourceById(localResource!.id!)
		} catch {
			print("Error deleting local resource \(localResource!.id)  \(error)")
		}
		localResource!.id = nil
		person?.givenNameAudioPath = nil
		updateButtonStates()
    }
    
    @IBAction func BackButtonClicked(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        openingScene!.showPersonDetails(person!, listener: listener!)
    }
    
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio Play finished")
		playing = false
		recording = false
		updateButtonStates()
	}

	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer) {
		print("Audio Play Decode Error")
		playing = false
		recording = false
		updateButtonStates()
	}

	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio Record finished")
		playing = false
		recording = false
		updateButtonStates()
	}

	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder) {
		print("Audio Record Encode Error")
		playing = false
		recording = false
		updateButtonStates()
	}
	
	
}
