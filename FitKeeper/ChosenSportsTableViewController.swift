//
//  ChosenSportsTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class ChosenSportsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var date = String()
    var sport = String()
    
    var kcals = Int()
    var kcalBurned = Int()
    var time = Int()
    var initTime = Int()
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var kcal: UITextField!
    @IBOutlet weak var header: UINavigationItem!
    
    let number = ["5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60", "65", "70", "75", "80", "85", "90", "95", "100", "105", "110", "115", "120", "125", "130", "135", "140", "145", "150", "155", "160", "165", "170", "175", "180"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return number[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return number.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if number[row] != nil {
            self.time = Int(number[row])!
            self.kcal.text = String((kcals * Int(number[row])!) / self.initTime)
        }
    }
    
    @IBAction func addSport(_ sender: UIButton) {
        
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() {  return }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["burned"] as? String {
                        self.kcalBurned = Int(info)!
                    }
            })
            self.kcalBurned += Int(self.kcal.text!)!
            let data : [String: String] = ["mins": String(self.time),
                        "kcal" : self.kcal.text!,
                        "name" : self.sport]
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("balance").updateChildValues(["burned" : String(kcalBurned)])
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("activities").child(sport).updateChildValues(data)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.header.title = self.sport
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        //self.pickerView.selectRow(5, inComponent: 1, animated: true)
        
        self.kcal.text = "0"

        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("activities").child(sport)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["kcal"] as? String {
                    self.kcals = Int(info)!
                    self.kcal.text = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["mins"] as? String {
                    self.initTime = Int(info)!
                    self.time = self.initTime
                    let find = self.number.index(of: info)
                    self.pickerView.selectRow(find!, inComponent: 0, animated: true)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
