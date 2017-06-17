//
//  ПуеЬуьиук.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase


class Member {
    
    let uid : String
    let marathone : String
    
    var storage: StorageReference!
    
    var username: String
    var age: Int
    var heightNow: Double
    var weightNow: Double
    var photoUrl: String
    var photo: UIImage
    var tasksIntime: Int = 0
    var tasksOverdue: Int = 0
    var allTasks: Int = 0
    var parameter : Double = 0.0
    
    var ranks : [String : Double]
    var values : [String: Double]
    
    
    var weight : [Double]
    var chest : [Double]
    var hip : [Double]
    var waist : [Double]
    
    
//    func getUsername()
//    func getAge()
//    func getHeight()
//    func getWeight()
//    func getPhotoUrl()
//    func getPhoto()
//    func getTasksIntimeOverdue()
//    func getTasks()
//    func getParameters()
//    func getRanks()
//    func getPercent()
    
    init(uid: String, marathone: String) {
        self.uid = uid
        self.marathone = marathone
        self.storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/").child("users")
        self.username = ""
        self.age = 0
        self.heightNow = 0.0
        self.weightNow = 0.0
        self.photoUrl = ""
        self.photo = UIImage()
        self.tasksIntime = 0
        self.tasksOverdue = 0
        self.allTasks = 0
        self.weight = [Double]()
        self.chest = [Double]()
        self.hip = [Double]()
        self.waist = [Double]()
        self.parameter = 0.0
        self.ranks = [String : Double]()
        self.values = [String: Double]()

        self.getUsername()
        self.getAge()
        self.getHeight()
        self.getWeight()
        self.getPhotoUrl()
        self.getPhoto()
        self.getTasksIntimeOverdue()
        self.getTasks()
        self.getParameters()
        self.getRanks()
        //self.getPercent()
    }
    
    
    func getUsername() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.uid).observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                self.username = info
                
            }
        })
    }
    
    func getAge() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.uid).observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            if let dict = snapshot.value as? NSDictionary, let info = dict["bday"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MM yyyy"
                let bday = dateFormatter.date(from: String(describing: info))
                let today = Date()
                let calendar = Calendar.current
                let ageComponents = calendar.dateComponents([.year], from: bday!, to: today)
                self.age = Int(ageComponents.year!)
            }
        })
    }
    
    
    func getHeight() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.uid).child("parameters").observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            if let dict = snapshot.value as? NSDictionary, let info = dict["height"] as? String {
                self.heightNow = Double(info)!
            }
        })
    }
    
    func getWeight() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.uid).child("parameters").observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            if let dict = snapshot.value as? NSDictionary, let info = dict["weight"] as? String {
                self.weightNow = Double(info)!
            }
        })
    }
    func getPhotoUrl() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.uid).observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            if let dict = snapshot.value as? NSDictionary, let info = dict["photo"] as? String {
                self.photoUrl = info
                
            }
        })
    }

    func getPhoto() {
        if self.photoUrl != nil {
            self.storage.child(self.uid + ".jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                DispatchQueue.main.async() {
                    self.photo = UIImage(data: data!) as! UIImage
                }
            })
        }
    }
    
    func getTasksIntimeOverdue() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(self.uid).observe(.value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for ma in snapshot.children {
                    let mSnap = ma as! DataSnapshot
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
    }

    func getTasks() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).observe(.value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for m in snapshot.children {
                    let marathoneSnap = m as! DataSnapshot
                    self.allTasks += Int(marathoneSnap.childrenCount)
                }
            }
        })
    }
    
    func getParameters() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(self.uid).child("parameters").observe(.value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for m in snapshot.children {
                    let marathoneSnap = m as! DataSnapshot
                    if let dict = marathoneSnap.value as? [String: String] {
                        let k = marathoneSnap.key as! String
                        for (key, value) in dict {
                            if k == "weight" {
                                self.weight.append(Double(value)!)
                            }
                            if k == "chest" {
                                self.chest.append(Double(value)!)
                            }
                            if k == "hip" {
                                self.hip.append(Double(value)!)
                            }
                            if k == "waist" {
                                self.waist.append(Double(value)!)
                            }
                        }
                    }
                }
            }
        })
    }
    
    func getRanks() {
        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(self.marathone).child("rank").observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            if let dict = snapshot.value as? NSDictionary, let info = dict["Losted weight"] as? String {
                self.ranks["Losted weight"] = Double(info)!
            }
            if let dict = snapshot.value as? NSDictionary, let info = dict["On-time completed tasks"]as? String {
                self.ranks["On-time completed tasks"] = Double(info)!
            }
            if let dict = snapshot.value as? NSDictionary, let info = dict["Completed tasks"]as? String {
                self.ranks["Completed tasks"] = Double(info)!
            }
            if let dict = snapshot.value as? NSDictionary, let info = dict["Losted chest girth"] as? String {
                self.ranks["Losted chest girth"] = Double(info)!
            }
            if let dict = snapshot.value as? NSDictionary, let info = dict["Losted waist girth"] as? String {
                self.ranks["Losted waist girth"] = Double(info)!
            }
            if let dict = snapshot.value as? NSDictionary, let info = dict["Losted hip girth"] as? String {
                self.ranks["Losted hip girth"] = Double(info)!
            }
        })
    }


    func getPercent() {
        self.values["On-time completed tasks"] = ((Double(self.tasksIntime) * 100.0) / Double(self.allTasks)) * self.ranks["On-time completed tasks"]!
        self.parameter += self.values["On-time completed tasks"]!
        self.values["Completed tasks"] = ((Double(self.tasksIntime) + Double(self.tasksOverdue) * 100.0) / Double(self.allTasks)) * self.ranks["Completed tasks"]!
        self.parameter += self.values["Completed tasks"]!
        if weight.count >= 2 {
            self.values["Losted weight"] = (100.0 - (((self.weight[self.weight.count - 1] * 100.0) / self.weight[0]) * self.ranks["Losted weight"]!))
        } else {
            self.values["Losted weight"] = 0
        }
        self.parameter += self.values["Losted weight"]!
        if self.chest.count >= 2 {
            self.values["Losted chest girth"] = (100.0 - (((self.chest[self.chest.count - 1] * 100.0) / self.chest[0]) * self.ranks["Losted chest girth"]!))
        } else {
            self.values["Losted chest girth"] = 0
        }
        self.parameter += self.values["Losted waist girth"]!
        if self.waist.count >= 2 {
            self.values["Losted waist girth"] = (100.0 - (((self.waist[self.waist.count - 1] * 100.0) / self.waist[0]) * self.ranks["Losted waist girth"]!))
        } else {
            self.values["Losted waist girth"] = 0
        }
        self.parameter += self.values["Losted hip girth"]!
        if self.hip.count >= 2 {
            self.values["Losted hip girth"] = (100.0 - (((self.hip[self.hip.count - 1] * 100.0) / self.hip[0]) * self.ranks["Losted hip girth"]!))
        } else {
            self.values["Losted hip girth"] = 0
        }
        self.parameter += self.values["Losted hip girth"]!
    }
    
}
