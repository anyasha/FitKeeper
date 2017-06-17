//
//  Step1ViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class Step1ViewController: UIViewController {

    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    
    //Пользователь выбрал male
    @IBAction func male(_ sender: Any) {
     
        if let uid = Auth.auth().currentUser?.uid {
        
        //Записываем в БД gender
        let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/")
                
        let usersReference = ref.child("users").child(uid)
                
        let values = ["sex": "male"]
                
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
            if err != nil {
         
                self.signupErrorAlert(title: "Error!", message: "No internet connection!")
                return
            }
        })
        }
    }
    
    //Пользователь выбрал female
    @IBAction func female(_ sender: Any) {
        
        if let uid = Auth.auth().currentUser?.uid {
        
        //Записываем в БД gender
        let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/")
        
        let usersReference = ref.child("users").child(uid)
        
        let values = ["sex": "female"]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                
                self.signupErrorAlert(title: "Error!", message: "No internet connection!")
                return
            }
        })
            
            let par = ["hip": "0",
            "waist" : "0",
            "chest" : "0"]
            usersReference.child("parameters").updateChildValues(par, withCompletionBlock: { (err, ref) in
                
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

    

    //Segue to Step1ViewController
    @IBAction func unwindToStep1(storyboard:UIStoryboardSegue){
    }
}
