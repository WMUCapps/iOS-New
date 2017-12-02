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
import CoreData

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
        self.saveContext()
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
        self.saveContext()
    }
    
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
    
    func reachabilityChanged(note: NSNotification) {
        
        

        
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

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("RadioTest.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

