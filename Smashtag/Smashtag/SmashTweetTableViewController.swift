//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Admin on 06.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {

    var container: NSPersistentContainer? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }

    override func insertTweets(_ tweets: [Twitter.Tweet]) {
        super.insertTweets(tweets)
        updateDatabase(with: tweets)
    }

    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        container?.performBackgroundTask { [weak self] context in
            for twitterInfo in tweets {
                _ = try? Tweet.findOrCreateTweet(matching: twitterInfo, in: context)
            }
            try? context.save()
            self?.printDatabaseStatistics()
        }

    }

    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if let tweetCount = (try? context.fetch(Tweet.fetchRequest()))?.count {
                    print("\(tweetCount) tweets")
                }
                if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
                    print("\(tweeterCount) Twitter users")
                }
            }
        }
    }
}
