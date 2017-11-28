//
//  FallingAnimation.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 28.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import UIKit


struct FallingAnimationSettings {
    var animatedCell: CAEmitterCell = CAEmitterCell()
    var animatedLayer: CAEmitterLayer = CAEmitterLayer()
    var objectImage: UIImage!
    unowned var view : UIView
    
    init(objectImage: UIImage, to view: UIView) {
        self.objectImage = objectImage
        self.view = view
    }
}

class FallingAnimation {
    //
    var animationSettings: FallingAnimationSettings
    //
    func gestureRecognizerSetup() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(startAnimation(recognizer:)))
        gestureRecognizer.minimumPressDuration = 0.5
        animationSettings.view.addGestureRecognizer(gestureRecognizer)
    }
    //
    init(objectImage: UIImage, to view: UIView) {
        
        self.animationSettings = FallingAnimationSettings(objectImage: objectImage, to: view)
        animationSettings.animatedLayer.birthRate = 0 // to switch off permanent animation
        animationSettings.animatedLayer.renderMode = kCAEmitterLayerAdditive
        animationSettings.animatedLayer.frame = animationSettings.view.bounds
        animationSettings.animatedLayer.seed = 155
        animationSettings.animatedLayer.drawsAsynchronously = true
        //
        animationSettings.animatedCell.alphaRange = 0.2
        animationSettings.animatedCell.alphaSpeed = -0.1
        animationSettings.animatedCell.scale = 0.1
        animationSettings.animatedCell.scaleSpeed = -0.1
        animationSettings.animatedCell.contents = animationSettings.objectImage.cgImage
        animationSettings.animatedCell.velocity = 110.0
        animationSettings.animatedCell.velocityRange = 200.0
        //
        animationSettings.animatedCell.spin = CGFloat.pi
        animationSettings.animatedCell.spinRange = CGFloat(0)
        animationSettings.animatedCell.emissionRange = CGFloat.pi / 2
        //
        animationSettings.animatedCell.lifetime = 2.0
        animationSettings.animatedCell.birthRate = 5.0
        animationSettings.animatedCell.xAcceleration = 55.0
        animationSettings.animatedCell.yAcceleration = 450.0
        //
        animationSettings.animatedLayer.emitterCells = [animationSettings.animatedCell]
        //
        animationSettings.view.layer.addSublayer(animationSettings.animatedLayer)
    }
    
    @objc func startAnimation(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animationSettings.animatedLayer.emitterPosition = recognizer.location(in: animationSettings.view)
            animationSettings.animatedLayer.birthRate = 1.0
        case .changed:
            animationSettings.animatedLayer.emitterPosition = recognizer.location(in: animationSettings.view)
        case .ended:
            animationSettings.animatedLayer.birthRate = 0
        default:
            break
        }
    }
}

