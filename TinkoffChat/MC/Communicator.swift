//
//  Communicator.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 22.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    weak var delegate: CommunicatorDelegate? {get set}
    var online: Bool {get set}
}
