# Quantization
Get dominant color of an image

Inspired from the JS version from Xia.

## Installation

`pod 'Quantization', :git => 'https://github.com/gbarre/Quantization.git'`

## Use

```swift
@IBOutlet var background: UIView!

func quantizeImage(img: UIImage) {
    let quantizeImage = Quantization()
    // quantizeImage.setAccuracy(10) // Change accuracy if quantization is too long
    quantizeImage.setImage(img)
    let dominant_color = quantizeImage.getDominantColor()
    self.background.backgroundColor = dominant_color
}
```
