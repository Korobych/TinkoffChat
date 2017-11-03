//
//  ProfileModel.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileManagerProtocol {
    weak var delegate: ProfileManagerDelegateProtocol? {get set}
    func getProfileInfo()
    func saveProfileUsingGCD(photo: UIImage?, name: String?, info: String?)
    func saveProfileUsingOperation(photo: UIImage?, name: String?, info: String?)
    func profileDidChange(photo: UIImage?, name: String?, info: String?) -> Bool
}

protocol ProfileManagerDelegateProtocol: class {
    func didGet(profileViewModel: ProfileViewModel)
    func didFinishSave(success: Bool)
}

class ProfileViewModel {
    let photo: UIImage
    let name: String
    let info: String
    
    init(profile: Profile) {
        self.photo = profile.photo
        self.name = profile.name
        self.info = profile.info
    }
    
    init(photo: UIImage, name: String, info: String) {
        self.photo = photo
        self.name = name
        self.info = info
    }
}

class ProfileManager: ProfileManagerProtocol {
    //
    var lastSavedProfile: Profile?
    weak var delegate: ProfileManagerDelegateProtocol?
    let profileService: ProfileServiceProtocol = ProfileService()
    //
    func getProfileInfo() {
        profileService.getProfile { [weak self] profile in
            let profileViewModel = ProfileViewModel(profile: profile)
            self?.delegate?.didGet(profileViewModel: profileViewModel)
            self?.lastSavedProfile = profile
        }
    }
    
    func saveProfileUsingGCD(photo: UIImage?, name: String?, info: String?) {
        guard let photo = photo, let name = name, let info = info else {
            self.delegate?.didFinishSave(success: false)
            return
        }
        
        let profile = Profile(photo: photo, name: name, info: info)
        profileService.saveProfileUsingGCD(profile) { [weak self] success in
            self?.delegate?.didFinishSave(success: success)
            self?.lastSavedProfile = profile
        }
    }
    
    func saveProfileUsingOperation(photo: UIImage?, name: String?, info: String?) {
        guard let photo = photo, let name = name, let info = info else {
            self.delegate?.didFinishSave(success: false)
            return
        }
        
        let profile = Profile(photo: photo, name: name, info: info)
        profileService.saveProfileUsingOperation(profile) { [weak self] success in
            self?.delegate?.didFinishSave(success: success)
            self?.lastSavedProfile = profile
        }
    }
    
    func profileDidChange(photo: UIImage?, name: String?, info: String?) -> Bool {
        var checkingFlag: Bool = false
        guard let lastSavedProfile = lastSavedProfile else {
            return true
        }
        
        guard let photo = photo, let name = name, let info = info,
            !name.isEmpty, !info.isEmpty else {
                return false
        }
        checkingFlag = photo != lastSavedProfile.photo || name != lastSavedProfile.name ||
            info != lastSavedProfile.info
        return checkingFlag
    }
}

