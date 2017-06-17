//
//  MarathoneCell.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//


import UIKit

class MarathoneTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var coachLabel: UILabel!
    @IBOutlet weak var coachTextField: UITextField!
    
    @IBOutlet weak var startsLabel: UILabel!
    @IBOutlet weak var startsTextField: UITextField!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imView: UIImageView?
}
