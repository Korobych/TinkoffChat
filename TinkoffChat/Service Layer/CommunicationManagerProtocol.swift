//
//  CommunicationManagerProtocol.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol CommunicationManagerProtocol {
    var online: Bool {get set}
    var displayedName: String {get set}
    var onlineDialogs: [ConversationProtocol] {get}
    var offlineDialogs: [ConversationProtocol] {get}
    weak var communicationManagerDelegate: CommunicationManagerDelegateProtocol? {get set}
    weak var dialogDelegate: CommunicationManagerDelegateProtocol? {get set}
    func sendMessageToDialog(dialog: ConversationProtocol, text: String, successHadler: ((Bool) -> ())?)
}
