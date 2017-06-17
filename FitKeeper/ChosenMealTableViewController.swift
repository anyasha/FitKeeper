//
//  ChosenMealTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import PieCharts

class ChosenMealTableViewController: UITableViewController, PieChartDelegate {

    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var header: UINavigationItem!
    @IBOutlet weak var addGrams: UITextField!
    
    var date = ""
    var meal = ""
    var product = String()
    var isAdded = false
    
    var mealInfo = [String: String]()
    var balanceInfo = [String: String]()
    
    
    var age : Int = 0
    var height : Double = 0
    var weight: Double = 0
    var lifestyle : String = ""
    var gender : String = ""
    var kcalNorm : Int = 0
    var kcal : Int = 0
    var proteinNorm : Double = 0
    var carbNorm : Double = 0
    var fatNorm : Double = 0
    

    var carb : Double = 0
    var kcals : Int = 0
    var protein : Double = 0
    var fats : Double = 0
    var gram : Int = 0
    var name : String = ""
    
    var carbAdd : Double = 0
    var kcalAdd : Int = 0
    var proteinAdd : Double = 0
    var fatsAdd : Double = 0
    var gramAdd : Int = 0
    var nameAdd : String = ""
    
    @IBOutlet weak var kcalGramAmount: UITextField!
    @IBOutlet weak var carbsPercent: UITextField!
    @IBOutlet weak var carbsGram: UITextField!
    @IBOutlet weak var proteinPercent: UITextField!
    @IBOutlet weak var proteinGram: UITextField!
    @IBOutlet weak var fatPercent: UITextField!
    @IBOutlet weak var fatGram: UITextField!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var carbsAmount: UITextField!
    @IBOutlet weak var kcalProgress: UIProgressView!
    @IBOutlet weak var proteinAmount: UITextField!
    @IBOutlet weak var proteinProgress: UIProgressView!
    @IBOutlet weak var fatAmount: UITextField!
    @IBOutlet weak var fatProgress: UIProgressView!
    @IBOutlet weak var kcalAmount: UITextField!
    
    override func viewDidLoad() {
        getInfo()
        super.viewDidLoad()
        self.header.title = product
        
        tableView.delegate = self
        tableView.dataSource = self
        self.pieChart.delegate = self
        
        //User Info
        
    
            //Кнопка назад без названия
       // self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: plain, target:nil, action:nil)
    
        self.tableView.tableFooterView = UIView()
    }

    func getAge(_ date: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let bday = dateFormatter.date(from: String(describing: date))
        let today = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: bday!, to: today)
        return Int(ageComponents.year!)
    }

    
    func getInfo() {
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
                
                self.pieChart.models =  [
                    PieSliceModel(value: self.carb, color: UIColor.white.withAlphaComponent(0.8)),
                    PieSliceModel(value: self.protein, color: UIColor.white.withAlphaComponent(0.55)),
                    PieSliceModel(value: self.fats, color: UIColor.white.withAlphaComponent(0.3))
                ]
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
            if self.isAdded == true {
                let dairyRef = ref.child("dairy").child(date).child("meals").child(meal).child("products").child(product)
                dairyRef.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() {  return }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["kcal"] as? String {
                        self.kcalAdd = Int(info)!
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["fats"] as? String {
                        self.fatsAdd = Double(info)!
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["carbs"] as? String {
                        self.carbAdd = Double(info)!
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["proteins"] as? String {
                        self.proteinAdd = Double(info)!
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                        self.nameAdd = info
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["grams"] as? String {
                        self.gramAdd = Int(info)!
                    }
                })
            }
                let prodRef = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("products").child(product)
                prodRef.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() {  return }
                    if let dict = snapshot.value as? NSDictionary, let info =   dict["kcal"] as? String {
                        self.kcals = Int(info)!
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
                    if let dict = snapshot.value as? NSDictionary, let info = dict["portion"] as? String {
                        self.gram = Int(info)!
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["name"] as? String {
                        self.name = info
                    }
                })
            let balanceRef = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("balance")
            balanceRef.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["bday"] as? String {
                    self.balanceInfo["bday"] = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["eaten"] as? String {
                    self.balanceInfo["eaten"] = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["carbs"] as? String {
                    self.balanceInfo["carbs"] = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["fats"] as? String {
                    self.balanceInfo["fats"] = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["proteins"] as? String {
                    self.balanceInfo["proteins"] = info
                }
            })
            let mealRef = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("meals").child(meal).observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() {
                    self.mealInfo["kcal"] = "0"
                    self.mealInfo["grams"] = "0"
                    self.mealInfo["fats"] = "0"
                    self.mealInfo["carbs"] = "0"
                    self.mealInfo["proteins"] = "0"
                    return
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["grams"] as? String {
                    self.mealInfo["grams"] = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["kcal"] as? String {
                    self.mealInfo["kcal"] = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["carbs"] as? String {
                    self.mealInfo["carbs"] = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["fats"] as? String {
                    self.mealInfo["fats"] = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["proteins"] as? String {
                    self.mealInfo["proteins"] = info
                }
            })

        }
    }

    func setValues() {
        if self.age != 0, self.gender != "", self.weight != 0, self.height != 0, self.lifestyle != "" {
            self.kcalNorm = Int(10.0 * self.weight + 6.25 * self.height - 5.0 * Double(age))
            self.kcalNorm -= Int(self.gender == "female" ? 161.0 : -5.0)
            self.kcalNorm  *= Int(self.lifestyle == "Sedentary" ? 1.2 : self.lifestyle == "LightActive" ? 1.375 : self.lifestyle == "ModeratelyActive" ? 1.4625 : 1.550)
            self.carbNorm = self.weight * 1.7
            self.fatNorm = self.gender == "female" ? self.age < 29 ? 103 : 98 : self.age < 29 ? 130 : 125
            self.proteinNorm  = self.lifestyle == "Sedentary" ? 300 : self.lifestyle == "LightActive" ? 400 : 500
        } else {
            self.kcalNorm = 1300
            self.carbNorm = 105
            self.fatNorm = 100
            self.proteinNorm = 400
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func rewrightData() {
        
        self.proteinPercent.text = String(Int((self.protein / self.proteinNorm) * 100)) + "%"
        self.proteinGram.text = String(self.protein) + "g"
        self.carbsPercent.text = String(Int((self.carb / self.carbNorm) * 100)) + "%"
        self.carbsGram.text = String(self.carb) + "g"
        self.fatPercent.text = String(Int((self.fats / self.fatNorm) * 100)) + "%"
        self.fatGram.text = String(self.fats) + "g"
        if self.isAdded != true {
            self.kcalAmount.text = String(self.kcalNorm - self.kcals) + " left"
            self.kcalProgress.setProgress(Float(Float(self.kcals) / Float(self.kcalNorm)), animated: true)
            self.carbsAmount.text = String(self.carbNorm - self.carb) + " left"
            self.carbsProgress.setProgress(Float(Float(self.carb) / Float(self.carbNorm)), animated: true)
            self.fatAmount.text = String(self.fatNorm - self.fats) + " left"
            self.fatProgress.setProgress(Float(Float(self.fats) / Float(self.fatNorm)), animated: true)
            self.proteinAmount.text = String(self.proteinNorm - self.protein) + " left"
            self.proteinProgress.setProgress(Float(Float(self.protein) / Float(self.proteinNorm)), animated: true)
            self.addGrams.text = String(self.gram)
            self.kcalGramAmount.text = String(self.kcals) + " kcal, " + String(self.gram) + " g"
        } else {
            self.kcalAmount.text = String(self.kcalNorm - self.kcalAdd) + " left"
            self.kcalProgress.setProgress(Float(Float(self.kcalAdd) / Float(self.kcalNorm)), animated: true)
            self.carbsAmount.text = String(self.carbNorm - self.carbAdd) + " left"
            self.carbsProgress.setProgress(Float(Float(self.carbAdd) / Float(self.carbNorm)), animated: true)
            self.fatAmount.text = String(self.fatNorm - self.fatsAdd) + " left"
            self.fatProgress.setProgress(Float(Float(self.fatsAdd) / Float(self.fatNorm)), animated: true)
            self.proteinAmount.text = String(self.proteinNorm - self.proteinAdd) + " left"
            self.proteinProgress.setProgress(Float(Float(self.proteinAdd) / Float(self.proteinNorm)), animated: true)
            self.addGrams.text = String(self.gramAdd)
            self.kcalGramAmount.text = String(self.kcalAdd) + " kcal, " + String(self.gramAdd) + " g"
        }
    }
    
    
    @IBAction func addProduct(_ sender: Any) {
        let p = String((Double(addGrams.text!)! * protein) / Double(gram))
        let f = String((Double(addGrams.text!)! * fats) / Double(gram))
        let c = String((Double(addGrams.text!)! * carb) / Double(gram))
        let k = String((Int(addGrams.text!)! * kcals / gram)) //!!!!!!!!!!
        let newVal : [String: String] = ["grams": addGrams.text!,
                      "kcal": k,
                      "carbs": c,
                      "fats": f,
                      "proteins": p,
                      "name": name
            ]
        let childUpdates : [String: [String: String]] = [product: newVal]
        
        self.mealInfo["grams"] = String(Int(self.mealInfo["grams"]!)! + (Int(addGrams.text!)!))
        self.mealInfo["kcal"] = String(Int(self.mealInfo["kcal"]!)! + Int(k)!)
        self.balanceInfo["eaten"] = String(Int(self.balanceInfo["eaten"]!)! + Int(k)!)
        self.mealInfo["carbs"] = String(Double(self.mealInfo["carbs"]!)! + Double(c)!)
        self.balanceInfo["carbs"] = String(Double(self.balanceInfo["carbs"]!)! + Double(c)!)
        self.mealInfo["fats"] = String(Double(self.mealInfo["fats"]!)! + Double(f)!)
        self.balanceInfo["fats"] = String(Double(self.balanceInfo["fats"]!)! + Double(f)!)
        self.mealInfo["proteins"] = String(Double(self.mealInfo["proteins"]!)! + Double(p)!)
        self.balanceInfo["proteins"] = String(Double(self.balanceInfo["proteins"]!)! + Double(p)!)
        self.mealInfo["name"] = self.meal

        if let uid = Auth.auth().currentUser?.uid{
            
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("balance").updateChildValues(balanceInfo)
             Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("meals").child(meal).updateChildValues(mealInfo)
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("meals").child(meal).child("products").updateChildValues(childUpdates)
        }
          dismiss(animated: true, completion: nil)
    }
    
    func onSelected(slice: PieSlice, selected: Bool) {
        //print("Selected: \(selected), slice: \(slice)")
    }
}
