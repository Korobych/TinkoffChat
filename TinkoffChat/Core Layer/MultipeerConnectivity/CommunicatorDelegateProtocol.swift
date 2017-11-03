//
//  CommunicatorDelegateProtocol.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol CommunicatorDelegateProtocol : class {
    // discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    // errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //message recieving
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}
