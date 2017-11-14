//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import UIKit

class GCDDataManager: DataManagerProtocol {
    //
    var profile = Profile()
    //
    func write(profile: Profile, completion: @escaping (_ success: Bool) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            if NSKeyedArchiver.archiveRootObject(profile, toFile: self.fileName) {
                DispatchQueue.main.async {
                    completion(true)
                    print("запись в файл произошла\n")
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                    print("запись в файл не произошла\n")
                }
            }
        }
    }
    func read(completion: @escaping (_ profile: Profile) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let storedData = NSKeyedUnarchiver.unarchiveObject(withFile: self.fileName) as? Profile {
                self.profile = storedData
            }
            DispatchQueue.main.async {
                print("Профиль прочитался из GCD")
                completion(self.profile)
            }
        }
    }
}

