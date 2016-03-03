//
//  SongAlbum.swift
//  Little Family Tree
//
//  Created by Melissa on 2/25/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

class SongAlbum {
    var songs = [Song]()
    var currentSong = 0
	var selectedPerson:LittlePerson
    
    init(person:LittlePerson) {
		self.selectedPerson = person
		
        addFamilyTreeSong()
        addMyHistorySong()
		addThisIsMyHistorySong()
    }
    
    func nextSong() -> Song {
        let song = songs[currentSong]
        currentSong++
        if (currentSong >= songs.count) {
            currentSong = 0
        }
        return song
    }

    
    private func addFamilyTreeSong() {
        let song = Song()
        song.drumTrack = "drums_allinourfamilytree"
        song.fluteTrack = "flute_allinourfamilytree"
        song.pianoTrack = "piano_allinourfamilytree"
        song.violinTrack = "violin_allinourfamilytree"
        song.voiceTrack = "voice_allinourfamilytree"
        song.words = "We are a fam -i -ly. We are a fam -i -ly. We have _.  We have _. We have _. We have _. They're all in our fami -ly tree. They're all in our fami -ly tree."
        song.wordTimings.append(1500)//are
        song.wordTimings.append(1700)//a
        song.wordTimings.append(2200)//fam
        song.wordTimings.append(2500)//i
        song.wordTimings.append(2900)//ly
        song.wordTimings.append(3330)//we
        song.wordTimings.append(4200)//are
        song.wordTimings.append(4900)//a
        song.wordTimings.append(5100)//fam
        song.wordTimings.append(5400)//i
        song.wordTimings.append(5600)//ly
        song.wordTimings.append(7000)//we
        song.wordTimings.append(7400)//have
        song.wordTimings.append(7900)//_
        song.wordTimings.append(9000)//we
        song.wordTimings.append(9600)//have
        song.wordTimings.append(10080)//_
        song.wordTimings.append(11100)//we
        song.wordTimings.append(11900)//have
        song.wordTimings.append(12100)//_
        song.wordTimings.append(13400)//we
        song.wordTimings.append(13800)//have
        song.wordTimings.append(14300)//_
        song.wordTimings.append(15800)//Theyre
        song.wordTimings.append(16100)//all
        song.wordTimings.append(16600)//in
        song.wordTimings.append(16900)//our
        song.wordTimings.append(17200)//fam
        song.wordTimings.append(18000)//ly
        song.wordTimings.append(18500)//tree
        song.wordTimings.append(19300)//theyre
        song.wordTimings.append(19700)//all
        song.wordTimings.append(20200)//in
        song.wordTimings.append(20800)//our
        song.wordTimings.append(21100)//fam
        song.wordTimings.append(21500)//ly
        song.wordTimings.append(22000)//tree
        song.wordTimings.append(23500)
        song.wordTimings.append(24500)
        
        song.danceTimings.append(6900)
        song.danceTimings.append(9000)
        song.danceTimings.append(11000)
        song.danceTimings.append(13200)
        song.danceTimings.append(15400)
        song.danceTimings.append(23000)
        song.danceTimings.append(24000)
        
        song.attributor = SongNameAttributor()
        
        songs.append(song)

    }
    
    private func addMyHistorySong() {
        let song = Song()
        song.drumTrack = "drums_myhistory"
        song.fluteTrack = "flute_myhistory"
        song.pianoTrack = "piano_myhistory"
        song.violinTrack = "violin_myhistory"
        song.voiceTrack = "voice_myhistory"
        song.words = "Fami -ly his -tor -y, is my his -tor -y. My an -cest -or was born in _. This rel -a -tive lived in _. My an -cest -or was born in _. This rel -a -tive lived in _. That's my his -tor -y."
        
        song.wordTimings.append(500)//-ly
        song.wordTimings.append(1200)//his
        song.wordTimings.append(1800)//-tor
        song.wordTimings.append(2300)//-y
        song.wordTimings.append(2500)//is
        song.wordTimings.append(3100)//my
        song.wordTimings.append(3700)//his
        song.wordTimings.append(4500)//-tor
        song.wordTimings.append(4900)//-ry
        song.wordTimings.append(5200)//my
        song.wordTimings.append(5800)//an
        song.wordTimings.append(6400)//-cest
        song.wordTimings.append(6700)//-or
        song.wordTimings.append(6900)//was
        song.wordTimings.append(7300)//born
        song.wordTimings.append(7700)//in
        song.wordTimings.append(8300)//_
        song.wordTimings.append(10800)//this
        song.wordTimings.append(11200)//rel
        song.wordTimings.append(11700)//-a
        song.wordTimings.append(12300)//-tive
        song.wordTimings.append(12800)//lived
        song.wordTimings.append(13300)//in
        song.wordTimings.append(13500)//_
        song.wordTimings.append(14800)//My
        song.wordTimings.append(15100)//An
        song.wordTimings.append(15700)//-cest
        song.wordTimings.append(16000)//-or
        song.wordTimings.append(16300)//was
        song.wordTimings.append(16500)//born
        song.wordTimings.append(16900)//in
        song.wordTimings.append(17300)//_
        song.wordTimings.append(19500)//this
        song.wordTimings.append(20000)//rel
        song.wordTimings.append(20500)//-a
        song.wordTimings.append(20900)//-tive
        song.wordTimings.append(21400)//lived
        song.wordTimings.append(21900)//in
        song.wordTimings.append(22100)//_
        song.wordTimings.append(23700)//thats
        song.wordTimings.append(24200)//my
        song.wordTimings.append(24800)//his
        song.wordTimings.append(25400)//-tor
        song.wordTimings.append(26000)//-y
        song.wordTimings.append(27000)

        song.danceTimings.append(6000)
        song.danceTimings.append(10000)
        song.danceTimings.append(14600)
        song.danceTimings.append(19000)
        song.danceTimings.append(23000)
        song.danceTimings.append(27000)
        song.danceTimings.append(28000)

        song.attributor = SongDatePlaceAttributor()
        
        songs.append(song)
    }
	
	private func addThisIsMyHistorySong() {
        let song = Song()
        song.drumTrack = "drums_thisismyfamily"
        song.fluteTrack = "flute_thisismyfamily"
        song.pianoTrack = "piano_thisismyfamily"
        song.violinTrack = "guitar_thisismyfamily"
        song.voiceTrack = "voice_thisismyfamily"
        song.words = "This is my fam -i -ly. They mean so much to me. Here is my _. My _ is here too. Here is my _. My _ is here too. This is my fam -i -ly."

        song.wordTimings.append(700)//is
        song.wordTimings.append(1170)//my
        song.wordTimings.append(1750)//fam
        song.wordTimings.append(2360)//i
        song.wordTimings.append(2980)//ly
        song.wordTimings.append(4400)//they
        song.wordTimings.append(5000)//mean
        song.wordTimings.append(5450)//so
        song.wordTimings.append(6000)//much
        song.wordTimings.append(6600)//to
        song.wordTimings.append(7100)//me
        song.wordTimings.append(8700)//here
        song.wordTimings.append(9270)//is
        song.wordTimings.append(9770)//my
        song.wordTimings.append(10400)//_
        song.wordTimings.append(13100)//my
        song.wordTimings.append(13800)//_
        song.wordTimings.append(15700)//is
        song.wordTimings.append(16300)//here
        song.wordTimings.append(16800)//too.

        song.wordTimings.append(18400)//here
        song.wordTimings.append(18900)//is
        song.wordTimings.append(19400)//my
        song.wordTimings.append(20100)//_
        song.wordTimings.append(22800)//my
        song.wordTimings.append(23400)//_
        song.wordTimings.append(25300)//is
        song.wordTimings.append(25950)//here
        song.wordTimings.append(26500)//too.

        song.wordTimings.append(28170)//this
        song.wordTimings.append(28760)//is
        song.wordTimings.append(29280)//my
        song.wordTimings.append(29770)//fam
        song.wordTimings.append(30500)//i
        song.wordTimings.append(31070)//ly
        song.wordTimings.append(32300)//

        song.danceTimings.append(8700)
        song.danceTimings.append(13300)
        song.danceTimings.append(18300)
        song.danceTimings.append(22800)
        song.danceTimings.append(28000)
        song.danceTimings.append(32500)
        song.danceTimings.append(34000)

        song.attributor = SongRelationshipAttributor(me: selectedPerson)

        songs.append(song)
    }
}