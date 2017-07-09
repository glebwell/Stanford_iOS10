//
//  PopularityTableViewController.swift
//  Smashtag
//
//  Created by Gleb on 09.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData

class PopularityTableViewController: FetchedResultsTableViewController {

    var searchTerm: String? { didSet{ updateUI() } }
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    { didSet{ updateUI() } }

    fileprivate var fetchedResultsController: NSFetchedResultsController<Mention>?

    private func updateUI() {
        if let context = container?.viewContext, searchTerm != nil {
            let request: NSFetchRequest<Mention> = Mention.fetchRequest()
            request.predicate = NSPredicate(format: "count > 1 AND searchTerm = %@", searchTerm!)
            request.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true,
                                                       selector: #selector(NSString.localizedStandardCompare(_:))),
                                       NSSortDescriptor(key: "count", ascending: false,
                                                        selector: #selector(NSString.localizedStandardCompare(_:))),
                                       NSSortDescriptor(key: "keyword", ascending: true,
                                                        selector: #selector(NSString.caseInsensitiveCompare(_:)))
            ]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                managedObjectContext: context,
                                                                sectionNameKeyPath: "type",
                                                                cacheName: nil) // searchTerm!
            fetchedResultsController!.delegate = self
            try? fetchedResultsController!.performFetch()
            tableView?.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopularityCell", for: indexPath)

        if let frc = fetchedResultsController {
            let mention = frc.object(at: indexPath)
            cell.textLabel?.text = mention.keyword
            cell.detailTextLabel?.text = "tweets count: \(mention.count)"
        }
        return cell
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Constants.Title
    }

    private struct Constants {
        static let SearchTweetsSegue = "SearchTweets"
        static let Title = "Popularity"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier,
            id == Constants.SearchTweetsSegue,
            let cell = sender as? UITableViewCell,
            let dvc = segue.destination as? TweetTableViewController,
            let cellText = cell.textLabel?.text {
            dvc.searchText = cellText
            dvc.searchTextField?.text = cellText
        }
    }
}


extension PopularityTableViewController
{
    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
}
