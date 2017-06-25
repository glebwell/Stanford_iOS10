//
//  RecentTableViewController.swift
//  Smashtag
//
//  Created by Admin on 20.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class RecentTableViewController: UITableViewController {

    // MARK: - Model

    var recentSearches: [String] {
        return RecentSearches.searches
    }

    // MARK: - View

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.RecentCell,
                                                 for: indexPath) as UITableViewCell
        cell.textLabel?.text = recentSearches[indexPath.row]
        return cell
    }

    // Edit tableView
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            RecentSearches.removeAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Constants

    private struct Storyboard {
        static let RecentCell = "RecentCell"
        static let TweetsSegue = "ShowTweets"
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier,
            id == Storyboard.TweetsSegue,
            let cell = sender as? UITableViewCell,
            let dvc = segue.destination as? TweetTableViewController {
            dvc.searchText = cell.textLabel?.text
        }
    }
}