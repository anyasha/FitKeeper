//
//  MarListTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class ProfileMarathonesTableViewController: UITableViewController {
    
    let sectionTitles = ["Organized Marathones", "Participated Marathones"]
    var organizedMarathones = [[String: Any]]()
    var participatedMarathones = [[String: Any]]()
    var marathonesCreated = [String]()
    var marathonesParticipated = [String]()
    
    var storage: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Прозрачный  Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Rectangle 33.png"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = false
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/").child("marathones")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
       
        getInfo()
        self.tableView.reloadData()
        
    }
    
    func getInfo() {
        self.organizedMarathones.removeAll()
        self.participatedMarathones.removeAll()
        marathonesCreated.removeAll()
        marathonesParticipated.removeAll()
        
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("created").observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary {
                    for key in dict.allKeys as! [String] {
                        self.marathonesCreated.append(key)
                    }
                    for m in self.marathonesCreated {
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(m).observeSingleEvent(of: .value, with: { snapshot in
                            if !snapshot.exists() { return }
                            var marathone = [String: Any]()
                            if let dict = snapshot.value as? NSDictionary, let info = dict["startDate"] as? String {
                                marathone["startDate"] = info
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                                marathone["title"] = info
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["period"] as? String {
                                marathone["period"] = info
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["organizer"] as? String {
                                marathone["organizerID"] = info
                                marathone["organizer"] = "a"
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["Logo"] as? String {
                                marathone["logoID"] = info
                                marathone["logo"] = UIImage(named: "Check.png")
                            }
                            self.organizedMarathones.append(marathone)
                            //                }
                            self.organizedMarathones.sort(by: {self.compareDates($0["startDate"] as! String,$1["startDate"] as! String)})
                            for m in 0..<self.organizedMarathones.count {
                                let uref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.organizedMarathones[m]["organizerID"] as! String).observeSingleEvent(of: .value, with: { snapshot in
                                    if !snapshot.exists() { return }
                                    if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                                        self.organizedMarathones[m]["organizer"] = info
                                    }
                                })
                                self.storage.child(self.organizedMarathones[m]["title"] as! String).child("Logo.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                    DispatchQueue.main.async() {
                                        self.organizedMarathones[m]["logo"] = UIImage(data: data!)
                                        self.tableView.reloadData()
                                    }
                                })
                            }
                        })
                    }
                }
            })
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("participated").observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary {
                    for key in dict.allKeys as! [String] {
                        self.marathonesParticipated.append(key)
                    }
                    for m in self.marathonesParticipated {
                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(m).observeSingleEvent(of: .value, with: { snapshot in
                            if !snapshot.exists() { return }
                            var marathone = [String: Any]()
                            if let dict = snapshot.value as? NSDictionary, let info = dict["startDate"] as? String {
                                marathone["startDate"] = info
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                                marathone["title"] = info
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["period"] as? String {
                                marathone["period"] = info
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["organizer"] as? String {
                                marathone["organizerID"] = info
                                marathone["organizer"] = "a"
                            }
                            if let dict = snapshot.value as? NSDictionary, let info = dict["Logo"] as? String {
                                marathone["logoID"] = info
                                marathone["logo"] = UIImage(named: "Check.png")
                            }
                            self.participatedMarathones.append(marathone)
                            //                }
                            self.participatedMarathones.sort(by: {self.compareDates($0["startDate"] as! String,$1["startDate"] as! String)})
                            for m in 0..<self.participatedMarathones.count {
                                let uref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.participatedMarathones[m]["organizerID"] as! String).observeSingleEvent(of: .value, with: { snapshot in
                                    if !snapshot.exists() { return }
                                    if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                                        self.participatedMarathones[m]["organizer"] = info
                                    }
                                })
                                self.storage.child(self.participatedMarathones[m]["title"] as! String).child("Logo.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                    DispatchQueue.main.async() {
                                        self.participatedMarathones[m]["logo"] = UIImage(data: data!)
                                        self.tableView.reloadData()
                                    }
                                })
                            }
                        })
                    }
                }
            })
            
            
        }
    }
    
    func compareDates(_ date1: String, _ date2: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.date(from: String(describing: date1))! < dateFormatter.date(from: String(describing: date2))!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        if section < sectionTitles.count {
            return sectionTitles[section]
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 && participatedMarathones.count == 0) || (indexPath.section == 1 && participatedMarathones.count == 0) {
            return 70
        }
        return 110
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if organizedMarathones.count != 0 {
                return organizedMarathones.count
            }
            else {
                return 1
            }
        } else {
            if participatedMarathones.count != 0 {
                return participatedMarathones.count
            }
            else {
                return 1
            }
        }
    }
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "Winners", sender: self.organizedMarathones[indexPath.row]["title"] as! String)

//            if indexPath.section == 0 {
//                performSegue(withIdentifier: "ProfileShowMarathone", sender: self.organizedMarathones[indexPath.row]["title"] as! String)
//            } else {
//                performSegue(withIdentifier: "ProfileShowMarathone", sender: self.participatedMarathones[indexPath.row]["title"] as! String)
//            }
        }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ProfileShowMarathone" {
                let nav = segue.destination as! UINavigationController
                let guest = nav.topViewController as! MarathoneInfoViewController
                guest.marathone = sender as! String
            }
            if segue.identifier == "Winners" {
                let nav = segue.destination as! UINavigationController
                let guest = nav.topViewController as! ProfileWinnersTableViewController
                guest.marathone = sender as! String
            }

        }
    
    
    func setCell( _ cell : MarathoneTableViewCell, _ marathone : [String: Any]) {
        cell.titleLabel?.text = (marathone["title"] as? String)?.uppercased()
        cell.coachTextField?.text = marathone["organizer"] as? String
        cell.startsTextField?.text = marathone["startDate"] as? String
        cell.durationTextField?.text = (marathone["period"] as? String)! + (Int((marathone["period"] as? String)!)! <= 1 ? " week" : " weeks")
        
        cell.imView?.center.y = cell.frame.size.height / 2
        cell.imView?.image = marathone["logo"] as? UIImage
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (organizedMarathones.count == 0 && indexPath.section == 0) || (participatedMarathones.count == 0 && indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MarathoneCell", for: indexPath) as! MarathoneTableViewCell
            cell.titleLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
            cell.titleLabel?.text = "There is no marathones."
            cell.titleLabel?.center.y = cell.frame.size.height / 2
            cell.titleLabel?.center.x = cell.frame.size.width / 2
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.coachLabel?.text = ""
            cell.startsLabel.text = ""
            cell.durationLabel?.text = ""
            cell.coachTextField.text = ""
            cell.startsTextField.text = ""
            cell.durationTextField?.text = ""
            cell.imView?.image = nil
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarathoneCell", for: indexPath) as! MarathoneTableViewCell
        if indexPath.section == 0 {
            setCell(cell, self.organizedMarathones[indexPath.row])
        } else if indexPath.section == 1 {
            setCell(cell, self.participatedMarathones[indexPath.row])
        }
        return cell
    }
    //
    //
    //    func marathoneErrorAlert(title: String, message: String) {
    //        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    //        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
    //        alert.addAction(action)
    //        present(alert, animated: true, completion: nil)
    //    }
    //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
