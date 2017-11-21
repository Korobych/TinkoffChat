//
//  ImagesListParser.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 21.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

struct ImagesListModel {
    let url: String
}

class ImagesListParser: ParserProtocol {
    
    typealias model = [ImagesListModel]
    var modelsStorage : [ImagesListModel] = []
    func parse(data: Data) -> [ImagesListModel]? {
        do {
            
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return nil
            }
            
            guard let items = json["hits"] as? [[String: AnyObject]] else {
                return nil
            }
            
            for item in items {
                guard let url = item["webformatURL"] as? String else {
                    continue
                }
                modelsStorage.append(ImagesListModel(url: url))
            }
            
            return modelsStorage
            
        } catch {
            print("Can't get data from JSON\n\(error)")
            return nil
        }
    }
}
