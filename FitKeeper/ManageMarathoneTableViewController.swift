//
//  ManageMarathoneTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FSCalendar

class ManageMarathoneTableViewController: UITableViewController, FSCalendarDataSource, FSCalendarDelegate  {
    
    var flag = false
    var marathone = ""
    var startDate = ""
    var period = ""
    var date = "" {
        didSet {
            //viewWillAppear(true)
            viewDidAppear(true)
        }
    }
    
    var material = [String : String]()
    var materials = [[String : String]]()

    @IBOutlet weak var header: UINavigationItem!
    
    @IBOutlet weak var calendar: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.scope = .week
        self.calendar.firstWeekday = 2
        self.calendar.clipsToBounds = true
        self.header.title = marathone
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Rectangle 33.png"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = false
        
        if let uid = Auth.auth().currentUser?.uid{
             Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(self.marathone).observeSingleEvent(of: .value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    if let dict = snapshot.value as? NSDictionary, let info = dict["startDate"] as? String {
                        self.startDate = info
                         self.date = info
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd MM yyyy"
                        self.calendar.select(dateFormatter.date(from: self.startDate), scrollToDate: true)
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["period"] as? String {
                        self.period = info
                    }
                }
            })
        }
        
        
       // self.calendar.select(<#T##date: Date?##Date?#>, scrollToDate: <#T##Bool#>)
        //Прозрачный  Navigation bar
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Rectangle 33.png"), for: UIBarMetrics.default)
      //  self.navigationController?.navigationBar.shadowImage = UIImage(named: "Rectangle 33.png")
        self.navigationController?.navigationBar.isTranslucent = false
        //self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.hidesBarsOnSwipe = true
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }
    
      override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
     self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Rectangle 33.png"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = false

        
       self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
         navigationController?.hidesBarsOnSwipe = true
        self.materials.removeAll()
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
         self.tableView.reloadData()
        flag = false
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).child(self.date)
            ref.observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else if self.flag == false {
                    for m in snapshot.children {
                        self.material.removeAll()
                        let marathoneSnap = m as! DataSnapshot
                        if let dict = marathoneSnap.value as? NSDictionary, let info = dict["type"] as? String {
                            self.material["type"] = info
                        }
                        if let dict = marathoneSnap.value as? NSDictionary, let info = dict["title"] as? String {
                            self.material["title"] = info
                        }
                        if let dict = marathoneSnap.value as? NSDictionary, let info = dict["time"] as? String {
                            self.material["time"] = info
                            self.materials.append(self.material)
                            //self.materials = self.materials.sorted(by: { $0["type"] != "motivation" &&  $1["type"] == "motivation" })
                            self.tableView.reloadData()
                        }
                    }
                    self.tableView.reloadData()
                    self.flag = true
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Todays materials"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return materials.count
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }

    
    func calendar(_ calendar: FSCalendar!, didSelect date: Date!) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        self.date = dateFormatter.string(from: date as Date)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return  tableView.dequeueReusableCell(withIdentifier: "AddSmth", for: indexPath) as! AddTableViewCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
            
            cell.descriptionTextField.text = self.materials[indexPath.row]["type"]
            if self.materials[indexPath.row]["type"] == "motivation" {
                cell.titleLabel.text = self.materials[indexPath.row]["type"]
                cell.imView?.image = UIImage(named: "paper-icon.png")
            } else {
                 cell.titleLabel.text = self.materials[indexPath.row]["title"]
                if self.materials[indexPath.row]["type"] == "advice" {
                    cell.imView?.image = UIImage(named: "bulb-icon.png")
                }
                if self.materials[indexPath.row]["type"] == "exercise" {
                    cell.imView?.image = UIImage(named: "jumping-rope-icon.png")
                }
                if self.materials[indexPath.row]["type"] == "recipe" {
                    cell.imView?.image = UIImage(named: "stew-1.png")
                }
                if self.materials[indexPath.row]["type"] == "photo" {
                    cell.imView?.image = UIImage(named: "photo-icon.png")
                }
                if self.materials[indexPath.row]["type"] == "parameter" {
                    cell.imView?.image = UIImage(named: "wave-icon.png")
                }
            }
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if let uid = Auth.auth().currentUser?.uid{
                let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).child(self.date).child(self.materials[indexPath.row]["time"]!).removeValue()
                //self.viewDidLoad()
                self.materials.removeAll()
                self.tableView.reloadData()
                self.viewDidAppear(true)
            }
        }
    }

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
                performSegue(withIdentifier: "AddTasks", sender: self.marathone)
        }
        if indexPath.section == 1 {
//            if self.materials[indexPath.row]["type"] == "motivation" {
//                performSegue(withIdentifier: "AddMot", sender: indexPath.row)
//            }
//            if self.materials[indexPath.row]["type"] == "advice" {
//                 performSegue(withIdentifier: "AddAdv", sender: indexPath.row)
//            }
//            if self.materials[indexPath.row]["type"] == "exercise" {
//                 performSegue(withIdentifier: "AddEx", sender: indexPath.row)
//            }
//            if self.materials[indexPath.row]["type"] == "recipe" {
//                 performSegue(withIdentifier: "AddEx", sender: indexPath.row)
//            }
//            if self.materials[indexPath.row]["type"] == "photo" {
//                  performSegue(withIdentifier: "AddAdv", sender: indexPath.row)
//            }
//            if self.materials[indexPath.row]["type"] == "parameter" {
//                 performSegue(withIdentifier: "AddPar", sender: indexPath.row)
//            }
//            
            
            performSegue(withIdentifier: "ManageTasks", sender: indexPath.row)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AddMot" {
//            let guest = segue.destination as! AddMotivationTableViewController
//            guest.marathone = self.marathone
//            guest.date = self.date
//            guest.time = self.materials[sender as! Int]["time"]!
//        }
//        if segue.identifier == "AddAdv" {
////            let nav = segue.destination as! UINavigationController
////            let guest = nav.topViewController as! AddAdviceTableViewController
//           let guest = segue.destination as! AddAdviceTableViewController
//            guest.marathone = self.marathone
//            guest.date = self.date
//            guest.time = self.materials[sender as! Int]["time"]!
//            guest.titl = self.materials[sender as! Int]["type"]!
//        }
//        if segue.identifier == "AddEx" {
//            let guest = segue.destination as! AddExerciseTableViewController
//            guest.marathone = self.marathone
//            guest.date = self.date
//            guest.time = self.materials[sender as! Int]["time"]!
//            guest.titl = self.materials[sender as! Int]["type"]!
//        }
//        if segue.identifier == "AddPar" {
//            let guest = segue.destination as! AddParameterTableViewController
//            guest.marathone = self.marathone
//            guest.date = self.date
//            guest.time = self.materials[sender as! Int]["time"]!
//        }
        if segue.identifier == "AddTasks" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! AddTasksTableViewController
           // let guest = segue.destination as! AddTasksTableViewController
            guest.marathone = sender as! String
            guest.date = self.date
        }
        if segue.identifier == "MembersSegue" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! MarathoneMembersTableViewController
            guest.marathone = self.marathone
            if compareDates(self.getToday(), self.date) == true {
                guest.end = true
            }
        }
        if segue.identifier == "ManageTasks" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! ManageTasksViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.materials[sender as! Int]["time"]!
            if self.materials[sender as! Int]["type"] != "motivation" {
                guest.name = self.materials[sender as! Int]["title"]!
            }
            guest.type = self.materials[sender as! Int]["type"]!
        }
    }
    
    func calendar(_ calendar: FSCalendar!, shouldSelectDate date: Date!) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let start = dateFormatter.date(from: String(describing: self.startDate))
        let end = Calendar.current.date(byAdding: .day, value: (7 * Int(self.period)!), to: start!)
        if dateFormatter.date(from: dateFormatter.string(from: date as Date))! >= start! && dateFormatter.date(from: dateFormatter.string(from: date as Date))! <= end! {
            return true
        }
        self.signupErrorAlert(title: "Error!", message: "You could pick only marathone days .")
        return false
    }
    
    func compareDates(_ date1: String, _ date2: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.date(from: String(describing: date1))! == dateFormatter.date(from: String(describing: date2))!
        
    }
    
    func signupErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func unwindToManage(storyboard:UIStoryboardSegue){
    }

}
