//
//  PredictionManager.swift
//  Irony
//
//  Created by Oded Golden on 22/07/2019.
//  Copyright © 2019 Oded Golden. All rights reserved.
//

import UIKit
import CoreML
import Vision

class PredictionManager: NSObject{
    var currentPrediction = Emotion.calm

    func predictImage(image: CIImage, completion : @escaping (Emotion) -> ()){
        guard let visionModel = try? VNCoreMLModel(for: YOLOv3Tiny().model) else {
            fatalError("Error while loading YOLOv3Tiny mlmodel")
        }
        
        let objectRecognitionRequest = VNCoreMLRequest(model: visionModel){ [weak self](request, error) in
            DispatchQueue.main.async(execute: {
                // perform all the UI updates on the main queue
                if let results = request.results {
                    print(results.first ?? "No Results")
//                    completion(self?.currentPrediction)
                } else {
                    print("Doesn't work")
                }
            })
        }
        // Run the Core ML YOLOv3Tiny classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([objectRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
}
