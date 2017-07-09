//
//  Mention.swift
//  Smashtag
//
//  Created by Gleb on 09.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Mention: NSManagedObject {

    struct MentionType {
        static let user = "Users"
        static let hashtag = "Hashtags"
    }

    class func findOrCreateMentions(matching keywords: [String],
                                    searchTerm term: String,
                                    in context: NSManagedObjectContext) throws -> [Mention] {
        let request: NSFetchRequest<Mention> = Mention.fetchRequest()
        request.predicate = NSPredicate(format: "(searchTerm =[cd] %@) AND (keyword IN %@)", term, keywords)
        do {
            let matches = try context.fetch(request)
            for mention in matches { // increment use count for existed mentions
                mention.count += 1
            }
            let existedKeywords = matches.flatMap{ $0.keyword! }
            let keywordsForCreation = keywords.filter{ !existedKeywords.contains($0) }

            print("[Mention][findOrCreateMentions] find \(existedKeywords.count) existed mentions for searchTerm: \(term)")
            print("[Mention][findOrCreateMentions] find \(keywordsForCreation.count) new mentions for searchTerm: \(term)")

            var mentions = [Mention]()
            for keyword in keywordsForCreation { // create new mention entities
                let mention = Mention(context: context)
                mention.keyword = keyword
                mention.count = 1
                mention.type = keyword.hasPrefix("#") ? MentionType.hashtag : MentionType.user
                mention.searchTerm = term
                mentions.append(mention)
            }
            return mentions
            
        } catch {
            throw error
        }
    }
}
