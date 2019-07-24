//
//  CameraViewController.swift
//  Irony
//
//  Created by Oded Golden on 25/07/2019.
//  Copyright © 2019 Oded Golden. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let predictionManager = PredictionManager()

    let cameraSession = AVCaptureSession()
    private let context = CIContext()
    private let sampleBufferQueue = DispatchQueue(label : "sample_buffer")
    var previewLayer : AVCaptureVideoPreviewLayer!
    var activeInput : AVCaptureDeviceInput!
    let photoOutput = AVCapturePhotoOutput()
    let videoOutput = AVCaptureVideoDataOutput()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var emotionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSession()
        setupPreview()
        self.cameraSession.startRunning()
    }
    
    private func setupSession()
    {
        cameraSession.sessionPreset = .high
        let camera = AVCaptureDevice.default(for: .video)
        if camera != nil
        {
            do {
                let input = try AVCaptureDeviceInput(device: camera!)
                if cameraSession.canAddInput(input){
                    cameraSession.addInput(input)
                    activeInput = input
                }
                if cameraSession.canAddOutput(photoOutput)
                {
                    videoOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
                    videoOutput.alwaysDiscardsLateVideoFrames = true
                    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                    cameraSession.addOutput(photoOutput)
                    cameraSession.addOutput(videoOutput)
                }
            }
            catch
            {
                print("Error setting input: \(error)")
            }
        }
    }
    
    private func setupPreview()
    {
        previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
    }
    
    //    AVCaptureVideoDataOutputSampleBufferDelegate methods:
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        guard let ciImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else {return}
        // Predict image
        predictionManager.predictImage(image: ciImage, completion: { [weak self] (emotion) in
            DispatchQueue.main.async{
                self?.emotionLabel.text = emotion.rawValue
            }
        })
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CIImage?
    {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return nil}
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        return ciImage
    }
}
