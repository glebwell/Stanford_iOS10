//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Gleb on 04.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter
import SafariServices

class MentionsTableViewController: UITableViewController {

    var tweet: Twitter.Tweet? {
        didSet {
            title = tweet?.user.screenName
            if tweet != nil {
                mentionSections = initMentionSections(from: tweet!)
            }
            tableView?.reloadData()
        }
    }

    private enum MentionItem {
        case keyword(String)
        case image(URL, Double)
    }

    private struct MentionSection {
        var type: String
        var mentions: [MentionItem]
    }

    private var mentionSections: [MentionSection] = []

    private func initMentionSections(from tweet: Twitter.Tweet) -> [MentionSection] {
        var mentionSections = [MentionSection]()

        if tweet.media.count > 0 {
            mentionSections.append(MentionSection(type: SectionNames.images,
                                                  mentions: tweet.media.map { MentionItem.image($0.url, $0.aspectRatio) }))
        }

        if tweet.hashtags.count > 0 {
            mentionSections.append(MentionSection(type: SectionNames.hashtags,
                                                  mentions: tweet.hashtags.map { MentionItem.keyword($0.keyword) }))
        }

        if tweet.urls.count > 0 {
            mentionSections.append(MentionSection(type: SectionNames.urls,
                                                  mentions: tweet.urls.map { MentionItem.keyword($0.keyword) }))
        }

        if tweet.userMentions.count > 0 {
            mentionSections.append(MentionSection(type: SectionNames.users,
                                                  mentions: tweet.userMentions.map { MentionItem.keyword($0.keyword) }))
        }

        return mentionSections
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentionSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionSections[section].mentions.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionSections[section].type
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.section == 0 ? CellId.image : CellId.text
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let mention = mentionSections[indexPath.section].mentions[indexPath.row]

        switch mention {
        case .image(let url, _):
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageUrl = url
            }
        case .keyword(let keyword):
            cell.textLabel?.text = keyword
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mention = mentionSections[indexPath.section].mentions[indexPath.row]

        switch mention {
        case .image(_, let aspectRatio):
            return tableView.bounds.width / CGFloat(aspectRatio)
        default:
            return UITableViewAutomaticDimension
        }
    }

    // MARK: - Constants

    private struct SectionNames {
        static let images = "Images"
        static let hashtags = "Hashtags"
        static let users = "Users"
        static let urls = "URLs"
    }

    private struct CellId {
        static let image = "ImageCell"
        static let text = "TextCell"
    }

    private struct SegueId {
        static let search = "Search"
        static let showImage = "ShowImage"
    }

    // MARK: - Navigation

    private func isSearchSegueId(_ id: String?) -> Bool {
        return (id != nil) && (id == SegueId.search)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if isSearchSegueId(identifier),
            let cell = sender as? UITableViewCell,
            let indexPath = tableView?.indexPath(for: cell),
            mentionSections[indexPath.section].type == SectionNames.urls {
            if let stringUrl = cell.textLabel?.text,
                let url = URL(string: stringUrl) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
                return false
            }
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if let cell = sender as? UITableViewCell {
                switch id {
                case SegueId.search:
                    if let dvc = segue.destination as? TweetTableViewController,
                        let cellText = cell.textLabel?.text {
                        dvc.searchText = cellText
                    }
                case SegueId.showImage:
                    if let imageCell = cell as? ImageTableViewCell,
                        let dvc = segue.destination as? ImageViewController {
                        dvc.image = imageCell.tweetImage?.image
                    }
                default:
                    break
                }
            }
        }
    }
}
