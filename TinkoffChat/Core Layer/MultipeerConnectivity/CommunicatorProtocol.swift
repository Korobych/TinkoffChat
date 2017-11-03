//
//  Communicator.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 22.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol CommunicatorProtocol {
    var displayedName: String {get set}
    weak var delegate: CommunicatorDelegateProtocol? {get set}
    var online: Bool {get set}
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
}
