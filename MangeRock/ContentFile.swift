//
//  ContentFile.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/10/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import Foundation

class ContentFile: Equatable {
    var name: String = ""
    var path: String = ""
    var url: URL? = nil
    var status: ContentFileStatus = .queuering
    
    var isDownloading = false
    var progress: Float = 0.0
    
    enum ContentFileStatus {
        case downloading
        case queuering
        case finished
        case error
        case unzip
    }
    
    init(url: String) {
        if let url = URL(string: url) {
            self.url = url
            self.name = url.lastPathComponent
        }
    }
    
    public static func ==(lhs: ContentFile, rhs: ContentFile) -> Bool {
        return lhs.url == rhs.url
    }
}
