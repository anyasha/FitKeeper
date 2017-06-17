//
//  AddMarTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AddMarathoneTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    
    @IBOutlet weak var titletextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var periodPicker: UIPickerView!
    @IBOutlet weak var marathoneDetailsTextField: UITextField!
    @IBOutlet weak var authorInfoTextField: UITextField!
    @IBOutlet weak var activityLevelPicker: UIPickerView!
    
    @IBOutlet weak var full: UIButton!
    @IBOutlet weak var legs: UIButton!
    @IBOutlet weak var butt: UIButton!
    @IBOutlet weak var arms: UIButton!
    @IBOutlet weak var abs: UIButton!
    
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var bg: UIButton!
    @IBOutlet weak var cert1: UIButton!
    @IBOutlet weak var cert2: UIButton!
    @IBOutlet weak var cert3: UIButton!
    
    var currPeriod = "1"
    var periods = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    var currActivity = "Low"
    var activities = ["Low", "Medium", "High"]
    
    
    var photos = [String: UIImage]()
    var resistance = ["FullBody" : false,
                      "Legs" : true,
                      "Buttocks" : true,
                      "Arms" : true,
                      "Abs" : false]
    
    var databaseRef: DatabaseReference!
    var userStorage: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        full.accessibilityIdentifier = "FullBody"
        legs.accessibilityIdentifier = "Legs"
        butt.accessibilityIdentifier = "Buttocks"
        arms.accessibilityIdentifier = "Arms"
        abs.accessibilityIdentifier = "Abs"
        
        logo.accessibilityIdentifier = "Logo"
        bg.accessibilityIdentifier = "Background"
        cert1.accessibilityIdentifier = "Certificate1"
        cert2.accessibilityIdentifier = "Certificate2"
        cert3.accessibilityIdentifier = "Certificate3"
        
        let storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/")
        userStorage = storage.child("marathones")
        
        self.startDatePicker.minimumDate = Date()
        self.activityLevelPicker.dataSource = self
        self.activityLevelPicker.delegate = self
        self.activityLevelPicker.accessibilityIdentifier = "al"
        self.periodPicker.dataSource = self
        self.periodPicker.delegate = self
        self.periodPicker.accessibilityIdentifier = "p"
        createToolbar()
    }
    
    @IBAction func addLogo(_ sender: Any) {
        getPhoto("Logo")
    }
    @IBAction func addBG(_ sender: Any) {
        getPhoto("Background")
    }
    @IBAction func addCert1(_ sender: Any) {
        getPhoto("Certificate1")
    }
    @IBAction func addCert2(_ sender: Any) {
        getPhoto("Certificate2")
    }
    @IBAction func addCert3(_ sender: Any) {
        getPhoto("Certificate3")
    }
    
    @IBAction func check(_ sender: UIButton) {
        if resistance[sender.accessibilityIdentifier!]! == false {
            if sender.accessibilityIdentifier! == "FullBody" {
                resistance["FullBody"] = true
                full.setImage(UIImage(named: "Check_1.png"), for: .normal)
                resistance["Legs"] = true
                legs.setImage(UIImage(named: "Check_1.png"), for: .normal)
                resistance["Buttocks"] = true
                butt.setImage(UIImage(named: "Check_1.png"), for: .normal)
                resistance["Arms"] = true
                arms.setImage(UIImage(named: "Check_1.png"), for: .normal)
                resistance["Abs"] = true
                abs.setImage(UIImage(named: "Check_1.png"), for: .normal)
            }
            else {
                resistance[sender.accessibilityIdentifier!]! = true
                sender.setImage(UIImage(named: "Check_1"), for: .normal)
            }
        } else {
            if sender.accessibilityIdentifier! == "FullBody" {
                resistance["FullBody"] = false
                full.setImage(UIImage(named: "Check.png"), for: .normal)
                resistance["Legs"] = false
                legs.setImage(UIImage(named: "Check.png"), for: .normal)
                resistance["Buttocks"] = false
                butt.setImage(UIImage(named: "Check.png"), for: .normal)
                resistance["Arms"] = false
                arms.setImage(UIImage(named: "Check.png"), for: .normal)
                resistance["Abs"] = false
                abs.setImage(UIImage(named: "Check.png"), for: .normal)
            }
            else {
                resistance[sender.accessibilityIdentifier!]! = true
                sender.setImage(UIImage(named: "Check.png"), for: .normal)
            }
        }
        self.tableView.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerView.accessibilityIdentifier == "al" {
            return self.activities[row]
        } else {
            return self.periods[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerView.accessibilityIdentifier == "al" {
            return self.activities.count
        } else {
            return self.periods.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView.accessibilityIdentifier == "al" {
            if self.activities[row] != nil {
                self.currActivity = activities[row]
            }
        } else {
            if self.periods[row] != nil {
                self.currPeriod = periods[row]
            }
        }
        
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
    }
    func getDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: self.startDatePicker.date)
    }
    
    
    func addPhotoToDB(_ name: String, _ title: String) {
        let storageItem = self.userStorage.child(title).child("\(name).jpg")
        guard let image = self.photos[name] else {return}
        if let newImage = UIImageJPEGRepresentation(image, 0.6){
            storageItem.putData(newImage, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storageItem.downloadURL(completion: {(url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let URL = url?.absoluteString {
                        if let uid = Auth.auth().currentUser?.uid{
                            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(title).updateChildValues([name : URL], withCompletionBlock: { (err, ref) in
                                if err != nil {
                                    self.addErrorAlert(title: "Error!", message: "No internet connection.")
                                    AppDelegate.instance().dismissActivityIndicators()
                                    return
                                }
                            })
                        }
                    }
                })
            })
            
        }
    }
    
    func addImageToDB(_ name: String, _ title: String, _ image: UIImage) {
        let storageItem = self.userStorage.child(title).child("\(name).jpg")
        if let newImage = UIImageJPEGRepresentation(image, 0.6){
            storageItem.putData(newImage, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storageItem.downloadURL(completion: {(url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let URL = url?.absoluteString {
                        if let uid = Auth.auth().currentUser?.uid{
                            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(title).updateChildValues([name : URL], withCompletionBlock: { (err, ref) in
                                if err != nil {
                                    self.addErrorAlert(title: "Error!", message: "No internet connection.")
                                    AppDelegate.instance().dismissActivityIndicators()
                                    return
                                }
                            })
                        }
                    }
                })
            })
            
        }
    }

    @IBAction func addMarathone(_ sender: UIButton) {
        AppDelegate.instance().showActivityIndicator()
        guard self.titletextField.text != "", self.marathoneDetailsTextField.text != "", self.authorInfoTextField.text != ""
            else {
                self.addErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
                AppDelegate.instance().dismissActivityIndicators()
                return
        }
        if self.titletextField.text != "" {
            let nameRegEx = "^[A-Za-z0-9 ]*$"
            let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
            if nameTest.evaluate(with: self.titletextField.text!) == false {
                self.addErrorAlert(title: "Error!", message: "Title in incorrect. It should contains only letters and spaces.")
                AppDelegate.instance().dismissActivityIndicators()
                        return
            }
        }

        var flag = false
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(self.titletextField.text!)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                        if self.titletextField.text! == info {
                            flag = true
                            self.addErrorAlert(title: "Error!", message: "Marathone with such name already exists!")
                            AppDelegate.instance().dismissActivityIndicators()
                            return

                        }
                    }
                }
            })
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("active")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let dict = snapshot.value as? NSDictionary, let info = dict["organizer"] as? String {
                        flag = true
                         self.addErrorAlert(title: "Error!", message: "You can organize only one marathone at one time!")
                        AppDelegate.instance().dismissActivityIndicators()
                        return
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })

            
            if flag == false {
                var res = [String : Bool]()
                for (key, value) in resistance {
                    if value == true {
                        res[key] = value
                    }
                }
                let voc = ["On-time completed tasks" : "0.9",
                           "Completed tasks" : "0.75",
                           "Losted weight" : "0.6",
                           "Losted chest girth" : "0.45",
                           "Losted waist girth" : "0.3",
                           "Losted hip girth" : "15"]

                var values : [String : Any] = ["activityLevel" : self.currActivity,
                                               "creationDate" : self.getToday(),
                                               "marathoneInfo" : self.marathoneDetailsTextField.text!,
                                               "orgInfo" : self.authorInfoTextField.text!,
                                               "organizer" : uid,
                                               "period" : self.currPeriod,
                                               "startDate" : getDate(),
                                               "title" : self.titletextField.text!,
                                               "resistance" : res,
                                               "rank" : voc]
                ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        self.addErrorAlert(title: "Error!", message: "No internet connection.")
                        AppDelegate.instance().dismissActivityIndicators()
                        return
                    } else {
                        for photo in self.photos.keys {
                            self.addPhotoToDB(photo, self.titletextField.text!)
                        }
                        if self.photos["Logo"] == nil {
                            self.addImageToDB("Logo", self.titletextField.text!, UIImage(named: "Logo.png")!)
                        }
                        if self.photos["Background"] == nil {
                            self.addImageToDB("Background", self.titletextField.text!, UIImage(named: "Logo_1.png")!)
                        }
                    }
                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("created").updateChildValues([self.titletextField.text! : self.getDate()], withCompletionBlock: { (err, ref) in
                        if err != nil {
                            self.addErrorAlert(title: "Error!", message: "No internet connection.")
                            AppDelegate.instance().dismissActivityIndicators()
                            return
                        } else {
                            AppDelegate.instance().dismissActivityIndicators()
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("active").updateChildValues(["organizer": self.titletextField.text!], withCompletionBlock: { (err, ref) in
                        if err != nil {
                            self.addErrorAlert(title: "Error!", message: "No internet connection.")
                            AppDelegate.instance().dismissActivityIndicators()
                            return
                        } else {
                            AppDelegate.instance().dismissActivityIndicators()
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                })
            }
        }
       
    }
    
    //Загружаем фото
    func getPhoto(_ title: String) {
        let picker = UIImagePickerController()
        picker.accessibilityLabel = title
        picker.delegate = self
        //изображение будет доступно для редактирования(масштабирование)
        picker.allowsEditing = true
        let alertController = UIAlertController(title: "Chose " + title + " photo", message: "Pick", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
                picker.modalPresentationStyle = .fullScreen
                self.present(picker, animated: true, completion: nil)
            }else {
                self.noCameraErrorAlert(title: "Error!", message: "Camera is not found.")
            }
            
        }
        
        let photoLiraryAction = UIAlertAction(title: "Chose from camera roll", style: .default) { (action) in
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(picker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Back", style: .destructive, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLiraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    //ошибка, если нет камеры
    func noCameraErrorAlert(title: String, message: String) {
        // Всплывающее окно ошибки
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //что происходит, когда пользователь выбирает фотографию?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //сохраняем редактированное изображение в переменную UIImage
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            //обновляем изображение
            self.photos[picker.accessibilityLabel!] = chosenImage
            if self.logo.accessibilityIdentifier == picker.accessibilityLabel! {
                logo.setImage(chosenImage, for: .normal)
            } else if self.bg.accessibilityIdentifier == picker.accessibilityLabel! {
                bg.setImage(chosenImage, for: .normal)
            } else if self.cert1.accessibilityIdentifier == picker.accessibilityLabel! {
                cert1.setImage(chosenImage, for: .normal)
            } else if self.cert2.accessibilityIdentifier == picker.accessibilityLabel! {
                cert2.setImage(chosenImage, for: .normal)
            } else if self.cert1.accessibilityIdentifier == picker.accessibilityLabel! {
                cert3.setImage(chosenImage, for: .normal)
            }
  
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //что происходит, когда пользователь нажимает "отмена"?
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //
    //Кнопка Done которая прячет клавиатуру
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        toolBar.tintColor = .black
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.titletextField.inputAccessoryView = toolBar
        self.marathoneDetailsTextField.inputAccessoryView = toolBar
        self.authorInfoTextField.inputAccessoryView = toolBar
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
    
    func addErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension String {
    var isLiteral: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m"]
        return Set(self.characters).isSubset(of: nums)
    }
    var isLiteralNumeral: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}
