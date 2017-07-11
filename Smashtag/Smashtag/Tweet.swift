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
    class func createTweetsIfNeeded(matching tweets: [Twitter.Tweet], searchTerm term: String, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        let allTweetsIds = tweets.flatMap{ $0.identifier }
        request.predicate = NSPredicate(format: "unique IN %@", allTweetsIds)
        do {
            let matches = try context.fetch(request)
            let existedTweetsIds = matches.flatMap{ $0.unique }
            let tweetsIdsForCreation = allTweetsIds.filter { !existedTweetsIds.contains($0) }

            print("[Tweet][createTweetsIfNeeded] find \(tweetsIdsForCreation.count) new tweets for searchTerm: \(term)")
            for id in tweetsIdsForCreation {
                if let index = tweets.index(where: { $0.identifier == id }) {
                    let twitterInfo = tweets[index]
                    let tweet = Tweet(context: context)
                    tweet.unique = twitterInfo.identifier
                    tweet.text = twitterInfo.text
                    tweet.created = twitterInfo.created as NSDate

                    var keywords = [String]()
                    keywords += twitterInfo.hashtags.flatMap{ $0.keyword }
                    keywords += twitterInfo.userMentions.flatMap{ $0.keyword }
                    keywords.append("@"+twitterInfo.user.screenName)

                    if let mentions = try? Mention.findOrCreateMentions(matching: keywords, searchTerm: term, in: context) {
                        for m in mentions {
                            tweet.addToMentions(m)
                        }
                    }
                }
            }
        } catch {
            throw error
        }
    }

    class func removeOldTweets(which older: Date, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "created < %@", older as CVarArg)
        do {
            let matches = try context.fetch(request)
            for tweet in matches {
                context.delete(tweet)
            }
            print("[Tweet][removeOldTweets] Removed \(matches.count) tweets")
        } catch {
            throw error
        }
    }

    override func prepareForDeletion() {
        print("prepare to deletion tweet: \(self.unique ?? "<?>")")
        if let mentionsSet = mentions as? Set<Mention> {
            for mention in mentionsSet {
                mention.removeFromTweets(self)
                mention.count -= 1
                if mention.count == 0 {
                    managedObjectContext?.delete(mention)
                }
            }
        }
    }
}
