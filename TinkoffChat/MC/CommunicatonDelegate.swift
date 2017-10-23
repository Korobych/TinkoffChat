//
//  CommunicatonDelegate.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 22.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol CommunicatorDelegate : class {
    // discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    // errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}

protocol CommunicationManagerDelegate: class {
    func reloadAfterChange()
}

class CommunicationManager: CommunicatorDelegate {
    weak var communicationManagerDelegate:CommunicationManagerDelegate?
    weak var dialogDelegate: CommunicationManagerDelegate?
    var communicator = MultipeerCommunicator()
    var onlineDialogs = [DialogCustomOnlineCellData]()
    var offlineDialogs = [DialogCustomOfflineCellData]()
    var online: Bool = false {
        didSet {
            if online {
                communicator.online = true
            } else {
                communicator.online = false
            }
        }
    }
    
    func sendMessageToDialog(dialog: DialogCustomOnlineCellData, text: String, successHadler: ((Bool) -> ())?) {
        communicator.sendMessage(string: text, to: dialog.userID!, completionHandler: { (success, error) in
            if success {
                dialog.messagesStore.append(ReceivedMessageData(message: text, type: "outgoing"))
            }
            successHadler?(success)
            if success{
                self.dialogDelegate?.reloadAfterChange()
            }
        })
    }
    
    init() {
        communicator.delegate = self
    }
    
    func didFoundUser(userID: String, userName: String?) {
        // при попытке добавить этого же пользователя еще раз (при перевходе в приложение)
        for conv in onlineDialogs {
            if conv.userID == userID {
                return
            }
        }
        onlineDialogs.append(DialogCustomOnlineCellData(userID: userID, name: userName, hasUnreadMessages: true))
        DispatchQueue.main.async {
            self.communicationManagerDelegate?.reloadAfterChange()
        }
    }
    //Логика обработки потери юзера
    func didLostUser(userID: String) {
        var lostUserIndex: Int = 0
        for (index, dialog) in onlineDialogs.enumerated() {
            if dialog.userID == userID {
                lostUserIndex = index

                break
            }
        }
        // опцианально
        onlineDialogs[lostUserIndex].online = false
        onlineDialogs.remove(at: lostUserIndex)
        DispatchQueue.main.async {
            self.communicationManagerDelegate?.reloadAfterChange()
            self.dialogDelegate?.reloadAfterChange()
        }
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        communicationManagerDelegate?.reloadAfterChange()
    }
    
    func failedToStartAdvertising(error: Error) {
        communicationManagerDelegate?.reloadAfterChange()
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        var foundDialog: DialogCustomOnlineCellData?
        let newMessage = ReceivedMessageData(message: text, type: "incoming")
        for dialog in onlineDialogs {
            if dialog.userID == fromUser {
                foundDialog = dialog
            }
        foundDialog?.messagesStore.append(newMessage)
        foundDialog?.hasUnreadMessages = true
            DispatchQueue.main.async {
                self.communicationManagerDelegate?.reloadAfterChange()
                self.dialogDelegate?.reloadAfterChange()
            }
        }
    }

}
