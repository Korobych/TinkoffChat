//
//  DialogCustomCell.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit
// для удобства вызова вчерашней даты (необходимо для проверки на замену формата вывода даты последнего сообщения)
extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}
// Класс ячейки диалогов
class DialogCustomCell: UITableViewCell {
    
    // Имя
    @IBOutlet weak var dialogPartnerNameLabel: UILabel!
    //Текст последнего сообщения
    @IBOutlet weak var dialogPartnerLastMessageLabel: UILabel!
    //Дата последнего сообщения
    @IBOutlet weak var dialogPartnerLastMessageDateLabel: UILabel!
    
    
    func setupCell(name: String?, message: String?, date: Date?, online: Bool, unread: Bool){
        // Логика проверки даты
        let dateFormatter = DateFormatter()
        if date != nil{
            if date! < Date().yesterday{
                dateFormatter.setLocalizedDateFormatFromTemplate("dd MMM")
            } else{
                dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
            }
        }
        //логика проверки нулевого сообщения + установление для него нового шрифта
        if message == nil{
            dialogPartnerLastMessageLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: 14)
            dialogPartnerLastMessageLabel.text = "No messages yet"
        }
        else{
            // логика выделения жирным шрифтом непрочитанного сообещения
            if unread{
                dialogPartnerLastMessageLabel.font = UIFont.boldSystemFont(ofSize: 15)
            } else
            {
                dialogPartnerLastMessageLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: 14)
            }
            dialogPartnerLastMessageLabel.text = message
        }
        
        dialogPartnerNameLabel.text = name
        dialogPartnerLastMessageDateLabel.text = dateFormatter.string(for: date)
    }

    

}
