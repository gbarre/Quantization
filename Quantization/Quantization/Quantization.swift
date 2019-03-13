//  Quantization.swift
//  Quantization
//
//  Created by Guillaume on 11/03/2019.
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

import Foundation

public class Quantization: NSObject {
    
    var image: UIImage = UIImage()
    var originalImage: UIImage = UIImage()
    
    let resize: CGSize = CGSize(width: 768, height: 768)
    
    /*
     *  Define Image
     */
    public func setImage(image: UIImage) {
        self.originalImage = image
        self.image = image.resized(to: resize)
    }
    
    /*
     * Split pixels in 3 families : RED, BLUE and GREEN
     */
    func firstFilter() -> [UIColor] {
        var redColors   = [UIColor]()
        var blueColors  = [UIColor]()
        var greenColors = [UIColor]()
        
        let pixelData = self.image.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        for varx in 0 ... Int(self.image.size.width - 1) {
            for vary in 0 ... Int(self.image.size.height - 1) {
                
                let position1: Int = 4 * (vary * Int(self.image.size.width) + varx)
                let red     = CGFloat(data[position1 + 0])
                let green   = CGFloat(data[position1 + 1])
                let blue    = CGFloat(data[position1 + 2])
                let alpha   = CGFloat(data[position1 + 3])
                if alpha > 200 {
                    if (red >= green) && (red >= blue) {
                        redColors.append(UIColor(
                            red: red,
                            green: green,
                            blue: blue,
                            alpha: alpha
                        ))
                    }
                    if (green >= red) && (green >= blue) {
                        greenColors.append(UIColor(
                            red: red,
                            green: green,
                            blue: blue,
                            alpha: alpha
                        ))
                    }
                    if (blue >= red) && (blue >= green) {
                        blueColors.append(UIColor(
                            red: red,
                            green: green,
                            blue: blue,
                            alpha: alpha
                        ))
                    }
                }
            }
        }
        let maxi = max(redColors.count, greenColors.count, blueColors.count)
        if redColors.count == maxi {
            return redColors
        } else if greenColors.count == maxi {
            return greenColors
        } else {
            return blueColors
        }
    }
    
    /*
     * Split once more time colors
     */
    func secondFilter(colorArray: [UIColor], color1: String, color2: String) -> [UIColor] {
        var color1Array = [UIColor]()
        var color2Array = [UIColor]()
        for i in 0 ... (colorArray.count - 1) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            colorArray[i].getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            let c1 = (color1 == "red") ? red : green
            let c2 = (color2 == "red") ? red : blue
            if c1 >= c2 {
                color1Array.append(colorArray[i])
            }
            else {
                color2Array.append(colorArray[i])
            }
        }

        let maxi = max(color1Array.count, color2Array.count)
        if color1Array.count == maxi {
            return color1Array
        } else {
            return color2Array
        }
    }
    
    /*
     * calculate average color from array colors
     */
    func calculateAverage(colorArray: [UIColor]) -> UIColor {
        var (r, g, b) = (0.0, 0.0, 0.0)
        

        for i in 0 ... (colorArray.count - 1) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            colorArray[i].getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            r = r + Double(red)
            g = g + Double(green)
            b = b + Double(blue)
        }

        r = r / Double(colorArray.count) / Double(255.0)
        g = g / Double(colorArray.count) / Double(255.0)
        b = b / Double(colorArray.count) / Double(255.0)
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
    }
    
    /*
     * get dominant color using MEDIAN CUT algorithm
     */
    public func getDominantColor() -> UIColor {
        
        var firstArray = self.firstFilter()
        var secondArray = [UIColor]()
        
        /*
         * Sometimes resizing generate an error on firstFilter(). So we try another method of resizing
         */
        if firstArray.count == 0 {
            self.image = resizeImage(image: originalImage, targetSize: resize)
            firstArray = self.firstFilter()
            
            // Belt and suspenders!
            if firstArray.count == 0 {
                return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        firstArray[0].getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if (red >= green) && (red >= blue) {
            secondArray = self.secondFilter(colorArray: firstArray, color1: "green", color2: "blue")
        }
        else if (green >= red) && (green >= blue) {
            secondArray = self.secondFilter(colorArray: firstArray, color1: "red", color2: "blue")
        }
        else if (blue >= red) && (blue >= green) {
            secondArray = self.secondFilter(colorArray: firstArray, color1: "green", color2: "red")
        }
        
        return self.calculateAverage(colorArray: secondArray)
    }
}

extension Quantization {
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
