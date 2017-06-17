//
//  MarListTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class MainMarathoneTableViewController: UITableViewController {
    
    
    var organizer = ""
    var organizerMarathone = [String: Any]()
    var participant = ""
    var participantMarathone = [String: Any]()
    
    var marathones = [[String: Any]]()
    var marathone = [String: Any]()
    
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
    }
  
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Rectangle 33.png"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = false

        
        self.organizer = ""
        self.organizerMarathone.removeAll()
        self.participant = ""
        self.participantMarathone.removeAll()
        self.marathones.removeAll()
        self.tableView.reloadData()
        
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("active")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["organizer"] as? String {
                    self.organizer = info
                    
                    let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(self.organizer)
                    ref.observeSingleEvent(of: .value, with: { snapshot in
                        if !snapshot.exists() { return }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["startDate"] as? String {
                            self.organizerMarathone["startDate"] = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                            self.organizerMarathone["title"] = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["period"] as? String {
                            self.organizerMarathone["period"] = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["organizer"] as? String {
                            let uref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(info as! String).observeSingleEvent(of: .value, with: { snapshot in
                                if !snapshot.exists() { return }
                                if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                                    self.organizerMarathone["organizer"] = info
                                }
                            })
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["Logo"] as? String {
                            self.storage.child(self.organizerMarathone["title"] as! String).child("Logo.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                DispatchQueue.main.async() {
                                    self.organizerMarathone["logo"] = UIImage(data: data!)
                                    self.tableView.reloadData()
                                }
                            })
                            
                        }
                    })
                   
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["participant"] as? String {
                    self.participant = info
                    let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(self.participant)
                    ref.observeSingleEvent(of: .value, with: { snapshot in
                        if !snapshot.exists() { return }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["startDate"] as? String {
                            self.participantMarathone["startDate"] = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                            self.participantMarathone["title"] = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["period"] as? String {
                            self.participantMarathone["period"] = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["organizer"] as? String {
                            let uref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(info as! String).observeSingleEvent(of: .value, with: { snapshot in
                                if !snapshot.exists() { return }
                                if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                                    self.participantMarathone["organizer"] = info
                                }
                            })
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["Logo"] as? String {
                            self.storage.child(self.participantMarathone["title"] as! String).child("Logo.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                DispatchQueue.main.async() {
                                    self.participantMarathone["logo"] = UIImage(data: data!)
                                    self.tableView.reloadData()
                                }
                            })
                            
                        }
                    })
                }
            })
        }
        let mref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones")
        mref.observe(.value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for m in snapshot.children {
                    self.marathone.removeAll()
                    let marathoneSnap = m as! DataSnapshot
                    if let dict = marathoneSnap.value as? NSDictionary, let info = dict["startDate"] as? String {
                       self.marathone["startDate"] = info
                    }
                    if let dict = marathoneSnap.value as? NSDictionary, let info = dict["title"] as? String {
                        self.marathone["title"] = info
                    }
                    if let dict = marathoneSnap.value as? NSDictionary, let info = dict["period"] as? String {
                        self.marathone["period"] = info
                    }
                    if let dict = marathoneSnap.value as? NSDictionary, let info = dict["organizer"] as? String {
                        self.marathone["organizerID"] = info
                        self.marathone["organizer"] = "a"
                    }
                    if let dict = marathoneSnap.value as? NSDictionary, let info = dict["Logo"] as? String {
                        self.marathone["logoID"] = info
                        self.marathone["logo"] = UIImage(named: "Check.png")
                    }
                    self.marathones.append(self.marathone)
                }
                self.marathones.sort(by: {self.compareDates($0["startDate"] as! String,$1["startDate"] as! String)})
                for m in 0..<self.marathones.count {
                    let uref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(self.marathones[m]["organizerID"] as! String).observeSingleEvent(of: .value, with: { snapshot in
                        if !snapshot.exists() { return }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                            self.marathones[m]["organizer"] = info
                        }
                    })
                    self.storage.child(self.marathones[m]["title"] as! String).child("Logo.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                        DispatchQueue.main.async() {
                            self.marathones[m]["logo"] = UIImage(data: data!)
                            self.tableView.reloadData()
                        }
                    })
                   
                }
                
            }
        })
       
    }

    
    @IBAction func addMarathone(_ sender: UIBarButtonItem) {
        if self.organizer == "" {
            performSegue(withIdentifier: "AddMarathone", sender: self)
        } else{
             self.marathoneErrorAlert(title: "Error!", message: "You can manage only ONE marathone at one time!")
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.organizer != "" || self.participant != "" {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.organizer != "" || self.participant != "") && section == 0 {
            return "My marathones"
        }
        return "All marathones"
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.organizer != "" || self.participant != "") && section == 0 {
            return self.organizer != "" ? self.participant != "" ? 2 : 1 : self.participant != "" ? 1 : 0
        }
        return marathones.count
    }
    
    func compareDates(_ date1: String, _ date2: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.date(from: String(describing: date1))! < dateFormatter.date(from: String(describing: date2))!
        
    }


    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if self.marathones[indexPath.row]["title"] as! String != self.participant && self.marathones[indexPath.row]["title"] as! String != self.organizer {
                performSegue(withIdentifier: "MarathoneDetails", sender: self.marathones[indexPath.row]["title"] as! String)
            }
            else {
                if self.marathones[indexPath.row]["title"] as! String == self.participant {
                    if self.compareDates(self.getToday(), self.participantMarathone["startDate"] as! String), let a = self.participantMarathone["title"], let b = self.participantMarathone["startDate"] {
                        self.marathoneErrorAlert(title: "Attention!", message: "Marathone \(a) starts on \(b)")
                    } else {
                        performSegue(withIdentifier: "PartMarathone", sender: self.marathones[indexPath.row]["title"] as! String)
                    }
                }
                if self.marathones[indexPath.row]["title"] as! String == self.organizer{
                    performSegue(withIdentifier: "OrgMarathone", sender: self.marathones[indexPath.row]["title"] as! String)
                }
            }
        } else if indexPath.section == 0 {
            if self.organizer != "" && indexPath.row == 0 {
                performSegue(withIdentifier: "OrgMarathone", sender: self.organizerMarathone["title"] as! String)
            } else if self.participant != "" && ((self.organizer == "" && indexPath.row == 0) || (self.organizer != "" && indexPath.row == 1)) {
                if self.compareDates(self.getToday(), self.participantMarathone["startDate"] as! String), let a = self.participantMarathone["title"], let b = self.participantMarathone["startDate"] {
                    self.marathoneErrorAlert(title: "Attention!", message: "Marathone \(a) starts on \(b)")
                } else {
                    performSegue(withIdentifier: "PartMarathone", sender: self.participantMarathone["title"] as! String)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MarathoneDetails" {
            let nav = segue.destination as! UINavigationController
            let guest = nav.topViewController as! MarathoneInfoViewController
            guest.marathone = sender as! String
        }
        
        if segue.identifier == "OrgMarathone" {
            //let nav = segue.destination as! UINavigationController
            //let guest = nav.topViewController as! ManageMarathoneTableViewController
            let guest = segue.destination as! ManageMarathoneTableViewController
            guest.marathone = sender as! String
            guest.date = self.getToday()
        }
        if segue.identifier == "PartMarathone" {
//            let nav = segue.destination as! UINavigationController
//            let guest = nav.topViewController as! ParticipateMarathoneTableViewController
            let guest = segue.destination as! ParticipateMarathoneTableViewController
            guest.marathone = sender as! String
            guest.date = self.getToday()
        }
    }

    
    
    func setCell( _ cell : MarathoneTableViewCell, _ marathone : [String: Any], _ flag : Bool = false) {
        cell.titleLabel?.text = (marathone["title"] as? String)?.uppercased()
        cell.coachTextField?.text = marathone["organizer"] as? String
        cell.startsTextField?.text = marathone["startDate"] as? String
        cell.durationTextField?.text = (marathone["period"] as? String)! + (Int((marathone["period"] as? String)!)! <= 1 ? " week" : " weeks")
        
        cell.imView?.center.y = cell.frame.size.height / 2
        cell.imView?.image = marathone["logo"] as? UIImage
        
        if flag == true {
            if marathone["title"] as! String != self.participant && marathone["title"] as! String != self.organizer  {
                cell.button.setTitle("join +", for: .normal)
                cell.button.isEnabled = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarathoneCell", for: indexPath) as! MarathoneTableViewCell
        if (self.organizer == "" && self.participant == "") || indexPath.section == 1 {
            setCell(cell, marathones[indexPath.row], true)
        } else if self.organizer != "", indexPath.section == 0, indexPath.row == 0 {
            setCell(cell, organizerMarathone, false)
        } else if (self.participant != "" && indexPath.section == 0) {
            if (indexPath.row == 0 && self.organizer == "") || (indexPath.row == 1 && self.organizer != "") {
                setCell(cell, self.participantMarathone, false)
            }
        }
        return cell
    }

    
    func marathoneErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
