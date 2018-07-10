//
//  SearchScope.swift
//  Documents Core Data Search
//
//  Created by Dale Musser on 7/9/18.
//  Copyright © 2018 Dale Musser. All rights reserved.
//

import Foundation

enum SearchScope: String {
    case all
    case name
    case content
    
    static var titles: [String] {
        get {
            return [SearchScope.all.rawValue, SearchScope.name.rawValue, SearchScope.content.rawValue]
        }
    }
    
    static var scopes: [SearchScope] {
        get {
            return [SearchScope.all, SearchScope.name, SearchScope.content]
        }
    }
}
