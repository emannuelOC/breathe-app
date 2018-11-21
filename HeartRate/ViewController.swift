//
//  ViewController.swift
//  HeartRate
//
//  Created by emannuel.carvalho on 21/11/18.
//  Copyright © 2018 emannuel.carvalho. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    lazy var heartView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "❤️"
        return label
    }()
    
    var extractor: FrameExtractor!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(heartView)
        
        heartView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        heartView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        extractor = FrameExtractor()
        extractor.delegate = self
        
//        turnOnFlashLight()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        turnOffFlashLight()
    }
    
    private func toggleTorch(on: Bool) {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if let hasTorch = device?.hasTorch, hasTorch {
            do {
                try device!.lockForConfiguration()
                if (device!.torchMode == AVCaptureDevice.TorchMode.on) {
                    device!.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device!.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device!.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    private func turnOnFlashLight() {
        toggleTorch(on: true)
    }
    
    private func turnOffFlashLight() {
        toggleTorch(on: false)
    }

}

extension ViewController: FrameExtractorDelegate {
    
    func captured(image: CIImage) {
        if let heartRate = average(from: image) {
            heartView.text = "\(heartRate)"
        }
    }
    
    func average(from image: CIImage) -> CGFloat? {
        let extentVector = CIVector(x: image.extent.origin.x, y: image.extent.origin.y, z: image.extent.size.width, w: image.extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey : image, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let red = CGFloat(bitmap[0])
        let green = CGFloat(bitmap[1])
        let blue = CGFloat(bitmap[2])
        
        let color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
        view.backgroundColor = color
        print(color)
        
        
        return (red + green + blue)/3
    }
    
}



