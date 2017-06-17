//
//  MarathoneRankTableViewController.swift
//  FitKeeper
//
//  Created by Анна Писаренко on 30.05.17.
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class MarathoneRankTableViewController: UITableViewController {
    
    @IBOutlet weak var headerTitle: UINavigationItem!
   
    var vocabulary = ["On-time completed tasks", "Completed tasks", "Losted weight", "Losted chest girth", "Losted waist girth", "Losted hip girth"]
    var mult = ["0.9", "0.75", "0.6", "0.45", "0.3", "0.15"]
    
    
    var marathone = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.delegate = self
        self.tableView.dataSource = self
       // self.headerTitle.title = marathone
        self.tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
        var voc = [String]()
        
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(self.marathone).child("rank").observe(.value, with: { snapshot in
                    if ( snapshot.value is NSNull ) {
                        print("not found")
                    } else {
                        for m in snapshot.children {
                            let marathoneSnap = m as! DataSnapshot
                            voc.append(marathoneSnap.value as! String)
                        }
                        self.vocabulary = voc
                    }
                })
        }

    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vocabulary.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rankCell", for: indexPath) 
        cell.textLabel?.text = vocabulary[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = vocabulary[sourceIndexPath.row]
        vocabulary.remove(at: sourceIndexPath.row)
        vocabulary.insert(itemToMove, at: destinationIndexPath.row)
        var data = [ String : String ]()
        for i in 0..<vocabulary.count {
            data[vocabulary[i]] = mult[i]
        }
         if let uid = Auth.auth().currentUser?.uid{
           let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/marathones").child(marathone)
            ref.updateChildValues(["rank" : data])
        }
    
    }
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
