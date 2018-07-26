//
//  ViewController.swift
//  Hot Dog or Not Dog
//
//  Created by Michael on 7/25/18.
//  Copyright © 2018 michael papesca. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - UI Outlet Variables
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Class Variables
    
    let imagePicker = UIImagePickerController()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    // MARK: - UIImagePickerController Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage.")
            }
            
            detect(from: ciImage)
            
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Class Methods
    
    func detect(from image: CIImage) {

        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
                fatalError("Loading CoreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Couldn't cast request results as [VNClassificationObservation]")
            }

            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog"
                } else {
                    self.navigationItem.title = "Notdog"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error performing request: \(error)")
        }
        
    }
    
    // MARK: - UI Action Methods

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }

}

