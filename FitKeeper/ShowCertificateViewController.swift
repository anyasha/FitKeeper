//
//  ShowCertificateViewController.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import Foundation
import UIKit

class ShowCertificateViewController: UIViewController {
    
    var img = UIImage()
    //var  = UIImage(named: "cert1.png")
    
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = img
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func close(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
    
    
}
