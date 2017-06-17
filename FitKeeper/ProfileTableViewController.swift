//
//  ProfileTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var age : Int = 0
    var name : String = ""
    var photo : String = ""
    var gender : String = ""
    var height : Double = 0
    var weight: Double = 0
    var hip : Double = 0
    var waist: Double = 0
    var chest : Double = 0
    
    var url : String = ""
    
    var userStorage: StorageReference!
    
    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UITextField!
    @IBOutlet weak var weightLabel: UITextField!
    @IBOutlet weak var chestLabel: UITextField!
    @IBOutlet weak var waistLabel: UITextField!
    @IBOutlet weak var hipLabel: UITextField!
    
    @IBOutlet weak var heightButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var chestButton: UIButton!
    @IBOutlet weak var waistButton: UIButton!
    @IBOutlet weak var hipButton: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getUserInfo()

        let storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/")
        
        userStorage = storage.child("users")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //Прозрачный  Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getUserInfo()
        self.mainView.reloadInputViews()
        self.mainView.setNeedsDisplay()
        self.view.setNeedsDisplay()
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 1 {
            performSegue(withIdentifier: "ProfileCharts", sender: indexPath.row - 1)
        }
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

    func rewrightData() {
        self.nameLabel.text = name
        self.ageLabel.text = String(age) + " years"
        self.heightLabel.text = String(height) + " cm"
        self.weightLabel.text = String(weight) + " kg"
        self.chestLabel.text = String(chest) + " cm"
        self.waistLabel.text = String(waist) + " cm"
        self.hipLabel.text = String(hip) + " cm"
    }
    
    func getUserInfo() {
        
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["bday"] as? String {
                    self.age = self.getAge(info)
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["photo"] as? String {
                    self.photo = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                    self.name = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["sex"] as? String {
                    self.gender = info
                }
                if self.photo != "" {
                    self.userStorage.child(uid + ".jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                        DispatchQueue.main.async() {
                            self.profileImageView.image = UIImage(data: data!)
                            self.tableView.reloadData()
                            self.mainView.reloadInputViews()
                        }
                    })
                }

                self.rewrightData()
            })
            let parametrsRef = ref.child("parameters")
            parametrsRef.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["height"] as? String {
                    self.height = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["weight"] as? String {
                    self.weight = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["hip"] as? String {
                    self.hip = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["waist"] as? String {
                    self.waist = Double(info)!
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["chest"] as? String {
                    self.chest = Double(info)!
                }
                self.rewrightData()
            })
            
        }
    }

  
    @IBAction func logOut(_ sender: Any) {
       
        let alert = UIAlertController(title: "", message: "Вы уверены, что хотите выйти?", preferredStyle: UIAlertControllerStyle.alert)
        //Кнопка ДА с действием
        let actionYes = UIAlertAction(title: "Да", style: .default, handler: { action in
            if Auth.auth().currentUser != nil {
                do {
                    try Auth.auth().signOut()
                    let LoginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login")
                    UIApplication.shared.keyWindow?.rootViewController = LoginViewController
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        })
        //Кнопка нет
        let actionNo = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        //Добовляем кнопки
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        //Показать всплывающее окно
        present(alert, animated: true, completion: nil)
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
    
    @IBAction func plusButton(_ sender: UIButton) {
        performSegue(withIdentifier: "AddParameter", sender: sender.tag)
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddParameter" {
            let guest = segue.destination as! AddParameterViewController
            guest.tag = sender as! Int
            
        }
        if segue.identifier == "ProfileCharts" {
            let guest = segue.destination as! ProfileChartsViewController
            guest.tag = sender as! Int
            
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

    //что происходит, когда пользователь нажимает "отмена"?
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }

    //Segue to ProfileViewController
    @IBAction func unwindToProfile(storyboard:UIStoryboardSegue){
    }
}
