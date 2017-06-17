//
//  TodaysActivitiesTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TodaysActivitiesTableViewController: UITableViewController, UISearchBarDelegate {
    
    let sectionTitles = ["Meals", "Exercises"]
    
    var date = String()
    
    var activities = [(String,String,String)]()
    var meals = [(String,String,String,String,String,String)]()
    var mealsRows = [Int]()
    var actRows = [Int]()
    
    
    var balance = [String : String]()
    
    var mealflag = false
    var actflag = false
    
    var mealcounter = 0
    var activitiescounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
       
        self.tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        activities.removeAll()
        meals.removeAll()
        mealsRows.removeAll()
        actRows.removeAll()
        
        mealflag = false
        actflag = false
        
        mealcounter = 0
        activitiescounter = 0
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid)
            let activityRef = ref.child("dairy").child(self.date).child("activities")
            activityRef.observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for activity in snapshot.children {
                        let activitySnap = activity as! DataSnapshot
                        let dict = activitySnap.value as! [String: String]
                        if dict["name"] != nil {
                            self.activities.append((dict["name"]!, dict["mins"]!, dict["kcal"]!))
                            self.actflag = true
                            self.tableView.reloadData()
                        }

                    }
                    self.mealcounter = 0
                    self.activitiescounter = 0
                    self.tableView.reloadData()
                }
            })
           
            
            let mRef = ref.child("dairy").child(self.date).child("meals")
            mRef.observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for activity in snapshot.children {
                        let activitySnap = activity as! DataSnapshot
                        let dict = activitySnap.value as! [String: AnyObject]
                        if dict["name"] != nil {
                            self.meals.append((dict["name"] as! String, dict["grams"]! as! String, dict["kcal"]! as! String, dict["carbs"]! as! String, dict["fats"]! as! String, dict["proteins"]! as! String))
                            self.mealflag = true
                            self.tableView.reloadData()
                        }

                    }
                    self.mealcounter = 0
                self.activitiescounter = 0
                self.tableView.reloadData()
                }
                self.mealcounter = 0
                self.activitiescounter = 0
                self.tableView.reloadData()
            })
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }
    
    override func tableView(_ tableView: UITableView,
                                     titleForHeaderInSection section: Int) -> String? {
            if section < sectionTitles.count {
            return sectionTitles[section]
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if meals.count != 0 {
                return meals.count
            }
            else {
                return 1
            }
        } else {
            if activities.count != 0 {
                return activities.count
            }
            else {
                return 1
            }
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let i = mealsRows.index(of: indexPath.row)
            performSegue(withIdentifier: "mealsSegue", sender: meals[i!].0)
        } else {
            let i = actRows.index(of: indexPath.row)
            performSegue(withIdentifier: "sportsSegue", sender: activities[i!].0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mealsSegue" {
            let guest = segue.destination as! MealViewController
            guest.meal = sender as! String
            guest.date = date
        }
        if segue.identifier == "sportsSegue" {
            let guest = segue.destination as! ChosenSportsTableViewController
            guest.sport = sender as! String
            guest.date = date
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (meals.count == 0 && indexPath.section == 0) || (activities.count == 0 && indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
            cell.titleLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
            cell.titleLabel?.text = "There is no activities today."
            cell.titleLabel?.center.y = cell.frame.size.height / 2
            cell.titleLabel?.center.x = cell.frame.size.width / 2
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.descriptionTextField?.text = ""
            cell.kcalLabel.text = ""
            cell.imView?.image = nil
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
            cell.titleLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
            cell.descriptionTextField?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
            cell.titleLabel?.font = cell.titleLabel?.font.withSize(20)
            cell.imView?.center.y = cell.frame.size.height / 2
            if indexPath.section == 0 {
                cell.imView?.image = UIImage(named: "cottage cheese")!
                cell.titleLabel?.text = meals[mealcounter].0
                cell.descriptionTextField?.text = meals[mealcounter].1 + " g"
                cell.descriptionTextField?.isEnabled = false
                cell.kcalLabel.text = meals[mealcounter].2 + " kcal"
                cell.kcalLabel.textColor  = UIColor(red: 234/255, green: 135/255, blue: 135/255, alpha: 1)
                mealsRows.append(indexPath.row)
                mealcounter += 1
                return cell
            }
            if indexPath.section == 1 {
                cell.imView?.image = UIImage(named: "cycle-icon")!
                cell.titleLabel?.text = activities[activitiescounter].0
                cell.descriptionTextField?.text = activities[activitiescounter].1 + " min"
                cell.descriptionTextField?.isEnabled = false
                cell.kcalLabel.text = activities[activitiescounter].2 + " kcal"
                cell.kcalLabel.textColor  = UIColor(red: 87/255, green: 209/255, blue: 194/255, alpha: 1)
                actRows.append(indexPath.row)
                activitiescounter += 1
                return cell
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (meals.count == 0  && indexPath.section == 0) || (activities.count == 0 && indexPath.section == 1) {
            return false
        }
            return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if let uid = Auth.auth().currentUser?.uid{
                if indexPath.section == 0 {
                    var post = [String : String] ()
                    let belRef = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance")
                    belRef.observeSingleEvent(of: .value, with: { snapshot in
                        if !snapshot.exists() { return }
                        if let dict = snapshot.value as? NSDictionary {
                           var eaten = String(Int((dict["eaten"] as? String)!)! - Int(self.meals[indexPath.row].2)!)
                           var post =  ["eaten": eaten]
                            eaten =  String(Double((dict["carbs"] as? String)!)! - Double(self.meals[indexPath.row].3)!)
                            post["carbs"] = eaten
                            eaten = String(Double((dict["fats"] as? String)!)! - Double(self.meals[indexPath.row].4)!)
                            post["fats"] = eaten
                            eaten = String(Double((dict["proteins"] as? String)!)! - Double(self.meals[indexPath.row].5)!)
                            post["proteins"] = eaten
                            belRef.updateChildValues(post)
                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("meals").child(self.meals[indexPath.row].0).removeValue()
                            self.viewDidAppear(true)
                        }
                    })
            } else if indexPath.section == 1 {
                    var post = [String : String] ()
                    let belRef = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance")
                    belRef.observeSingleEvent(of: .value, with: { snapshot in
                        if !snapshot.exists() { return }
                        if let dict = snapshot.value as? NSDictionary {
                            var burned = String(Int((dict["burned"] as? String)!)! - Int(self.activities[indexPath.row].2)!)
                            var post =  ["burned": burned]
                            belRef.updateChildValues(post)
                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("activities").child(self.activities[indexPath.row].0).removeValue()
                            self.viewDidLoad()
                            self.viewDidAppear(true)
                        }
                    })
                }
                self.viewDidLoad()
                self.viewDidAppear(true)
            }
        }
    }
    

    func myErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToSearchProd(storyboard:UIStoryboardSegue){
    }
}
