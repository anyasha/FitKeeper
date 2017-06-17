//
//  SignUpViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var comfirmPw: UITextField!
    
    var databaseRef: DatabaseReference!
    var userStorage: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/")
        
        userStorage = storage.child("users")
        
        self.Name.delegate = self
        self.Username.delegate = self
        self.Password.delegate = self
        self.comfirmPw.delegate = self
        
        createToolbar()
        
    }
    
    @IBAction func nameStartTyping(_ sender: UITextField) {
        Name.placeholder = ""
    }
    
    @IBAction func nameCancelEditing(_ sender: Any) {
        Name.placeholder = "Name"
    }
    
    @IBAction func usernameStartTyping(_ sender: UITextField) {
        Username.placeholder = ""
    }
    
    @IBAction func usernameCancelEditing(_ sender: Any) {
        Username.placeholder = "Email"
    }
    
    @IBAction func passwordStartTyping(_ sender: UITextField) {
        Password.placeholder = ""
    }
    
    @IBAction func passwordCancelEditing(_ sender: Any) {
        Password.placeholder = "Password"
    }
    
    @IBAction func confirmPwStartTyping(_ sender: UITextField) {
        comfirmPw.placeholder = ""
    }
    
    @IBAction func confirmPwCancelEditing(_ sender: Any) {
        comfirmPw.placeholder = "Password"
    }
    
    //Загружаем фото
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
            profileImageView.image = chosenImage
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //что происходит, когда пользователь нажимает "отмена"?
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }

    //Создание аккаунта
    @IBAction func CreateAccount(_ sender: Any) {
        
        //показать индикатор загрузки
        AppDelegate.instance().showActivityIndicator()
        
        //Проверка на правильность введённых данных
        guard Name.text != "", Username.text != "", Password.text != ""
            else {
                self.signupErrorAlert(title: "Error!", message: "Empty fields are forbidden. Try again.")
                self.Password.text = ""
                self.comfirmPw.text = ""
                //послезагрузки изображения индикатор исчезнет
               AppDelegate.instance().dismissActivityIndicators()
                return
        }
        
        if Name.text != "" {
            let nameRegEx = "^[A-Za-z ]*$"
            let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
            if nameTest.evaluate(with: Name.text!) == false {
                self.signupErrorAlert(title: "Error!", message: "Name in incorrect. It should contains only letters and spaces.")
            }
        }
        
        if Username.text != "" {
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if emailTest.evaluate(with: Username.text!) == false {
                self.signupErrorAlert(title: "Error!", message: "Email in incorrect. Try again.")
            }
            
        }

        
        //Проверка на совпадение паролей
        if Password.text == comfirmPw.text {
            
            //1 ----- Создание аккаунта в Authentication
            
            Auth.auth().createUser(withEmail: Username.text!, password: Password.text!, completion: { (user, error) in
                
                if error != nil {
                    
                    self.signupErrorAlert(title: "Error!", message: "User with such email already exist.")
                    self.Password.text = ""
                    self.comfirmPw.text = ""
                    
                    //послезагрузки изображения индикатор исчезнет
                    AppDelegate.instance().dismissActivityIndicators()
                    
                }
                guard let uid = user?.uid
                    
                    else { return }
                
                
                //создаем хранилище в FirebaseStorage
                let storageItem = self.userStorage.child("\(uid).jpg")
                
                //получить изображение из библиотеки фотографий
                guard let image = self.profileImageView.image else {return}
                
                            
            //2 ----- Сохранение аккаунта в Database и сохранение фото в Storage
                
                let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/")
                
                let usersReference = ref.child("users").child(uid)
                
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
                                
                                let values = ["email": self.Username.text!, "username": self.Name.text!, "uid": user?.uid, "photo": profilePhotoURL]
                                
                                //Занасим данные в FirebaseDatabase
                                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                                    
                                    if err != nil {
                                        
                                        self.signupErrorAlert(title: "Error!", message: "No internet connection.")
                                        self.Password.text = ""
                                        self.comfirmPw.text = ""
                                        
                                        //послезагрузки изображения индикатор исчезнет
                                        AppDelegate.instance().dismissActivityIndicators()
                                        
                                        return
                                    } else {
                                            
                                            //3 ----- Если пользователь был успешно зарегистрирован, происходит автоматический вход.
                                            
                                            Auth.auth().signIn(withEmail: self.Username.text!, password: self.Password.text!, completion: { (user, error) in
                                                
                                                if error != nil {
                                                    self.signupErrorAlert(title: "Error!", message: "Incorrect data.")
                                                    self.Password.text = ""
                                                    self.comfirmPw.text = ""
                                                    
                                                }else {
                                                    
                                                    //4 ----- Переход к приложению
                                                    
                                                    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                                    appDel.Step1User()
                                                    
                                                }})
                                        }
                                        
                                    })
                    }
                })
            })
                        
                }})
            //послезагрузки изображения индикатор исчезнет
            AppDelegate.instance().dismissActivityIndicators()
            
        }else {
            self.signupErrorAlert(title: "Error!", message: "Passwors are not equal>")
            self.Password.text = ""
            self.comfirmPw.text = ""
            
            //послезагрузки изображения индикатор исчезнет
            AppDelegate.instance().dismissActivityIndicators()
        }
    }
    
    //Кнопка Done которая прячет клавиатуру
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        toolBar.tintColor = .black
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        Username.inputAccessoryView = toolBar
        Name.inputAccessoryView = toolBar
        Password.inputAccessoryView = toolBar
        comfirmPw.inputAccessoryView = toolBar
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
    
    func signupErrorAlert(title: String, message: String) {
        
        // Всплывающее окно ошибки
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    //Segue to SignUpViewController
    @IBAction func unwindToSignUp(storyboard:UIStoryboardSegue){
    }
}
