//
//  ScheduleView.swift
//  RadioTest
//
//  Created by ben on 3/8/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit


let DayNotificationKey = "DayChangedKey"
let ChannelNotificationKey = "Channel"

class ScheduleView: UIViewController {
    
    let daysArray = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    var day = Int(Calendar.current.component(.weekday, from: Date())) - 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

        
        viewerSetting = RadioPlayer.sharedInstance.getChannel()
        if (viewerSetting == "none") {
            viewerSetting = "FM"
        }
        
        FMselect.isSelected = (viewerSetting == "FM")
        
        if (FMselect.isSelected){
            var dot = self.dot.frame
            dot.origin.x = self.FMselect.frame.midX - (0.5 * dot.width)
            self.dot.frame=dot
        } else {
            Digselect.isSelected = true
            var dot = self.dot.frame
            dot.origin.x = self.Digselect.frame.midX - (0.5 * dot.width)
            self.dot.frame=dot
        }
        
        self.dot.updateConstraints()
       
        day = Int(Calendar.current.component(.weekday, from: Date())) - 1
        
        self.daysel.selectedSegmentIndex = day
        self.DayLabel.text=daysArray[self.daysel.selectedSegmentIndex]
        
        let dayValue: [AnyHashable: Any] = [AnyHashable("dayVal"): day]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: DayNotificationKey), object: self, userInfo: dayValue)
        
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.Swipe(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.Swipe(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        
        // Do any additional setup after loading the view.
    }
    
    

    @IBOutlet weak var daysel: UISegmentedControl!
    @IBOutlet weak var dotLeading: NSLayoutConstraint!
    @IBOutlet weak var DayLabel: UILabel!
    @IBOutlet weak var dot: UIImageView!
    @IBOutlet weak var FMselect: UIButton!
    @IBOutlet weak var Digselect: UIButton!
    
    @IBAction func FMselected(_ sender: Any) {
        viewerSetting = "FM"
        FMselect.isSelected = true
        Digselect.isSelected = false
        
        UIView.animate(withDuration: 0.16, delay: 0, options: .curveEaseInOut, animations: {
            var dot = self.dot.frame
            dot.origin.x = self.FMselect.frame.midX - (0.5 * dot.width)
            self.dot.frame=dot
        })
        self.dot.updateConstraints();

         NotificationCenter.default.post(name: Notification.Name(rawValue: ChannelNotificationKey), object: self)
    }

    @IBAction func digsel(_ sender: Any) {
        viewerSetting = "Dig"
        FMselect.isSelected = false
        Digselect.isSelected = true
        UIView.animate(withDuration: 0.16, delay: 0, options: .curveEaseInOut, animations: {
            var dot = self.dot.frame
            dot.origin.x = self.Digselect.frame.midX - (0.5 * dot.width)
            
            self.dot.frame=dot
        })
        self.dot.updateConstraints();
        
         NotificationCenter.default.post(name: Notification.Name(rawValue: ChannelNotificationKey), object: self)
        
    }
    
    
    @IBAction func Swipe(_ gesture: UISwipeGestureRecognizer) {
        let swipeGesture = gesture
        
        print("SWIPE")

        
        
        switch swipeGesture.direction {
        case UISwipeGestureRecognizerDirection.right:
            digsel(gesture)
        case UISwipeGestureRecognizerDirection.left:
            FMselected(gesture)
        default:
            break
        }
        
    }
    
    
    @IBAction func settDay(_ sender: Any) {
        let dayValue: [AnyHashable: Any] = [AnyHashable("dayVal"): daysel.selectedSegmentIndex]
        
        self.DayLabel.text=daysArray[self.daysel.selectedSegmentIndex]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: DayNotificationKey), object: self, userInfo: dayValue)
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
            print("viewdidappear!!")
            let alert = UIAlertController(title: "No Internet Connection", message: "You are not connected to the internet, so the app might not work as expected. Check your connectivity settings and come back 😊", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                print("OK")
            })
            
            self.present(alert, animated: true)
        }
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToPlayerWithSegue", sender: self)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
