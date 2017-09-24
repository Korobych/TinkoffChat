//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 20.09.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var calledfunction: String!

    // Метод, вызывающийся  после того, как вьюшка контроллера была загружена в память.
    override func viewDidLoad() {
        super.viewDidLoad()
        calledfunction = "Being called: " + FuncName() + "\n"
        print(calledfunction)
    }
    
    //Метод, вызывающийся перед появлением view на экране. Уже после viewDidLoad. Перед анимацией.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calledfunction = "Being called: " + FuncName() + "\n"
        print(calledfunction)
    }
    
    //Метод, вызывающийся после срабатывания viewWillAppear(). После анимации.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        calledfunction = "Being called: " + FuncName() + "\n"
        print(calledfunction)
    }
    
    //Метод, который вызвается при изменении layout’а view.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calledfunction = "Being called: " + FuncName() + "\n"
        print(calledfunction)
    }
    
    //Метод, который вызвается после расстановки элементов на layout'е. После viewWillLayoutSubviews().
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calledfunction = "Being called: " + FuncName() + "\n"
        print(calledfunction)
    }
    
    //Метод, вызывающийся перед исчезновении view на экране. Перед анимацией.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        calledfunction = "Being called: " + FuncName() + "\n"
        print(calledfunction)
    }
    
    //Метод, вызывающийся после срабатывания viewWillDisappear(). После анимации.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        calledfunction = "Being called: " + FuncName() + "\n"
        print(calledfunction)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    //Функция, возвращающая имя функции, из которой она была вызвана.
    func FuncName(string: String = #function) -> String {
        return string
    }


}

