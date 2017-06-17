//
//  EditProfileTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let lifestyles = ["Sedentary", "LightActive", "ModeratelyActive", "VeryActive"]
    
    var name : String = ""
    var photo : String = ""
    var email : String = ""
    var bday : String = ""
    var sex : String = ""
    var lifestyle : String = ""
    var selectedLifestyle = ""

    var url : String = ""
    
    var userStorage: StorageReference!
    
    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var lifestylePicker: UIPickerView!
    
    @IBOutlet weak var bdayPicker: UIDatePicker!
    @IBOutlet weak var mainView: UIView!
    
        override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.lifestylePicker.dataSource = self
        self.lifestylePicker.delegate = self
        
        let storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/")
        
        userStorage = storage.child("users")
        
        getUserInfo()
        
        createToolbar()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        //Скрывающийся navigationBar
        self.navigationController?.hidesBarsOnSwipe = true
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return lifestyles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return lifestyles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if lifestyles[row] != nil {
            self.selectedLifestyle = lifestyles[row]
        }
    }
    

    
    func rewrightData() {
        self.nameLabel.text = name
        self.emailLabel.text = email
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "dd MM yyyy"
        self.bdayPicker.date = dateFormatter.date(from: String(describing: bday))!
        self.gender.selectedSegmentIndex = sex == "male" ? 0 : 1
        let find = self.lifestyles.index(of: lifestyle)
        self.lifestylePicker.selectRow(find!, inComponent: 0, animated: true)
        self.selectedLifestyle = lifestyle
    }
    
    @IBAction func save(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "dd MM yyyy"
        
        guard nameLabel.text != "", emailLabel.text != ""
            else {
                self.myErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
                return
        }
        if emailLabel.text != "" {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if emailTest.evaluate(with:  emailLabel.text!) == false {
                self.myErrorAlert(title: "Error!", message: "Email in incorrect. Try again.")
                return
            }
        }
        if nameLabel.text != "" {
            let nameRegEx = "^[A-Za-z ]*$"
            let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
            if nameTest.evaluate(with: nameLabel.text!) == false {
                self.myErrorAlert(title: "Error!", message: "Name in incorrect. It should contains only letters and spaces.")
                return
            }
        }

        if let uid = Auth.auth().currentUser?.uid {
            
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/")
            
            let usersReference = ref.child("users").child(uid)
            let values = ["bday": dateFormatter.string(from: self.bdayPicker.date),
                          "email" : emailLabel.text != nil ? emailLabel.text : email,
                          "username" : nameLabel.text != nil ? nameLabel.text : name,
                          "sex" : gender.selectedSegmentIndex == 0 ? "male" : "female",
                          "lifestyle" : selectedLifestyle]
            
            usersReference.updateChildValues(values)
        }

    }
    
    func getUserInfo() {
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["bday"] as? String {
                    self.bday = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["photo"] as? String {
                    self.photo = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                    self.name = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["sex"] as? String {
                    self.sex = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["lifestyle"] as? String {
                    self.lifestyle = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["email"] as? String {
                    self.email = info
                }
                if self.photo != "" {
                    self.userStorage.child(uid + ".jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                        DispatchQueue.main.async() {
                            self.profileImageView.image = UIImage(data: data!)
//                            self.tableView.reloadData()
//                            self.mainView.reloadInputViews()
                        }
                    })
                }
                
                self.rewrightData()
            })
        }
    }
    
    
    @IBAction func getPhoto(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        //изображение будет доступно для редактирования(масштабирование)
        picker.allowsEditing = true
        
        let alertController = UIAlertController(title: "Chose profile photo", message: "Pick", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
                picker.modalPresentationStyle = .fullScreen
                self.present(picker, animated: true, completion: nil)
            } else {
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
        
        
        if let uid = Auth.auth().currentUser?.uid{
            let storageItem = self.userStorage.child("\(uid).jpg")
            
            //получить изображение из библиотеки фотографий
            guard let image = self.profileImageView.image else {return}
            if let newImage = UIImageJPEGRepresentation(image, 0.6){
                //загрузить фото в FirebaseStorage
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
                        if let profilePhotoURL = url?.absoluteString {
                            self.url = profilePhotoURL
                        }
                    })
                })
                
            }
        }
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
            self.profileImageView.image = chosenImage
        }
        
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid)
            var data = NSData()
            data = UIImageJPEGRepresentation(self.profileImageView.image!, 0.6) as! NSData
            
            let storageItem = self.userStorage.child("\(uid).jpg")
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            storageItem.putData(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else{
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    ref.updateChildValues(["photo": downloadURL])
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        toolBar.tintColor = .black
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        emailLabel.inputAccessoryView = toolBar
        nameLabel.inputAccessoryView = toolBar
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
    
    func myErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    //что происходит, когда пользователь нажимает "отмена"?
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //Segue to ProfileViewController
    @IBAction func unwindToProfile(storyboard:UIStoryboardSegue){
    }
}
