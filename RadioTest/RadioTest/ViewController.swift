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

var FirstLaunch = true;

class ViewController: UIViewController {
    
    @objc var flag = false
    @objc var today = 0;
    @objc var hour = 0;
    
    
    
    //Mark: Constraints
    @IBOutlet weak var FMIconHeight: NSLayoutConstraint!
    @IBOutlet weak var FMIconWidth: NSLayoutConstraint!
    @IBOutlet weak var FMIconLeading: NSLayoutConstraint!
    
    
    //MARK: UIButtons
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fmIcon: UIButton!
    @IBOutlet weak var digitalButton: UIButton!
    
    
    
    //MARK: UIImages
    @objc var fmImage : UIImage = UIImage(named: "AlbumArtFM")!
    @objc var digitalImage : UIImage = UIImage(named: "AlbumArtDigital")!
    
    
    //Mark: Labels
    @IBOutlet weak var ShowName: UILabel!
    @IBOutlet weak var DJNames: UILabel!
    
    
    //MARK: Size Properties
    @objc let screenSize: CGRect = UIScreen.main.bounds
    @objc let smallSizeIcon : CGFloat = 80
    @objc let bigSizeIcon : CGFloat = 150
    
    @objc var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // setup Reachability
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        
        
        //MARK: UI Setup
        self.view.backgroundColor = UIColor.white
        self.ShowName.text = ""
        self.DJNames.text = ""
    
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
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : CurrentShow(channel: RadioPlayer.sharedInstance.getChannel())[0], MPMediaItemPropertyArtist : CurrentShow(channel: RadioPlayer.sharedInstance.getChannel())[1], MPMediaItemPropertyArtwork : MPMediaItemArtwork(image: fmImage)]
        
        // Swipe Gesture Recognition
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FirstLaunch){
          if(reachability.isReachable == false){
            
          let alert = UIAlertController(title: "No Internet Connection", message: "You are not connected to the internet, so the app might not work as expected. Check your connectivity settings and come back 😊", preferredStyle: .alert)
        
          alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
              print("OK")
          })
        
          self.present(alert, animated: true)
          }
        }
        
        FirstLaunch = false
    }
        
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
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
    
    @objc func playRadio() {
        
        if !RadioPlayer.sharedInstance.currentlyPlaying() {
            RadioPlayer.sharedInstance.refresh()
        }
        
        RadioPlayer.sharedInstance.play()
        playButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        
    }
    
    @objc func pauseRadio() {
        RadioPlayer.sharedInstance.pause()
        RadioPlayer.sharedInstance.refresh()
        playButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        
    }
    
    //MARK: FM Functionality
    
    @IBAction func fmIconPressed(_ sender: UIButton?) {
        flag = true
        viewerSetting = "FM"
        
        toggleAnimation(channel: "FM")
        RadioPlayer.sharedInstance.changePlaying(channel: "FM")
        
        hour = Int(Calendar.current.component(.hour, from: Date()))
        
        today = Int(Calendar.current.component(.weekday, from: Date())) - 1
        
        if (schedge.digSched[0][0].name != "Unable to load Schedule"){
        let indexfiltered = schedge.fmSched[today].filter{ $0.time <= hour && ($0.time + ($0.len/2) - 1) >= hour }
        
        if indexfiltered.isEmpty{
            self.ShowName.text = ""
            self.DJNames.text = ""
            
        }else {
            self.ShowName.text=indexfiltered[0].name
            self.DJNames.text=indexfiltered[0].dj
        }
        }
        
        updateMediaProperty(channel: RadioPlayer.sharedInstance.getChannel())
    }
    
    //MARK: Digital Functionality
    
    @IBAction func digitalIconPressed(_ sender: UIButton?) {
        flag = true
        viewerSetting = "Dig"
        
        toggleAnimation(channel: "Digital")
        RadioPlayer.sharedInstance.changePlaying(channel: "Digital")
        
        updateMediaProperty(channel: RadioPlayer.sharedInstance.getChannel())
        
        hour = Int(Calendar.current.component(.hour, from: Date()))
        today = Int(Calendar.current.component(.weekday, from: Date())) - 1
        if (schedge.digSched.count >= 7){
        let index = schedge.digSched[today].filter{ $0.time <= hour && ($0.time + ($0.len/2) - 1 ) >= hour }
        
        if index.isEmpty{
            self.ShowName.text = " "
            self.DJNames.text = " "
        }else {
            self.ShowName.text=index[0].name
            self.DJNames.text=index[0].dj
        }
        }
    }
    
    
    //MARK TOGGLE ANIMATIONS
    
    @objc func toggleAnimation(channel : String){
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
    
    @objc func nextChannel() {
        if RadioPlayer.sharedInstance.getChannel() == "FM" {
            digitalIconPressed(nil)
            
        }
        else {
            fmIconPressed(nil)
        }
        
    }
    
    @objc func updateMediaProperty(channel : String) {
        let artwork = (channel == "FM") ? MPMediaItemArtwork(image: fmImage) : MPMediaItemArtwork(image: digitalImage)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : CurrentShow(channel: RadioPlayer.sharedInstance.getChannel())[0], MPMediaItemPropertyArtist : CurrentShow(channel: RadioPlayer.sharedInstance.getChannel())[1], MPMediaItemPropertyArtwork : artwork]
    }
    
    
    @objc func handleInterruption(notification: NSNotification) {
        
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
    
 
    
    
    
    @objc dynamic private func audioRouteChangeListener(notification:NSNotification) {
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
    
    @objc func reachabilityChanged(note: NSNotification) {
        print(" CHANGE")
        

        let thisreachability = note.object as! Reachability
    
        if thisreachability.isReachable {
            
        if thisreachability.isReachableViaWiFi {
        print("Reachable via WiFi")
        } else {
        print("Reachable via Cellular")
        }
        } else {
            let alert = UIAlertController(title: "No Internet Connection", message: "You are not connected to the internet, so you won't be able to stream WMUC. Check your connectivity settings and come back 😊", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            })
            
            self.present(alert, animated: true)
        }
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

    }
    
    @IBAction func backToPlayer(segue: UIStoryboardSegue) {}
    
    
    @objc func CurrentShow(channel: String) -> [String]{
        
        var show = ""
        var dj = ""
        
        hour = Int(Calendar.current.component(.hour, from: Date()))
        
        today = Int(Calendar.current.component(.weekday, from: Date())) - 1
        
        if (schedge.digSched[0][0].name != "Unable to load Schedule"){
            if channel == "FM" {
                let indexfiltered = schedge.fmSched[today].filter{ $0.time <= hour && ($0.time + ($0.len/2) - 1) >= hour }
                
                if indexfiltered.isEmpty{
                    show = ""
                    dj = ""
                    
                }else {
                    show = indexfiltered[0].name
                    dj = indexfiltered[0].dj
                }

                
            }else{
                let indexfiltered = schedge.digSched[today].filter{ $0.time <= hour && ($0.time + ($0.len/2) - 1) >= hour }
                
                if indexfiltered.isEmpty{
                    show = ""
                    dj = ""
                    
                }else {
                    show = indexfiltered[0].name
                    dj = indexfiltered[0].dj
                }
        }
            
        }
        return [show, dj]
    }
    
    
//    dynamic private func AVPlayerStatusListener(notification:NSNotification) {
//        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
//        
//        
//        
//    }
}

