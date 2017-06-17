//
//  LogMealTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class LogMealTableViewController: UITableViewController {
    
   
    
    var meals = ["Breakfast", "MorningSnack", "Lunch", "AfternoonSnack", "Dinner", "EveningSnack"]
    
    var eaten = String()
    
    var dictionary : [String : String] = [String : String]()
    
    var date = String()
    
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 100
        }
        else {
            return 75
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowMeal", sender: tableView.cellForRow(at: indexPath)?.textLabel?.text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMeal" {
        let guest = segue.destination as! MealViewController
        guest.meal = sender as! String
        guest.date = self.date
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = self.date
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.imageView?.image = nil
            cell.backgroundColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
            cell.textLabel?.font = cell.textLabel?.font.withSize(20)
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
            cell.detailTextLabel?.text = "0 kcal"
            if let uid = Auth.auth().currentUser?.uid{
                let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() { return }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["eaten"] as? String {
                        cell.detailTextLabel?.text = info + " kcal"
                    }
                })
            }
        } else {
            cell.textLabel?.text = meals[indexPath.row - 1]
            if let uid = Auth.auth().currentUser?.uid{
                let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("meals").child(meals[indexPath.row - 1])
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() { cell.detailTextLabel?.text = "0 kcal" }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["kcal"] as? String {
                        cell.detailTextLabel?.text = (info + " kcal")
                    } else {
                        cell.detailTextLabel?.text = "0 kcal"
                    }
                })
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
