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
        if let searchText = self.searchText {
            container?.performBackgroundTask { [weak self] context in
                try? Tweet.createTweetsIfNeeded(matching: tweets, searchTerm: searchText, in: context)
                try? context.save()
                self?.printDatabaseStatistics()
            }
        }
    }

    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if let tweetCount = try? context.count(for: Tweet.fetchRequest()) {
                    print("[SmashTweetTableViewController][printDatabaseStatistics] \(tweetCount) tweets")
                }
                if let mentionsCount = try? context.count(for: Mention.fetchRequest()) {
                    print("[SmashTweetTableViewController][printDatabaseStatistics] \(mentionsCount) mentions")
                }
            }
        }
    }
}
