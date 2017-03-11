//
//  FileTableViewCell.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/9/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(jsonFile: JsonFile) {
        titleLable.text = jsonFile.name
        statusLabel.text = String(describing: jsonFile.status)
        downloadProgressView.progress = jsonFile.progress
//        downloadProgressView.setProgress(jsonFile.progress, animated: false)
    }
}
