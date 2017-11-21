//
//  PictureCollectionViewCustomCell.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 20.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

class PictureCollectionViewCustomCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewCell: UIImageView!
    
    var image : UIImage? {
        get {
            return self.imageViewCell?.image
        }
        
        set (newImage) {
            if let newImage = newImage {
                self.imageViewCell?.image =  newImage
            }
        }
    }
}
