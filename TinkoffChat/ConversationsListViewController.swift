//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration{
    var name: String? {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
    
}
// класс ячейки онлайна
class DialogCustomOnlineCellData : ConversationCellConfiguration{
    var name: String?
    
    var message: String?
    
    var date: Date?
    
    var online = true
    
    var hasUnreadMessages: Bool
    
    init(name: String?, message: String?, date: Date?, hasUnreadMessages: Bool ) {
        self.name = name
        self.message = message
        self.date = date
        self.hasUnreadMessages = hasUnreadMessages
        // Экстра - не в тз! Квик фикс на случай отсутствия сообщения, при том что флаг пропущенного сообещния и его дата (вдруг) появятся среди данных (?)
        if message == nil{
            self.date = nil
            self.hasUnreadMessages = false
        }
    }
}
// класс ячейки оффлайн - History
class DialogCustomOfflineCellData : ConversationCellConfiguration{
    var name: String?
    
    var message: String?
    
    var date: Date?
    
    var online = false
    
    var hasUnreadMessages: Bool
    
    init(name: String?, message: String?, date: Date?, hasUnreadMessages: Bool ) {
        self.name = name
        self.message = message
        self.date = date
        self.hasUnreadMessages = hasUnreadMessages
        // Экстра - не в тз! Квик фикс на случай отсутствия сообщения, при том что флаг пропущенного сообещния и его дата (вдруг) появятся
        if message == nil{
            self.date = nil
            self.hasUnreadMessages = false
        }
    }
}

class ConversationsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dialogsTableView: UITableView!
    //лист онлайн пользовател с инфой
    var datasetOnline = [DialogCustomOnlineCellData]()
    // лист оффлайн пользователей с инфой
    var datasetOffline = [DialogCustomOfflineCellData]()
    // для удобства взятия текущего времени
    let currentDateTime = Date()
    // строка с именем собеседника, отправляемая в следующий вью контроллер
    var sendingTitleString: String?
    // строка с последним сообщением собеседника, отправляемая в следующий вью контроллер
    var sendingLastMessageString : String?
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return datasetOnline.count
        }
        else{
            return datasetOffline.count
        }
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Логика отправки информации на следующий экран
        if indexPath.section == 0{
            sendingTitleString = datasetOnline[indexPath.row].name
            sendingLastMessageString = datasetOnline[indexPath.row].message
        }
        else {
            sendingTitleString = datasetOffline[indexPath.row].name
            sendingLastMessageString = datasetOffline[indexPath.row].message
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        // выполение перехода
        performSegue(withIdentifier: "moveToConversation", sender: self)
        
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
            cell.setupCell(name: datasetOnline[indexPath.row].name, message: datasetOnline[indexPath.row].message, date: datasetOnline[indexPath.row].date, online: datasetOnline[indexPath.row].online, unread: datasetOnline[indexPath.row].hasUnreadMessages)
            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
        }
        if indexPath.section == 1{
            cell.setupCell(name: datasetOffline[indexPath.row].name, message: datasetOffline[indexPath.row].message, date: datasetOffline[indexPath.row].date, online: datasetOffline[indexPath.row].online, unread: datasetOffline[indexPath.row].hasUnreadMessages)
            cell.backgroundColor = UIColor.white
        }
        return cell
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dialogsTableView.dataSource = self
        self.dialogsTableView.delegate = self
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //-----
        //ввод информации о собеседниках.
        datasetOnline.append(DialogCustomOnlineCellData(name: "Barson Barson", message: "Daayamn son! It's triple", date: dateFormatter.date(from: "2017-10-6 20:15:30"), hasUnreadMessages: false))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Michail Medetskyi", message: "Что за чудесный денёк.", date: currentDateTime , hasUnreadMessages: false))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Andrey Sizov", message: "Hi, boy! Would you like some cookies?", date: dateFormatter.date(from: "2017-09-5 12:45:54"), hasUnreadMessages: true))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Anton Sherbakov", message: "C'mon bro. Do something already. xD", date: currentDateTime, hasUnreadMessages: true))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Налоговая РФ", message: "Где мои бабки?????", date: dateFormatter.date(from: "2017-10-9 00:17:25"), hasUnreadMessages: false))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Доставка пиццы ДоДо", message: "Да закажите вы уже по промо пиццу. Хватит сопротивляться.", date: dateFormatter.date(from: "2017-09-5 12:45:54"), hasUnreadMessages: true))
        datasetOnline.append(DialogCustomOnlineCellData(name: "HSE INC 🎓", message: "Еще немного и Вы завалите сессию! Примите во внимание тот факт, что еще один незасчитанный экзамен с вашей стороны и мы прощаемся с Вами!", date: dateFormatter.date(from: "2017-08-20 12:00:00") , hasUnreadMessages: true))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Diman", message: nil, date: currentDateTime, hasUnreadMessages: false))
        datasetOnline.append(DialogCustomOnlineCellData(name: "", message: nil, date: currentDateTime, hasUnreadMessages: true)) // это кейс с предварительной ошибкой
        datasetOnline.append(DialogCustomOnlineCellData(name: "Василиса Зинкова", message: nil, date: nil, hasUnreadMessages: true)) // это кейс с предварительной ошибкой
        
        
        // ----///
        datasetOffline.append(DialogCustomOfflineCellData(name: "Tonya Alaeva", message: "Pythonить!", date: dateFormatter.date(from: "2017-10-6 20:15:30"), hasUnreadMessages: false))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Voenka HSE 🎓", message: nil, date: currentDateTime , hasUnreadMessages: false)) // данные с заведомой ошибкой
        datasetOffline.append(DialogCustomOfflineCellData(name: "Mishakin Kolya", message: "Где моя домашка? Я тебя из под земли достану! 😡", date: dateFormatter.date(from: "2017-09-12 15:49:58"), hasUnreadMessages: true))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Ганджелло", message: "Гоу гулять, хватит сидеть за прогой. А то вообще и света дня не видишь.", date: currentDateTime, hasUnreadMessages: true))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Ден", message: "Рок'н'ролл, детка. Пахнет деньгами, да мы реально взорвём это всё.", date: currentDateTime, hasUnreadMessages: true))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Petrov Anatoliy", message: nil, date: currentDateTime, hasUnreadMessages: true)) // данные с заведомо известной ошибкой
        datasetOffline.append(DialogCustomOfflineCellData(name: "", message: "Где моя домашка, мазафакер? А ну иди сюда, ты гавно собачье", date: dateFormatter.date(from: "2016-05-25 23:11:00"), hasUnreadMessages: false))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Ганджелло", message: "Don't ask me in any case how am I come to these hights. I'm trully prodessional.", date: currentDateTime, hasUnreadMessages: true))
        datasetOnline.append(DialogCustomOnlineCellData(name: "STYLE RU INC", message: "Поздавляю с успешным выполнением задачи. 👏🏼", date: dateFormatter.date(from: "2015-11-18 18:11:15") , hasUnreadMessages: false))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Georgiy Lebovsky", message: nil, date: dateFormatter.date(from: "2015-11-18 18:11:15") , hasUnreadMessages: false)) // заведомая ошибка в данных

    }
    //Логика отправки данных на следующий экран (диалога)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveToConversation") {
            let nextViewController = segue.destination as! ConversationViewController
            nextViewController.dialogPersonNameString = self.sendingTitleString
            nextViewController.dialogLastMessageString = self.sendingLastMessageString
        }
    }
    


}
