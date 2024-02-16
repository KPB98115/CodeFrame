//
//  ImageCodeGenerator.swift
//  CodeFrame
//
//  Created by 施家浩 on 2024/2/9.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

func qrcodeGenerator(from textCode: String) -> UIImage? {
    let filter = CIFilter.qrCodeGenerator()
    let inputData = textCode.data(using: .ascii)
    
    filter.message = inputData!
    filter.correctionLevel = "H"
    
    guard let image = filter.outputImage else {
        return nil
    }
    return convert(ciImage: image)
}

func barcodeGenerator(from textCode: String) -> UIImage? {
    let filter = CIFilter.code128BarcodeGenerator()
    let inputData = textCode.data(using: .ascii)
    
    filter.message = inputData!
    filter.quietSpace = 5
    
    guard let image = filter.outputImage else {
        return nil
    }
    return convert(ciImage: image)
}


private func convert(ciImage:CIImage) -> UIImage {
    // The native method ain't able to convert ciImage to uiImage
    // Use following function to convert
    let context:CIContext = CIContext.init(options: nil)
    let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
    let image:UIImage = UIImage.init(cgImage: cgImage)
    return image
}
