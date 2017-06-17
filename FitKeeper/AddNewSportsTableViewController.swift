//
//  AddNewSportsTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class AddNewSportsTableViewController: UITableViewController {

    @IBOutlet weak var titleSport: UITextField!
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var kcal: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
       // createToolbar()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewSport(_ sender: UIButton) {
    
        guard titleSport.text != "", time.text != "", kcal.text != ""
            else {
                self.addErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
                return
        }
        
        guard (time.text?.isNumeric)!, (kcal.text?.isNumeric)!
            else {
                self.addErrorAlert(title: "Error!", message: "Only numbers are available.")
                return
        }
        let post = ["name": self.titleSport.text,
                    "mins": self.time.text,
                    "kcal": self.kcal.text]
        let head = self.titleSport.text
        let childUpdates : [String: [String: String]] = [head!: post as! Dictionary<String, String>]
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("activities").updateChildValues(childUpdates)
        dismiss(animated: true, completion: nil)
    }
    
    
    func addErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Try again", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        toolBar.tintColor = .black
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        titleSport.inputAccessoryView = toolBar
        time.inputAccessoryView = toolBar
        kcal.inputAccessoryView = toolBar
    }
   
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //Скрывать клавиатуру, когда пользователь коснется выше неё
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Скрывать клавиатуру, когда пользователь коснется return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return(true)
    }
//
}
