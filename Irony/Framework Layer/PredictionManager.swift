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

    func predictImage(image: CIImage, completion : (Emotion) -> ()){
//        guard visionModel = try? VNCoreMLModel(for: YOLOv3Tiny().model) else {
//            fatalError("Error while loading YOLOv3Tiny mlmodel")
//        }
        completion(currentPrediction)
    }
}
