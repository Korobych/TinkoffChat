//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 07.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration {
    var text: String? {get set}
    var type: String {get set}
}

class ReceivedMessageData : Codable, MessageCellConfiguration{
    let eventType = "TextMessage"
    let messageId = generateMessageId()
    var text: String?
    var type: String
    var date: Date?
    init(message: String?, type: String) {
        self.text = message
        self.type = type
        self.date = Date()
    }
    
    static func generateMessageId() -> String {
        return ("\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString())!
    }
    
    
}

class ConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommunicationManagerDelegate {
    
    var communicationManager: CommunicationManager!
    var conversation: DialogCustomOnlineCellData!
    //строка с предыдущего экрана с Именем собеседника - идет в тайтл
    var dialogPersonNameString: String?
    //экстра функционал - не используется в тз (для логики очистки экрана диалога при отсутствии сообщений)
    var dialogLastMessageString: String?
    // искусственно созданный лист сообщений
    
    @IBOutlet weak var messagesTableView: UITableView!
    
    @IBOutlet weak var messageTextFiled: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        communicationManager.sendMessageToDialog(dialog: conversation, text: messageTextFiled.text!, successHadler:
        { (success) in
            if success {
                self.messageTextFiled.text = ""
                self.messageTextFiled.endEditing(true)
                self.messagesTableView.reloadData()
            }
        })
    }
    
    func reloadAfterChange() {
        DispatchQueue.main.async {
            self.messagesTableView.reloadData()
            if self.conversation.online {
                self.sendButton.isEnabled = true
            } else {
                self.sendButton.isEnabled = false
            }
            self.conversation.hasUnreadMessages = false
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return conversation.messagesStore.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageUnit = conversation.messagesStore[indexPath.section]
        if messageUnit.type == "incoming"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PartnerMessage", for: indexPath) as! IncomingMessageCustomCell
            cell.messageCellFixing()
            cell.setupCell(message: messageUnit.text)
            DispatchQueue.main.async {
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 15
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessage", for: indexPath) as! OutgoingMessageCustomCell
            cell.messageCellFixing()
            cell.setupCell(message: messageUnit.text)
            DispatchQueue.main.async {
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 15
            }
            return cell
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messagesTableView.dataSource = self
        self.messagesTableView.delegate = self
        self.communicationManager.communicationManagerDelegate = self
        navigationItem.title = self.dialogPersonNameString
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
     
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y += keyboardHeight
        }
    }
    // Заканчивать редактирование текстового поля при нажатии в "пустоту"
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
