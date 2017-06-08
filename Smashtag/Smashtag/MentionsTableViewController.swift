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

    private var mediaItems = Array<Twitter.MediaItem>()
    private var mentions = [Array<Twitter.Mention>?]()


    var tweet: Twitter.Tweet? {
        didSet {
            mediaItems = tweet?.media ?? []
            mentions.insert(tweet?.hashtags, at: 0)
            mentions.insert(tweet?.userMentions, at: 1)
            tableView?.reloadData()
        }
    }


    private let sectionNames = [0: "Images", 1: "Hashtags", 2: "Users"]
    //private let cellTypesMap

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 500
        //tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionNames.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count: Int
        if section == 0 {
            count = mediaItems.count
        } else {
            if let specificMentions = mentions[section - 1] {
                count = specificMentions.count
            } else {
                count = 0
            }

        }
        return count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.section == 0 ? "ImageCell" : "TextCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        if let imageCell = cell as? ImageTableViewCell {
            if !mediaItems.isEmpty && indexPath.row < mediaItems.count {
                let item = mediaItems[indexPath.row]
                imageCell.imageView?.image = getImage(from: item.url)
            }
        } else {
            print("section: \(indexPath.section); row: \(indexPath.row)")
            let ar = mentions[indexPath.section - 1]
            let data = ar?[indexPath.row]
            cell.textLabel?.text = data?.keyword
        }
        return cell
    }

    private func getImage(from url: URL) -> UIImage? {
        var image: UIImage?
        DispatchQueue.global(qos: .userInitiated).sync {
            let oldUrl = url
            if let imageData = try? Data(contentsOf: url), url == oldUrl {
                image = UIImage(data: imageData)
            }
        }
        return image
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
