//
//  ViewController.swift
//  RadioTest
//
//  Created by Hwang Lee on 10/3/16.
//  Copyright © 2016 Hwang Lee. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit

class ViewController: UIViewController {
    
    var flag = false
    
    //Mark: Constraints
    @IBOutlet weak var FMIconHeight: NSLayoutConstraint!
    @IBOutlet weak var FMIconWidth: NSLayoutConstraint!
    @IBOutlet weak var FMIconLeading: NSLayoutConstraint!
    
    
    //MARK: UIButtons
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fmIcon: UIButton!
    @IBOutlet weak var digitalButton: UIButton!
    
    //MARK: UIImages
    var fmImage : UIImage = UIImage(named: "AlbumArtFM")!
    var digitalImage : UIImage = UIImage(named: "AlbumArtDigital")!
    
    //MARK: Size Properties
    let screenSize: CGRect = UIScreen.main.bounds
    let smallSizeIcon : CGFloat = 80
    let bigSizeIcon : CGFloat = 150
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //MARK: UI Setup
        self.view.backgroundColor = UIColor.black
        
        
        
        //playRadio()
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        //MARK: Observers
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleInterruption(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(AVPlayerStatusListener), name: NSNotification.Name.AV, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListener), name: NSNotification.Name.AVAudioSessionRouteChange,
                                               object: nil)
        
        // Control Center Functionality
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(ViewController.playRadio))
        commandCenter.pauseCommand.addTarget(self, action: #selector(ViewController.pauseRadio))
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(ViewController.nextChannel))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(ViewController.nextChannel))
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : RadioPlayer.sharedInstance.getChannel(), MPMediaItemPropertyArtist : "WMUC", MPMediaItemPropertyArtwork : MPMediaItemArtwork(image: fmImage)]
        
        // Swipe Gesture Recognition
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewDidLayoutSubviews() {
        print("did layout subviews")
        print(RadioPlayer.sharedInstance.getChannel())
        //self.FMIconHeight.constant = 160
        
        //self.FMIconWidth.constant = 160
        
        //self.FMIconLeading.constant = 100
                    self.view.layoutIfNeeded()
        if flag {

                    if(RadioPlayer.sharedInstance.getChannel()=="FM"){
        
                        self.fmIcon.frame = CGRect(x: (self.view.frame.midX - (self.bigSizeIcon/(2*1.19))), y: self.screenSize.midY - 150, width: (self.bigSizeIcon/1.19), height: self.bigSizeIcon)
                        self.digitalButton.frame = CGRect(x: (self.screenSize.maxX - 38 - self.smallSizeIcon), y: self.screenSize.midY - (self.smallSizeIcon), width: self.smallSizeIcon, height: self.smallSizeIcon)
        
                    }else{
        
                        self.fmIcon.frame = CGRect(x: (self.screenSize.minX + 38), y: self.screenSize.midY - (self.smallSizeIcon), width: (self.smallSizeIcon/1.19), height: self.smallSizeIcon)
                        self.digitalButton.frame = CGRect(x: (self.view.frame.midX - (self.bigSizeIcon/2)), y: self.screenSize.midY - 150, width: self.bigSizeIcon, height: self.bigSizeIcon)
                    }
                
                
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Play Pause Button Functionality
    @IBAction func buttonPressed(_ sender: UIButton) {
        if flag {
            if RadioPlayer.sharedInstance.currentlyPlaying() {
                pauseRadio()
            }
            else {
                playRadio()
            }
        }
        
        updateMediaProperty(channel: RadioPlayer.sharedInstance.getChannel())
        
    }
    
    func playRadio() {
        
        if !RadioPlayer.sharedInstance.currentlyPlaying() {
            RadioPlayer.sharedInstance.refresh()
        }
        
        RadioPlayer.sharedInstance.play()
        playButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        
    }
    
    func pauseRadio() {
        RadioPlayer.sharedInstance.pause()
        RadioPlayer.sharedInstance.refresh()
        playButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        
    }
    
    //MARK: FM Functionality
    
    @IBAction func fmIconPressed(_ sender: UIButton?) {
        flag = true
        
        toggleAnimation(channel: "FM")
        RadioPlayer.sharedInstance.changePlaying(channel: "FM")
    
    
        updateMediaProperty(channel: RadioPlayer.sharedInstance.getChannel())
    }
    
    //MARK: Digital Functionality
    
    @IBAction func digitalIconPressed(_ sender: UIButton?) {
        flag = true
        
        toggleAnimation(channel: "Digital")
        RadioPlayer.sharedInstance.changePlaying(channel: "Digital")
        
        updateMediaProperty(channel: RadioPlayer.sharedInstance.getChannel())
    }
    
    
    //MARK TOGGLE ANIMATIONS
    
    func toggleAnimation(channel : String){
        if channel == "Digital" {
            if RadioPlayer.sharedInstance.getChannel() != "Digital" {
                //perform animation
                UIView.animate(withDuration: 0.2) {
                    
                    self.fmIcon.frame = CGRect(x: (self.screenSize.minX + 38), y: self.screenSize.midY - (self.smallSizeIcon), width: (self.smallSizeIcon/1.19), height: self.smallSizeIcon)
                    self.digitalButton.frame = CGRect(x: (self.view.frame.midX - (self.bigSizeIcon/2)), y: self.screenSize.midY - 150, width: self.bigSizeIcon, height: self.bigSizeIcon)
                    
                }
            }
        } else if channel == "FM" {
            if RadioPlayer.sharedInstance.getChannel() != "FM" {
                //perform animation
                UIView.animate(withDuration: 0.2) {
                    self.fmIcon.frame = CGRect(x: (self.view.frame.midX - (self.bigSizeIcon/(2*1.19))), y: self.screenSize.midY - 150, width: (self.bigSizeIcon/1.19), height: self.bigSizeIcon)
                    self.digitalButton.frame = CGRect(x: (self.screenSize.maxX - 38 - self.smallSizeIcon), y: self.screenSize.midY - (self.smallSizeIcon), width: self.smallSizeIcon, height: self.smallSizeIcon)
                    
                    
                }
            }
        }
    }
    
    func nextChannel() {
        if RadioPlayer.sharedInstance.getChannel() == "FM" {
            digitalIconPressed(nil)
            
        }
        else {
            fmIconPressed(nil)
        }
        
    }
    
    func updateMediaProperty(channel : String) {
        let artwork = (channel == "FM") ? MPMediaItemArtwork(image: fmImage) : MPMediaItemArtwork(image: digitalImage)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : channel, MPMediaItemPropertyArtist : "WMUC", MPMediaItemPropertyArtwork :artwork]
    }
    
    
    func handleInterruption(notification: NSNotification) {
        
        if notification.name != NSNotification.Name.AVAudioSessionInterruption || notification.userInfo == nil{
            return
        }
        
        var info = notification.userInfo!
        var intValue: UInt = 0
        (info[AVAudioSessionInterruptionTypeKey] as! NSValue).getValue(&intValue)
        if let interruptionType = AVAudioSessionInterruptionType(rawValue: intValue) {
            
            switch interruptionType {
                
            case .began:
                print("began")
                pauseRadio()
                print("audio paused")
                
            case .ended:
            
                print("ended")
                playRadio()
                print("audio resumed")
            }
            
        }
        
    }
    
    @IBAction func onSwipe(_ gesture: UISwipeGestureRecognizer) {
        let swipeGesture = gesture
        
        switch swipeGesture.direction {
        case UISwipeGestureRecognizerDirection.right:
            fmIconPressed(nil)
        case UISwipeGestureRecognizerDirection.left:
            digitalIconPressed(nil)
        default:
            break
        }
        
    }
    
    dynamic private func audioRouteChangeListener(notification:NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            print("headphone plugged in")
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            pauseRadio()
        default:
            break
        }
    }
    
//    dynamic private func AVPlayerStatusListener(notification:NSNotification) {
//        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
//        
//        
//        
//    }
}

