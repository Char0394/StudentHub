//
//  ImageTransformer.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/13/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import UIKit

class ImageTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> Swift.AnyClass {
        return NSData.self
    }
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    override func transformedValue(_ value: Any?) -> Any? {
        return UIImagePNGRepresentation((value as! UIImage?)!)
    }
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        return UIImage(data: (value as? Data)!)
    }
}

