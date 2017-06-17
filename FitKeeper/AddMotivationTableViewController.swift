//
//  AddMotivationTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class AddMotivationTableViewController: UITableViewController {
    
    var date = ""
    var marathone = ""
        var time = ""
    
 
    @IBOutlet weak var textF: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
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
                    }
                })
            }
        }
        
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    
    func getTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        return (String(calendar.component(.hour, from: date)) + " " + String(calendar.component(.minute, from: date)) + " " + String(calendar.component(.second, from: date)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
        
    }
    
    @IBAction func add(_ sender: UIButton) {
        AppDelegate.instance().showActivityIndicator()
        if self.textF.text != "" {
            let txt = self.textF.text
            if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(marathone).child(self.date).updateChildValues( [ self.time.trimmingCharacters(in: .whitespaces) :
                ["type" : "motivation",
                "time" : self.time,
                "text" : txt ]])
            }
            AppDelegate.instance().dismissActivityIndicators()
            _ = navigationController?.popViewController(animated: true)
           // self.dismiss(animated: true, completion: nil)
        } else {
            self.signupErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
            //послезагрузки изображения индикатор исчезнет
            AppDelegate.instance().dismissActivityIndicators()
            return
        }
        _ = navigationController?.popViewController(animated: true)
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
