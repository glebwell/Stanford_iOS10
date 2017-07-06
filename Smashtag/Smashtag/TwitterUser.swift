//
//  TwitterUser.swift
//  Smashtag
//
//  Created by Admin on 06.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class TwitterUser: NSManagedObject {
    class func findOrCreateTwitterUser(matching twitterInfo: Twitter.User, in context: NSManagedObjectContext) throws -> TwitterUser {
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        request.predicate = NSPredicate(format: "handle = %@", twitterInfo.screenName)
        do {
            let matches = try context.fetch(request)
            if !matches.isEmpty {
                assert(matches.count == 1, "[TwitterUser][findOrCreateTwitterUser] database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }

        let twitterUser = TwitterUser(context: context)
        twitterUser.handle = twitterInfo.screenName
        twitterUser.name = twitterInfo.name
        return twitterUser
    }
}
