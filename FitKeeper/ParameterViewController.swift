//
//  ParameterViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class ParameterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    var marathone = ""
    var date = ""
    var time = ""
    
    var titleE = ""
    var photoURL = ""
    var isUsed = false
    var parameter = "hip"
    
    var currParameter = "60"
    
    let voc = ["weight" : ["40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "77", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120", "121", "122", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "134", "135", "136", "137", "138", "139", "140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150", "151", "152", "153", "154", "155", "156", "157", "158", "159", "160", "161", "162", "163", "164", "165", "166", "167", "168", "169", "170", "171", "172", "173", "177", "175", "176", "177", "178", "179", "180", "181", "182", "183", "184", "185", "186", "187", "188", "189", "190", "191", "192", "193", "194", "195", "196", "197", "198", "199", "200", "201", "202", "203", "204", "205", "206", "207", "208", "209", "210", "211", "212", "213", "214", "215", "216", "217", "218", "219", "220", "221", "222", "223", "224", "225", "226", "227", "228", "229", "230", "231", "232", "233", "234", "235", "236", "237", "238", "239", "240", "241", "242", "243", "244", "245", "246", "247", "248", "249", "250", "251", "252", "253", "254", "255", "256", "257", "258", "259", "260", "261", "262", "263", "264", "265", "266", "267", "268", "269", "270", "271", "272", "273", "277", "275", "276", "277", "278", "279", "280", "281", "282", "283", "284", "285", "286", "287", "288", "289", "290", "291", "292", "293", "294", "295", "296", "297", "298", "299", "300"],
        "chest" : ["40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "77", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120", "121", "122", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "134", "135", "136", "137", "138", "139", "140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150"],
        "waist" : ["40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "77", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120", "121", "122", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "134", "135", "136", "137", "138", "139", "140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150"],
        "hip" : ["40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "77", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120", "121", "122", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "134", "135", "136", "137", "138", "139", "140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150"]]
    
    @IBOutlet weak var header: UINavigationItem!
    @IBOutlet weak var exercise: UILabel!
    @IBOutlet weak var text: UITextView!
    
    @IBOutlet weak var addParameter: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        self.header.title = marathone
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self

        
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).child(self.date).child(self.time.trimmingCharacters(in: .whitespaces))
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    if let dict = snapshot.value as? NSDictionary, let info = dict["text"] as? String {
                        self.text.text = info
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                        self.exercise.text = info
                        self.titleE = info
                    }
                    if let dict = snapshot.value as? NSDictionary, let info = dict["value"] as? String {
                        self.parameter = info
                        self.addParameter.text = "ADD YOUR " + self.parameter.uppercased() + " PARAMETER"
                        let parametrsRef = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("parameters")
                        parametrsRef.observeSingleEvent(of: .value, with: { snapshot in
                            if !snapshot.exists() { return }
                            if let dict = snapshot.value as? NSDictionary, let info = dict[self.parameter] as? String {
                                self.currParameter = info
                                let find = self.voc.keys.index(of: self.parameter)
                                let findParam = self.voc[find!].value.index(of: self.currParameter)
                                self.pickerView.selectRow(findParam!, inComponent: 0, animated: true)
                            }
                        })
                    }
                }
            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.voc[self.parameter]?[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return self.voc[self.parameter]!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if self.voc[self.parameter]?[row] != nil {
            self.currParameter = (self.voc[self.parameter]?[row])!
        }
        
    }
    
    @IBAction func add(_ sender: UIButton) {
        if isUsed == false {
            if let uid = Auth.auth().currentUser?.uid{
                let val = compareDates(self.getToday(), self.date) == true ? "intime" : "overdue"
                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child(date).updateChildValues([self.time : val])
                
                var tasks = 0
                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() {  return }
                    if self.compareDates(self.getToday(), self.date) == true {
                        if let dict = snapshot.value as? NSDictionary, let info = dict["intimeTasks"] as? String {
                            tasks = Int(info)! + 1
                        }
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").updateChildValues(["intimeTasks" : String(tasks)])
                    } else {
                        if let dict = snapshot.value as? NSDictionary, let info = dict["overdueTasks"] as? String {
                            tasks = Int(info)! + 1
                        }
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").updateChildValues(["overdueTasks" : String(tasks)])
                    }
                })
                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").observeSingleEvent(of: .value, with: { snapshot in
                    if ( snapshot.value is NSNull ) {
                        return
                    } else {
                        if let dict = snapshot.value as? NSDictionary, let info = dict[self.parameter + "Init"] as? String, info == "0" {
                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").updateChildValues([self.parameter + "Init" : self.currParameter])
                        } else if let dict = snapshot.value as? NSDictionary, let info = dict[self.parameter + "Init"] as? String, info != "0" {
                            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").updateChildValues([self.parameter + "Last" : self.currParameter])
                        }
                    }
                })
                
                var values = [self.parameter : self.currParameter]
                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("parameters").updateChildValues(values)
                values = [getToday(): self.currParameter]
                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("history").child(self.parameter).updateChildValues(values)
                //navigationController?.popViewController(animated: true)
               // dismiss(animated: true, completion: nil)
                values = [self.time.trimmingCharacters(in: .whitespaces) : self.currParameter]
                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("parameters").child(self.parameter).updateChildValues(values)
                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
        //_ = navigationController?.popViewController(animated: true)
    }
    
    func compareDates(_ date1: String, _ date2: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.date(from: String(describing: date1))! == dateFormatter.date(from: String(describing: date2))!
        
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
