//
//  ThumbnailCollectionViewCell.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/10/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var progressLable: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        thumbnailImageView.backgroundColor = UIColor.clear
    }
    
    func updateCell(jsonFile: JsonFile?, index: Int) {
        guard let jsonFile = jsonFile else { return }
        
        if jsonFile.contentFiles[index].status == .downloading {
            progressLable.text = String(format: "Downloading %.1f%%",  jsonFile.contentFiles[index].progress * 100)
        } else {
            progressLable.text = String(describing: jsonFile.contentFiles[index].status)
        }
        
        if jsonFile.contentFiles[index].status == .finished {
            let imagePath = (jsonFile.path as NSString).appendingPathComponent(jsonFile.contentFiles[index].name)
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: imagePath) {
                if jsonFile.contentFiles[index].url?.pathExtension == "pdf" {
                    self.thumbnailImageView.image = Utils.loadImageFromPDF(at: imagePath)
                    self.thumbnailImageView.backgroundColor = UIColor.white
                } else if jsonFile.contentFiles[index].url?.pathExtension == "zip" {
                    self.thumbnailImageView.image = Utils.unzipImage(path: imagePath)
                } else {
                    if let image = UIImage(contentsOfFile: imagePath) {
                        self.thumbnailImageView.image = image
                    } else {
                        progressLable.text = ""
                    }
                }
            }
        }
    }
}
