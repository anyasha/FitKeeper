//
//  AddParameterTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class AddParameterTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var date = ""
    var marathone = ""
    
    var text = ""
    var time = ""
    
    let lifestyles = ["weight", "hip", "waist", "chest"]
     @IBOutlet weak var lifestylePicker: UIPickerView!
    var parameter = "weight"
    
    @IBOutlet weak var titleF: UITextField!
    @IBOutlet weak var textF: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lifestylePicker.dataSource = self
        self.lifestylePicker.delegate = self

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
         self.navigationController?.hidesBarsOnSwipe = false
        
        if time == "" {
            time = getTime()
        } else {
            if let uid = Auth.auth().currentUser?.uid{
                let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).child(self.date).child(self.time.trimmingCharacters(in: .whitespaces))
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if ( snapshot.value is NSNull ) {
                        print("not found")
                    } else {
                        if let dict = snapshot.value as? NSDictionary, let info = dict["text"] as? String {
                            self.textF.text = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                            self.titleF.text = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["value"] as? String {
                            self.parameter = info
                            self.lifestylePicker.selectRow(self.lifestyles.index(of: self.parameter)!, inComponent: 0, animated: true)
                        }
                        
                    }
                })
            }
        }
        
        
        //Кнопка назад без названия
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return lifestyles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return lifestyles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if lifestyles[row] != nil {
            self.parameter = lifestyles[row]
        }
    }
    
    
    func getTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        return (String(calendar.component(.hour, from: date)) + " " + String(calendar.component(.minute, from: date)) + " " + String(calendar.component(.second, from: date)))
    }
    
    @IBAction func add(_ sender: UIButton) {
        AppDelegate.instance().showActivityIndicator()
        if self.textF.text != "" && self.titleF.text != ""{
            let txt = self.textF.text
            let ttl = self.titleF.text
            if let uid = Auth.auth().currentUser?.uid{
                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(marathone).child(self.date).updateChildValues( [ self.time.trimmingCharacters(in: .whitespaces) :
                    ["type" : "parameter",
                     "title" : ttl,
                     "value" : self.parameter,
                     "time" : self.time,
                     "text" : txt ]])
            }
            AppDelegate.instance().dismissActivityIndicators()
            self.dismiss(animated: true, completion: nil)
        } else {
            self.signupErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
            //послезагрузки изображения индикатор исчезнет
            AppDelegate.instance().dismissActivityIndicators()
            return
        }
    }
    
    func signupErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
