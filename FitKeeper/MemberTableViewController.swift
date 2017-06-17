//
//  MemberTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class MemberTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var marathone = ""
    var member = ""
    
    var age = ""
    var name = ""
    var height = ""
    var tasksCount = 0
    var tasksIntime = 0
    var tasksOverdue = 0
    var photo = UIImage()
    var photos = [(String, UIImage)]()
     var weight = [(String, String)]()
    var chest = [(String, String)]()
    var hip = [(String, String)]()
    var waist = [(String, String)]()
    var parameters = [String : [(String, String)]]()
//    var name : String = ""
//    var photo : String = ""
//    var gender : String = ""
//
//    var weight: Double = 0
//    var hip : Double = 0
//    var waist: Double = 0
//    var chest : Double = 0
//    
//    var url : String = ""
//    
    var userStorage: StorageReference!
    var marathoneStorage: StorageReference!
//    
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var profileImageView: CustomImageView!
    
    @IBOutlet weak var completed: UITextField!
    @IBOutlet weak var left: UITextField!
    @IBOutlet weak var overdue: UITextField!
    
    @IBOutlet weak var before: CustomImageView!
    @IBOutlet weak var after: CustomImageView!
    
    @IBOutlet weak var weightAfter: UITextField!
    @IBOutlet weak var weightBefore: UITextField!
    @IBOutlet weak var weightPercent: UITextField!
    
    
    @IBOutlet weak var chestBefore: UITextField!
    @IBOutlet weak var chestAfter: UITextField!
    @IBOutlet weak var chestPercent: UITextField!
    
    @IBOutlet weak var waistBefore: UITextField!
    @IBOutlet weak var waistAfter: UITextField!
    @IBOutlet weak var waistPercent: UITextField!
    
    @IBOutlet weak var hipBefore: UITextField!
    @IBOutlet weak var hipAfter: UITextField!
    @IBOutlet weak var hipPercent: UITextField!
    
    @IBOutlet weak var header: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        //getUserInfo()
        
        let storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/")
       
        userStorage = storage.child("users")
        marathoneStorage = storage.child("marathoneMembers").child(self.marathone).child(self.member)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //Прозрачный  Navigation bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.member).observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["bday"] as? String {
                    self.age = String(self.getAge(info)) + " years, "
                  ///////////////  self.header.title = self.age + self.height
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                    self.name = info
                    self.header.prompt = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["photo"] as? String {
                   // self.photo = info
                    //if self.photo != "" {
                        self.userStorage.child(self.member + ".jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                            DispatchQueue.main.async() {
                                self.photo = UIImage(data: data!)!
                               // self.profileImageView.image = UIImage(data: data!)
                                //self.rewrightData()
                                // self.tableView.reloadData()
                                //                  self.mainView.reloadInputViews()
                            }
                        })
                    //}

                }
            })
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("parameters").observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["height"] as? String {
                    self.height = info + " cm"
                }
            })
            
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for m in snapshot.children {
                        let marathoneSnap = m as! DataSnapshot
                        self.tasksCount += Int(marathoneSnap.childrenCount)
                    }
                }
            })
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(self.member).observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for m in snapshot.children {
                        let mSnap = m as! DataSnapshot
                        for mm in mSnap.children {
                            let mmSnap = mm as! DataSnapshot
                            if let dict = mmSnap.value as? String {
                                if dict == "intime" {
                                    self.tasksIntime += 1
                                } else  {
                                    self.tasksOverdue += 1
                                }
                            }
                        }
                    }
                }
            })
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(self.member).child("photos").observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for m in snapshot.children {
                        let marathoneSnap = m as! DataSnapshot
                        if let key = marathoneSnap.key as? String,  let value = marathoneSnap.value as? String{
                           // self.photos[key] = value
                            self.marathoneStorage.child(key + ".jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                DispatchQueue.main.async() {
                                    self.photos.append((key, UIImage(data: data!)!))
                                    // self.profileImageView.image = UIImage(data: data!)
                                     self.rewrightData()
                                    // self.tableView.reloadData()
                                    //                  self.mainView.reloadInputViews()
                                }
                            })
                        }
                    }
                }
            })
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(self.member).child("parameters").observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for m in snapshot.children {
                        let marathoneSnap = m as! DataSnapshot
                        if let dict = marathoneSnap.value as? [String: String] {
                            let k = marathoneSnap.key as! String
                            for (key, value) in dict {
                                if k == "weight" {
                                    self.weight.append(key, value)
                                }
                                if k == "chest" {
                                    self.chest.append(key, value)
                                }
                                if k == "hip" {
                                    self.hip.append(key, value)
                                }
                                if k == "waist" {
                                    self.waist.append(key, value)
                                }
                            }
                            //self.parameters[k]! = dict
                        }
                    }
                }
            })
        }
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

    override func viewDidLayoutSubviews() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        before.layer.cornerRadius = profileImageView.frame.size.width
        before.clipsToBounds = true
        after.layer.cornerRadius = profileImageView.frame.size.width
        after.clipsToBounds = true
    }

    
    @IBAction func showBefore(_ sender: UIButton) {
        performSegue(withIdentifier: "photomodal", sender: before.image)
    }
    @IBAction func showAfter(_ sender: UIButton) {
        performSegue(withIdentifier: "photomodal", sender: after.image)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photomodal" {
            let guest = segue.destination as! ShowCertificateViewController
            guest.img = sender as! UIImage
        }
        else {
            UIView.setAnimationsEnabled(false)
            self.navigationItem.prompt = nil
            UIView.setAnimationsEnabled(true)
        }
    }

    
    
    
    
    func rewrightData() {
//        place
//        percent
        self.profileImageView.image = self.photo
        self.completed.text = String(self.tasksIntime)
        self.overdue.text = String(self.tasksOverdue)
        self.left.text = String(self.tasksCount - self.tasksOverdue - self.tasksIntime)
        if self.photos.count > 1 {
            if photos[0].0 < photos[1].0 {
                self.before.image = photos[0].1
                self.after.image = photos[1].1
            } else {
                self.before.image = photos[1].1
                self.after.image = photos[0].1
            }
        } else if self.photos.count == 1 {
            self.before.image = photos[0].1
        }
        self.weightPercent.text = ""
        if self.weight != nil
        {
            if self.weight.count > 1 {
                if self.weight[0].0 < self.weight[1].0 {
                    self.weightBefore.text = self.weight[0].1
                    self.weightAfter.text = self.weight[1].1
                    let val = ((Int(self.weight[1].1)! * 100 ) / Int(self.weight[0].1)!) - 100
                    self.weightPercent.text = "(" + String(val) + "%)"
                    if val < 0 {
                        self.weightPercent.textColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
                    }
                } else {
                    self.weightBefore.text = self.weight[1].1
                    self.weightAfter.text = self.weight[0].1
                    let val = ((Int(self.weight[0].1)! * 100 ) / Int(self.weight[1].1)!) - 100
                    self.weightPercent.text = "(" + String(val) + "%)"
                    if val < 0 {
                        self.weightPercent.textColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
                    }
                }
            } else {
                self.weightBefore.text = self.weight[0].1
            }
        }
        self.chestPercent.text = ""
        if chest != nil
        {
            if chest.count > 1 {
                if chest[0].0 < chest[1].0 {
                    self.chestBefore.text = chest[0].1
                    self.chestAfter.text = chest[1].1
                     let val = ((Int(chest[1].1)! * 100 ) / Int(chest[0].1)!) - 100
                     self.chestPercent.text = "(" + String(val) + "%)"
                    if val < 0 {
                        self.chestPercent.textColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
                    }
                } else {
                    self.chestBefore.text = chest[1].1
                    self.chestAfter.text = chest[0].1
                    let val = ((Int(chest[0].1)! * 100 ) / Int(chest[1].1)!) - 100
                    self.chestPercent.text = "(" + String(val) + "%)"
                    if val < 0 {
                        self.chestPercent.textColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
                    }
                }
            } else {
                self.chestBefore.text = chest[0].1
            }
        }
         self.waistPercent.text = ""
        if self.waist != nil
        {
            if self.waist.count > 1 {
                if self.waist[0].0 < self.waist[1].0 {
                    self.waistBefore.text = self.waist[0].1
                    self.waistAfter.text = self.waist[1].1
                    let val = ((Int(self.waist[1].1)! * 100 ) / Int(self.waist[0].1)!) - 100
                    self.waistPercent.text = "(" + String(val) + "%)"
                    if val < 0 {
                        self.waistPercent.textColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
                    }
                } else {
                    self.waistBefore.text = self.waist[1].1
                    self.waistAfter.text = self.waist[0].1
                    let val = ((Int(self.waist[0].1)! * 100 ) / Int(self.waist[1].1)!) - 100
                    self.waistPercent.text = "(" + String(val) + "%)"
                    if val < 0 {
                        self.waistPercent.textColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
                    }
                }
            } else {
                self.waistBefore.text = self.waist[0].1
            }
        }
        self.hipPercent.text = ""
        if hip != nil
        {
            if hip.count > 1 {
                if hip[0].0 < hip[1].0 {
                    self.hipBefore.text = hip[0].1
                    self.hipAfter.text = hip[1].1
                    let val = ((Int(hip[1].1)! * 100 ) / Int(hip[0].1)!) - 100
                    self.hipPercent.text = "(" + String(val) + "%)"
                    if val < 0 {
                        self.hipPercent.textColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
                    }
                } else {
                    self.hipBefore.text = hip[1].1
                    self.hipAfter.text = hip[0].1
                    let val = ((Int(hip[0].1)! * 100 ) / Int(hip[1].1)!) - 100
                    self.hipPercent.text = "(" + String(val) + "%)"
                    if val < 0 {
                        self.hipPercent.textColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
                    }

                }
            } else {
                self.hipBefore.text = hip[0].1
            }
        }

        self.header.title = self.age + self.height
        self.header.prompt = self.name
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
