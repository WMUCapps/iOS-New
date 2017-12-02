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
    
    
    public var digSched = [[Show]]()
    public var fmSched = [[Show]]()

    
    init(){
        digSched = [[Show]]()
        fmSched = [[Show]]()
    }
    
    public func fetchShows(){
    
    digSched = [[Show]]()
    fmSched = [[Show]]()
    var shtuffm: Elements
    var shtufdig: Elements
    var colTrackfm = [Int: Int]()
    var colTrackdig = [Int: Int]()
    let offAir=["offAir","none"]
    var docDig: Document
    var docFM: Document
    var timetracker = "00:00 AM"
    var daytracker = 0;
    let day = [Show]()
    
    for _ in 0...6 {
    digSched.append(day)
    fmSched.append(day)
    }
    
    
    //Initializes the current row of each col in the sched as they may get out of order.
    colTrackfm.updateValue(0, forKey: 0);
    colTrackfm.updateValue(0, forKey: 1);
    colTrackfm.updateValue(0, forKey: 2);
    colTrackfm.updateValue(0, forKey: 3);
    colTrackfm.updateValue(0, forKey: 4);
    colTrackfm.updateValue(0, forKey: 5);
    colTrackfm.updateValue(0, forKey: 6);
    
    colTrackdig.updateValue(0, forKey: 0);
    colTrackdig.updateValue(0, forKey: 1);
    colTrackdig.updateValue(0, forKey: 2);
    colTrackdig.updateValue(0, forKey: 3);
    colTrackdig.updateValue(0, forKey: 4);
    colTrackdig.updateValue(0, forKey: 5);
    colTrackdig.updateValue(0, forKey: 6);
    
    var htmldig: String!;
    var htmlfm: String!;
    
    do {
    
    let digUrlString = "http://wmuc.umd.edu/station/schedule/0/2"
    guard let digUrl = URL(string: digUrlString) else {
    print("Error: \(digUrlString) doesn't seem to be a valid URL")
    throw NSError.init()
    }
    let fmUrlString = "http://wmuc.umd.edu/station/schedule"
    guard let fmUrl = URL(string: fmUrlString) else {
    print("Error: \(fmUrlString) doesn't seem to be a valid URL")
    throw NSError.init()
    }
    
    htmldig = try String(contentsOf: digUrl, encoding: .utf8) //get the HTML
    htmlfm = try String(contentsOf: fmUrl, encoding: .utf8) //get the HTML
        
    
    } catch {
        
    print(error);
    }
    
        
    
    
        
        if (htmldig == nil){
            let noShow = [Show(s: ["Unable to load Schedule","No Internet"])]
            for i in 0...6 {
                digSched[i] = noShow
                fmSched[i] = noShow
            }
        }else{
            
            do{
                
                try docDig = SwiftSoup.parse(htmldig)
                do{
                    shtufdig = try docDig.select("td"); // select all the 'TD' elements
                    
                    for n in shtufdig {
                        let x = try n.text().contains("Find us on Facebook Follow WMUC on Twitter!") //  if it's one of these not-important ones, ignore it dude.
                        let y = try n.text().contains("Previous Schedules for Channel")
                        let z = try n.text().contains("Get Involved")
                        let e = (try n.text().characters.count == 0)
                        
                        
                        if(x || y || z || e ){ //ignore the ones that don't matter
                            
                        }else{
                            do {
                                
                                let a = try n.text().contains(":00") // if it's a time, do one thing
                                let b = try n.text().contains(":30")
                                let c = try n.text().contains("Off The Air") // if it's off air, do another
                                let d = try n.text().contains("***") // if it's a show, do another thing
                                
                                if( a || b ){
                                    daytracker = 0 // if it's the time, set the day to sunday,
                                    timetracker = try n.text() // set the time for the shows we get during this slot
                                } else if(c){
                                    digSched[daytracker].append(Show(s: offAir)) // if it's off air, put a new off air show on
                                    let length = try n.attr("rowspan") // use the rowspan to get how many half-hour blocks the show takes up
                                    let len = Int(length)!;
                                    digSched[daytracker].last?.setTime(t: timetracker, length: Int16(len)) //set the show's time info
                                    colTrackdig.updateValue(len, forKey: daytracker) // update that we have a show in this column for the next (len) half hour blocks.
                                } else if d {
                                    let NewShow = try n.text().components(separatedBy:"***") // get the various components: name *** dj *** etc
                                    digSched[daytracker].append(Show(s: NewShow)) // add the new show in
                                    let length = try n.attr("rowspan") // get in thew new length info
                                    let len = Int(length)!;
                                    digSched[daytracker].last?.setTime(t: timetracker, length: Int16(len))// update that we have a show in this column for the next (len) half hour blocks.
                                    colTrackdig.updateValue(len, forKey: daytracker)
                                }
                                
                                
                                //try print(n.text())
                                while(colTrackdig[daytracker] != 0){ //function to set what day the next show we get should plop into.
                                    if(daytracker>6){ // if we go thru the entire week, then reset to prevent array overrun
                                        break
                                    }
                                    let curVal = colTrackdig[daytracker]!
                                    colTrackdig.updateValue((curVal-1), forKey: daytracker)
                                    daytracker+=1
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    
                } catch {
                    print(error);
                }
            }catch{
                let noShow = [Show(s: ["Unable to load Schedule","No Internet"])]
                for i in 0...6 {
                    digSched[i] = noShow
                }
                print(error)
            }
            do{
                try docFM = SwiftSoup.parse(htmlfm)
                
                do{
                    shtuffm = try docFM.select("td"); // select all the 'TD' elements
                    
                    for n in shtuffm {
                        let x = try n.text().contains("Find us on Facebook Follow WMUC on Twitter!") //  if it's one of these not-important ones, ignore it dude.
                        let y = try n.text().contains("Previous Schedules for Channel 1Spring 2006 (01/30/06")
                        let z = try n.text().contains("Get Involved")
                        let e = (try n.text().characters.count == 0)
                        
                        
                        if(x || y || z || e ){ //ignore the ones that don't matter
                            
                        }else{
                            do {
                                print("|")
                                try print(n.text())
                                
                                let a = try n.text().contains(":00") // if it's a time, do one thing
                                let b = try n.text().contains(":30")
                                let c = try n.text().contains("Off The Air") // if it's off air, do another
                                let d = try n.text().contains("***") // if it's a show, do another thing
                                
                                if( a || b ){
                                    daytracker = 0 // if it's the time, set the day to sunday,
                                    timetracker = try n.text() // set the time for the shows we get during this slot
                                } else if(c){
                                    fmSched[daytracker].append(Show(s: offAir)) // if it's off air, put a new off air show on
                                    let length = try n.attr("rowspan") // use the rowspan to get how many half-hour blocks the show takes up
                                    let len = Int(length)!;
                                    fmSched[daytracker].last?.setTime(t: timetracker, length: Int16(len)) //set the show's time info
                                    colTrackfm.updateValue(len, forKey: daytracker) // update that we have a show in this column for the next (len) half hour blocks.
                                } else if d {
                                    let NewShow = try n.text().components(separatedBy:"***") // get the various components: name *** dj *** etc
                                    fmSched[daytracker].append(Show(s: NewShow)) // add the new show in
                                    let length = try n.attr("rowspan") // get in thew new length info
                                    let len = Int(length)!;
                                    fmSched[daytracker].last?.setTime(t: timetracker, length: Int16(len))// update that we have a show in this column for the next (len) half hour blocks.
                                    colTrackfm.updateValue(len, forKey: daytracker)
                                }
                                
                                
                                //try print(n.text())
                                while(colTrackfm[daytracker] != 0){ //function to set what day the next show we get should plop into.
                                    if(daytracker>6){ // if we go thru the entire week, then reset to prevent array overrun
                                        break
                                    }
                                    let curVal = colTrackfm[daytracker]!
                                    colTrackfm.updateValue((curVal-1), forKey: daytracker)
                                    daytracker+=1
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    
                } catch {
                    print(error);
                }

            }catch{
                let noShow = [Show(s: ["Unable to load Schedule","No Internet"])]
                for i in 0...6 {
                    digSched[i] = noShow
                    fmSched[i] = noShow
                }
                print(error)
            }
    
        
        
    ///// NOW DO DIGITAL ///////////////////////////
    

    }
    }
}
