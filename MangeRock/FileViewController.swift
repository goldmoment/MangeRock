//
//  FileViewController.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/9/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import UIKit
import SSZipArchive

class FileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pauseBarButtonItem: UIBarButtonItem!
    
    lazy var downloadsSession: URLSession = {
//         Run mutilple thread
        let configuration = URLSessionConfiguration.default
        // Run with enable background transfers but only one thread 😢
//        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var jsonFiles: [JsonFile] = []
    var queue: [Download] = []
    var activeDownloads: [String: Download] = [:]
    var numberOfConcurrent = 4
    var isPause = false
    
    weak var thumbnailVC: ThumbnailViewController?
    
    var jsonFileUrl = "https://storage.googleapis.com/nabstudio/Developer/iOS/Interview/Image%20Downloader/JSON%20files%20updated.zip"
    
    typealias CurrentItem = (Int, JsonFile)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _ = self.downloadsSession
        
        tableView.dataSource = self
        tableView.delegate = self
        
        createDirectory()
        pauseBarButtonItem.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Find current JsonFile and index of content in collectionview
    func contentIndexForDownloadTask(downloadTask: URLSessionDownloadTask) -> CurrentItem? {
        if let url = downloadTask.originalRequest?.url?.absoluteString {
            for jsonFile in jsonFiles {
                for (index, item) in jsonFile.contentFiles.enumerated() {
                    if item.url?.absoluteString == url {
                        return (index, jsonFile)
                    }
                }
            }
        }
        return nil
    }
}

// MARK - Download control
extension FileViewController {
    func initQueue() {
        for file in jsonFiles {
            for item in file.contentFiles {
                if let url = item.url {
                    let download = Download(url: url.absoluteString)
                    download.downloadTask = downloadsSession.downloadTask(with: url)
                    download.isDownloading = false
                    queue.append(download)
                }
            }
        }
    }
    
    func dequeue() {
        pauseBarButtonItem.isEnabled = true
        if isPause {
            return
        }
        
        let remainNumber = numberOfConcurrent - activeDownloads.count
        if remainNumber < 1 {
            return
        }
        
        for _ in 0..<remainNumber {
            if queue.isEmpty {
                return
            }
            
            let download = queue.removeFirst()
            download.downloadTask?.resume()
            download.isDownloading = true
            activeDownloads[download.url] = download
        }
    }
    
    @IBAction func didTapAdd(_ sender: UIBarButtonItem) {
        guard let url = URL(string: jsonFileUrl) else { return }
        
        let download = Download(url: jsonFileUrl)
        download.downloadTask = downloadsSession.downloadTask(with: url)
        download.downloadTask?.resume()
        download.isDownloading = true
    }
    
    @IBAction func didTapReset(_ sender: UIBarButtonItem) {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        documentsPath = documentsPath.appendingPathComponent("mangerock") as NSString
        
        do {
            try FileManager.default.removeItem(atPath: documentsPath as String)
            createDirectory()
        } catch let error {
            print(error.localizedDescription)
        }
        
        activeDownloads.values.forEach { (download) in
            download.downloadTask?.cancel()
        }
        activeDownloads = [:]
        queue = []
        
        jsonFiles = []
        tableView.reloadData()
        
        pauseBarButtonItem.isEnabled = false
    }
    
    @IBAction func didTapPause(_ sender: UIBarButtonItem) {
        
        isPause = !isPause
        
        if isPause {
            activeDownloads.values.forEach { (download) in
                if (download.isDownloading) {
                    download.downloadTask?.cancel(byProducingResumeData: { (data) in
                        if data != nil {
                            download.resumeData = data
                        }
                    })
                    download.isDownloading = false
                }
            }
            pauseBarButtonItem.title = "Resume"
        } else {
            activeDownloads.values.forEach { (download) in
                if let resumeData = download.resumeData {
                    download.downloadTask = downloadsSession.downloadTask(withResumeData: resumeData)
                    download.downloadTask?.resume()
                    download.isDownloading = true
                } else if let url = URL(string: download.url) {
                    download.downloadTask = downloadsSession.downloadTask(with: url)
                    download.downloadTask?.resume()
                    download.isDownloading = true
                }
            }
            pauseBarButtonItem.title = "Pause"
        }
    }
    
    @IBAction func didChangeConcurrent(_ sender: UISlider) {
        numberOfConcurrent = Int(sender.value)
    }
}

extension FileViewController: ThumbnailViewControllerDelegate {
    func reloadAt(_ jsonFile: JsonFile?) {
        guard let jsonFile = jsonFile else { return }
        
        // Remove all file that belong JsonFile
        do {
            try FileManager.default.removeItem(atPath: jsonFile.path)
        } catch let error {
            print(error.localizedDescription)
        }
        
        // Remove in queue
        queue = queue.filter({ (download) -> Bool in
            return !jsonFile.contentFiles.contains(where: { (contentFile) -> Bool in
                return download.url == contentFile.url?.absoluteString
            })
        })
        
        // Add to queue
        jsonFile.getFiles(url: jsonFile.url!)
        jsonFile.isDownloading = false
        jsonFile.progress = 0.0
        jsonFile.status = .queuering
        
        for item in jsonFile.contentFiles {
            if let url = item.url {
                let download = Download(url: url.absoluteString)
                download.downloadTask = downloadsSession.downloadTask(with: url)
                download.isDownloading = false
                queue.append(download)
            }
        }
        
        if activeDownloads.isEmpty {
            dequeue()
        }
        
        self.tableView.reloadData()
        self.thumbnailVC?.collectionView.reloadData()
    }
}

extension FileViewController {
    
    func createDirectory() {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("mangerock")
        
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } else {
            print("Already dictionary created.")
        }
    }
    
    func localFilePathForUrl(_ previewUrl: String) -> URL? {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        documentsPath = documentsPath.appendingPathComponent("mangerock") as NSString
        
        if let url = URL(string: previewUrl) {
            let lastPathComponent = url.lastPathComponent
            let fullPath = documentsPath.appendingPathComponent(lastPathComponent)
            return URL(fileURLWithPath:fullPath)
        }
        return nil
    }
    
    func unzipFile(url: URL) {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        documentsPath = documentsPath.appendingPathComponent("mangerock") as NSString

        let sourcePath = "\(documentsPath)/\(url.lastPathComponent)"
        SSZipArchive.unzipFile(atPath: sourcePath, toDestination: documentsPath as String, delegate: self)
    }
}

extension FileViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalURL = downloadTask.originalRequest?.url?.absoluteString else { return }
        guard let fileName = downloadTask.originalRequest?.url?.lastPathComponent else { return }

        var destinationURL: URL
        var currentCompletedItem: CurrentItem? = nil
        
        if let currentItem = contentIndexForDownloadTask(downloadTask: downloadTask) {
            destinationURL = URL(fileURLWithPath: "\(currentItem.1.path)/\(fileName)")
            currentCompletedItem = currentItem
            
            currentItem.1.updateContent(url: originalURL, status: .finished, progress: 1.0)
        } else {
            if let path = localFilePathForUrl(originalURL) {
                destinationURL = path
            } else {
                return
            }
        }
        
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: destinationURL)
        } catch {
            // Non-fatal: file probably doesn't exist
        }
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error as NSError {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
    
        if originalURL == jsonFileUrl {
            print(destinationURL)
            unzipFile(url: destinationURL)
        } else {
            activeDownloads[originalURL] = nil
            dequeue()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            if let jsonFile = thumbnailVC?.jsonFile, let item = currentCompletedItem {
                if jsonFile.name == item.1.name {
                    DispatchQueue.main.async {
                        self.thumbnailVC?.collectionView.reloadItems(at: [IndexPath(row: item.0, section: 0)])
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString, let download = activeDownloads[downloadUrl] {
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            
            if let currentItem = contentIndexForDownloadTask(downloadTask: downloadTask) {
                currentItem.1.updateContent(url: downloadUrl, status: .downloading, progress: download.progress)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                if let jsonFile = thumbnailVC?.jsonFile {
                    if jsonFile.name == currentItem.1.name {
                        DispatchQueue.main.async {
                            self.thumbnailVC?.collectionView.reloadItems(at: [IndexPath(row: currentItem.0, section: 0)])
                        }
                    }
                }
            }
        }
    }
}

extension FileViewController: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
}

extension FileViewController: SSZipArchiveDelegate {
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        let zipPath: String = (path as NSString).deletingPathExtension
        
        jsonFiles = FileManager.default.listFiles(path: zipPath, ext: "json").map({ (url) -> JsonFile in
            return JsonFile(url: url)
        })
        
        initQueue()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.dequeue()
        }
    }
}

extension FileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let thumbnailVC = self.storyboard?.instantiateViewController(withIdentifier: "ThumbnailViewController") as? ThumbnailViewController {
            self.thumbnailVC = thumbnailVC
            self.thumbnailVC?.delegate = self

            thumbnailVC.jsonFile = jsonFiles[indexPath.row]
            self.navigationController?.pushViewController(thumbnailVC, animated: true)
        }
    }
}

extension FileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell") as! FileTableViewCell
        cell.updateCell(jsonFile: jsonFiles[indexPath.row])
        return cell
    }
}
