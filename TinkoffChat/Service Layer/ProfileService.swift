//
//  ProfileService.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol ProfileServiceProtocol {
    
    func getProfile(completion: @escaping (Profile) -> ())
    func saveProfileUsingGCD(_ profile: Profile, completion: @escaping (_ success: Bool) -> ())
    func saveProfileUsingOperation(_ profile: Profile, completion: @escaping (_ success: Bool) -> ())
    func saveProfileUsingCoreData(_ profile: Profile, completion: @escaping (_ success: Bool) -> ())
}

class ProfileService: ProfileServiceProtocol {
 //
    var dataManager: DataManagerProtocol = GCDDataManager()
    //
    let coreDataStack = CoreDataStack()
    
    func getProfile(completion: @escaping (Profile) -> ()) {
        dataManager = StorageManager(withStack: coreDataStack)
        dataManager.read(completion: completion)
    }
        
    func saveProfileUsingGCD(_ profile: Profile, completion: @escaping (_ success: Bool) -> ()) {
        //changing to GCDDataManager
        dataManager = GCDDataManager()
        dataManager.write(profile: profile, completion: completion)
    }
    
    func saveProfileUsingOperation(_ profile: Profile, completion: @escaping (_ success: Bool) -> ()) {
        //changing to OperationDataManager
        dataManager = OperationDataManager()
        dataManager.write(profile: profile, completion: completion)
    }
    
    func saveProfileUsingCoreData(_ profile: Profile, completion: @escaping (_ success: Bool) -> ()) {
        
        let storage = StorageManager(withStack: coreDataStack)
        dataManager = storage
        print("Зашли в сохранение core data")
        dataManager.write(profile: profile, completion: completion)
    }
}

