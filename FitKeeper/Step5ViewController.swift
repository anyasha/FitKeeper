//
//  Step5ViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class Step5ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveLifestyle(_ lifestyle: String) {
        
        //Обновляем БД
        if let uid = Auth.auth().currentUser?.uid{
            
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/")
            
            let usersReference = ref.child("users").child(uid)
            
            let values = ["lifestyle": lifestyle]
            
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    
                    self.signupErrorAlert(title: "Error!", message: "No internet connection.")
                    return
                }
            })
        }
    }
    
    @IBAction func sedentary(_ sender: Any) {
        saveLifestyle("Sedentary")
    }
    
    @IBAction func lightActive(_ sender: Any) {
        saveLifestyle("LightActive")
    }
    
    @IBAction func moderatelyActive(_ sender: Any) {
        saveLifestyle("ModeratelyActive")
    }
    
    @IBAction func veryActive(_ sender: Any) {
        saveLifestyle("VeryActive")
    }
    
    
    
    func signupErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

    
    
    //Segue to Step5ViewController
    @IBAction func unwindToStep5(storyboard:UIStoryboardSegue){
    }
}
