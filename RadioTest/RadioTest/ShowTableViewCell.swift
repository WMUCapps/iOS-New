//
//  ShowTableViewCell.swift
//  RadioTest
//
//  Created by ben on 5/3/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit

class ShowTableViewCell: UITableViewCell {

    @IBOutlet weak var showTime: UILabel!
    
    @IBOutlet weak var showTitle: UILabel!
    
    @IBOutlet weak var showDj: UILabel!
    
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var fav: UIButton!
    
    //MARK: Favorite Button Functionality
    @IBAction func favorite(_ sender: UIButton) {
        fav.isSelected=(!fav.isSelected)
    }
}
