//
//  AppDelegate.swift
//  RadioTest
//
//  Created by Hwang Lee on 10/3/16.
//  Copyright © 2016 Hwang Lee. All rights reserved.
//
//


import UIKit
import AVFoundation

let schedge = WMUCCrawler()
var reachability = Reachability()!


var viewerSetting = "FM"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Headphone controls
    override func remoteControlReceived(with event: UIEvent?) {
        let root : ViewController = self.window!.rootViewController! as! ViewController
        if event?.type == UIEventType.remoteControl {
            
            if event?.subtype == UIEventSubtype.remoteControlTogglePlayPause {
                if (RadioPlayer.sharedInstance.currentlyPlaying()) {
                    root.pauseRadio()
                }
                    
                else {
                    root.playRadio()
                }
            }
                
            else if event?.subtype == UIEventSubtype.remoteControlPause {
                root.pauseRadio()
            }
                
            else if event?.subtype == UIEventSubtype.remoteControlPlay {
                root.playRadio()
            }
        }
    }

    
    func  applicationDidFinishLaunching(_ application: UIApplication) {
        
        
        
        
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        schedge.fetchShows()
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
       
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Pause stream if other media is playing
        let root : ViewController = self.window!.rootViewController! as! ViewController
        
        if RadioPlayer.sharedInstance.digital.rate + RadioPlayer.sharedInstance.fm.rate == 0 {
            root.pauseRadio()
            
            
                    }
        if (reachability.isReachable){
            print("IT'S REACHABLE")
            
            if ( schedge.digSched[0][0].name == "Unable to load Schedule"){
                schedge.fetchShows() //load and parse the schedule
            }
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let root : ViewController = self.window!.rootViewController! as! ViewController
        if shortcutItem.type == "FM Radio" {
            root.fmIconPressed(nil)
            root.playRadio()
            
            completionHandler(true)
        }
        
        if shortcutItem.type == "Digital Radio" {
            root.digitalIconPressed(nil)
            root.playRadio()
            
            completionHandler(true)
        }
        
        completionHandler(false)
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        

        
        print(" CHANGE")
        let thisreachability = note.object as! Reachability
        
        
        
        if (thisreachability.isReachable) {
            
            if ( schedge.digSched[0][0].name == "Unable to load Schedule"){
                
                schedge.fetchShows()
                print("REFETCHING SHOWS, RECONNECTED")
            }
            
            if thisreachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            
        }
        
        reachability = Reachability()!
        
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }

    
}

