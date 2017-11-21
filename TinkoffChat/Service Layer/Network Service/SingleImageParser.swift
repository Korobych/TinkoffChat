//
//  SingleImageParser.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 21.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import UIKit

struct SingleImageModel {
    let image: UIImage
}

class SingleImageParser: ParserProtocol {
    
    typealias model = SingleImageModel
    
    func parse(data: Data) -> SingleImageModel? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        
        return SingleImageModel(image: image)
    }
}
