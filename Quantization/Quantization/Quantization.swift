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
    
    var accuracy: CGFloat = 5
    var image: UIImage = UIImage()
    
    /*
     *  Define Image
     */
    public func setImage(_ image: UIImage) {
        self.image = image
    }
    
    /*
     *  Define accuracy
     */
    public func setAccuracy(_ accuracy: CGFloat) {
        self.accuracy = accuracy
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

        for varx in stride(from: 0, to: self.image.size.width, by: self.accuracy) {
            for vary in stride(from: 0, to: self.image.size.height, by: self.accuracy) {
                
                let position1: Int = 4 * (Int(vary) * Int(self.image.size.width) + Int(varx))
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
            
            let c1 = (color1 == ColorIdentifier.red.rawValue) ? red : green
            let c2 = (color2 == ColorIdentifier.red.rawValue) ? red : blue
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
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        firstArray[0].getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if (red >= green) && (red >= blue) {
            secondArray = self.secondFilter(colorArray: firstArray, color1: ColorIdentifier.green.rawValue, color2: ColorIdentifier.blue.rawValue)
        }
        else if (green >= red) && (green >= blue) {
            secondArray = self.secondFilter(colorArray: firstArray, color1: ColorIdentifier.red.rawValue, color2: ColorIdentifier.blue.rawValue)
        }
        else if (blue >= red) && (blue >= green) {
            secondArray = self.secondFilter(colorArray: firstArray, color1: ColorIdentifier.green.rawValue, color2: ColorIdentifier.red.rawValue)
        }
        
        return self.calculateAverage(colorArray: secondArray)
    }
}
