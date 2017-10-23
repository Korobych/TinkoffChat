//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration{
    var userID: String? {get set}
    var name: String? {get set}
    var messagesStore: [ReceivedMessageData] {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
    
}
// класс ячейки онлайна
class DialogCustomOnlineCellData : ConversationCellConfiguration{
    var userID: String?
    var name: String?
    var lastMessage: String?{
        return messagesStore.last?.text
    }
    var messagesStore: [ReceivedMessageData]
    var date: Date?{
        return messagesStore.last?.date
    }
    var online = true
    var hasUnreadMessages: Bool
    
    init(userID: String?, name: String?, hasUnreadMessages: Bool, messagesStore :[ReceivedMessageData] = [] ) {
        self.userID = userID
        self.name = name
        self.messagesStore = messagesStore
        self.hasUnreadMessages = hasUnreadMessages
        // Экстра - не в тз! Квик фикс на случай отсутствия сообщения, при том что флаг пропущенного сообещния и его дата (вдруг) появятся среди данных (?)
//        if messagesStore.count == 0{
//            self.hasUnreadMessages = false
//        }
    }
}
// класс ячейки оффлайн - History
class DialogCustomOfflineCellData : ConversationCellConfiguration{
    var userID: String?
    var name: String?
    var messagesStore: [ReceivedMessageData]
    var date: Date?
    var online = false
    var hasUnreadMessages: Bool
    
    init(userID: String?, name: String?, hasUnreadMessages: Bool ) {
        self.userID = userID
        self.name = name
        self.messagesStore = [ReceivedMessageData]()
        self.date = Date()
        self.hasUnreadMessages = hasUnreadMessages
        // Экстра - не в тз! Квик фикс на случай отсутствия сообщения, при том что флаг пропущенного сообещния и его дата (вдруг) появятся среди данных (?)
        if messagesStore.count == 0{
            self.hasUnreadMessages = false
        }
    }
}

class ConversationsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommunicationManagerDelegate{
    
    @IBOutlet weak var dialogsTableView: UITableView!
    var communicationManager = CommunicationManager()
//    // строка с именем собеседника, отправляемая в следующий вью контроллер
    var sendingTitleString: String?
    // строка с последним сообщением собеседника, отправляемая в следующий вью контроллер
//    var sendingLastMessageString : String?
    
    func reloadAfterChange() {
        DispatchQueue.main.async {
            self.dialogsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return communicationManager.onlineDialogs.count
        }
        else{
            return communicationManager.offlineDialogs.count
        }
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDialog = communicationManager.onlineDialogs[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        sendingTitleString = selectedDialog.name
        // выполение перехода
        performSegue(withIdentifier: "moveToConversation", sender: selectedDialog)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToConversation" {
            let nextViewController = segue.destination as! ConversationViewController
            nextViewController.dialogPersonNameString = self.sendingTitleString
            nextViewController.conversation = sender as! DialogCustomOnlineCellData
            nextViewController.communicationManager = communicationManager
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Online"
        } else{
            return "History"
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! DialogCustomCell
        if indexPath.section == 0{
            let dialogData = communicationManager.onlineDialogs[indexPath.row]
            cell.setupCell(name: dialogData.name, message: dialogData.lastMessage, date: dialogData.date, online: dialogData.online, unread: dialogData.hasUnreadMessages)
            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dialogsTableView.dataSource = self
        self.dialogsTableView.delegate = self
        let dateFormatter = DateFormatter()
        communicationManager.communicationManagerDelegate = self
        communicationManager.online = true
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
}
