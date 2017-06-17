//
//  Meal.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import PieCharts

class MealViewController: UITableViewController, PieChartDelegate {
    
    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var mealHeader: UINavigationItem!
    @IBOutlet weak var mealLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    
    var meal = String()
    var date  = String()
    var prods = [String]()
    var prodKcal = [String]()
    var prodGram = [String]()
    var prodFats = [String]()
    var prodCarbs = [String]()
    var prodProteins = [String]()
    
    var deleted = [String: String]()
    
    var mealInfo = [String: String]()
    var balanceInfo = [String: String]()
    
    var age : Int = 0
    var height : Double = 0
    var weight: Double = 0
    var lifestyle : String = ""
    var gender : String = ""
    var kcalNorm : Int = 0
    var kcalEaten : Int = 0
    var proteinNorm : Double = 0
    var carbNorm : Double = 0
    var fatNorm : Double = 0
    var carb : Double = 0
    var protein : Double = 0
    var fats : Double = 0
    var gram : Int = 0
    
    var flag = false
    
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
    
    func getAge(_ date: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let bday = dateFormatter.date(from: String(describing: date))
        let today = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: bday!, to: today)
        return Int(ageComponents.year!)
    }
    
//    func getToday() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd MM yyyy"
//        return dateFormatter.string(from: Date())
//    }
    
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
        
            let dairyRef = ref.child("dairy").child(self.date).child("meals").child(meal)
            dairyRef.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() {  return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["kcal"] as? String {
                    self.kcalEaten = Int(info)!
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
                if let dict = snapshot.value as? NSDictionary, let info = dict["grams"] as? String {
                    self.gram = Int(Double(info)!)
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prods.count + 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 1 {
            return 50
        }
        else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func updateDB() {
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").updateChildValues(self.balanceInfo)
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("meals").child(self.meal).updateChildValues(self.mealInfo)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if let uid = Auth.auth().currentUser?.uid{
                let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("meals").child(meal).child("products")
                ref.observe(.value, with: { snapshot in
                    if ( snapshot.value is NSNull ) {
                        print("not found")
                    } else if self.flag == false {
                        prodBreak: for product in snapshot.children {
                            let prodSnap = product as! DataSnapshot
                            let dict = prodSnap.value as! [String: String]
                            if dict["name"] == self.prods[indexPath.row - 2] {
                                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("meals").child(self.meal).child("products").child(dict["name"]!).removeValue()
                                self.mealInfo["grams"] = String(Int(self.mealInfo["grams"]!)! - Int(self.prodGram[indexPath.row - 2])!)
                                self.mealInfo["kcal"] = String(Int(self.mealInfo["kcal"]!)! - Int(self.prodKcal[indexPath.row - 2])!)
                                self.balanceInfo["eaten"] = String(Int(self.balanceInfo["eaten"]!)! - Int(self.prodKcal[indexPath.row - 2])!)
                                self.mealInfo["carbs"] = String(Double(self.mealInfo["carbs"]!)! - Double(self.prodCarbs[indexPath.row - 2])!)
                                self.balanceInfo["carbs"] = String(Double(self.balanceInfo["carbs"]!)! - Double(self.prodCarbs[indexPath.row - 2])!)
                                self.mealInfo["fats"] = String(Double(self.mealInfo["fats"]!)! - Double(self.prodFats[indexPath.row - 2])!)
                                self.balanceInfo["fats"] = String(Double(self.balanceInfo["fats"]!)! - Double(self.prodFats[indexPath.row - 2])!)
                                self.mealInfo["proteins"] = String(Double(self.mealInfo["proteins"]!)! - Double(self.prodProteins[indexPath.row - 2])!)
                                self.balanceInfo["proteins"] = String(Double(self.balanceInfo["proteins"]!)! - Double(self.prodProteins[indexPath.row - 2])!)
                  
                                self.prods.remove(at: indexPath.row - 2)
                                self.prodGram.remove(at: indexPath.row - 2)
                                self.prodKcal.remove(at: indexPath.row - 2)
                                self.prodFats.remove(at: indexPath.row - 2)
                                self.prodCarbs.remove(at: indexPath.row - 2)
                                self.prodProteins.remove(at: indexPath.row - 2)
                                
                                 self.tableView.reloadData()
                                 self.flag = true
                                 return
                            }
                            
                        }
                       
                    } else {
                        self.tableView.reloadData()
                    }
                    self.updateDB()
                    self.flag = false
                    self.tableView.reloadData()
                    self.viewDidLoad()
                    self.viewDidAppear(true)
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "SearchProduct", sender: self.meal )
        } else {
            performSegue(withIdentifier: "ShowProduct", sender: prods[indexPath.row - 2])

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchProduct" {
           let guest  = segue.destination as! SearchMealTableViewController
            guest.meal = meal
            guest.date = date
        } else if segue.identifier == "ShowProduct" {
            let guest = segue.destination as! ChosenMealTableViewController
            guest.meal = meal
            guest.date = date
            guest.product = sender as! String
            guest.isAdded = true
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! CustomTableViewCell
        cell.titleLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
        cell.descriptionLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
        cell.titleLabel?.font = cell.titleLabel?.font.withSize(20)
        if indexPath.row == 0 {
            cell.titleLabel?.text = "Add product"
            cell.titleLabel?.center.y = cell.frame.size.height / 2
//            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.imView?.center.y = cell.frame.size.height / 2
            cell.imView?.image = UIImage(named: "icon_ios_add copy")!
            cell.descriptionLabel?.isHidden = true
        } else if indexPath.row == 1 {
            cell.titleLabel?.font = cell.titleLabel?.font.withSize(18)
            cell.titleLabel?.text = "Products"
            cell.titleLabel?.center.y = cell.frame.size.height / 2
           // cell.titleLabel?.font = cell.titleLabel?.font.withSize(18)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.imView?.image = nil
            cell.descriptionLabel?.text = nil
            cell.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 249/255, alpha: 1)
        } else {
            cell.titleLabel?.text = prods[indexPath.row - 2]
            cell.imView?.image = nil
            cell.descriptionLabel?.text = prodGram[indexPath.row - 2] + "g, " + prodKcal[indexPath.row - 2] + "kcal"
        }
        return cell
    }
    
    override func viewDidLoad() {
    
        self.pieChart.delegate = self
        //User Info
        getUserInfo()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        super.viewDidLoad()
        
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        self.mealHeader.title = meal
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onSelected(slice: PieSlice, selected: Bool) {
        //print("Selected: \(selected), slice: \(slice)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        prodProteins.removeAll()
        prodKcal.removeAll()
        prodGram.removeAll()
        prods.removeAll()
        prodFats.removeAll()
        prodCarbs.removeAll()
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(date).child("meals").child(meal).child("products")
            ref.observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for product in snapshot.children {
                        let prodSnap = product as! DataSnapshot
                        let dict = prodSnap.value as! [String: String]
                        if dict["name"] != nil {
                            self.prods.append(dict["name"]!)
                            self.prodGram.append(dict["grams"]!)
                            self.prodKcal.append(dict["kcal"]!)
                            self.prodFats.append(dict["fats"]!)
                            self.prodCarbs.append(dict["carbs"]!)
                            self.prodProteins.append(dict["proteins"]!)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }

    func rewrightData() {
        self.kcalGramAmount.text = String(self.kcalEaten) + " kcal, " + String(self.gram) + " g"
        self.proteinPercent.text = String(Int((self.protein / self.proteinNorm) * 100)) + "%"
        self.proteinGram.text = String(self.protein) + "g"
        self.carbsPercent.text = String(Int((self.carb / self.carbNorm) * 100)) + "%"
        self.carbsGram.text = String(self.carb) + "g"
        self.fatPercent.text = String(Int((self.fats / self.fatNorm) * 100)) + "%"
        self.fatGram.text = String(self.fats) + "g"
        
        self.kcalAmount.text = String(self.kcalNorm - self.kcalEaten) + " left"
        self.kcalProgress.setProgress(Float(Float(self.kcalEaten) / Float(self.kcalNorm)), animated: true)
        self.carbsAmount.text = String(self.carbNorm - self.carb) + " left"
        self.carbsProgress.setProgress(Float(Float(self.carb) / Float(self.carbNorm)), animated: true)
        self.fatAmount.text = String(self.fatNorm - self.fats) + " left"
        self.fatProgress.setProgress(Float(Float(self.fats) / Float(self.fatNorm)), animated: true)
        self.proteinAmount.text = String(self.proteinNorm - self.protein) + " left"
        self.proteinProgress.setProgress(Float(Float(self.protein) / Float(self.proteinNorm)), animated: true)
    }
    
}
