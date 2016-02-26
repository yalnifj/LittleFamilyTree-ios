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
    
    init() {
        addFamilyTreeSong()
        addMyHistorySong()
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
        /*
        List<Long> wordTimings = new ArrayList<>();
        wordTimings.add(1500L);//are
        wordTimings.add(1700L);//a
        wordTimings.add(2200L);//fam
        wordTimings.add(2500L);//i
        wordTimings.add(2900L);//ly
        wordTimings.add(3330L);//we
        wordTimings.add(4200L);//are
        wordTimings.add(4900L);//a
        wordTimings.add(5100L);//fam
        wordTimings.add(5400L);//i
        wordTimings.add(5600L);//ly
        wordTimings.add(7000L);//we
        wordTimings.add(7400L);//have
        wordTimings.add(7900L);//_
        wordTimings.add(9000L);//we
        wordTimings.add(9600L);//have
        wordTimings.add(10080L);//_
        wordTimings.add(11100L);//we
        wordTimings.add(11900L);//have
        wordTimings.add(12100L);//_
        wordTimings.add(13400L);//we
        wordTimings.add(13800L);//have
        wordTimings.add(14300L);//_
        wordTimings.add(15800L);//Theyre
        wordTimings.add(16100L);//all
        wordTimings.add(16600L);//in
        wordTimings.add(16900L);//our
        wordTimings.add(17200L);//fam
        wordTimings.add(18000L);//ly
        wordTimings.add(18500L);//tree
        wordTimings.add(19300L);//theyre
        wordTimings.add(19700L);//all
        wordTimings.add(20200L);//in
        wordTimings.add(20800L);//our
        wordTimings.add(21100L);//fam
        wordTimings.add(21500L);//ly
        wordTimings.add(22000L);//tree
        wordTimings.add(23500L);
        wordTimings.add(24500L);
        song.setWordTimings(wordTimings);
        
        List<Long> timings = new ArrayList<>(12);
        timings.add(6900L);
        timings.add(9000L);
        timings.add(11000L);
        timings.add(13200L);
        timings.add(15400L);
        timings.add(23000L);
        timings.add(24000L);
        
        song.setDanceTimings(timings);
        */
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
        
        song.attributor = SongNameAttributor()
        
        songs.append(song)
    }
}