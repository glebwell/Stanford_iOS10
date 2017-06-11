//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Gleb on 04.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter

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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 500
        //tableView.rowHeight = UITableViewAutomaticDimension
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
