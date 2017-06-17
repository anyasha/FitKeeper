//
//  LoginViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    var databaseRef: DatabaseReference!
    
    var gender = ""
    var date = ""
    var tall = ""
    var weight = ""
    var active = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.Username.delegate = self
        self.Password.delegate = self
        
        createToolbar()
    }

    @IBAction func usernameStartTyping(_ sender: UITextField) {
        Username.placeholder = ""
    }
    
    @IBAction func usernameCancelEditing(_ sender: UITextField) {
        Username.placeholder = "Email"
    }
    
    @IBAction func passwordStartTyping(_ sender: UITextField) {
        Password.placeholder = ""
    }
    
    @IBAction func passwordCancelEditing(_ sender: UITextField) {
        Password.placeholder = "Password"
    }

    
    @IBAction func Login(_ sender: Any) {
        
        
        //Проверка на правильность введённых данных
        guard Username.text != "", Password.text != ""
            else {
                self.loginErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
                self.Password.text = ""
                return
        }
        
        
        //1 ----- Вход в приложение.
        
        Auth.auth().signIn(withEmail: Username.text!, password: Password.text!, completion: {
            
            (user, error) in
            
            if error != nil {
                self.loginErrorAlert(title: "Error!", message: "Incorrect login or password. Try again")
                self.Password.text = ""
                
            } else {
                
                            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDel.logUser()
                        }
                    })
                }
    
    func loginErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Try again", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //Кнопка Done которая прячет клавиатуру
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        toolBar.tintColor = .black
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        Username.inputAccessoryView = toolBar
        Password.inputAccessoryView = toolBar
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
    
    //Segue to LoginViewController
    @IBAction func unwindToLogin(storyboard:UIStoryboardSegue){
    }
}
