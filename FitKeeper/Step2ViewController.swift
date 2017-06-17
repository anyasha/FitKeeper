//
//  Step2ViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class Step2ViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func update(_ sender: Any) {
        //обновляем БД
        save()
    }
    
    
    func save() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "dd MM yyyy"
        
        if let uid = Auth.auth().currentUser?.uid {
        
        let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/")
        
        let usersReference = ref.child("users").child(uid)
        let values = ["bday": dateFormatter.string(from: self.datePicker
            .date)]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                
                self.signupErrorAlert(title: "Error!", message: "No internet connection!")
                return
            }
            })
        }
 
    }
    
    
    func signupErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Segue to Step2ViewController
    @IBAction func unwindToStep2(storyboard:UIStoryboardSegue){
    }
}
