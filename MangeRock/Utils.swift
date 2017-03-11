//
//  Utils.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/10/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import UIKit
import SSZipArchive

class Utils {
    class func loadImageFromPDF(at path: String, page: Int = 1) -> UIImage? {
        do {
            let pdfdata = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.init(rawValue: 0))

            let pdfData = pdfdata as CFData
            let provider: CGDataProvider = CGDataProvider(data: pdfData)!
            let pdfDoc: CGPDFDocument = CGPDFDocument(provider)!

            let pdfPage: CGPDFPage = pdfDoc.page(at: page)!
            var pageRect: CGRect = pdfPage.getBoxRect(.mediaBox)
            pageRect.size = CGSize(width: pageRect.size.width, height: pageRect.size.height)

            UIGraphicsBeginImageContext(pageRect.size)
            let context:CGContext = UIGraphicsGetCurrentContext()!
            context.saveGState()
            context.translateBy(x: 0.0, y: pageRect.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
            context.drawPDFPage(pdfPage)
            context.restoreGState()
            let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            return pdfImage
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    class func unzipImage(path: String) -> UIImage? {
        let zipUrl = URL(fileURLWithPath: path)
        
        var imgUrl = URL(fileURLWithPath: path)
        imgUrl.deletePathExtension()
        imgUrl.appendPathExtension("jpg")
        
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: imgUrl.path) {
            if let image = UIImage(contentsOfFile: imgUrl.path) {
                return image
            }
        }
        
        let destination = zipUrl.deletingLastPathComponent()
        SSZipArchive.unzipFile(atPath: zipUrl.path, toDestination: destination.path, delegate: nil)
        
        if fileManager.fileExists(atPath: imgUrl.path) {
            if let image = UIImage(contentsOfFile: imgUrl.path) {
                return image
            }
        }
        
        return nil
    }
}
