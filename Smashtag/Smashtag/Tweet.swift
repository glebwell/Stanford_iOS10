//
//  Tweet.swift
//  Smashtag
//
//  Created by Admin on 06.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Tweet: NSManagedObject {
    class func findOrCreateTweet(matching twitterInfo: Twitter.Tweet, searchTerm term: String, in context: NSManagedObjectContext) throws -> Tweet {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.identifier)
        do {
            let matches = try context.fetch(request)
            if !matches.isEmpty {
                assert(matches.count == 1, "[Tweet][findOrCreateTweet] database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }

        let tweet = Tweet(context: context)
        tweet.unique = twitterInfo.identifier
        tweet.text = twitterInfo.text
        tweet.created = twitterInfo.created as NSDate
        
        for tag in twitterInfo.hashtags {
            if let mention = try? Mention.findOrCreateMention(matching: tag.keyword, searchTerm: term, in: context) {
                tweet.addToMentions(mention)
            }
        }

        if let authorMention = try? Mention.findOrCreateMention(matching: "@"+twitterInfo.user.screenName, searchTerm: term, in: context) {
            tweet.addToMentions(authorMention)
        }

        for user in twitterInfo.userMentions {
            if let mention = try? Mention.findOrCreateMention(matching: user.keyword, searchTerm: term, in: context) {
                tweet.addToMentions(mention)
            }
        }

        return tweet
    }
}
