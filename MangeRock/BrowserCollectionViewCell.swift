//
//  BrowserCollectionViewCell.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/10/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import UIKit

class BrowserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        coverImageView.backgroundColor = UIColor.clear
    }
    
    func updateCell(jsonFile: JsonFile?, index: Int) {
        guard let jsonFile = jsonFile else { return }
        
        if jsonFile.contentFiles[index].status == .finished {
            let imagePath = (jsonFile.path as NSString).appendingPathComponent(jsonFile.contentFiles[index].name)
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: imagePath) {
                
                if jsonFile.contentFiles[index].url?.pathExtension == "pdf" {
                    self.coverImageView.image = Utils.loadImageFromPDF(at: imagePath)
                    self.coverImageView.backgroundColor = UIColor.white
                } else if jsonFile.contentFiles[index].url?.pathExtension == "zip" {
                    self.coverImageView.image = Utils.unzipImage(path: imagePath)
                } else {
                    if let image = UIImage(contentsOfFile: imagePath) {
                        self.coverImageView.image = image
                    }
                }
            }
        }
    }
}
