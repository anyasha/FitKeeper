//
//  ProfileWinnersTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.


import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class ProfileWinnersTableViewController: UITableViewController {
    
    var storage: StorageReference!
    
    var marathone = ""
    var members = [String]()
    var allTasks = 0
    var ranks = [String: Double]()
    
    var allMembers = [[String: Any]]()
    var memberInfo = [String: Any]()
    
    var end = false
    
    @IBOutlet weak var header: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/").child("users")
        
        self.header.title = marathone + "/ Winners"
        //Прозрачный  Navigation bar
        //        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Rectangle 33.png"), for: UIBarMetrics.default)
        //        self.navigationController?.navigationBar.isTranslucent = false
        //  self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clear
        if end  == true {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        //   self.tableView.isEditing = true
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).observe(.value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                    print("not found")
                } else {
                    for mm in snapshot.children {
                        let marathoneSnap = mm as! DataSnapshot
                        self.allTasks = self.allTasks + Int(marathoneSnap.childrenCount)
                    }
                }
            })
            
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(self.marathone).child("rank").observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["Losted weight"] as? String {
                    self.ranks["Losted weight"] = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["On-time completed tasks"] as? String {
                    self.ranks["On-time completed tasks"] = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["Completed tasks"] as? String {
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
        
        if let uid = Auth.auth().currentUser?.uid{
            var ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("winners").child(self.marathone)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary{
                    self.members = dict.allKeys as! [String]
                    self.allMembers.removeAll()
                    for m in self.members {
                        self.memberInfo.removeAll()
                        self.memberInfo["uid"] = m
                        //2
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(m).observeSingleEvent(of: .value, with: { snapshot in
                            if !snapshot.exists() { return }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["uid"] as? String {
                                self.memberInfo["uid"] = info
                            }
                            
                            if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                                self.memberInfo["username"] = info
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["bday"] as? String {
                                self.memberInfo["age"] = self.getAge(info)
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["photo"] as? String {
                                self.memberInfo["photoURL"] = info
                                Storage.storage().reference(forURL: info).getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                    self.memberInfo["photo"] = UIImage(data: data!) as! UIImage
                                })
                            }
                        })
                        //1
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(m).child("parameters").observeSingleEvent(of: .value, with: { snapshot in
                            if !snapshot.exists() { return }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["height"] as? String {
                                self.memberInfo["height"] = Double(info)
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["weight"] as? String {
                                self.memberInfo["weight"] = Double(info)
                            }
                        })
                        //3
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(m).child("progress").observeSingleEvent(of: .value, with: { snapshot in
                            if !snapshot.exists() { return }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["chestInit"] as? String {
                                self.memberInfo["chestInit"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["chestLast"] as? String {
                                self.memberInfo["chestLast"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["hipInit"] as? String {
                                self.memberInfo["hipInit"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["hipLast"] as? String {
                                self.memberInfo["hipLast"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["intimeTasks"] as? String {
                                self.memberInfo["intimeTasks"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["overdueTasks"] as? String {
                                self.memberInfo["overdueTasks"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["waistInit"] as? String {
                                self.memberInfo["waistInit"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["waistLast"] as? String {
                                self.memberInfo["waistLast"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["weightInit"] as? String {
                                self.memberInfo["weightInit"] = Double(info)!
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["weightLast"] as? String {
                                self.memberInfo["weightLast"] = Double(info)!
                            }
                            self.memberInfo["percent"] = 0.0 as! Double
                            self.memberInfo["percent"] = self.memberInfo["percent"] as! Double +  (((self.memberInfo["intimeTasks"] as! Double * 100.0) /  Double(self.allTasks)) * self.ranks["On-time completed tasks"]!)
                            
                            self.memberInfo["percent"] = self.memberInfo["percent"] as! Double + (((((self.memberInfo["intimeTasks"] as! Double) + (self.memberInfo["overdueTasks"] as! Double)) * 100.0) /  Double(self.allTasks)) * self.ranks["Completed tasks"]!)
                            
                            if  self.memberInfo["chestLast"] as! Double != 0 {
                                self.memberInfo["percent"] = self.memberInfo["percent"] as! Double + ((100 - ((self.memberInfo["chestLast"] as! Double * 100.0) / (self.memberInfo["chestInit"] as! Double ))) * self.ranks["Losted chest girth"]!)
                            }
                            if  self.memberInfo["hipLast"] as! Double != 0 {
                                self.memberInfo["percent"] = self.memberInfo["percent"] as! Double + ((100 - ((self.memberInfo["hipLast"] as! Double * 100.0) / (self.memberInfo["hipInit"] as! Double))) * self.ranks["Losted hip girth"]!)
                            }
                            if  self.memberInfo["waistLast"] as! Double != 0 {
                                self.memberInfo["percent"] = self.memberInfo["percent"] as! Double + ((100 - ((self.memberInfo["waistLast"] as! Double * 100.0) / (self.memberInfo["waistInit"] as! Double) )) * self.ranks["Losted waist girth"]!)
                            }
                            if  self.memberInfo["weightLast"] as! Double != 0 {
                                self.memberInfo["percent"] = self.memberInfo["percent"] as! Double + ((100 - ((self.memberInfo["weightLast"] as! Double * 100.0) / (self.memberInfo["weightInit"] as! Double ))) * self.ranks["Losted weight"]!)
                            }
                            
                            self.allMembers.append(self.memberInfo)
                            self.allMembers.sort(by: { $0["percent"] as! Double > $1["percent"] as! Double } )
                            self.tableView.reloadData()
                            for m in 0..<self.allMembers.count {
                                if self.allMembers[m]["photoURL"] != nil {
                                    Storage.storage().reference(forURL: self.allMembers[m]["photoURL"] as! String).getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                        self.allMembers[m]["photo"] = UIImage(data: data!) as! UIImage
                                        self.tableView.reloadData()
                                    })
                                }
                            }
                            self.tableView.reloadData()
                        })
                    }
                }
            })
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMembers.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MemberDetailsProfile", sender:  self.allMembers[indexPath.row]["uid"] as! String)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MemberDetailsProfile" {
            let guest = segue.destination as! MemberTableViewController
            guest.member = sender as! String
            guest.marathone = self.marathone
        }
    }
    
    func signupErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberTableViewCell
        cell.titleLabel?.text = self.allMembers[indexPath.row]["username"] as! String
        let text1 = String(self.allMembers[indexPath.row]["age"] as! Int) + " years, "
        let text2 = String(self.allMembers[indexPath.row]["height"] as! Double) + " cm, "
        let text3 = String(self.allMembers[indexPath.row]["weight"] as! Double) + " kg"
        cell.descriptionLabel?.text = text1 + text2 + text3
        cell.imView?.center.y = cell.frame.size.height / 2
        var ph = UIImage(named: "icon_ios_user_slct.png")
        if self.allMembers[indexPath.row]["photo"] != nil{
            ph = self.allMembers[indexPath.row]["photo"] as! UIImage
        }
        cell.imView?.image = ph
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //Segue to ActivityTableViewController
    @IBAction func unwindToWinners(storyboard:UIStoryboardSegue){
    }
}
