//
//  AddParameterViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//


import UIKit
import Firebase
import SwiftChart

class ProfileChartsViewController: UIViewController, ChartDelegate {
    
    var tag = 0
    var values = [(String, String)]()
    var currMonth = [(String, String)]()
    var monthNum = ""
    var monthTxt = ""
    //var minMonth = ""
    
    
    var data = [(x: Float, y: Float)]()
    
    @IBOutlet weak var parameterLabel: UILabel!
    @IBOutlet weak var currentParameter: UILabel!
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var currentMonth: UILabel!
   
    @IBOutlet weak var prevB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    
    let vocabulary = ["Height", "Weight", "Chest girth", "Waist girth", "Hip girth"]
    let voc = ["height", "weight", "chest", "waist", "hip"]
    
    let monthes = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let monthesDates = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chart.delegate = self
        getUserInfo()
        self.nextB.isEnabled = false
        self.nextB.isHidden = true
        
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }
   
    func getMonthes(_ num: String) {
        self.monthNum = num
        self.monthTxt = self.monthes[Int(num)! - 1]
        self.currMonth.removeAll()
        self.currentMonth.text = self.monthTxt
        var prev = ("", "")
        var next = ("", "")
        for m in values {
            if isCurrMonth(m.0, self.monthNum) {
                self.currMonth.append(m)
            } else if isPrevMonth(m.0, self.monthNum) {
                if prev.0 == "" {
                   prev = m
                }
                if prev.0 < m.0 {
                    prev = m
                }
            } else if isNextMonth(m.0, self.monthNum) {
                if next.0 == "" {
                    next = m
                }
                if next.0 > m.0 {
                    next = m
                }
            }
        }
        if prev.0 != ""{
            if self.currMonth.count > 1 {
                self.currMonth.sort(by: { Int(self.day($0.0))! < Int(self.day($1.0))!})
                if self.currMonth[0].0 != addDate(true, monthNum) {
                    self.currMonth.append((addDate(true, monthNum), prev.1))
                }
            }
            else {
                self.currMonth.append((addDate(true, monthNum), prev.1))
            }
        }
        if next.0 != "" {
            if self.currMonth.count > 1 {
                self.currMonth.sort(by: { Int(self.day($0.0))! > Int(self.day($1.0))!})
                if self.currMonth[0].0 != addDate(true, monthNum) {
                    self.currMonth.append((addDate(false, monthNum), next.1))
                }
            }
            else {
                self.currMonth.append((addDate(false, monthNum), next.1))
            }
        }
        if self.currMonth.count > 1 && ((self.currMonth.count == 1 && self.isCurrMonth(getToday(), self.monthNum) == false) || (next.0 == "" && self.isCurrMonth(getToday(), self.monthNum) == false)) {
            self.currMonth.append((addDate(false, monthNum), self.currMonth[0].1))
        }
        if self.currMonth.count > 1 && (prev.0 == "" && self.isCurrMonth(getToday(), self.monthNum) == false) {
            self.currMonth.append((addDate(true, monthNum), self.currMonth[0].1))
        }
        createChart()
        self.view.setNeedsDisplay()
        self.view.reloadInputViews()
    }
    
    
    func addDate(_ isFirst: Bool, _ month: String) -> String {
        let day = isFirst == true ? "01" : String(self.monthesDates[Int(month)! - 1])
        let mo = Int(month)! < 10 ? "0" + String(describing: Int(month)!) : String(describing: Int(month)!)
        return  day + " " + mo + " 2017"
    }
    
    func isCurrMonth(_ date: String, _ month: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let mo = dateFormatter.date(from: String(describing: date))
        let calendar = Calendar.current
        let mnth = calendar.component(.month, from: mo!)
        if Int(String(mnth)) == Int(month) {
            return true
        } else {
            return false
        }
    }
    func isPrevMonth(_ date: String, _ month: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let mo = dateFormatter.date(from: String(describing: date))
        let calendar = Calendar.current
        let mnth = calendar.component(.month, from: mo!)
        if Int(String(mnth))! == Int(month)! - 1 {
            return true
        } else {
            return false
        }
    }
    
    func isNextMonth(_ date: String, _ month: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let mo = dateFormatter.date(from: String(describing: date))
        let calendar = Calendar.current
        let mnth = calendar.component(.month, from: mo!)
        if Int(String(mnth))! == Int(month)! + 1 {
            return true
        } else {
            return false
        }
    }
    
    func getMinMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        var minMonth = dateFormatter.string(from: Date())
        
        for m in values {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "dd MM yyyy"
            let dd = dateFormatter1.date(from: String(describing: m.0))
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "MM"
            let curMnth = dateFormatter2.string(from: dd!)
            if Int(minMonth)! > Int (curMnth)! {
                minMonth = curMnth
            }
        }
        return minMonth
    }
    
    func getMinParameter() -> Int {
        var min = 300
        for p in currMonth {
            if Int(p.1)! < min {
                min = Int(p.1)!
            }
        }
        return min
    }
    
    func getMaxParameter() -> Int {
        var max = 0
        for p in currMonth {
            if Int(p.1)! > max {
                max = Int(p.1)!
            }
        }
        return max
    }

    
//    func getToday() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd MM yyyy"
//        return dateFormatter.string(from: Date())
//    }
    
    func getCurrentMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: Date())
    }
    
    func getMnth(_ date: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let dd = dateFormatter.date(from: String(describing: date))

        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MM"
        return Int(dateFormatter1.string(from: dd!))!
    }

    
    func getWeightNorm() -> Float {
        var gender = "male"
        var height : Float = 0.0
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["sex"] as? String {
                    gender = info
                }
            })
            let parametrsRef = ref.child("parameters")
            parametrsRef.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["height"] as? String {
                    height = Float(info)!
                }
            })
        }
        if height == 0 {
            return 0
        }
        return (height - 100 - ((height - 10) / (gender == "female" ? 10 : 20)))
    }

    func getUserInfo() {
        if let uid = Auth.auth().currentUser?.uid{
            var ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("history").child(self.voc[self.tag])
            ref.observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        let name = child.key
                        if let date = child.key as? String, let val = child.value as? String {
                            self.values.append((date,val))
                        }
                    }
//                    if self.values.count > 1 {
//                        self.values.sorted(by: { self.getMnth($0.0) > self.getMnth($1.1) } )
//                    }
                    self.monthNum = self.getCurrentMonth()
                    self.getMonthes(self.monthNum)
                    
                }
            })
            ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("parameters")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict[self.voc[self.tag]] as? String {
                    self.currentParameter.text = self.currentParameter.text! + self.vocabulary[self.tag] + ":"
                    self.parameterLabel.text = info
                }
            })
            
        }
    }
    
    @IBAction func prevMonth(_ sender: UIButton) {
        if Int(self.getMinMonth())! == Int(self.monthNum)! - 1 {
            self.prevB.isHidden = true
            self.prevB.isEnabled = false
        }
        if Int(self.getMinMonth())! < Int(self.monthNum)! {
            self.nextB.isHidden = false
            self.nextB.isEnabled = true
            self.monthNum = Int(self.monthNum)! > 1 ? String(Int(self.monthNum)! - 1) : "12"
            self.getMonthes(self.monthNum)
        }
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
    
        if Int(self.getCurrentMonth())! == Int(self.monthNum)! + 1 {
            self.nextB.isHidden = true
            self.nextB.isEnabled = false
        }
        if Int(self.getCurrentMonth())! > Int(self.monthNum)! {
            self.prevB.isHidden = false
            self.prevB.isEnabled = true
            self.monthNum = Int(self.monthNum)! < 12 ? String(Int(self.monthNum)! + 1) : "01"

            self.getMonthes(self.monthNum)
        }
    }
    
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
    }
    
    func didEndTouchingChart(_ chart: Chart) {
    }
    
    func day(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let d = dateFormatter.date(from: String(describing: date))
        let calendar = Calendar.current
        return String(calendar.component(.day, from: d!))
    }
    

    func createChart() {
        chart.labelFont = UIFont(name: "Avenir", size: 12)
        self.chart.removeAllSeries()
        self.data.removeAll()
        chart.areaAlphaComponent = 0.3
        self.chart.minX = Float(1)
        self.chart.maxX = Float(self.monthesDates[Int(self.monthNum)! - 1])

        var xLa = [Float]()
        xLa.append(1.0)
        for i in 1...self.monthesDates[Int(self.monthNum)! - 1] {
            xLa.append(Float(i))
        }
        chart.xLabels = xLa
        chart.xLabelsOrientation = ChartLabelOrientation.vertical
        chart.xLabelsFormatter = { String(Int(round($1)))}
        var yLa = [Float]()
        if self.currMonth.isEmpty == false {
            for i in (getMinParameter() - 3) ... (getMaxParameter() + 3) {
                yLa.append(Float(i))
            }
        }
        chart.yLabels = yLa
        if self.currMonth.isEmpty == false {
            self.chart.minY = Float(getMinParameter() - 3)
            self.chart.maxY = Float(getMaxParameter() - 3)
        }
        chart.yLabelsFormatter = { String(Int(round($1))) + (self.tag == 0 ? " cm" : " kg") }
        
        if self.currMonth.isEmpty {
            self.data.append((x: 0, y: 0))
            self.data.append((x: 0, y: 0))
        } else {
            self.currMonth.sort(by: { Int(self.day($0.0))! < Int(self.day($1.0))!})
            if  self.currMonth.count == 1 {
                 self.data.append((x: Float(Int(self.day(self.currMonth[0].0))! - 1), y: Float(self.currMonth[0].1)!))
            }
            for (x,y) in self.currMonth {
                let range = Int(self.day(x))
                self.data.append((x: Float(self.day(x))!, y: Float(y)!))
            }
            if  self.currMonth.count == 1 {
                self.data.append((x: Float(Int(self.day(self.currMonth[0].0))! + 1), y: Float(self.currMonth[0].1)!))
            }
        }
        xLa.append(Float(self.monthesDates[Int(self.monthNum)! - 1]))
        chart.xLabels = xLa
        let series = ChartSeries(data: data)
        series.area = true
        if tag == 1 {
            var gender = "male"
            var height : Float = 0.0
            if let uid = Auth.auth().currentUser?.uid{
                let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid)
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() { return }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["sex"] as? String {
                        gender = info
                        series.colors = (above: ChartColors.blueColor(), below: ChartColors.greenColor(), (height - 100 - ((height - 10) / (gender == "female" ? 10 : 20))))
                         self.chart.add(series)
                    }
                })
                let parametrsRef = ref.child("parameters")
                parametrsRef.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() { return }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["height"] as? String {
                        height = Float(info)!
                        series.colors = (above: ChartColors.blueColor(), below: ChartColors.greenColor(), (height - 100 - ((height - 10) / (gender == "female" ? 10 : 20))))
                    }
                })
            }
        } else {
            chart.add(series)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
