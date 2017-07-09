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

    class func findOrCreateMention(matching keyword: String,
                             searchTerm term: String,
                             in context: NSManagedObjectContext) throws -> Mention {
        let request: NSFetchRequest<Mention> = Mention.fetchRequest()
        request.predicate = NSPredicate(format: "keyword = %@ AND searchTerm =[cd] %@", keyword, term)
        do {
            let matches = try context.fetch(request)
            if !matches.isEmpty {
                assert(matches.count == 1, "[Tweet][findOrCreateMention] database inconsistency")
                matches[0].count += 1 // increment use count
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let mention = Mention(context: context)
        mention.keyword = keyword
        mention.count = 1
        mention.type = keyword.hasPrefix("#") ? MentionType.hashtag : MentionType.user
        mention.searchTerm = term
        return mention
    }
}
