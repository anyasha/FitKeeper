//
//  AddParameterViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AddParameterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    var tag = 0
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var parameterLabel: UILabel!
    @IBOutlet weak var currentParameter: UILabel!
    
    var value: String?
    
    let vocabulary = ["Height", "Weight", "Chest girth", "Waist girth", "Hip girth"]
    let voc = ["height", "weight", "chest", "waist", "hip"]
    
    
    let height = ["140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150", "151", "152", "153", "154", "155", "156", "157", "158", "159", "160", "161", "162", "163", "164", "165", "166", "167", "168", "169", "170", "171", "172", "173", "177", "175", "176", "177", "178", "179", "180", "181", "182", "183", "184", "185", "186", "187", "188", "189", "190", "191", "192", "193", "194", "195", "196", "197", "198", "199", "200", "201", "202", "203", "204", "205", "206", "207", "208", "209", "210", "211", "212", "213", "214", "215", "216", "217", "218", "219", "220", "221", "222", "223", "224", "225", "226", "227", "228", "229", "230"]
    
    let weight = ["40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "77", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120", "121", "122", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "134", "135", "136", "137", "138", "139", "140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150", "151", "152", "153", "154", "155", "156", "157", "158", "159", "160", "161", "162", "163", "164", "165", "166", "167", "168", "169", "170", "171", "172", "173", "177", "175", "176", "177", "178", "179", "180", "181", "182", "183", "184", "185", "186", "187", "188", "189", "190", "191", "192", "193", "194", "195", "196", "197", "198", "199", "200", "201", "202", "203", "204", "205", "206", "207", "208", "209", "210", "211", "212", "213", "214", "215", "216", "217", "218", "219", "220", "221", "222", "223", "224", "225", "226", "227", "228", "229", "230", "231", "232", "233", "234", "235", "236", "237", "238", "239", "240", "241", "242", "243", "244", "245", "246", "247", "248", "249", "250", "251", "252", "253", "254", "255", "256", "257", "258", "259", "260", "261", "262", "263", "264", "265", "266", "267", "268", "269", "270", "271", "272", "273", "277", "275", "276", "277", "278", "279", "280", "281", "282", "283", "284", "285", "286", "287", "288", "289", "290", "291", "292", "293", "294", "295", "296", "297", "298", "299", "300"]
    
    let girth = ["40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "77", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120", "121", "122", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132", "133", "134", "135", "136", "137", "138", "139", "140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150"]
    
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.tag == 0 ? height[row] : self.tag == 1 ? weight[row] : girth[row]
        
     }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return self.tag == 0 ? height.count : self.tag == 1 ? weight.count : girth.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        if self.tag == 0 {
            if height[row] != nil {
                self.value = height[row]
            }
        }
        if self.tag == 1 {
            if weight[row] != nil {
                self.value = weight[row]
            }
        }
        else {
            if girth[row] != nil {
                self.value = girth[row]
            }
        }

    }
    
    func getUserInfo() {
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("parameters")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict[self.voc[self.tag]] as? String {
                    self.currentParameter.text = self.currentParameter.text! + self.vocabulary[self.tag] + ":"
                    if info != "0" {
                        self.value = info
                        self.parameterLabel.text = info
                        let find = self.tag == 0 ? self.height.index(of: self.value!) : self.tag == 1 ? self.weight.index(of: self.value!) : self.girth.index(of: self.value!)
                        self.pickerView.selectRow(find!, inComponent: 0, animated: true)
                    } else {
                        self.value = self.vocabulary[self.tag] == "Height" ? "140" : "40"
                        self.parameterLabel.text = "0"
                        self.pickerView.selectRow(0, inComponent: 0, animated: true)
                    }
                }
            })
        }
    }

    
    @IBAction func update(_ sender: Any) {
        if let uid = Auth.auth().currentUser?.uid{
            var ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("parameters")
            var values = [self.voc[self.tag]: self.value]
            ref.updateChildValues(values)
            ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("history").child(self.voc[self.tag])
            values = [getToday(): self.value]
            ref.updateChildValues(values)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tall = "140"
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        getUserInfo()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
