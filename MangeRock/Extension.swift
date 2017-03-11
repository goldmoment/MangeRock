//
//  Extension.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/9/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension FileManager {
    func listFiles(path: String, ext: String) -> [URL] {
        let baseurl: URL = URL(fileURLWithPath: path)
        var urls = [URL]()
        enumerator(atPath: path)?.forEach({ (e) in
            guard let s = e as? String else { return }
            
            if s.hasSuffix(ext) {
                if #available(iOS 9.0, *) {
                    let relativeURL = URL(fileURLWithPath: s, relativeTo: baseurl)
                    let url = relativeURL.absoluteURL
                    urls.append(url)
                } else {
                    // Fallback on earlier versions
                }
            }
        })
        return urls
    }
}
