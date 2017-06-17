//
//  ManageTasksTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class ManageTasksViewController: UIViewController {
    
    
    var marathone = ""
    var date = ""
    var time = ""
    
    var type = ""
    var name = ""
    
    var isOver = false
    
    @IBOutlet weak var ttl: UILabel!
 
    @IBOutlet weak var famil: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if compareDates(date, getToday()) == true {
            isOver = true
        }
        if self.type == "motivation" {
            self.famil.isEnabled = false
             self.famil.isHidden = true
        }
        self.ttl.text = self.name
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        
    }
    
    
    @IBAction func edit(_ sender: UIButton) {
        if isOver == false {
            if self.type == "motivation" {
                performSegue(withIdentifier: "AddMot", sender: nil)
            }
            if self.type == "advice" {
                 performSegue(withIdentifier: "AddAdv", sender: nil)
            }
            if self.type == "exercise" {
                 performSegue(withIdentifier: "AddEx", sender: nil)
            }
            if self.type == "recipe" {
                 performSegue(withIdentifier: "AddEx", sender: nil)
            }
            if self.type == "photo" {
                  performSegue(withIdentifier: "AddAdv", sender: nil)
            }
            if self.type == "parameter" {
                 performSegue(withIdentifier: "AddPar", sender: nil)
            }
        } else {
            self.signupErrorAlert(title: "Error!", message: "You can not change tasks of today and days before today.")
            return
        }
    }
    
    @IBAction func familiarize(_ sender: UIButton) {
        
        if self.type == "advice" {
            performSegue(withIdentifier: "Adv", sender: nil)
        }
        if self.type == "exercise" {
            performSegue(withIdentifier: "Ex", sender: nil)
        }
        if self.type == "recipe" {
            performSegue(withIdentifier: "Ex", sender: nil)
        }
        if self.type == "photo" {
            performSegue(withIdentifier: "Ph", sender: nil)
        }
        if self.type == "parameter" {
            performSegue(withIdentifier: "Par", sender: nil)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddMot" {
            let guest = segue.destination as! AddMotivationTableViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.time
        }
        if segue.identifier == "AddAdv" {
            let guest = segue.destination as! AddAdviceTableViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.time
            guest.titl = self.type
        }
        if segue.identifier == "AddEx" {
            let guest = segue.destination as! AddExerciseTableViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.time
            guest.titl = self.type
        }
        if segue.identifier == "AddPar" {
            let guest = segue.destination as! AddParameterTableViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.time
        }
        if segue.identifier == "Adv" {
            let guest = segue.destination as!  AdviceViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.time
        }
        if segue.identifier == "Ex" {
            let guest = segue.destination as! ExerciseViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.time
        }
        if segue.identifier == "Ph" {
            let guest = segue.destination as! PhotoViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.time
        }
        if segue.identifier == "Par" {
            let guest = segue.destination as! ParameterViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.time
        }

    }

    func signupErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func compareDates(_ date1: String, _ date2: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.date(from: String(describing: date1))! <= dateFormatter.date(from: String(describing: date2))!
    }

    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
