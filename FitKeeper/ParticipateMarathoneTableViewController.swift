//
//  ParticipateMarathone.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//


import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FSCalendar

class ParticipateMarathoneTableViewController: UITableViewController, FSCalendarDataSource, FSCalendarDelegate  {
    
    var flag = false
    var marathone = ""
    var startDate = ""
    var period = ""
    var date = "" {
        didSet {
           super.viewDidLoad()
           // viewWillAppear(true)
            
           viewDidAppear(true)
            
        }
    }
    var tasks : Int = 0
    var doneTask : Int = 0
   
    var material = [String : String]()
    var materials = [[String : String]]()
    
    @IBOutlet weak var day: UITextField!
    @IBOutlet weak var header: UINavigationItem!
    
    @IBOutlet weak var doneTasks: UITextField!
    @IBOutlet weak var allTasks: UITextField!
    @IBOutlet weak var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.scope = .week
        self.calendar.firstWeekday = 2
        self.calendar.clipsToBounds = true
        self.header.title = marathone
    
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd MM yyyy"
//        self.calendar.select(dateFormatter.date(from: self.getToday()), scrollToDate: true)
//        self.date = getToday()
        self.tasks = 0
        self.doneTask = 0
        self.doneTasks.text = String(0)
        self.allTasks.text = String(0)
        
        //Прозрачный  Navigation bar
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clear
       self.navigationController?.hidesBarsOnSwipe = true
        
        
         navigationController?.hidesBarsOnTap = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Rectangle 33.png"), for: UIBarMetrics.default)
       // self.navigationController?.navigationBar.shadowImage = UIImage(named: "Rectangle 33.png")
        self.navigationController?.navigationBar.isTranslucent = false
        //self.navigationController?.view.backgroundColor = UIColor.clear
        // self.navigationController?.hidesBarsOnSwipe = true
        //Кнопка назад без названия
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
      //  self.tableView.reloadData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        self.tableView.reloadData()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
         navigationController?.hidesBarsOnSwipe = true
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clear
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
       
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(self.marathone)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    if let dict = snapshot.value as? NSDictionary, let info = dict["startDate"] as? String {
                        self.startDate = info
                        let currentCalendar = Calendar.current
                        let startD = currentCalendar.ordinality(of: .day, in: .era, for: dateFormatter.date(from: self.startDate)!)
                        let endD = currentCalendar.ordinality(of: .day, in: .era, for: dateFormatter.date(from: self.date)!)
                        
                        self.day.text = "Day " + String(endD! - startD! + 1)
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["period"] as? String {
                        self.period = info
                    }
                }
            })
        }
        

        
        self.materials.removeAll()
        self.tasks = 0
        self.doneTask = 0
        
       // self.doneTasks.text = String(0)
        self.tableView.reloadData()
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        flag = false
        if let uid = Auth.auth().currentUser?.uid{
            self.doneTasks.text = "0"
            self.allTasks.text = "0"
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).child(self.date)
            ref.observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else if self.flag == false {
                    for m in snapshot.children {
                        self.material.removeAll()
                        let marathoneSnap = m as! DataSnapshot
                        if let dict = marathoneSnap.value as? NSDictionary, let info = dict["type"] as? String {
                            if info != "motivation" {
                                 self.tasks += 1
                                self.material["type"] = info
                       
                                if let dict = marathoneSnap.value as? NSDictionary, let info = dict["title"] as? String {
                                    self.material["title"] = info
                                }
                                if let dict = marathoneSnap.value as? NSDictionary, let info = dict["time"] as? String {
                                    self.material["time"] = info

                                    
                                }
                                if let dict = marathoneSnap.value as? NSDictionary, let info = dict["kcal"] as? String {
                                    self.material["kcal"] = info
                                   // self.materials.append(self.material)
                                }
                                if let dict = marathoneSnap.value as? NSDictionary, let info = dict["mins"] as? String {
                                    self.material["mins"] = info
                                }
                                if let dict = marathoneSnap.value as? NSDictionary, let info = dict["value"] as? String {
                                    self.material["value"] = info
                                }
                                    
                            self.materials.append(self.material)
                            //self.tableView.reloadData()
                            }
                        }
                        self.allTasks.text = String(self.tasks)
                        self.tableView.reloadData()
                         self.flag = true
                    }
                    for m in 0..<self.materials.count {
                        self.doneTasks.text = "0"
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child(self.date).observeSingleEvent(of: .value, with: { snapshot in
                            if ( snapshot.value is NSNull ) {
                                print("not found")
                            } else  {
                                if let dict = snapshot.value as? NSDictionary, let info = dict[self.materials[m]["time"]] as? String {
                                    self.self.materials[m]["done"] = info
                                    self.doneTask += 1
                                    self.doneTasks.text = String(self.doneTask)
                                    self.tableView.reloadData()
                                    self.flag = true
                                }
                            }
                        })
                        
                    }
                    
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "Todays tasks"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materials.count
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }
    
    
    func calendar(_ calendar: FSCalendar!, didSelect date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        self.date = dateFormatter.string(from: date as Date)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
        cell.titleLabel.text = self.materials[indexPath.row]["title"]
        cell.kcalLabel.text = nil
        if self.materials[indexPath.row]["type"] != "motivation" {
            if self.materials[indexPath.row]["type"] == "advice" {
                cell.imView?.image = UIImage(named: "bulb-icon.png")
                cell.descriptionTextField.text = self.materials[indexPath.row]["type"]
            }
            if self.materials[indexPath.row]["type"] == "exercise" {
                cell.imView?.image = UIImage(named: "jumping-rope-icon.png")
                cell.descriptionTextField.text = self.materials[indexPath.row]["type"]! + ", " + self.materials[indexPath.row]["mins"]! + " min"
                cell.kcalLabel.text = "-" + self.materials[indexPath.row]["kcal"]! + " kcal"
                cell.kcalLabel.textColor  = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
            }
            if self.materials[indexPath.row]["type"] == "recipe" {
                cell.imView?.image = UIImage(named: "stew-1.png")
                 cell.descriptionTextField.text = self.materials[indexPath.row]["type"]! + ", " + self.materials[indexPath.row]["mins"]! + " min"
                cell.kcalLabel.text = "+" + self.materials[indexPath.row]["kcal"]! + " kcal"
               cell.kcalLabel.textColor  = UIColor(red: 231/255, green: 135/255, blue: 135/255, alpha: 1)
            }
            if self.materials[indexPath.row]["type"] == "photo" {
                cell.imView?.image = UIImage(named: "photo-icon.png")
                 cell.descriptionTextField.text = self.materials[indexPath.row]["type"]
                
            }
            if self.materials[indexPath.row]["type"] == "parameter" {
                cell.imView?.image = UIImage(named: "wave-icon.png")
                cell.descriptionTextField.text = self.materials[indexPath.row]["type"]! + ", " + self.materials[indexPath.row]["value"]!
            }
            if self.materials[indexPath.row]["done"] != nil {
                if self.materials[indexPath.row]["done"] == "intime" {
                    cell.button.setImage(UIImage(named: "Oval 2.png"), for: .normal)
                }
                if self.materials[indexPath.row]["done"] == "overdue" {
                    cell.button.setImage(UIImage(named: "Combined Shape_prpl.png"), for: .normal)
                }
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MM yyyy"
                if dateFormatter.date(from: getToday())! > dateFormatter.date(from: self.date)! {
                    cell.button.setImage(UIImage(named: "Oval 2 Copy 2_or.png"), for: .normal)
                } else {
                    cell.button.setImage(UIImage(named: "Combined Shape.png"), for: .normal)
                }
            }
        }
         cell.descriptionTextField.text = self.materials[indexPath.row]["type"]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.materials[indexPath.row]["type"] == "motivation" {
//            performSegue(withIdentifier: "AddMot", sender: indexPath.row)
//        }
        if self.materials[indexPath.row]["type"] == "advice" {
            performSegue(withIdentifier: "AdviceSegue", sender: indexPath.row)
        }
        if self.materials[indexPath.row]["type"] == "exercise" {
            performSegue(withIdentifier: "Exercise", sender: indexPath.row)
        }
        if self.materials[indexPath.row]["type"] == "recipe" {
            performSegue(withIdentifier: "Exercise", sender: indexPath.row)
        }
        if self.materials[indexPath.row]["type"] == "photo" {
            performSegue(withIdentifier: "PhotoSegue", sender: indexPath.row)
        }
        if self.materials[indexPath.row]["type"] == "parameter" {
            performSegue(withIdentifier: "ParameterSegue", sender: indexPath.row)
        }
    }
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AddMot" {
//            let guest = segue.destination as! AddMotivationTableViewController
//            guest.marathone = self.marathone
//            guest.date = self.date
//            guest.time = self.materials[sender as! Int]["time"]!
//        }
        if segue.identifier == "AdviceSegue" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! AdviceViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.materials[sender as! Int]["time"]!
        }
        if segue.identifier == "Exercise" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! ExerciseViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.materials[sender as! Int]["time"]!
            guest.isUsed = self.materials[sender as! Int]["done"] != nil ? true : false
        }
        if segue.identifier == "PhotoSegue" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! PhotoViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.materials[sender as! Int]["time"]!
            guest.isUsed = self.materials[sender as! Int]["done"] != nil ? true : false
        }
        if segue.identifier == "ParameterSegue" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! ParameterViewController
            guest.marathone = self.marathone
            guest.date = self.date
            guest.time = self.materials[sender as! Int]["time"]!
        }
    }

    
    
    func calendar(_ calendar: FSCalendar!, shouldSelectDate date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let start = dateFormatter.date(from: String(describing: self.startDate))
        let end = dateFormatter.date(from: self.getToday())
        //Calendar.current.date(byAdding: .day, value: (7 * Int(self.period)!), to: start!)
        if dateFormatter.date(from: dateFormatter.string(from: date as Date))! >= start! && dateFormatter.date(from: dateFormatter.string(from: date as Date))! <= end! {
            return true
        }
        self.signupErrorAlert(title: "Error!", message: "You could pick only marathone days till today.")
        return false
    }

    
    func signupErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    @IBAction func unwindToParticipate(storyboard:UIStoryboardSegue){
    }
    
}
//extension Date {
//    
//    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
//        
//        let currentCalendar = Calendar.current
//        
//        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
//        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
//        
//        return end - start
//    }
//}
