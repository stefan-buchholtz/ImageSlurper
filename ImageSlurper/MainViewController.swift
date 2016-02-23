//
//  MainViewController.swift
//  ImageSlurper
//
//  Created by Stefan Buchholtz on 11.02.16.
//  Copyright © 2016 Stefan Buchholtz. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, ImageDownloaderDelegate {

    @IBOutlet weak var destinationFolderField: NSTextField!
    @IBOutlet weak var baseUrlField: NSTextField!
    @IBOutlet weak var imagePathField: NSTextField!
    @IBOutlet weak var startIndexField: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var config: DownloadConfig = DownloadConfig()
    var downloader: ImageDownloader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFieldValues()
        // Do any additional setup after loading the view.
    }

    @IBAction func selectFolderClicked(sender: AnyObject) {
        guard let window = self.view.window else {
            return
        }
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.message = "Select destination folder"
        openPanel.beginSheetModalForWindow(window, completionHandler: { result in
            if result == NSFileHandlingPanelOKButton {
                let urls = openPanel.URLs
                if urls.count >= 1 {
                    self.destinationFolderField.stringValue = urls[0].path!
                }
            }
        })
    }

    @IBAction func downloadClicked(sender: AnyObject) {
        if !getFieldValues() {
            return
        }
        progressIndicator.startAnimation(self)
        progressLabel.stringValue = ""
        
        downloader = ImageDownloader(config: config)
        downloader!.execute()
    }
    
    private func setFieldValues() {
        destinationFolderField.stringValue = config.destinationFolder?.path ?? ""
        baseUrlField.stringValue = config.baseUrl?.absoluteString ?? ""
        imagePathField.stringValue = config.firstImagePath
        if let startIndex = config.startIndex {
            startIndexField.integerValue = startIndex
        } else {
            startIndexField.stringValue = ""
        }
    }
    
    private func getFieldValues() -> Bool {
        if let baseUrl = NSURL(string: baseUrlField.stringValue) {
            config.baseUrl = baseUrl
        } else {
            return false
        }
        if let destinationFolder = NSURL(string: destinationFolderField.stringValue) {
            config.destinationFolder = destinationFolder
        } else {
            return false
        }
        config.firstImagePath = imagePathField.stringValue
        config.startIndex = startIndexField.integerValue
        return true
    }
    
    func downloadedFile(sender: ImageDownloader, fileName: String, index: Int) {
        progressLabel.stringValue = NSString(format: "file %d: %@", index, fileName) as String
    }
    
    func downloadDone(sender: ImageDownloader) {
        progressIndicator.stopAnimation(self)
    }
    
    func downloadError(sender: ImageDownloader, status: Int) {
        progressIndicator.stopAnimation(self)
        progressLabel.stringValue = NSString(format: "server returned status code %d", status) as String
    }
    
    

}

