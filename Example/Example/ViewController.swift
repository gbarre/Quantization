//  ViewController.swift
//  Example
//
//  Created by Guillaume on 13/03/2019.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
//
//  @author : guillaume.barre@ac-versailles.fr
//

import UIKit
import Quantization

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var background: UIView!
    @IBOutlet weak var img: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    @IBAction func loadImage(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.img.contentMode = .scaleAspectFit
            self.img.image = pickedImage
            
            self.quantizeImage(img: pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.background.backgroundColor = UIColor.black
        imagePicker.delegate = self
    }
    
    func quantizeImage(img: UIImage) {
        let quantizeImage = Quantization()
        quantizeImage.setImage(image: img)
        let dominant_color = quantizeImage.getDominantColor()
        self.background.backgroundColor = dominant_color
    }


}

