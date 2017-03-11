//
//  Download.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/9/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import Foundation

class Download {
    var url: String
    var isDownloading = false
    var progress: Float = 0.0
    
    var downloadTask: URLSessionDownloadTask?
    var resumeData: Data?
    
    init(url: String) {
        self.url = url
    }
}
