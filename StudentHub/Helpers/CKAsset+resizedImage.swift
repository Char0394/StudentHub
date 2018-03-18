//
//  CKAsset+resizedImage.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/5/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

extension CKAsset {
    
    private static let kWidth: CGFloat = 210.0
    
    var resizedRoundedImage: UIImage? {
        if let data = NSData(contentsOf: self.fileURL),
            let image = UIImage(data: data as Data) {
            return image.resizedRoundedImage(CKAsset.kWidth)
        }
        return nil
    }
    
}

