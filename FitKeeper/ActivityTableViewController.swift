//
//  ActivityTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase
import HealthKit

class ActivityTableViewController: UITableViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    //var date = String()
    var date : String = "" {
        didSet {
            createNewPost()
            viewWillAppear(true)
            viewDidAppear(true)
        }
    }
    
    let healthStore: HKHealthStore = HKHealthStore()
    
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
    var steps : Int = 0
    var stepsBurned : Int = 0
    var distance : Int = 0
    
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
    
    @IBOutlet weak var StepsLabel: UILabel!
    @IBOutlet weak var details: UIButton!
    
    @IBOutlet weak var waterAmount: UITextField!
    @IBOutlet weak var waterProgress: UIProgressView!
    @IBOutlet weak var stepsProgress: UIProgressView!
    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var mainView: UIView!
    
    func calendar(_ calendar: FSCalendar!, didSelect date: Date!) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        self.date = dateFormatter.string(from: date as Date)
    }
    
    func calendar(_ calendar: FSCalendar!, shouldSelectDate date: Date!) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let end = dateFormatter.date(from: self.getToday())
        //Calendar.current.date(byAdding: .day, value: (7 * Int(self.period)!), to: start!)
        if dateFormatter.date(from: dateFormatter.string(from: date as Date))! <= end! {
            return true
        }
        self.signupErrorAlert(title: "Error!", message: "You could not fill in future days.")
        return false
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
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         age = 0
         height = 0
         weight = 0
         lifestyle = ""
         gender = ""
         kcalNorm = 0
         kcalEaten = 0
         kcalBurned = 0
         proteinNorm = 0
         carbNorm = 0
         fatNorm = 0
         waterNorm = 0
         carb = 0
         protein = 0
         fats = 0
         water = 0
         steps = 0
         stepsBurned = 0
         distance = 0

        self.getSteps()
        self.getUserInfo()
       // self.getSteps()
        self.mainView.reloadInputViews()
        //reloadData()
        self.mainView.setNeedsDisplay()
        self.view.setNeedsDisplay()
        self.tableView.reloadData()
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
            
            let dairyRef = ref.child("dairy").child(self.date).child("balance")
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
        self.kcalAmount.text = String(self.kcalNorm - self.kcalEaten + self.kcalBurned + self.stepsBurned)
        self.kcalProgress.setProgress(Float(Float(self.kcalEaten) / Float(self.kcalNorm + self.kcalBurned)), animated: true)
        self.eatenAmount.text = String(self.kcalEaten)
        self.burnedAmount.text = String(self.kcalBurned + self.stepsBurned)
        self.carbsAmount.text = String(self.carbNorm - self.carb) + "left"
        self.carbsProgress.setProgress(Float(Float(self.carb) / Float(self.carbNorm)), animated: true)
        self.proteinsAmount.text = String(self.proteinNorm - self.protein) + "left"
        self.proteinsProgress.setProgress(Float(Float(self.protein) / Float(self.proteinNorm)), animated: true)
        self.fatAmount.text = String(self.fatNorm - self.fats) + "left"
        self.fatProgress.setProgress(Float(Float(self.fats) / Float(self.fatNorm)), animated: true)
        self.waterAmount.text = String(self.water) + (self.water == 1 ? " glass" : " glasses")
        self.waterProgress.setProgress(Float(Float(self.water) / Float(self.waterNorm)), animated: true)
        self.stepper.value = Double(self.water)
        self.StepsLabel.text  = String(self.steps) + " steps, " + String(self.distance) + " meters, " + String(self.stepsBurned) + " kcal"
        let a = Float(self.steps) / 10000.0
        //a < 0.1 ? 0.1 : a
        self.stepsProgress.setProgress(Float(Float(self.steps) / 10000.0), animated: true)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Календарь
        
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.scope = .week
        self.calendar.firstWeekday = 2
        
        self.navigationController?.hidesBarsOnSwipe = true
        //Прозрачный  Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        //Скрывающийся navigationBar
        self.navigationController?.hidesBarsOnSwipe = true
        
        self.date = getToday()
        getUserInfo()
        createNewPost()
        
        
    }
    
    //override func viewDidAppear(_ animated: Bool) {
    func getSteps() {
        self.steps = 0
        var readTypes = Set<HKObjectType>()
        readTypes.insert(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
        readTypes.insert(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        
        healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: readTypes) { (success, error) -> Void in
            if success {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MM yyyy"
                let startDate = dateFormatter.date(from: String(describing: self.date))
                let endDate = Calendar.current.date(byAdding: .day, value: +1, to: startDate!)
                
                
                //  Set the Predicates & Interval
                let predicate = HKQuery.predicateForSamples(withStart: startDate , end: endDate, options: .strictStartDate)
                let interval: NSDateComponents = NSDateComponents()
                interval.day = 1
                
                let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
                //  Perform the Query
                let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: endDate!, intervalComponents:interval as DateComponents)
                query.initialResultsHandler = { query, results, error in
                    if error != nil {
                        return
                    }
                    if let myResults = results{
                        myResults.enumerateStatistics(from: startDate!, to: endDate!) {
                            statistics, stop in
                            if let quantity = statistics.sumQuantity() {
                                self.steps = Int(quantity.doubleValue(for: HKUnit.count()))
                                var h = 0.0
                                var w = 0.0
                                var k = 0
                                if let uid = Auth.auth().currentUser?.uid{
                                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("parameters").observeSingleEvent(of: .value, with: { snapshot in
                                        if !snapshot.exists() { return }
//                                        if let dict = snapshot.value as? NSDictionary, let info = dict["height"] as? String {
//                                            h = Double(info)!
//                                            
//                                            //self.rewrightData()
//                                        }
                                        if let dict = snapshot.value as? NSDictionary, let info = dict["weight"] as? String {
                                            w = Double(info)!
                                           // let a = Int((0.035 * w) + ((pow(1.5, 2) / (h / 100.0)) * 0.029 * w))
                                            self.stepsBurned = Int(( Double(self.distance) / 83.0 ) * 0.07 * w)
                                            
//                                            let values = ["steps" : String(self.steps),
//                                                          "distance" : String(self.distance),
//                                                          "stepsBurned" : String(self.stepsBurned)]
//                                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").updateChildValues(values)
                                           // let values = ["steps" : String(self.steps),
                                                       //   "distance" : String(self.distance),
                                                       //   "stepsBurned" : String(self.stepsBurned)]
                                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").updateChildValues(["steps" : String(self.steps)])
                                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").updateChildValues(["distance" : String(self.distance)])
                                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").updateChildValues(["stepsBurned" : String(self.stepsBurned)])
                                            self.StepsLabel.text  = String(self.steps) + " steps," + String(self.distance) + " meters, " + String(self.stepsBurned) + " kcal"
                                        }
                                    })
                                    
                                }
                            }
                        }
                    }
                }
                self.healthStore.execute(query)
                let distance = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
                let query1 = HKStatisticsCollectionQuery(quantityType: distance!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: endDate!, intervalComponents:interval as DateComponents)
                query1.initialResultsHandler = { query1, results, error in
                    if error != nil {
                        return
                    }
                    if let myResults = results {
                        myResults.enumerateStatistics(from: startDate!, to: endDate!) {
                            statistics, stop in
                            if let quantity = statistics.sumQuantity() {
                                self.distance = Int(quantity.doubleValue(for: HKUnit.meter()))
                            }
                        }
                    }
                }
                
                self.healthStore.execute(query1)
//                if let uid = Auth.auth().currentUser?.uid{
//                            let form = 0 + (0.035 * self.weight) + ((pow(1.5, 2) / (self.height / 100)) * 0.029 * self.weight)
//                            let kc = Int(self.kcalBurned) + Int(form)
//                            let values = ["steps" : String(self.steps),
//                                          "distance" : String(self.distance),
//                                          "burned" : String(kc)]
//                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").updateChildValues(values)
//                    self.tableView.reloadData()
//                    self.StepsLabel.text  = String(self.steps) + " steps," + String(self.distance) + " meters"
//                }
                //self.viewWillAppear(false)
               // self.tableView.reloadData()
                //self.StepsLabel.text  = String(self.steps) + " steps," + String(self.distance) + " meters"
                
            } else {
                print("failure")
            }
            if let error = error { print(error) }
        }
    }
    
    @IBAction func calendarClicked(sender: AnyObject) {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
            self.kcalAmount.isHidden = false
            self.kcalOval.isHidden = false
            self.kcal.isHidden = false
            self.kcalProgress.isHidden = false
            self.eaten.isHidden = false
            self.eatenAmount.isHidden = false
            self.burned.isHidden = false
            self.burnedAmount.isHidden = false
            self.carbs.isHidden = false
            self.carbsProgress.isHidden = false
            self.carbsAmount.isHidden = false
            self.proteins.isHidden = false
            self.proteinsProgress.isHidden = false
            self.proteinsAmount.isHidden = false
            self.fatProgress.isHidden = false
            self.fatAmount.isHidden = false
            self.fat.isHidden = false
            self.details.isHidden = false
        } else {
            self.calendar.setScope(.month, animated: true)
            self.kcalAmount.isHidden = true
            self.kcalOval.isHidden = true
            self.kcal.isHidden = true
            self.kcalProgress.isHidden = true
            self.eaten.isHidden = true
            self.eatenAmount.isHidden = true
            self.burned.isHidden = true
            self.burnedAmount.isHidden = true
            self.carbs.isHidden = true
            self.carbsProgress.isHidden = true
            self.carbsAmount.isHidden = true
            self.proteins.isHidden = true
            self.proteinsProgress.isHidden = true
            self.proteinsAmount.isHidden = true
            self.fatProgress.isHidden = true
            self.fatAmount.isHidden = true
            self.fat.isHidden = true
            self.details.isHidden = true
        }
    }
    
    
    
    func createNewPost() {
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").child("burned")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() {
                    if let uid = Auth.auth().currentUser?.uid{
                        let post = ["balance": ["burned": "0",
                                                "carbs": "0",
                                                "eaten" : "0",
                                                "fats" : "0",
                                                "steps" : "0",
                                                "distance" : "0",
                                                "proteins" : "0",
                                                "water": "0"]]
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).updateChildValues(post)
                    }
                }
            })
        }
    }
    
    @IBAction func step(_ sender: UIStepper) {
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("dairy").child(self.date).child("balance").updateChildValues(["water": String(Int(sender.value))])
        }
        self.water = Int(sender.value)
        self.waterProgress.setProgress(Float(Float(self.water) / Float(self.waterNorm)), animated: true)
        self.waterAmount.text = String(self.water) + (self.water == 1 ? " glass" : " glasses")
    }
    
    @IBAction func details(_ sender: Any) {
        //performSegue(withIdentifier: "DetailsSegue", sender: getToday())
        //        let DetailsViewController = self.storyboard!.instantiateViewController(withIdentifier: "Details")
        //        UIApplication.shared.keyWindow?.rootViewController = DetailsViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Meal" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! LogMealTableViewController
            guest.date = self.date
            
        }
        if segue.identifier == "SearchSports" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! SearchActivityTableViewController
            guest.date = self.date
        }
        if segue.identifier == "TodaysActivities" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! TodaysActivitiesTableViewController
            guest.date = self.date
        }
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
    
    //Segue to ActivityTableViewController
    @IBAction func unwindToActivity(storyboard:UIStoryboardSegue){
    }
    //Segue to ActivityTableViewController1
    @IBAction func unwindToActivity1(storyboard:UIStoryboardSegue){
    }
}
