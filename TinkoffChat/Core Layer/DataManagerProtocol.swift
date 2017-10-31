//
//  DataManagerProtocol.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol DataManagerProtocol {
    func write(profile: Profile, completion: @escaping (_ success: Bool) -> ())
    func read(completion: @escaping (_ profile: Profile) -> ())
}

//extra property to get fileName
extension DataManagerProtocol{
    
    var fileName: String {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = url.appendingPathComponent("ProfileInfo")
        return path.path
    }
}
