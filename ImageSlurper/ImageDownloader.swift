//
//  ImageDownloader.swift
//  ImageSlurper
//
//  Created by Stefan Buchholtz on 14.02.16.
//  Copyright © 2016 Stefan Buchholtz. All rights reserved.
//

import Foundation

protocol ImageDownloaderDelegate {
    
    func downloadedFile(sender: ImageDownloader, fileName: String, index: Int)
    
    func downloadDone(sender: ImageDownloader)
    
    func downloadError(sender: ImageDownloader, status: Int)
    
}

class ImageDownloader {
    
    let config: DownloadConfig
    let baseUrl: NSURL
    let destinationFolder: NSURL
    let encodedFirstImagePath: String
    let startIndex: Int
    let indexRange: Range<String.CharacterView.Index>?
    
    var delegate: ImageDownloaderDelegate?
    
    init?(config: DownloadConfig) {
        self.config = config
        
        self.startIndex = config.startIndex ?? 1
        if let baseUrl = config.baseUrl, destinationFolder = config.destinationFolder {
            self.baseUrl = baseUrl
            self.destinationFolder = destinationFolder
        } else {
            self.baseUrl = NSURL(string: "")!
            self.destinationFolder = NSURL(string: "")!
            self.encodedFirstImagePath = ""
            self.indexRange = nil
            return nil
        }
        encodedFirstImagePath = config.firstImagePath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        indexRange = encodedFirstImagePath.rangeOfString("01", options: .BackwardsSearch)
    }
    
    func execute() {
        downloadFile(startIndex)
    }
    
    private func downloadFile(fileIndex: Int) {
        var path = encodedFirstImagePath
        path.replaceRange(indexRange!, with: NSString(format: "%02d", fileIndex) as String)
        let url = NSURL(string: path, relativeToURL: baseUrl)
        
        if let url = url {
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) in
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode == 404 && fileIndex > self.startIndex {
                        self.delegate?.downloadDone(self)
                        return
                    } else if response.statusCode >= 400 {
                        self.delegate?.downloadError(self, status: response.statusCode)
                        return
                    }
                }
                if let data = data {
                    let fileName = url.lastPathComponent
                    let destFile = self.destinationFolder.URLByAppendingPathComponent(fileName!)
                    data.writeToURL(destFile, atomically: false)
                    
                    self.delegate?.downloadedFile(self, fileName: fileName!, index: fileIndex)
                    self.downloadFile(fileIndex + 1)
                }
            })
            task.resume()
        }
    }
}
