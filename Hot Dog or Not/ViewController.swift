//
//  ViewController.swift
//  Hot Dog or Not
//
//  Created by Raghav Prakash on 7/22/18.
//  Copyright © 2018 Raghav Prakash. All rights reserved.
//

import UIKit

import CoreML
import Vision

import ProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	@IBOutlet weak var imageView: UIImageView!
	let imagePicker = UIImagePickerController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imagePicker.delegate = self
		imagePicker.sourceType = .camera
		imagePicker.allowsEditing = false
	}
	
	//MARK: - The camera button is clicked
	
	@IBAction func cameraTapped(_ sender: UIBarButtonItem) {
		present(imagePicker, animated: true, completion: nil)
	}
	
	//MARK: - The camera button in the imagePicker view is clicked
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imageView.image = userPickedImage
			
			guard let userPickedCIImage = CIImage(image: userPickedImage) else {
				fatalError("Could not convert user picked image to a CIImage")
			}
			detect(image: userPickedCIImage)
		}
		imagePicker.dismiss(animated: true, completion: nil)
	}
	
	//MARK: - Image recognition functionality here.
	func detect(image: CIImage) {
		
		guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
			fatalError("Failed to load the model")
		}
		let request = VNCoreMLRequest(model: model) { (request, error) in
			if error != nil {
				fatalError("There was a problem in making a Vision request using your CoreML model")
			} else {
				guard let results = request.results as? [VNClassificationObservation] else {
					fatalError("Could not convert the results to an array of VNClassificationObservation objects")
				}
				
				if let topCategory = results.first {
					if topCategory.identifier.contains("hotdog") {
						let result = "HOT DOG"
						
						ProgressHUD.showSuccess(result)
						self.title = result
					}
					else {
						let result = "NOT A HOT DOG"
						
						ProgressHUD.showError(result)
						self.title = result
					}
				}
			}
		}
		
		let handler = VNImageRequestHandler(ciImage: image)
		do {
			try handler.perform([request])
		} catch {
			print("Could not perform the image recognition request on your CIImage: \(error)")
		}
	}
}

