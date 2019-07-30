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

    func predictImage(image: CIImage, completion : @escaping (Emotion) -> ()){
        guard let visionModel = try? VNCoreMLModel(for: YOLOv3Tiny().model) else {
            fatalError("Error while loading YOLOv3Tiny mlmodel")
        }
        
        let objectRecognitionRequest = VNCoreMLRequest(model: visionModel){(request, error) in
            DispatchQueue.main.async(execute: {
                // perform all the UI updates on the main queue
                if let results = request.results {
                    if results.count > 0{
                        completion(Emotion.happy)
                        if let objectObservation = results.first as? VNRecognizedObjectObservation {
                            print(objectObservation.labels[0])
                        } else {
                            print("Not an observation")
                        }
                    } else {
                        completion(Emotion.calm)
                    }
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
