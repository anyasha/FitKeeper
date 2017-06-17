//
//  CustomImageView.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidht: CGFloat = 0 {
        didSet{
            layer.borderWidth = borderWidht
        }
    }
}
