//
//  url.swift
//  Toucan
//
//  Created by Vikram Mullick on 12/25/18.
//  Copyright © 2018 Vikram Mullick. All rights reserved.
//

import Foundation

struct urlUtil {
    static func getURLQueryValueFor(key: String, url: String) -> String?
    {
        let queryItems = URLComponents(string: url)?.queryItems
        let param = queryItems?.filter({$0.name == key}).first        
        return param?.value
    }
}
