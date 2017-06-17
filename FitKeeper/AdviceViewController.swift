//
//  AdviceViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AdviceViewController: UIViewController {
    
    
    var marathone = ""
    var date = ""
    var time = ""
    
    var titleE = ""
    var photoURL = ""
    var isUsed = false
    
    
    var storage: StorageReference!
    var ustorage: StorageReference!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var header: UINavigationItem!
    @IBOutlet weak var exercise: UILabel!
    @IBOutlet weak var text: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        //self.navigationController?.hidesBarsOnSwipe = true
        
        self.header.title = marathone
        
        let storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/")
        ustorage = storage.child("marathones").child(marathone).child("materials").child(self.date)
        
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
                    if let dict = snapshot.value as? NSDictionary, let info = dict["photo"] as? String {
                        self.photoURL = info
                    }
                    if self.photoURL != "" {
                        self.ustorage.child(self.time.trimmingCharacters(in: .whitespaces) + ".jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                            DispatchQueue.main.async() {
                                self.photo.image = UIImage(data: data!)!
                            }
                        })
                    }
                    
                }
            })
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
