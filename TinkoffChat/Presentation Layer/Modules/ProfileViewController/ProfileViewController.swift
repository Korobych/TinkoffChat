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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate{
    
    
    enum ProfileSaveType {
        case GCD
        case Operation
        case CoreData
    }
    
    var imagePicker = UIImagePickerController() // переменная для хранения информации и взаимодействия пользователя с встроенными функциями (использование камеры и галерреи) для использования этих данных программой
    var lastProfileSave: ProfileSaveType = .CoreData
    private var model: ProfileManagerProtocol = ProfileManager()
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBOutlet weak var gcdButton: UIButton!
    // THOSE BUTTONS ARE HIDDEN NOW
    @IBOutlet weak var operationButton: UIButton!
    
    @IBOutlet weak var coreDataButton: UIButton!
    
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var dataSavingActivityIndicator: UIActivityIndicatorView!
    
    // Метод, вызывающийся  после того, как вьюшка контроллера была загружена в память.
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        nameTextField.delegate = self
        infoTextView.delegate = self
        
        model.delegate = self
        model.getProfileInfo()
        
        //
//        gcdButton.layer.cornerRadius = 10
//        gcdButton.layer.borderWidth = 2
//        gcdButton.layer.borderColor = UIColor.black.cgColor
        //
//        gcdButton.isEnabled = false
//        operationButton.isEnabled = false
//        gcdButton.alpha = 0.5
//        operationButton.alpha = 0.5
        coreDataButton.isEnabled = false
        coreDataButton.alpha = 0.5
        // Подпись на эвенты, в которых при вылете клавиатуры мы будем двигать фрейм. Для удобства заполнения данных в текстовых ячейках
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        //
//        operationButton.layer.cornerRadius = 10
//        operationButton.layer.borderWidth = 2
//        operationButton.layer.borderColor = UIColor.black.cgColor
        //
        coreDataButton.layer.cornerRadius = 10
        coreDataButton.layer.borderWidth = 2
        coreDataButton.layer.borderColor = UIColor.black.cgColor
        //
        addPhotoButton.layer.cornerRadius = addPhotoButton.bounds.size.width * 0.5
        addPhotoButton.layer.backgroundColor = UIColor(hue: 0.6111, saturation: 0.73, brightness: 0.94, alpha: 1.0).cgColor // разложенный цвет #3f78f0
        addPhotoButton.tintColor = UIColor.white
        addPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(20,20,20,20) // создание отступа картинки от границ
        profilePic.layer.cornerRadius = profilePic.bounds.size.width * 0.25
        profilePic.clipsToBounds = true
    }
    
    //GCD saving (unreachable now)
    @IBAction func gcdSavingProcessClick(_ sender: Any) {
        
//        gcdButton.isEnabled = false
//        operationButton.isEnabled = false
//        gcdButton.alpha = 0.5
//        operationButton.alpha = 0.5
        coreDataButton.isEnabled = false
        coreDataButton.alpha = 0.5
        self.view.endEditing(true)
        dataSavingActivityIndicator.isHidden = false
        dataSavingActivityIndicator.startAnimating()
        lastProfileSave = .GCD
        saveProfile(saveType: .GCD)
    }
    
    //Operation saving (unreachable now)
    @IBAction func operationSavingProcessClick(_ sender: Any) {
        
//        gcdButton.isEnabled = false
//        operationButton.isEnabled = false
//        gcdButton.alpha = 0.5
//        operationButton.alpha = 0.5
        coreDataButton.isEnabled = false
        coreDataButton.alpha = 0.5
        self.view.endEditing(true)
        dataSavingActivityIndicator.isHidden = false
        dataSavingActivityIndicator.startAnimating()
        lastProfileSave = .Operation
        saveProfile(saveType: .Operation)
    }
    //Core Data saving ( the only possible option)
    @IBAction func coreDataProcessClick(_ sender: Any) {
//        gcdButton.isEnabled = false
//        operationButton.isEnabled = false
//        gcdButton.alpha = 0.5
//        operationButton.alpha = 0.5
        coreDataButton.isEnabled = false
        coreDataButton.alpha = 0.5
        self.view.endEditing(true)
        dataSavingActivityIndicator.isHidden = false
        dataSavingActivityIndicator.startAnimating()
        lastProfileSave = .CoreData
        saveProfile(saveType: .CoreData)
    }
    
    func saveProfile(saveType: ProfileSaveType) {
        switch saveType {
        case .GCD:
            model.saveProfileUsingGCD(photo: profilePic.image, name: nameTextField.text, info: infoTextView.text)
        case .Operation:
            model.saveProfileUsingOperation(photo: profilePic.image, name: nameTextField.text, info: infoTextView.text)
        case .CoreData:
            model.saveProfileUsingCoreData(photo: profilePic.image, name: nameTextField.text, info: infoTextView.text)
        }
    }
    
    //Логика закрытия модального окна профиля
    @IBAction func modalViewClosureInit(_ sender: Any) {
        self.dismiss(animated: true)
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
        
        alertChooseVariantForPhotoMaking.addAction(UIAlertAction(title: "Загрузить фото", style: .default, handler: { _ in
            self.openPhotoLoader()
        }))
        
        alertChooseVariantForPhotoMaking.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: nil))
        
        self.present(alertChooseVariantForPhotoMaking, animated: true, completion: nil)
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
    
    //Функция обработки вызова загружаемых из интеренета фото для изменения аватара пользователя
    func openPhotoLoader()
    {
//        performSegue(withIdentifier: "showPictureLoader", sender: self)
        guard let imageSearchVC = self.storyboard?.instantiateViewController(withIdentifier: "PicLoader") as? PictureLoaderViewController else {
            return
        }
        imageSearchVC.delegate = self
        self.present(imageSearchVC, animated: true)
    }
    
    
    // необходимая функция для передачи данных о выбранном объекте - программе. Логика связывания выбранного изображения (редактированного или нет) к созданному в данной программе UIImageView profilePic.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageEdited = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            profilePic.image = imageEdited
//            gcdButton.isEnabled = true
//            operationButton.isEnabled = true
//            gcdButton.alpha = 1
//            operationButton.alpha = 1
            enableSaving()
        }
        else if let imageOriginal = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            profilePic.image = imageOriginal
//            gcdButton.isEnabled = true
//            operationButton.isEnabled = true
//            gcdButton.alpha = 1
//            operationButton.alpha = 1
            enableSaving()
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Изменяем фрейм для удобного редактирования текста
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
    
    // Заканчивать редактирование текстового поля при нажатии на Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Логика включения возможности сохранения
    @objc private func textFieldDidChange(_ textField: UITextField) {
//        gcdButton.isEnabled = true
//        operationButton.isEnabled = true
//        gcdButton.alpha = 1
//        operationButton.alpha = 1
        enableSaving()
    }
     // Логика включения возможности сохранения
    func textViewDidChange(_ textView: UITextView) {
//        gcdButton.isEnabled = true
//        operationButton.isEnabled = true
//        gcdButton.alpha = 1
//        operationButton.alpha = 1
        enableSaving()
    }

}

//Исключение для реализации фичи вызова уведомлений (алёртов) из других классов. Ориентир на верхнюю вьюшку
extension UIApplication {
    
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

extension ProfileViewController: ProfileManagerDelegateProtocol{
    func didGet(profileViewModel: ProfileViewModel) {
        nameTextField.text = profileViewModel.name
        infoTextView.text = profileViewModel.info
        profilePic.image = profileViewModel.photo
    }
    
    func didFinishSave(success: Bool) {
        dataSavingActivityIndicator.stopAnimating()
        
        if success {
            displayAlert(title: "Данные успешно сохранены.")
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            self.gcdButton.isEnabled = true
            self.operationButton.isEnabled = true
        }
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [unowned self] _ in
            DispatchQueue.main.async {
                self.gcdButton.isEnabled = false
                self.operationButton.isEnabled = false
                self.dataSavingActivityIndicator.startAnimating()
            }
            self.saveProfile(saveType: self.lastProfileSave)
        }
        displayAlert(title: "Ошибка", message: "Не удалось сохранить данные", firstAction: okAction, secondAction: retryAction)
        }
    }
}

extension ProfileViewController{
    func displayAlert(title: String? = "Warning", message: String? = nil, firstAction: UIAlertAction? = nil, secondAction: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let firstAction = firstAction {
            alertController.addAction(firstAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
        }
        if let secondAction = secondAction {
            alertController.addAction(secondAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func enableSaving(){
        coreDataButton.isEnabled = true
        coreDataButton.alpha = 1
    }
}

extension ProfileViewController : PictureLoaderViewControllerDelegate {
    func imagePicked(image: UIImage) {
        profilePic.image = image
        enableSaving()
    }
}



