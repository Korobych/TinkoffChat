//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 07.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    var dialogPersonNameString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.dialogPersonNameString
        // Do any additional setup after loading the view.
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationItem.title = self.dialogPersonNameString
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
