//
//  RadioPlayer.swift
//  RadioTest
//
//  Created by Hwang Lee on 10/3/16.
//  Copyright © 2016 Hwang Lee. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class RadioPlayer {
    
    // Single instance of this class
    static let sharedInstance = RadioPlayer()
    
    // Set up streams
    var digital = AVPlayer(url: NSURL(string: "http://wmuc.umd.edu/wmuc2-high.m3u")! as URL)
    var fm = AVPlayer(url: NSURL(string: "http://wmuc.umd.edu/wmuc-high.m3u")! as URL)
    
    private var currentChannel = "none"
    private var isPlaying = false
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
    }
    
    func play() {
        if currentChannel == "FM" {
            digital.pause()
            fm.play()
        } else {
            fm.pause()
            digital.play()
        }
        
        isPlaying = true
    }
    
    func pause() {
        digital.pause()
        fm.pause()
        isPlaying = false
    }
    
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
    
    func getChannel() -> String {
        return currentChannel
    }
    
    func changePlaying(channel : String) {
        currentChannel = channel == "FM" ? "FM" : "Digital"
        
        if isPlaying {
            play()
        }
    }
    
    func refresh() {
        pause()
        digital = AVPlayer(url: NSURL(string: "http://wmuc.umd.edu/wmuc2-high.m3u")! as URL)
        fm = AVPlayer(url: NSURL(string: "http://wmuc.umd.edu/wmuc-high.m3u")! as URL)
        if isPlaying {
            play()
        }
    }
    
    
    @objc func reachabilityChanged(note: NSNotification) {
        print(" CHANGE")
        
        let thisreachability = note.object as! Reachability
        
        if thisreachability.isReachable {
            self.refresh()
            print("reachable,reachability changed")
            if thisreachability.isReachableViaWiFi {
            } else {
            }
        } else {
            print("not reachable!")
            self.refresh()
            
        }
    }
    
}
