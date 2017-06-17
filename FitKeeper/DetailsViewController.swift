//
//  DetailsViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase

class DetailsViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    var date = ""
    var age : Int = 0
    var height : Double = 0
    var weight: Double = 0
    var lifestyle : String = ""
    var gender : String = ""
    var kcalNorm : Int = 0
    var kcalEaten : Int = 0
    var kcalBurned : Int = 0
    var proteinNorm : Double = 0
    var carbNorm : Double = 0
    var fatNorm : Double = 0
    var waterNorm : Int = 0
    var carb : Double = 0
    var protein : Double = 0
    var fats : Double = 0
    var water : Int = 0
    
    @IBOutlet weak var kcalAmount: UITextField!
    @IBOutlet weak var kcalOval: UIImageView!
    @IBOutlet weak var kcal: UILabel!
    @IBOutlet weak var kcalProgress: UIProgressView!
    @IBOutlet weak var eaten: UILabel!
    @IBOutlet weak var eatenAmount: UITextField!
    @IBOutlet weak var burned: UILabel!
    @IBOutlet weak var burnedAmount: UITextField!
    @IBOutlet weak var carbs: UILabel!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var carbsAmount: UITextField!
    @IBOutlet weak var proteins: UILabel!
    @IBOutlet weak var proteinsProgress: UIProgressView!
    @IBOutlet weak var proteinsAmount: UITextField!
    @IBOutlet weak var fat: UILabel!
    @IBOutlet weak var fatProgress: UIProgressView!
    @IBOutlet weak var fatAmount: UITextField!
    
    @IBOutlet weak var details: UIButton!
    
    @IBOutlet weak var waterAmount: UITextField!
    @IBOutlet weak var waterProgress: UIProgressView!
    
    @IBOutlet weak var stepper: UIStepper!
    
    
    
    func getAge(_ date: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let bday = dateFormatter.date(from: String(describing: date))
        let today = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: bday!, to: today)
        return Int(ageComponents.year!)
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }
    
    func setValues() {
        if self.age != 0, self.gender != "", self.weight != 0, self.height != 0, self.lifestyle != "" {
            self.kcalNorm = Int(10.0 * self.weight + 6.25 * self.height - 5.0 * Double(age))
            self.kcalNorm -= Int(self.gender == "female" ? 161.0 : -5.0)
            self.kcalNorm  *= Int(self.lifestyle == "Sedentary" ? 1.2 : self.lifestyle == "LightActive" ? 1.375 : self.lifestyle == "ModeratelyActive" ? 1.4625 : 1.550)
            self.carbNorm = self.weight * 1.7
            self.fatNorm = self.gender == "female" ? self.age < 29 ? 103 : 98 : self.age < 29 ? 130 : 125
            self.proteinNorm  = self.lifestyle == "Sedentary" ? 300 : self.lifestyle == "LightActive" ? 400 : 500
            self.waterNorm = Int(((self.gender != "female" ? 31.0 : 35.0) * self.weight) / 250.0)
        } else {
            self.kcalNorm = 1300
            self.carbNorm = 105
            self.fatNorm = 100
            self.proteinNorm = 400
            self.waterNorm = 9
        }
        
    }
    
    func getUserInfo() {
        //User Info
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["bday"] as? String {
                    self.age = self.getAge(info)
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["lifestyle"] as? String {
                    self.lifestyle = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["sex"] as? String {
                    self.gender = info
                }
                self.setValues()
                self.rewrightData()
            })
            let parametrsRef = ref.child("parameters")
            parametrsRef.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["height"] as? String {
                    self.height = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["weight"] as? String {
                    self.weight = Double(info)!
                }
            })
            
            let dairyRef = ref.child("dairy").child(getToday()).child("balance")
            dairyRef.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() {  return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["eaten"] as? String {
                    self.kcalEaten = Int(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["burned"] as? String {
                    self.kcalBurned = Int(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["fats"] as? String {
                    self.fats = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["carbs"] as? String {
                    self.carb = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["proteins"] as? String {
                    self.protein = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["water"] as? String {
                    self.water = Int(info)!
                }
            })
            
            
        }
    }
    
    func rewrightData() {
        self.kcalAmount.text = String(self.kcalNorm - self.kcalEaten + self.kcalBurned)
        self.kcalProgress.setProgress(Float(Float(self.kcalEaten) / Float(self.kcalNorm + self.kcalBurned)), animated: true)
        self.eatenAmount.text = String(self.kcalEaten)
        self.burnedAmount.text = String(self.kcalBurned)
        self.carbsAmount.text = String(self.carbNorm - self.carb) + "left"
        self.carbsProgress.setProgress(Float(Float(self.carb) / Float(self.carbNorm)), animated: true)
        self.proteinsAmount.text = String(self.proteinNorm - self.protein) + "left"
        self.fatAmount.text = String(self.fatNorm - self.fats) + "left"
        self.fatProgress.setProgress(Float(Float(self.fats) / Float(self.fatNorm)), animated: true)
        self.waterAmount.text = String(self.water) + (self.water == 1 ? " glass" : " glasses")
        self.waterProgress.setProgress(Float(Float(self.water) / Float(self.waterNorm)), animated: true)
        self.stepper.value = Double(self.water)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Прозрачный  Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        //Скрывающийся navigationBar
        self.navigationController?.hidesBarsOnSwipe = false

        //Календарь
        self.calendar.scope = .week
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        self.calendar.select(dateFormatter.date(from: String(describing: date)), scrollToDate: true)
    }
    

   
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func close(_ sender: Any) {
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.logUser()
    }
}
