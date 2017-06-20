//
//  RecentSearches.swift
//  Smashtag
//
//  Created by Admin on 20.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

struct RecentSearches {
    static let defaults = UserDefaults.standard
    static let limit = 100
    static let key = "RecentSearches"

    static var searches: [String] {
        return (defaults.object(forKey: key) as? [String]) ?? []
    }

    static func add(_ term: String) {
        guard !term.isEmpty else {return}
        var newArray = searches.filter { term.caseInsensitiveCompare($0) != .orderedSame }
        newArray.insert(term, at: 0)
        while newArray.count > limit {
            newArray.removeLast()
        }
        defaults.set(newArray, forKey: key)
    }

    static func removeAtIndex(_ index: Int) {
        var currentSearches = searches
        currentSearches.remove(at: index)
        defaults.set(currentSearches, forKey: key)
    }
}
