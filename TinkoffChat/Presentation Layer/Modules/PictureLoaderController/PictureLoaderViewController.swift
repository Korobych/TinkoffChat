//
//  PictureLoaderViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 20.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

protocol PictureLoaderViewControllerDelegate: class {
    func imagePicked(image: UIImage)
}

class PictureLoaderViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    
    var page: Int = 1
    var urlsStorage: [Int:URL] = [:]
    var imagesStorage: [Int:UIImage] = [:]
    let margin : CGFloat = 8.0
    let requestSender: RequestSenderProtocol = RequestSender(async: true)
    weak var delegate: PictureLoaderViewControllerDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func modalViewClosure(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        getNewImages()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: 0.0, right: margin)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.bounds.size.width - 35) / 3
        let cellHeigth = cellWidth
        return CGSize(width: cellWidth, height: cellHeigth)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? PictureCollectionViewCustomCell,
            let image = selectedCell.image else {
                return
        }
        print(image.description)
        
        delegate?.imagePicked(image: image)
        dismiss(animated: true, completion: nil)
    }
    
    

}

extension PictureLoaderViewController: UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlsStorage.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "PictureCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PictureCollectionViewCustomCell
        if let image = imagesStorage[indexPath.row] {
            cell.image = image
        } else {
            cell.image = #imageLiteral(resourceName: "imageloading")
            loadImage(row: indexPath.row)
        }
        
        if indexPath.row == urlsStorage.count - 1 {
            // realisation of pagination
            getNewImages()
        }
        return cell
    }
    

}
// Functions for urls and photo managing
extension PictureLoaderViewController {
    
    func loadImage(row: Int) {
        guard let url = urlsStorage[row]
        else {
            print("Can't find url for this picture")
            return
        }
        let imageConfig = RequestsFactory.GetPixabayImagesRequests.imageConfig(url: url)
        requestSender.send(config: imageConfig, completionHandler: { [weak self] (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.sync {
                    guard url == self?.urlsStorage[row]
                    else {
                        print("Image is already loaded")
                        return
                    }
                    self?.imagesStorage[row] = image.image
                    //
                    self?.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
                    //
                }
                
            case .error(let description):
                print("Some error happend: \(description)")
            }
        })
    }
    
    func getNewImages() {
        activityIndicator.startAnimating()
        if urlsStorage.count == 0 {
            self.page = 1
        }
        let config = RequestsFactory.GetPixabayImagesRequests.imagesListConfig(page: page)
        requestSender.send(config: config) { [weak self] (result) in
            switch result {
            case .success(let data):
                let number = self?.urlsStorage.count
                DispatchQueue.main.sync {
                    for (item, items) in data.enumerated()
                    {
                        // offers pagination
                        self?.urlsStorage[item + number!] = URL(string: items.url)
                    }
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.reloadData()
                    self?.page += 1
                }
            case .error(let description):
                print("Some error happend: \(description)")
            }
        }
    }
}


