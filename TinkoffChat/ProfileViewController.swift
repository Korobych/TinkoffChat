//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 20.09.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var logString: String! // строка для сборки сообщения выбрасываемого в лог
    var imagePicker = UIImagePickerController() // переменная для хранения информации и взаимодействия пользователя с встроенными функциями (использование камеры и галерреи) для использования этих данных программой

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var profilePic: UIImageView!
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        logString = "\(editButton.frame) - \(#function)"
//        print(logString)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    //      SOLVE: Срабатывает ошибка. Связано это с тем, что на момент вызова инита, вью еще не успело прогрузиться и такого элемента как editButton еще попросту нет (= nil).
    
    
    // Метод, вызывающийся  после того, как вьюшка контроллера была загружена в память.
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        logString = "\(editButton.frame) - \(#function)\n"
        print(logString)
        editButton.layer.cornerRadius = 10
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.layer.cornerRadius = 45
        addPhotoButton.layer.backgroundColor = UIColor(hue: 0.6111, saturation: 0.73, brightness: 0.94, alpha: 1.0).cgColor // разложенный цвет #3f78f0
        addPhotoButton.tintColor = UIColor.white
        addPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(20,20,20,20) // создание отступа картинки от границ
        profilePic.layer.cornerRadius = 45
        profilePic.clipsToBounds = true
    }
    
    @IBAction func editAction(_ sender: Any) {
        
    }
    
    //Вызов при нажатии на кнопку изменения аватара
    @IBAction func changeAvatarAction(_ sender: Any) {
        print("Выбери изображение профиля")
        let alertChooseVariantForPhotoMaking = UIAlertController(title: "Выберите способ", message: nil, preferredStyle: .actionSheet)
        alertChooseVariantForPhotoMaking.addAction(UIAlertAction(title: "Камера", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alertChooseVariantForPhotoMaking.addAction(UIAlertAction(title: "Галлерея", style: .default, handler: { _ in
            self.openLibrary()
        }))
        
        alertChooseVariantForPhotoMaking.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: nil))
        
        self.present(alertChooseVariantForPhotoMaking, animated: true, completion: nil)
    }
    
    
    //Метод, вызывающийся перед появлением view на экране. Уже после viewDidLoad. Перед анимацией.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    //Метод, вызывающийся после срабатывания viewWillAppear(). После анимации.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logString = "\(editButton.frame) - \(#function)"
        print(logString)
        // SOLVED: Значение фрейма отличается от предыдущего поскольку именно на данном этапе (а не в viewDidLoad) вью полностью прогружено (+ подгрузило всю иерархию элементов на экране) и появилось на экране. Именно это значение фрейма можно считать истинным в данном кейсе. Поскольку изначально оно отталкивалось от значений превью(iPhone SE), а при постройке актуального (на конечном устройстве к примеру: iPhone X) размеры могут отличаться. Следовательно нам нужно знать конечное значение.
    }
    
    //Метод, который вызвается при изменении layout’а view.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    
    //Метод, который вызвается после расстановки элементов на layout'е. После viewWillLayoutSubviews().
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    //Метод, вызывающийся перед исчезновении view на экране. Перед анимацией.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    //Метод, вызывающийся после срабатывания viewWillDisappear(). После анимации.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }

    //Функция обработки вызова камеры для изменения аватара пользователя
    func openCamera(){
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType) // статус доступа или отсутствии доступа к камере
        
        // алерт на отсутсвие камеры (создано для проверки в симуляторе)
        let warningNoCameraAlert  = UIAlertController(title: "Внимание", message: "Камера отсутствует!", preferredStyle: .alert)
        warningNoCameraAlert.addAction(UIAlertAction(title: "ОК, я в симуляторе relax", style: .default, handler: nil))
        
        // алерт из - за пользовательского запрета доступа к камере
        let deniedCameraAccessCameraAlert  = UIAlertController(title: "Внимание", message: "Доступ к камере запрещен! Разрешите доступ к ней в настройках.", preferredStyle: .alert)
        deniedCameraAccessCameraAlert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        
        // логика по проверке статусов (не)/разрешения пользованием доступа к камере
        switch cameraAuthorizationStatus {
        case .denied:
            self.present(deniedCameraAccessCameraAlert, animated: true, completion: nil)
        case .authorized:
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
            {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else
            {
                self.present(warningNoCameraAlert, animated: true, completion: nil)
            }
        case .restricted:
            self.present(deniedCameraAccessCameraAlert, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
                    {
                        self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                        self.imagePicker.allowsEditing = true
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                    else
                    {
                        self.present(warningNoCameraAlert, animated: true, completion: nil)
                    }
                } else {
                    self.present(deniedCameraAccessCameraAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Функция обработки вызова галереи для изменения аватара пользователя
    func openLibrary()
    {
        let photosStatus = PHPhotoLibrary.authorizationStatus() // статус доступа к галерее
        // алерт из - за пользовательского запрета доступа к галерее
        let deniedGalleryAccessAlert  = UIAlertController(title: "Ошибка", message: "Вход в галерею не был разрешен. Разрешите доступ к фото в настройках.", preferredStyle: .alert)
        deniedGalleryAccessAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //логика взаимодействия со статусами доступа
        if photosStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    DispatchQueue.main.async {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                    self.present(deniedGalleryAccessAlert, animated: true, completion: nil)
                    }
                }
            })
        } else if photosStatus == .authorized
        {
            DispatchQueue.main.async {
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
            }
        } else {
            self.present(deniedGalleryAccessAlert, animated: true, completion: nil)
        }
        
    }
    
    // необхолимая функция для передачи данных о выбранном объекте - программе. Логика связывания выбранного изображения (редактированного или нет) к созданному в данной программе UIImageView profilePic.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageEdited = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            profilePic.image = imageEdited
        }
        else if let imageOriginal = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            profilePic.image = imageOriginal
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    

}

