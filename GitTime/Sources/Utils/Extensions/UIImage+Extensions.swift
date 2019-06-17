//
//  UIImage+Extensions.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

extension UIImage {
    class func assetImage(name: ImageNames) -> UIImage {
        guard let image = UIImage(named: name.imageName) else { fatalError("Not found in Assets..") }
        return image
    }
}
