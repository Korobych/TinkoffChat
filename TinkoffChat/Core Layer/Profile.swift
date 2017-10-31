//
//  Profile.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import UIKit


class Profile: NSObject, NSCoding {
    enum Parts {
        static let photo = "photo"
        static let name = "name"
        static let info = "info"
    }
    
    var photo: UIImage
    var name: String
    var info: String
    
    override init() {
        photo = #imageLiteral(resourceName: "placeholder-user")
        name = "Serg Korobin"
        info = "Readhead programmer. Swift is my passion. :D"
    }
    
    init(photo: UIImage, name: String, info: String) {
        self.photo = photo
        self.name = name
        self.info = info
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: Parts.name) as? String,
            let photo = aDecoder.decodeObject(forKey: Parts.photo) as? UIImage,
            let info = aDecoder.decodeObject(forKey: Parts.info) as? String
            else { return nil }
        self.photo = photo
        self.name = name
        self.info = info
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Parts.name)
        aCoder.encode(photo, forKey: Parts.photo)
        aCoder.encode(info, forKey: Parts.info)
    }
}

