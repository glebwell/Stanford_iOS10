//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Gleb on 30.05.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter
class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    var tweet: Twitter.Tweet? { didSet { updateUI() } }

    private struct MentionColors {
        static let hashtagColor = UIColor.orange
        static let urlColor = UIColor.blue
        static let userColor = UIColor.black
    }

    private func colorizeTweetText() -> NSMutableAttributedString {
        if tweet == nil {
            return NSMutableAttributedString()
        } else {
            var tweetText = tweet!.text
            for _ in tweet!.media {
                tweetText += " 📷"
            }
            let attributedText = NSMutableAttributedString(string: tweetText)

            setMentionsColor(in: attributedText, mentions: tweet!.hashtags, color: MentionColors.hashtagColor)
            setMentionsColor(in: attributedText, mentions: tweet!.urls, color: MentionColors.urlColor)
            setMentionsColor(in: attributedText, mentions: tweet!.userMentions, color: MentionColors.userColor)
            return attributedText
        }
    }

    private func setMentionsColor(in string: NSMutableAttributedString, mentions: [Twitter.Mention], color: UIColor)
    {
        for m in mentions {
            string.addAttribute(NSForegroundColorAttributeName, value: color, range: m.nsrange)
        }
    }

    private func updateUI() {
        tweetTextLabel?.attributedText = colorizeTweetText()
        tweetUserLabel?.text = tweet?.user.description

        if let profileImageURL = tweet?.user.profileImageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if profileImageURL == self?.tweet?.user.profileImageURL, // if content is still actual
                    let imageData = try? Data(contentsOf: profileImageURL) {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }

        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
}
