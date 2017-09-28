//
//  WMUCCrawler.swift
//  RadioTest
//
//  Created by ben on 7/21/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import Foundation
import UIKit
import SwiftSoup

class WMUCCrawler {
    
    public var digSched: [[Show]]
    public var fmSched: [[Show]]
    
    init() {
        digSched = [[Show]]()
        fmSched = [[Show]]()
    }
    
    public func fetchShows() {

        var colTrackfm = [Int: Int]()
        var colTrackdig = [Int: Int]()
        let day = [Show]()
        var htmlDig: String!;
        var htmlFM: String!;
        
        for i in 0...6 {
            digSched.append(day)
            fmSched.append(day)
            colTrackfm.updateValue(0, forKey: i)
            colTrackdig.updateValue(0, forKey: i)
        }
        
        //Initializes the current row of each col in the sched as they may get out of order.
        
        do {
//            let digUrlString = "http://wmuc.umd.edu/station/schedule/0/2"
//            let fmUrlString = "http://wmuc.umd.edu/station/schedule"
//
//            guard let digUrl = URL(string: digUrlString), let fmUrl = URL(string: fmUrlString) else {
//                print("Error: \(digUrlString) doesn't seem to be a valid URL")
//                throw NSError.init()
//            }
            
            let digUrl = URL(string: "http://wmuc.umd.edu/station/schedule/0/2")
            let fmUrl = URL(string: "http://wmuc.umd.edu/station/schedule")
            
            htmlDig = try String(contentsOf: digUrl!, encoding: .utf8) //get the HTML
            htmlFM = try String(contentsOf: fmUrl!, encoding: .utf8) //get the HTML
            
        } catch {
            print(error);
        }
        
        
        if (htmlDig == nil) {
            for i in 0...6 {
                digSched[i] = [Show(s: ["Unable to load Schedule","No Internet"])]
                fmSched[i] = [Show(s: ["Unable to load Schedule","No Internet"])]
            }
        } else {
            print("started")
            let group = DispatchGroup()

            group.enter()
            fetchShowsHelp(show: "Dig", html: htmlDig, colTrack: &colTrackdig, sched: &digSched) {
                group.leave()
            }

            group.enter()
            fetchShowsHelp(show: "FM", html: htmlFM, colTrack: &colTrackfm, sched: &fmSched) {
                group.leave()
            }

            group.notify(queue: .main) {
                print("both done")
            }
        }
    }
    
    func fetchShowsHelp(show: String, html: String!, colTrack: inout [Int: Int], sched: inout [[Show]], resultHandler: () -> ()) {
        do {
            var doc: Document
            var timetracker = "00:00 AM"
            var daytracker = 0
            let offAir=["offAir","none"]
            
            try doc = SwiftSoup.parse(html)
    
            do {
                let shtuf = try doc.select("td"); // select all the 'TD' elements
                
                for n in shtuf {
                    let x = try n.text().contains("Find us on Facebook Follow WMUC on Twitter!") //  if it's one of these not-important ones, ignore it dude.
                    let y: Bool
                    
                    if show == "Dig" {
                        y = try n.text().contains("Previous Schedules for Channel")
                    } else {
                        y = try n.text().contains("Previous Schedules for Channel 1Spring 2006 (01/30/06")
                    }
                    
                    let z = try n.text().contains("Get Involved")
                    let e = (try n.text().characters.count == 0)
                    
                    print("checked text")
                    if (!x && !y && !z && !e) {
                        do {
                            
                            let a = try n.text().contains(":00") // if it's a time, do one thing
                            let b = try n.text().contains(":30")
                            let c = try n.text().contains("Off The Air") // if it's off air, do another
                            let d = try n.text().contains("***") // if it's a show, do another thing
                            
//                            var sched = (show == "Dig") ? digSched : fmSched
//                            var colTrack = colTrack
                            
                            if (a || b){
                                daytracker = 0 // if it's the time, set the day to sunday,
                                timetracker = try n.text() // set the time for the shows we get during this slot
                            } else if(c || d) {
                                if(c) {
                                    sched[daytracker].append(Show(s: offAir)) // if it's off air, put a new off air show on
                                }
                                
                                if(d) {
                                    let NewShow = try n.text().components(separatedBy:"***") // get the various components: name *** dj *** etc
                                    sched[daytracker].append(Show(s: NewShow)) // add the new show in
                                }
                                
                                let length = try n.attr("rowspan") // use the rowspan to get how many half-hour blocks the show takes up
                                let len = Int(length)!;
                                sched[daytracker].last?.setTime(t: timetracker, length: len) //set the show's time info
                                colTrack.updateValue(len, forKey: daytracker) // update that we have a show in this column for the next (len) half hour blocks.
                            }
                            
                            //try print(n.text())
                            while(colTrack[daytracker] != 0 && daytracker <= 6){ //function to set what day the next show we get should plop into.
                                colTrack.updateValue((colTrack[daytracker]! - 1), forKey: daytracker)
                                daytracker += 1
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
                
                
            } catch {
                print(error);
            }
            
        } catch {
//            let noShow = [Show(s: ["Unable to load Schedule","No Internet"])]
//            for i in 0...6 {
//                digSched[i] = noShow
//                fmSched[i] = noShow
//            }
            print(error)
        }
        
        print("done")
        resultHandler()
    }
}
