//
//  AddNewMealTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class AddNewMealTableViewController: UITableViewController {

    @IBOutlet weak var titleProd: UITextField!
    @IBOutlet weak var portion: UITextField!
    @IBOutlet weak var kcal: UITextField!
    @IBOutlet weak var carbs: UITextField!
    @IBOutlet weak var protein: UITextField!
    @IBOutlet weak var Fat: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createToolbar()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addnewProd(_ sender: UIButton) {
        
        
        guard titleProd.text != "", portion.text != "", kcal.text != "", carbs.text != "", protein.text != "", Fat.text != ""
            else {
                self.addErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
                return
        }
        
        guard (portion.text?.isNumeric)!, (kcal.text?.isNumeric)!, (carbs.text?.isNumeric)!, (protein.text?.isNumeric)!, (Fat.text?.isNumeric)!
            else {
                self.addErrorAlert(title: "Error!", message: "Only numbers are available.")
                return
        }
        let post = ["name": self.titleProd.text,
                    "portion": self.portion.text,
                    "kcal": self.kcal.text,
                    "carbs": self.carbs.text,
                    "protein": self.protein.text,
                    "fat": self.Fat.text]
        let head = self.titleProd.text
        let childUpdates : [String: [String: String]] = [head!: post as! Dictionary<String, String>]
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("products").updateChildValues(childUpdates)
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
        
        titleProd.inputAccessoryView = toolBar
        portion.inputAccessoryView = toolBar
        kcal.inputAccessoryView = toolBar
        carbs.inputAccessoryView = toolBar
        protein.inputAccessoryView = toolBar
        Fat.inputAccessoryView = toolBar
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

}


extension String {
    var isNumeric: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}
