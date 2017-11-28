//
//  CommunicatonDelegate.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 22.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

class CommunicationManager: CommunicationManagerProtocol, CommunicatorDelegateProtocol  {

    weak var communicationManagerDelegate: CommunicationManagerDelegateProtocol?
    weak var dialogDelegate: CommunicationManagerMessagesDelegateProtocol?
    var displayedName: String {
        didSet { communicator.displayedName = displayedName
        }
    }
    private var communicator: CommunicatorProtocol = MultipeerCommunicator()
    public private(set) var onlineDialogs: [ConversationProtocol] = []
    public private(set) var offlineDialogs: [ConversationProtocol] = []
    var online: Bool = false {
        didSet {
            communicator.online = online
        }
    }
    
    init() {
        displayedName = communicator.displayedName
        communicator.delegate = self
    }
    
    func sendMessageToDialog(dialog: ConversationProtocol, text: String, successHadler: ((Bool) -> ())?) {
        communicator.sendMessage(string: text, to: dialog.userID!, completionHandler: { (success, error) in
            if success {
                dialog.messagesStore.append(ReceivedMessageData(message: text, type: "outgoing"))
            }
            DispatchQueue.main.async {
                successHadler?(success)
                if success{
                    self.dialogDelegate?.reloadAfterChange()
                    self.communicationManagerDelegate?.reloadAfterChange()
                }
            }
        })
    }
    
    func didFoundUser(userID: String, userName: String?) {
        // при попытке добавить этого же пользователя еще раз (при перевходе в приложение)
        for conv in onlineDialogs {
            if conv.userID == userID {
                return
            }
        }
        
        var dialogNew = DialogCustomOnlineCellData(userID: userID, name: userName, hasUnreadMessages: true)
        
        var userIndex: Int
        for (index, dialog) in offlineDialogs.enumerated() {
            if dialog.userID == userID {
                userIndex = index
                offlineDialogs[userIndex].online = true
                dialogNew = dialog as! DialogCustomOnlineCellData
                offlineDialogs.remove(at: userIndex)
                break
            }
        }
        onlineDialogs.append(dialogNew)
        DispatchQueue.main.async {
            self.communicationManagerDelegate?.reloadAfterChange()
            self.dialogDelegate?.reloadAfterChange()
            self.dialogDelegate?.changeHeader()
        }
    }
    //Логика обработки потери юзера
    func didLostUser(userID: String) {
        var lostUserIndex: Int?
        for (index, dialog) in onlineDialogs.enumerated() {
            if dialog.userID == userID {
                lostUserIndex = index
                break
            }
        }
        if let lostUserIndex = lostUserIndex {
            onlineDialogs[lostUserIndex].online = false
            // new
            offlineDialogs.append(onlineDialogs[lostUserIndex])
            onlineDialogs.remove(at: lostUserIndex)
            DispatchQueue.main.async {
                self.communicationManagerDelegate?.reloadAfterChange()
                self.dialogDelegate?.reloadAfterChange()
                self.dialogDelegate?.changeHeader()
            }
        }
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        communicationManagerDelegate?.reloadAfterChange()
    }
    
    func failedToStartAdvertising(error: Error) {
        communicationManagerDelegate?.reloadAfterChange()
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        var foundDialog: ConversationProtocol? = nil
        let newMessage = ReceivedMessageData(message: text, type: "incoming")
        for dialog in onlineDialogs {
            if dialog.userID == fromUser {
                foundDialog = dialog
                break
            }
        }
        foundDialog?.messagesStore.append(newMessage)
        foundDialog?.hasUnreadMessages = true
            DispatchQueue.main.async {
                self.communicationManagerDelegate?.reloadAfterChange()
                self.dialogDelegate?.reloadAfterChange()
            }
    }

}
