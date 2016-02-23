//
//  DownloadConfig.swift
//  ImageSlurper
//
//  Created by Stefan Buchholtz on 14.02.16.
//  Copyright © 2016 Stefan Buchholtz. All rights reserved.
//

import Foundation

class DownloadConfig {
    
    var destinationFolder: NSURL?
    var baseUrl = NSURL(string: "http://vampyou.com")
    var firstImagePath: String = ""
    var startIndex: Int? = 1
    
}
