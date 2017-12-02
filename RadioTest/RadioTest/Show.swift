//
//  show.swift
//  RadioTest
//
//  Created by ben on 5/3/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//


class Show{
    
    //MARK: Properties
    
    var name: String
    var dj: String
    var time: Int
    var len: Int
    var favorited: Bool
    //MARK: Initialization
    
    init(s: [String]) {
        name = s[0]
        dj = s[1]
        time = 12
        len = 1
    }

    public func setTime(t: String, length: Int) {
        var semicolon = t.components(separatedBy: ":")
        var hour = Int(semicolon[0])!
        if (t.contains("PM") && hour<12){
            hour+=12
        }else if (t.contains("AM") && hour == 12){
            hour=0
        }
        
        time = hour //hour
        len = length
    }
    
    public func toString() -> String {
        return name + " - " + dj;
    }
    
    public func equals(o: Show) -> Bool {
        if (name == o.name && time == o.time) {
            return true;
        } else {
            return false;
        }
    }
}
