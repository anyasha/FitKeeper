//
//  SearchMealTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase

class SearchMealTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var headerTitle: UINavigationItem!
    @IBOutlet weak var searchController: UISearchBar!
    
    var meal = String()
    var date = String()
    
    
    var prods = [(String, String, String)]()
    var filteredProds = [(String, String, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchController.delegate = self
        
        self.headerTitle.title = meal
        self.tableView.tableFooterView = UIView()
        self.filteredProds = self.prods
        
        createToolbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("products")
        ref.observe(.value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for product in snapshot.children {
                    let prodSnap = product as! DataSnapshot
                    let dict = prodSnap.value as! [String: String]
                    if dict["name"] != nil {
                        self.prods.append((dict["name"]!, dict["portion"]!, dict["kcal"]!))
                    }
                }
                self.filteredProds = self.prods
                self.tableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProds.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowProduct1", sender: filteredProds[indexPath.row].0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "AddNewProd" {
            if segue.identifier == "ShowProduct1" {
                print(segue.destination)
            let guest = segue.destination as! ChosenMealTableViewController
            guest.meal = meal
            guest.date = date
            guest.product = sender as! String
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! CustomTableViewCell
        cell.titleLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
        cell.descriptionLabel?.textColor  = UIColor(red: 103/255, green: 104/255, blue: 111/255, alpha: 1)
        cell.titleLabel?.font = cell.titleLabel?.font.withSize(20)
        cell.imView?.center.y = cell.frame.size.height / 2
        cell.imView?.image = UIImage(named: "icon_ios_add copy")!
        cell.titleLabel?.text = filteredProds[indexPath.row].0
        cell.descriptionLabel?.text = filteredProds[indexPath.row].1 + "g, " + filteredProds[indexPath.row].2 + "kcal"
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredProds = searchText.isEmpty ? prods : prods.filter { item -> Bool in
            return item.0.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    
    @IBAction func unwindToSearchProd(storyboard:UIStoryboardSegue){
    }
}
