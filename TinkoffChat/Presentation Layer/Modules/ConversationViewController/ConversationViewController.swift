//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 07.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration {
    var text: String {get set}
    var type: String {get set}
}

class ReceivedMessageData : Codable, MessageCellConfiguration{
    let eventType = "TextMessage"
    let messageID = generateMessageID()
    var text: String
    var type: String
    var date: Date?
    init(message: String, type: String) {
        self.text = message
        self.type = type
        self.date = Date()
    }
    
    static func generateMessageID() -> String {
        return ("\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString())!
    }
    
    
}

class ConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommunicationManagerMessagesDelegateProtocol{
    
    var communicationManager:  CommunicationManagerProtocol!
    var conversation: ConversationProtocol!
    lazy var fallingAnimation = FallingAnimation(objectImage: #imageLiteral(resourceName: "tinkoff_bank_general_logo"), to: view)

    
    @IBOutlet weak var messagesTableView: UITableView!
    
    @IBOutlet weak var messageTextFiled: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if messageTextFiled.text == ""
        {
            print("No empty messages allowed!")
            return
        }
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
                UIView.animate(withDuration: 1, animations: {
                    self.sendButton.isEnabled = true
                    self.sendButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.sendButton.transform = CGAffineTransform.identity
                    })
                })
                
            } else {
                UIView.animate(withDuration: 1, animations: {
                    self.sendButton.isEnabled = false
                    self.sendButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.sendButton.transform = CGAffineTransform.identity
                    })
                })
            }
            self.conversation.hasUnreadMessages = false
            
        }
    }
    
    func changeHeader(){
        DispatchQueue.main.async {
            if self.conversation.online {
                UIView.animate(withDuration: 0.5, animations: {
                    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.green]
                    self.navigationController?.navigationBar.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.navigationController?.navigationBar.transform = CGAffineTransform.identity
                    })
                })
                
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
                    self.navigationController?.navigationBar.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.navigationController?.navigationBar.transform = CGAffineTransform.identity
                    })
                })
            }
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
        // autoscroll feature added
        let lastIndex = IndexPath(row: 0, section: conversation.messagesStore.count - 1)
        if indexPath.section == self.conversation.messagesStore.count - 1{
            DispatchQueue.main.async {
                self.messagesTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
            }
        }
        if messageUnit.type == "incoming"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PartnerMessage", for: indexPath) as! IncomingMessageCustomCell
            cell.messageCellFixing()
            cell.setupCell(message: messageUnit.text)
            cell.layer.borderWidth = 0
            cell.layer.cornerRadius = 15
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessage", for: indexPath) as! OutgoingMessageCustomCell
            cell.messageCellFixing()
            cell.setupCell(message: messageUnit.text)
            cell.layer.borderWidth = 0
            cell.layer.cornerRadius = 15
    
            return cell
    
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messagesTableView.dataSource = self
        self.messagesTableView.delegate = self
        self.communicationManager.dialogDelegate = self
        if conversation.online != true{
            sendButton.isEnabled = false
        }
        self.navigationItem.title = conversation.name
        fallingAnimation.gestureRecognizerSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    override func viewWillAppear(_ animated: Bool) {
        messagesTableView.reloadData()
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
