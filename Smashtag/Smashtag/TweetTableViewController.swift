//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Admin on 30.05.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: - Public

    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil    // REFRESHING
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
            if let term = searchText {
                RecentSearches.add(term)
            }
        }
    }

    var newTweets = Array<Twitter.Tweet>() {
        didSet {
            if !newTweets.isEmpty {
                tweets.insert(newTweets, at: 0)
                tableView?.insertSections([0], with: .fade)
            }
        }
    }

    @IBOutlet weak var refreshCtrl: UIRefreshControl!

    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // MARK: - UITextFieldDelegate

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField?.text
        }
        return true
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        if tweets.isEmpty {
            if searchText == nil, let searchLast = RecentSearches.searches.first {
                searchText = searchLast
            }
        }
        else {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureBarButtonItems()
    }

    // MARK: - Private

    private var tweets = [Array<Twitter.Tweet>]()
    private lazy var toRootVCButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                                       target: self,
                                                                       action: #selector(toRootViewController))
    private lazy var imagesCollectionButton: UIBarButtonItem =  {
        let button = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showCollectionView))
        button.isEnabled = false
        return button
    }()

    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
        }
        return nil
    }

    private var lastTwitterRequest: Twitter.Request?

    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest  {
                        self?.tweets.insert(newTweets, at: 0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                    self?.refreshCtrl?.endRefreshing()
                }
            }
        } else {
            refreshCtrl?.endRefreshing()
        }
    }

    private func configureBarButtonItems() {
        if let cntrls = navigationController?.viewControllers, cntrls.count >= 2 {
            /*
            if navigationItem.rightBarButtonItem != toRootVCButton {
                navigationItem.setRightBarButton(toRootVCButton, animated: true)
            }
            */
            let items = navigationItem.rightBarButtonItems
            if items == nil || items!.count < 2 {
                navigationItem.setRightBarButtonItems([toRootVCButton, imagesCollectionButton], animated: true)
            }
        } else {
            if navigationItem.rightBarButtonItem == nil {
                navigationItem.setRightBarButton(imagesCollectionButton, animated: true)
            }
        }
    }

    @objc private func showCollectionView() {
        performSegue(withIdentifier: Storyboard.collectionViewSegueId, sender: self)
    }

    @objc private func toRootViewController() {
        _ = navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                imagesCollectionButton.isEnabled = true
            }
        }
    }

    // added after lection of REFRESHING
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(tweets.count - section)
    }

    // MARK: - Constants
    private struct Storyboard {
        static let mentionsIdentifier = "ShowTweetMentions"
        static let collectionViewSegueId = "ShowCollectionView"
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.mentionsIdentifier:
                if let cell = sender as? TweetTableViewCell,
                    let indexPath = tableView?.indexPath(for: cell),
                    let dvc = segue.destination as? MentionsTableViewController {
                    let tweet = tweets[indexPath.section][indexPath.row]
                    dvc.tweet = tweet
                }
            case Storyboard.collectionViewSegueId:
                if let _ = sender as? TweetTableViewController,
                    let dvc = segue.destination as? TweetCollectionViewController {
                    dvc.tweets = tweets
                    dvc.title = "Images: " + (searchText ?? "")
                }
            default:
                break
            }
        }
    }
}
