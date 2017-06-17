//
//  Step3ViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class Step3ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var tall: String?
    
    let number = ["140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150", "151", "152", "153", "154", "155", "156", "157", "158", "159", "160", "161", "162", "163", "164", "165", "166", "167", "168", "169", "170", "171", "172", "173", "177", "175", "176", "177", "178", "179", "180", "181", "182", "183", "184", "185", "186", "187", "188", "189", "190", "191", "192", "193", "194", "195", "196", "197", "198", "199", "200", "201", "202", "203", "204", "205", "206", "207", "208", "209", "210", "211", "212", "213", "214", "215", "216", "217", "218", "219", "220", "221", "222", "223", "224", "225", "226", "227", "228", "229", "230"]
    
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
            tall = number[row]
        }
    }
    
    @IBAction func update(_ sender: Any) {
        
        save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tall = "140"
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
    }

    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }

    
    func save() {
        if let uid = Auth.auth().currentUser?.uid{
             Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("parameters").updateChildValues(["height": self.tall], withCompletionBlock: { (err, ref) in
                if err != nil {
                    self.signupErrorAlert(title: "Error!", message: "No internet connection!")
                    return
                }
            })
             Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("history").child("height").updateChildValues([self.getToday(): self.tall], withCompletionBlock: { (err, ref) in
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

    //Segue to Step3ViewController
    @IBAction func unwindToStep3(storyboard:UIStoryboardSegue){
    }

}
