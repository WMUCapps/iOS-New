//
//  ScheduleTableViewController.swift
//  RadioTest
//
//  Created by ben on 5/3/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit

var viewerSetting = "FM"

struct showMatrix{
    var day=[[Show](), [Show](), [Show](), [Show](), [Show](), [Show](), [Show]() ]
}

var FmMatrix=showMatrix()
var DigMatrix=showMatrix()

class ScheduleTableViewController: UITableViewController {
    

    var shows = [Show]()
    var day = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleTableViewController.updateChannel), name: NSNotification.Name(rawValue: ChannelNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleTableViewController.updateDay(_:)), name: NSNotification.Name(rawValue: DayNotificationKey), object: nil)
        
        loadShows()
        let hour = Int(Calendar.current.component(.hour, from: Date()))
        let today = Int(Calendar.current.component(.weekdayOrdinal, from: Date()))
        let index = FmMatrix.day[today].filter{ $0.time == hour }
        if index.isEmpty {
            
        }else{
            let indexPath = NSIndexPath(index: hour)
        
            tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
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
        }        // Configure the cell...
        
        let thisshow=shows[indexPath.row]
        
        cell.showTime.text = String(thisshow.time)
        cell.showTitle.text = thisshow.name
        cell.showDj.text = thisshow.dj
        
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
            
            day=dayVal
            
            loadShows()
            
        }
        
    }
    
    //MARK: Private Methods
    
    private func loadShows() {
        
        shows = []
        
        if viewerSetting == "FM" {
            shows = FmMatrix.day[day]
        }else{
            shows = DigMatrix.day[day]
        }
        
        self.tableView.reloadData()

    }

}
