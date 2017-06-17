//
//  AddAdviceTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

//
//  AddMotivationTableViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AddAdviceTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var date = ""
    var marathone = ""
    var titl = ""
    
    
    var time = ""
    var photo = UIImage()
     var photoURL = ""
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var header: UINavigationItem!
    
    var databaseRef: DatabaseReference!
    var userStorage: StorageReference!
    
    @IBOutlet weak var titleF: UITextField!
    @IBOutlet weak var textF: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)
         self.navigationController?.hidesBarsOnSwipe = false
        
        
        
        self.header.title = titl.capitalized
        if time == "" {
            time = getTime()
        } else {
            if let uid = Auth.auth().currentUser?.uid{
                let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).child(self.date).child(self.time.trimmingCharacters(in: .whitespaces))
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if ( snapshot.value is NSNull ) {
                        print("not found")
                    } else {
                        if let dict = snapshot.value as? NSDictionary, let info = dict["text"] as? String {
                            self.textF.text = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                            self.titleF.text = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["photo"] as? String {
                            self.photoURL = info
                        }
                        if self.photoURL != "" {
                            Storage.storage().reference(forURL: self.photoURL).getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                DispatchQueue.main.async() {
                                    self.photo = UIImage(data: data!)!
                                    self.photoButton.setImage(self.photo, for: .normal)
                                }
                            })
                        }
                        
                    }
                })
            }
        }

        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105/255, green: 215/255, blue: 202/255, alpha: 1)

    }
    
    func getTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        return (String(calendar.component(.hour, from: date)) + " " + String(calendar.component(.minute, from: date)) + " " + String(calendar.component(.second, from: date)))
    }
    
    @IBAction func add(_ sender: UIButton) {
        if self.photo == UIImage() {
              self.noCameraErrorAlert(title: "Error!", message: "Add photo.")
        } else {
            AppDelegate.instance().showActivityIndicator()
            if self.textF.text != "" && self.titleF.text != "" {
                let txt = self.textF.text
                let ttl = self.titleF.text
                if let uid = Auth.auth().currentUser?.uid{
                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).child(self.date).updateChildValues( [ self.time.trimmingCharacters(in: .whitespaces) :
                        ["type" : self.titl,
                         "title" : ttl,
                         "time" : self.time,
                         "text" : txt ]])
                    var a = self.time.trimmingCharacters(in: .whitespaces)
                    let storageItem = self.userStorage.child("\(a.trimmingCharacters(in: .whitespaces)).jpg")
                   // guard let image = self.photo else {return}
                    if let newImage = UIImageJPEGRepresentation(self.photo, 0.6){
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
                                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathoneMaterials").child(self.marathone).child(self.date).updateChildValues( [ self.time.trimmingCharacters(in: .whitespaces) :
                                        ["type" : self.titl,
                                         "title" : ttl,
                                         "time" : self.time,
                                         "text" : txt,
                                        "photo" : URL]])
                                }
                            })
                        })
                        
                    }

              }
            AppDelegate.instance().dismissActivityIndicators()
             _ = navigationController?.popViewController(animated: true)
            } else {
                self.noCameraErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
                //послезагрузки изображения индикатор исчезнет
                AppDelegate.instance().dismissActivityIndicators()
                return
            }
              _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func addErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.accessibilityLabel = title
        picker.delegate = self
        //изображение будет доступно для редактирования(масштабирование)
        picker.allowsEditing = true
        let alertController = UIAlertController(title: "Chose  photo", message: "Pick", preferredStyle: .actionSheet)
        
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
            self.photo = chosenImage
            self.photoButton.setImage( self.photo , for: .normal)
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //что происходит, когда пользователь нажимает "отмена"?
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
