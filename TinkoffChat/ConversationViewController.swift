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
}

class ReceivedMessageData : MessageCellConfiguration{
    var text: String?
    init(message: String?) {
        self.text = message
    }
    
}

class ConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var messagesTableView: UITableView!
    //строка с предыдущего экрана с Именем собеседника - идет в тайтл
    var dialogPersonNameString: String?
    //экстра функционал - не используется в тз (для логики очистки экрана диалога при отсутствии сообщений)
    var dialogLastMessageString: String?
    // искусственно созданный лист сообщений
    var messagesList = [ReceivedMessageData]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messagesList.count
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
        if indexPath.section % 2 == 0{
            // реализация протопипа ячейки входящего сообщения
            let cell = tableView.dequeueReusableCell(withIdentifier: "PartnerMessage", for: indexPath) as! IncomingMessageCustomCell
            cell.messageCellFixing() // см. описание класса IncomingMessageCustomCell
            cell.setupCell(message: messagesList[indexPath.section].text)
            DispatchQueue.main.async {
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 15
            }
            return cell
            
        } else{
            // реализация прототипа ячейки исходящего сообщения
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessage", for: indexPath) as! OutgoingMessageCustomCell
                cell.messageCellFixing() // см. описание класса OutgoingMessageCustomCell
                cell.setupCell(message: messagesList[indexPath.section].text)
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
        navigationItem.title = self.dialogPersonNameString
        // экстра функционал, делал чисто для проверки. В тз не используется. Если передается строка об отсутсвии сообщений в перписке - чистит массив.
        //-----------------------
        // SORRY Выбор хардкодингого варианта заполения информации  выбрал исходя из отсутствия уточнений в тз. Так же трудно ориентироваться без будущего понимания работы, хранения данных переписок, онлайна пользователей. Определенно структуру хранения данных переделаю с получением информации о дальнейшем развитии данного таска.
        //-----------------------
        if dialogLastMessageString != nil{
            
        messagesList.append(ReceivedMessageData(message: "O"))
        messagesList.append(ReceivedMessageData(message:"K"))
        messagesList.append(ReceivedMessageData(message: "Lorem ipsum dolor sit amet, co"))
        messagesList.append(ReceivedMessageData(message: "Ты чего несешь? Говори внятно."))
        messagesList.append(ReceivedMessageData(message: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec."))
        messagesList.append(ReceivedMessageData(message: "Swift — открытый мультипарадигмальный компилируемый язык программирования общего назначения. Создан компанией Apple в первую очередь для разработчиков iOS и macOS. Swift работает с фреймворками Cocoa и Cocoa Touch и совместим с основной кодовой базой Apple, написанной на Objective-C. Swift задумывал"))
            //конец требований тз
        messagesList.append(ReceivedMessageData(message: dialogLastMessageString))
        }
    }


}
