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

    }
}
