//
//  SearchActivityTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class SearchActivityTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchController: UISearchBar!
    
    var date = String()

    var sports = [(String, String, String)]()
    var filteredSports = [(String, String, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchController.delegate = self

        self.tableView.tableFooterView = UIView()
        self.filteredSports = self.sports
         createToolbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("activities")
        ref.observe(.value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for product in snapshot.children {
                    let sportsnap = product as! DataSnapshot
                    let dict = sportsnap.value as! [String: String]
                    if dict["name"] != nil {
                        self.sports.append((dict["name"]!, dict["mins"]!, dict["kcal"]!))
                    }
                }
                self.filteredSports = self.sports
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func addNew(_: UIBarButtonItem) {
        performSegue(withIdentifier: "NewSport", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSports.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSports1", sender: self.filteredSports[indexPath.row].0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSports1" {
            let guest = segue.destination as! ChosenSportsTableViewController
            guest.date = date
            guest.sport = sender as! String
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SportCell", for: indexPath) as! CustomTableViewCell
        cell.titleLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
        cell.descriptionLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
        cell.titleLabel?.font = cell.titleLabel?.font.withSize(20)
        cell.imView?.center.y = cell.frame.size.height / 2
        cell.imView?.image = UIImage(named: "icon_ios_add copy")!
        cell.titleLabel?.text = filteredSports[indexPath.row].0
        cell.descriptionLabel?.text = filteredSports[indexPath.row].1 + "min, -" + filteredSports[indexPath.row].2 + "kcal"
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredSports = searchText.isEmpty ? sports : sports.filter { item -> Bool in
            return item.0.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }
    
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        toolBar.tintColor = .black
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        searchController.inputAccessoryView = toolBar
    }
    
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //Скрывать клавиатуру, когда пользователь коснется выше неё
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Скрывать клавиатуру, когда пользователь коснется return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
