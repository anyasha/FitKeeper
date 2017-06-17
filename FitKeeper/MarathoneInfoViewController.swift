

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class MarathoneInfoViewController: UIViewController {
    
    @IBOutlet var scroller: UIScrollView!
    
    var marathone = ""
   // var currMarathone = [String: Any]()
    
     var storage: StorageReference!
    var ustorage: StorageReference!
    
    @IBOutlet weak var titleM: UITextField!
    @IBOutlet weak var logo: CustomImageView!
    @IBOutlet weak var members: UILabel!
    @IBOutlet weak var weeks: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var activity: UILabel!
    @IBOutlet weak var datils: UITextView!
    @IBOutlet weak var pic: CustomImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var organizer: UITextView!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var cert1: UIButton!
    @IBOutlet weak var cert2: UIButton!
    @IBOutlet weak var cert3: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Прозрачный  Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        //Кнопка назад без названия
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
         self.navigationController?.hidesBarsOnSwipe = true
        
         scroller.isScrollEnabled = true
         scroller.contentSize = CGSize(width: 414.0, height: 1200.0)
        
         storage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/").child("marathones")
         ustorage = Storage.storage().reference(forURL: "gs://fitkeeper-e9117.appspot.com/").child("users")
    }
    
    @IBAction func join(_ sender: Any) {
        var flag = false
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("active")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() {
                    ref.updateChildValues(["participant" : self.marathone])
                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("participated").updateChildValues([self.marathone : self.getToday()])
                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).updateChildValues([uid: true])
                    self.dismiss(animated: true, completion: nil)

                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["participant"] as? String {
                    self.marathoneErrorAlert(title: "Error!", message: "You can participate only in ONE marathone at one time!")
                    return
                } else {
                    var parameters = ["overdueTasks" : "0",
                                      "intimeTasks" : "0",
                                      "weightInit" : "0",
                                      "weightLast" : "0",
                                      "hipInit" : "0",
                                      "hipLast" : "0",
                                      "chestInit" : "0",
                                      "chestLast" : "0",
                                      "waistInit" : "0",
                                      "waistLast" : "0",
                                      "photoBefore" : "0",
                                      "photoAfter" : "0"
                                      ]
                    ref.updateChildValues(["participant" : self.marathone])
                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(uid).child("marathones").child("participated").updateChildValues([self.marathone : self.getToday()])
                    Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(self.marathone).updateChildValues([uid: ["isMember" : "true",
                                                 "progress" : parameters]])
                    self.dismiss(animated: true, completion: nil)

                    }
            })
        }
    }
    
    func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: Date())
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

    
    override func viewDidAppear(_ animated: Bool) {
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("marathones").child(marathone)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary, let info = dict["startDate"] as? String {
                    self.date.text = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["title"] as? String {
                    self.titleM.text = info.uppercased()
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["period"] as? String {
                    self.weeks.text = info + " WEEKS"
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["activityLevel"] as? String {
                    self.activity.text = info.uppercased()
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["marathoneInfo"] as? String {
                    self.datils.text = info
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["orgInfo"] as? String {
                    self.organizer.text = info
                }

                if let dict = snapshot.value as? NSDictionary, let info = dict["organizer"] as? String {
                    let uref = Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("users").child(info as! String).observeSingleEvent(of: .value, with: { snapshot in
                        if !snapshot.exists() { return }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["username"] as? String {
                            self.name.text = info
                        }
                        if let dict = snapshot.value as? NSDictionary, let info = dict["bday"] as? String {
                            self.age.text = String(self.getAge(info)) + " y.o."
                        }
                        self.ustorage.child("\(info).jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                            DispatchQueue.main.async() {
                                self.pic.image = UIImage(data: data!)
                            }
                        })
                    })
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["Logo"] as? String {
                    self.storage.child(self.marathone).child("Logo.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                        DispatchQueue.main.async() {
                            self.logo.image = UIImage(data: data!)
                        }
                    })
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["Certificate1"] as? String {
                    self.storage.child(self.marathone).child("Certificate1.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                        DispatchQueue.main.async() {
                            self.cert1.setImage(UIImage(data: data!), for: .normal)
                            self.cert1.isEnabled = true
                        }
                    })
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["Certificate2"] as? String {
                    self.storage.child(self.marathone).child("Certificate2.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                        DispatchQueue.main.async() {
                            self.cert2.setImage(UIImage(data: data!), for: .normal)
                             self.cert2.isEnabled = true
                        }
                    })
                }
                if let dict = snapshot.value as? NSDictionary, let info = dict["Certificate3"] as? String {
                    self.storage.child(self.marathone).child("Certificate3.jpg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                        DispatchQueue.main.async() {
                            self.cert3.setImage(UIImage(data: data!), for: .normal)
                             self.cert3.isEnabled = true
                        }
                    })
                }
            })
            Database.database().reference(fromURL: "https://fitkeeper-e9117.firebaseio.com/").child("members").child(marathone).observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { return }
                if let dict = snapshot.value as? NSDictionary {
                    self.members.text = String(dict.count)
                }
                else {
                    self.members.text = "0"
                }
            })
        }
    }
    
    
    func marathoneErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    @IBAction func showCert(_ sender: UIButton) {
        performSegue(withIdentifier: "CertificateModal", sender: sender.currentImage)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CertificateModal" {
            let guest = segue.destination as! ShowCertificateViewController
            guest.img = sender as! UIImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        scroller.contentSize = CGSize(width: 414.0, height: 1200.0)
    }
}
