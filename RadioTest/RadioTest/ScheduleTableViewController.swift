//
//  ScheduleTableViewController.swift
//  RadioTest
//
//  Created by ben on 5/3/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit
import CoreData


class ScheduleTableViewController: UITableViewController {
    

    var shows: [NSManagedObject] = []
    var day = Int(Calendar.current.component(.weekdayOrdinal, from: Date()));
    var isItToday = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadShows()
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleTableViewController.updateChannel), name: NSNotification.Name(rawValue: ChannelNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleTableViewController.updateDay(_:)), name: NSNotification.Name(rawValue: DayNotificationKey), object: nil)
        
        
        let hour = Int(Calendar.current.component(.hour, from: Date()))
        let today = Int(Calendar.current.component(.weekday, from: Date())) - 1
        
        if (schedge.digSched.count >= 7){
        if (viewerSetting == "FM"){
        if let realIndex = schedge.fmSched[today].index(where: { ($0.time <= hour) && (($0.time + ($0.len/2) - 1 ) >= hour) }) {
            
            let indexpAth = IndexPath(row: realIndex, section: 0)
            
            tableView.selectRow(at: indexpAth, animated: false, scrollPosition: .middle)
            
            print (tableView.cellForRow(at: indexpAth)!.isSelected)
        
            tableView.scrollToRow(at: indexpAth, at: .top, animated: false)
            }
        }else if(viewerSetting == "Dig"){
            if let realIndex = schedge.digSched[today].index(where: { ($0.time <= hour) && (($0.time + ($0.len/2) - 1 ) >= hour) }) {
                
                let indexpAth = IndexPath(row: realIndex, section: 0)
                
                tableView.selectRow(at: indexpAth, animated: false, scrollPosition: .middle)
                
                print (tableView.cellForRow(at: indexpAth)!.isSelected)
                
                tableView.scrollToRow(at: indexpAth, at: .top, animated: false)
            }
        }
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ShowTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ShowTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ShowTableViewCell.")
        }
        // Configure the cell...
        
        let thisshow=shows[indexPath.row]
        
        if (thisshow.time > 12){
            cell.showTime.text = String(thisshow.time - 12) + ":00 PM"
        }else if (thisshow.time == 0) {
            cell.showTime.text = "12:00 AM";
        }else if (thisshow.time == 12) {
            cell.showTime.text = "12:00 PM";
        }else{
            cell.showTime.text = String(thisshow.time) + ":00 AM"
        }
        
        cell.showTitle.text = thisshow.name
        cell.showDj.text = thisshow.dj
        
        let endTime = (thisshow.time + (thisshow.len/2))
        if (endTime > 12){
            cell.endTime.text = String(endTime - 12) + ":00 PM"
        }else if (endTime == 0) {
            cell.endTime.text = "12:00 AM"
        }else if(endTime == 12){
            cell.endTime.text = "12:00 PM"
        }else{
            cell.endTime.text = String(endTime) + ":00 AM"
        }
        
        if (thisshow.favorited) {
            // Set favorited in cell as "selected"
        } else {
            // Set favorited in cell as "NOT selected"
        }
        
        let hour = Int(Calendar.current.component(.hour, from: Date()))
        print("___________________")
        print(thisshow.time);
        print(thisshow.len);
        if (isItToday && (thisshow.time <= hour) && ((thisshow.time + (thisshow.len/2) - 1 ) >= hour)){
            print("SELECTED")
            cell.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.2)
        }else{
            cell.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
        }
        
        self.save(name: thisshow.name, dj: thisshow.dj, time: thisshow.time,
                  length: thisshow.len, fav: thisshow.favorited)
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
     func updateChannel(){
        
        loadShows()
        
    }
    
    
    func updateDay(_ notification:NSNotification){
        
        if let dayVal = notification.userInfo?["dayVal"] as? Int {
            
            if (dayVal == (Int(Calendar.current.component(.weekday, from: Date())) - 1)){
                isItToday = true
            } else {
                isItToday = false
            }
        
            day=dayVal
            
            loadShows()
            
        }
        
    }
    
    //MARK: Core Data Methods
    
    func save(name: String, dj: String, time: Int16, length: Int16, fav: Bool) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext = appDelegate.managedObjectContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Show",
                                       in: managedContext)!
        
        let show = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        show.setValue(name, forKeyPath: "name")
        show.setValue(dj, forKeyPath: "dj")
        show.setValue(time, forKeyPath: "time")
        show.setValue(length, forKeyPath: "length")
        show.setValue(fav, forKeyPath: "favorited")
        
        // 4
        do {
            try managedContext.save()
            shows.append(show)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Private Methods
    
    private func loadShows() {
        
        shows = []
        if (schedge.digSched.count >= 7){
        if viewerSetting == "FM" {
            shows = schedge.fmSched[day]
        }else{
            shows = schedge.digSched[day]
        }
        }
        self.tableView.reloadData()

    }

}
