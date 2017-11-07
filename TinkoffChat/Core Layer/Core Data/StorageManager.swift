//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class StorageManager: DataManagerProtocol  {
    

    let dataStack: CoreDataStackProtocol
    init(withStack dataStack: CoreDataStackProtocol) {
        self.dataStack = dataStack
    }

    func write(profile: Profile, completion: @escaping (_ success: Bool) -> ()){

        guard let appUser = AppUser.findOrInsertAppUser(in: dataStack.saveContext!) else {
            completion(false)
            return
        }
        guard let user = appUser.currentUser else {
            completion(false)
            return
        }

        let photoRepresentation = UIImagePNGRepresentation(profile.photo)
        user.name = profile.name
        user.info = profile.info
        user.photo = photoRepresentation

        dataStack.saveContext?.perform {
            self.dataStack.performSave(context: self.dataStack.saveContext!) {(success) in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
    }

    func read(completion: @escaping (_ profile: Profile) -> ()) {
        dataStack.saveContext?.perform {
            guard let appUser = AppUser.findOrInsertAppUser(in: self.dataStack.saveContext!)
            else {
                print("Completion error")
                return
                }
            guard let user = appUser.currentUser else {
                print("can't find current app User")
                return
            }
            var image = #imageLiteral(resourceName: "placeholder-user")
            if let photo = user.photo {
                image = UIImage(data: photo as Data)!
            }
            let profile = Profile.init(photo: image, name: user.name, info: user.info)
            print("я внутри Storage Manager!!\n")
            DispatchQueue.main.async {
                completion(profile)
            }
        }
    }

}



