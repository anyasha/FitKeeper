//
//  PhotoViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var marathone = ""
    var date = ""
    var time = ""
    
    var titleE = ""
    var photoURL = ""
    var isUsed = false
    
    var photoURl = ""
    
    var storage: StorageReference!
    // var ustorage: StorageReference!
    var userStorage: StorageReference!
    
    var photo = UIImage()
    
    
    @IBOutlet weak var header: UINavigationItem!
    @IBOutlet weak var exercise: UILabel!
    @IBOutlet weak var text: UITextView!
    
    @IBOutlet weak var photoBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        // self.navigationController?.hidesBarsOnSwipe = true
        
        
        self.header.title = marathone
        
        let storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/")
        //ustorage = storage.child("marathones").child(marathone).child("materials").child(self.date)
        
        
        if let uid = Auth.auth().currentUser?.uid{
            userStorage = storage.child("marathoneMembers").child(marathone).child(uid)
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
                    //                    if self.photoURL != "" {
                    //                        self.ustorage.child(self.time.trimmingCharacters(in: .whitespaces) + ".jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                    //                            DispatchQueue.main.async() {
                    //                                self.photo.image = UIImage(data: data!)!
                    //                            }
                    //                        })
                    //                    }
                }
            })
        }
        
    }
    
    @IBAction func add(_ sender: UIButton) {
        if isUsed == false {
            
            if let uid = Auth.auth().currentUser?.uid {
                let storageItem = self.userStorage.child("\(self.date.trimmingCharacters(in: .whitespaces))\(self.time.trimmingCharacters(in: .whitespaces)).jpg")
                let image = self.photo
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
                                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("photos").updateChildValues([self.getToday().trimmingCharacters(in: .whitespaces) + self.time : URL], withCompletionBlock: { (err, ref) in
                                    if err != nil {
                                        self.addErrorAlert(title: "Error!", message: "No internet connection.")
                                        AppDelegate.instance().dismissActivityIndicators()
                                        return
                                    } else {
                                        let val = self.compareDates(self.getToday(), self.date) == true ? "intime" : "overdue"
                                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child(self.date).updateChildValues([self.time : val])
                                    }
                                })
                                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").child("photoBefore").observeSingleEvent(of: .value, with: { snapshot in
                                    if ( snapshot.value is NSNull ) {
                                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").updateChildValues(["photoBefore" : URL], withCompletionBlock: { (err, ref) in
                                            if err != nil {
                                                self.addErrorAlert(title: "Error!", message: "No internet connection.")
                                                AppDelegate.instance().dismissActivityIndicators()
                                                return
                                            } else {
                                                let val = self.compareDates(self.getToday(), self.date) == true ? "intime" : "overdue"
                                                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child(self.date.trimmingCharacters(in: .whitespaces)).updateChildValues([self.time : val])
                                                if let uid = Auth.auth().currentUser?.uid{
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
                                        })
                                    } else {
                                        Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child("progress").updateChildValues(["photoAfter" : URL], withCompletionBlock: { (err, ref) in
                                            if err != nil {
                                                self.addErrorAlert(title: "Error!", message: "No internet connection.")
                                                AppDelegate.instance().dismissActivityIndicators()
                                                return
                                            } else {
                                                let val = self.compareDates(self.getToday(), self.date) == true ? "intime" : "overdue"
                                                Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).child(uid).child(self.date.trimmingCharacters(in: .whitespaces)).updateChildValues([self.time : val])
                                                if let uid = Auth.auth().currentUser?.uid{
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
                                        })
                                    }
                                })
                            }
                        })
                    })
                    
                }
                
            }
        }
        self.dismiss(animated: true, completion: nil)
        //_ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func getPhoto(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        //изображение будет доступно для редактирования(масштабирование)
        picker.allowsEditing = true
        let alertController = UIAlertController(title: "Chose photo", message: "Pick", preferredStyle: .actionSheet)
        
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
            self.photoBTN.setImage(chosenImage, for: .normal)
            self.photo = chosenImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //что происходит, когда пользователь нажимает "отмена"?
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
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
    
    func addErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
