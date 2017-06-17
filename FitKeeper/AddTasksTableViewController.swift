//
//  AddTasksTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit

class AddTasksTableViewController: UITableViewController {
    
    var date = ""
    var marathone = "" 
    
    @IBOutlet weak var dateLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)

        self.dateLabel.text = marathone.capitalized + " , " + date
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddMotivation" {
            let guest = segue.destination as! AddMotivationTableViewController
            guest.marathone = marathone
            guest.date = date
        }
        if segue.identifier == "AddAdvice" {
//            let nav = segue.destination as! UINavigationController
//            let guest = nav.topViewController as! AddAdviceTableViewController
           let guest = segue.destination as! AddAdviceTableViewController
            guest.marathone = marathone
            guest.date = date
            guest.titl = "advice"
        }
        if segue.identifier == "AddPhoto" {
            let guest = segue.destination as! AddAdviceTableViewController
            guest.marathone = marathone
            guest.date = date
            guest.titl = "photo"
        }
        if segue.identifier == "AddExercise" {
            let guest = segue.destination as! AddExerciseTableViewController
            guest.marathone = marathone
            guest.date = date
            guest.titl = "exercise"
        }
        if segue.identifier == "AddRecipe" {
            let guest = segue.destination as! AddExerciseTableViewController
            guest.marathone = marathone
            guest.date = date
             guest.titl = "recipe"
        }
        if segue.identifier == "AddRecipe" {
            let guest = segue.destination as! AddExerciseTableViewController
            guest.marathone = marathone
            guest.date = date
            guest.titl = "recipe"
        }
        if segue.identifier == "AddParameter" {
            let guest = segue.destination as! AddParameterTableViewController
            guest.marathone = marathone
            guest.date = date
        }
        
    }
    
    @IBAction func close(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    //Segue to ActivityTableViewController
   
    
}
