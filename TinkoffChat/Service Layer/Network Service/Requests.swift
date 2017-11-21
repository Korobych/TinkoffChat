//
//  Requests.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 21.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

//Request for List of images
class ImagesListRequest : RequestProtocol {
    
    var urlRequest: URLRequest?
    // hardcoded category
    let neededCategory = "sky"
    init(apiKey: String, page: Int = 1) {
        guard let url = URL(string: "https://pixabay.com/api/?key=\(apiKey)&q=\(neededCategory)&image_type=photo&page=\(page)")
            
        else {
            print("Can't create url with current parameters...")
            
            return
        }
        urlRequest = URLRequest(url: url)
    }
}

//Request for single image
class SingleImageRequest: RequestProtocol {
    var urlRequest: URLRequest?
    init(url: URL) {
        urlRequest = URLRequest(url: url)
    }
}
