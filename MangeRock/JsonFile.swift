//
//  JsonFile.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/9/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import Foundation

class JsonFile {
    var name: String
    var path: String = ""
    var url: URL?
    var status: JsonFileStatus = .queuering
    var contentFiles: [ContentFile] = []
    var isDownloading = false
    var progress: Float = 0.0
    
    enum JsonFileStatus {
        case downloading
        case queuering
        case finished
    }
    
    init(url: URL) {
        self.name = (url.lastPathComponent as NSString).deletingPathExtension
        self.url = url
        getFiles(url: url)
    }
    
    func getFiles(url: URL) {
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                let urlFiles = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String] ?? []
                contentFiles = urlFiles.map({ (url) -> ContentFile in
                    return ContentFile(url: url)
                })
            } catch let error {
                print(error.localizedDescription)
            }
        }
        createDirectory()
    }
    
    func createDirectory() {
        let fileManager = FileManager.default
        path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("mangerock")
        path = (path as NSString).appendingPathComponent(name)
        
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } else {
            print("Already dictionary created.")
        }
    }
    
    func updateContent(url: String, status: ContentFile.ContentFileStatus, progress: Float) {
        var isDone = true
        var sumProgress: Float = 0.0
        
        for file in contentFiles {
            if file.url?.absoluteString == url {
                file.isDownloading = true
                file.status = status
                file.progress = progress
                
                if progress < 0 {
                    file.status = .error
                }
            }
            
            if file.status != .finished {
                isDone = false
            }
            
            sumProgress += file.progress
        }
        
        self.status = isDone ? .finished : .downloading        
        self.progress = sumProgress / Float(self.contentFiles.count)
    }
}
