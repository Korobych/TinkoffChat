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

//Исключение для реализации фичи вызова уведомлений (алёртов) из других классов. Ориентир на вехнюю вьюшку
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
// протокол для сохранения данных пользователя
protocol DataManager {
    var personName: String {get set}
    var infoMessage: String {get set}
    var picture: UIImage {get set}

    func setupData()
}
//Класс для выполнения таска сохранения используя GCD (под протоколом)
class GCDDataManager : DataManager{
    var personName: String
    var infoMessage: String
    var picture: UIImage
    
    init(personName: String, infoMessage: String, picture: UIImage) {
        self.personName = personName
        self.infoMessage = infoMessage
        self.picture = picture
    }
    // сама логика сохранения
    func setupData(){
        let queue = DispatchQueue.global(qos: .userInitiated)
        let filePath = "person.txt"
        queue.async{
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(filePath)
                do {
                    let imageData = UIImagePNGRepresentation(self.picture)! as NSData
                    // используем base64
                    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                    let inputString = self.personName + ";" + self.infoMessage + ";" + strBase64
                    try inputString.write(to: fileURL, atomically: false, encoding: .utf8)
                    let completionAlert  = UIAlertController(title: "Данные сохранены", message: nil , preferredStyle: .alert)
                    completionAlert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    // запуск уведомления о удачном сохранении
                    UIApplication.topViewController()?.present(completionAlert, animated: true, completion: nil)
                    
                }
                catch{
                    let errorAlert  = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    errorAlert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: self.myErrorHandler))
                    // запуск уведомления о неудачном сохранении
                    UIApplication.topViewController()?.present(errorAlert, animated: true, completion: nil)
                    
                }
            }
        }
        
    }
    // вызов из алёрта при нажатии на Повторить. Срабатывает при ошибке сохранения
    func myErrorHandler(alert: UIAlertAction){
        setupData()
    }
}
//Класс для выполнения таска сохранения с использованием Operations (под протоколом)
class OperationDataManager: Operation, DataManager{
    var personName: String
    var infoMessage: String
    var picture: UIImage
    
    init(personName: String, infoMessage: String, picture: UIImage) {
        self.personName = personName
        self.infoMessage = infoMessage
        self.picture = picture
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        setupData()
        if self.isCancelled {
            return
        }
        
    }
    
    func setupData() {
        let filePath = "person.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filePath)
            do {
                let imageData = UIImagePNGRepresentation(self.picture)! as NSData
                let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                let inputString = self.personName + ";" + self.infoMessage + ";" + strBase64
                try inputString.write(to: fileURL, atomically: false, encoding: .utf8)
                let completionAlert  = UIAlertController(title: "Данные сохранены", message: nil , preferredStyle: .alert)
                completionAlert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                UIApplication.topViewController()?.present(completionAlert, animated: true, completion: nil)
            }
            catch{
                let errorAlert  = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                errorAlert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: myErrorHandler))
                UIApplication.topViewController()?.present(errorAlert, animated: true, completion: nil)
                
            }
        }
    }
    func myErrorHandler(alert: UIAlertAction){
        setupData()
    }
    
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var imagePicker = UIImagePickerController() // переменная для хранения информации и взаимодействия пользователя с встроенными функциями (использование камеры и галерреи) для использования этих данных программой

    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBOutlet weak var gcdButton: UIButton!
    
    @IBOutlet weak var operationButton: UIButton!
    
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var dataSavingActivityIndicator: UIActivityIndicatorView!
    
    // Метод, вызывающийся  после того, как вьюшка контроллера была загружена в память.
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        nameTextField.delegate = self
        infoTextView.delegate = self
        //
        gcdButton.layer.cornerRadius = 10
        gcdButton.layer.borderWidth = 2
        gcdButton.layer.borderColor = UIColor.black.cgColor
        //
        gcdButton.isEnabled = false
        operationButton.isEnabled = false
        gcdButton.alpha = 0.5
        operationButton.alpha = 0.5
        // Подпись на эвенты, в которых при вылете клавиатуры мы будем двигать фрейм. Для удобства заполнения данных в текстовых ячейках
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        //
        operationButton.layer.cornerRadius = 10
        operationButton.layer.borderWidth = 2
        operationButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.layer.cornerRadius = addPhotoButton.bounds.size.width * 0.5
        addPhotoButton.layer.backgroundColor = UIColor(hue: 0.6111, saturation: 0.73, brightness: 0.94, alpha: 1.0).cgColor // разложенный цвет #3f78f0
        addPhotoButton.tintColor = UIColor.white
        addPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(20,20,20,20) // создание отступа картинки от границ
        profilePic.layer.cornerRadius = profilePic.bounds.size.width * 0.25
        profilePic.clipsToBounds = true
        //Загрузка данных из файла и их моментальная загрузка на вью.
        DispatchQueue.main.async {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filePath = "person.txt"
                let fileURL = dir.appendingPathComponent(filePath)
                do {
                    let readString = try String(contentsOf: fileURL, encoding: .utf8)
                    let lines : [String] = readString.components(separatedBy: ";")
                    let dataDecoded : Data = Data(base64Encoded: lines[2], options: .ignoreUnknownCharacters)!
                    let decodedimage = UIImage(data: dataDecoded)
                    self.nameTextField.text = lines[0]
                    self.infoTextView.text = lines[1]
                    self.profilePic.image = decodedimage
                }
                catch{
                    print("read person.txt error")
                }
            }
        }
    }
    // Прожим на кнопку GCD
    @IBAction func gcdSavingProcessClick(_ sender: Any) {
        dataSavingActivityIndicator.isHidden = false
        dataSavingActivityIndicator.startAnimating()
        let data = GCDDataManager(personName: nameTextField.text!, infoMessage: infoTextView.text, picture: profilePic.image!)
        gcdButton.isEnabled = false
        operationButton.isEnabled = false
        gcdButton.alpha = 0.5
        operationButton.alpha = 0.5
        DispatchQueue.main.async {
            data.setupData()
            self.dataSavingActivityIndicator.stopAnimating()
        }
    }
    //Прожим на кнопку Operation
    @IBAction func operationSavingProcessClick(_ sender: Any) {
        let operationQueue = OperationQueue()
        dataSavingActivityIndicator.isHidden = false
        dataSavingActivityIndicator.startAnimating()
        gcdButton.isEnabled = false
        operationButton.isEnabled = false
        gcdButton.alpha = 0.5
        operationButton.alpha = 0.5
        operationQueue.addOperation(OperationDataManager(personName: nameTextField.text!, infoMessage: infoTextView.text, picture: profilePic.image!))
        self.dataSavingActivityIndicator.stopAnimating()
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
    
    // необходимая функция для передачи данных о выбранном объекте - программе. Логика связывания выбранного изображения (редактированного или нет) к созданному в данной программе UIImageView profilePic.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageEdited = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            profilePic.image = imageEdited
            gcdButton.isEnabled = true
            operationButton.isEnabled = true
            gcdButton.alpha = 1
            operationButton.alpha = 1
        }
        else if let imageOriginal = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            profilePic.image = imageOriginal
            gcdButton.isEnabled = true
            operationButton.isEnabled = true
            gcdButton.alpha = 1
            operationButton.alpha = 1
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Изменяем фрейм для удобного редактирования текста
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= self.view.frame.origin.y*0.3
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += self.view.frame.origin.y*0.3
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
        gcdButton.isEnabled = true
        operationButton.isEnabled = true
        gcdButton.alpha = 1
        operationButton.alpha = 1
    }
     // Логика включения возможности сохранения
    func textViewDidChange(_ textView: UITextView) {
        gcdButton.isEnabled = true
        operationButton.isEnabled = true
        gcdButton.alpha = 1
        operationButton.alpha = 1
    }
    
    
    

}

