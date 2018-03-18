//
//  GroupsTableViewController.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/2/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GroupsTableViewController: UITableViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    var minValue = 0
    var maxValue = 100
    var downloader = Timer()

    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenContainer = appDelegate.persistentContainer
        return persistenContainer.viewContext
    }()
    
    lazy var frc : NSFetchedResultsController<Group> = {
        
        let req = NSFetchRequest<Group>(entityName:"Group")
        req.sortDescriptors = [ NSSortDescriptor(key:"name", ascending:true)]
        
        let _frc = NSFetchedResultsController(fetchRequest: req,
                                              managedObjectContext: context,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        
        _frc.delegate = self
        
        try? _frc.performFetch()
        return _frc
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.isHidden = false
        downloader = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: (#selector(ChatViewController.updater)), userInfo: nil, repeats: true)
        progressBar.setProgress(0, animated: false)
    }
    
    @objc func updater() {
        if minValue != maxValue {
            minValue += 1
            progressBar.progress = Float(minValue) / Float(maxValue)
        } else {
            minValue = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        weak var weakSelf = self
        GroupManager.shared.downloadGroups(in: context, { (error) in
            guard error == nil else {
                return
            }
            
            self.progressBar.isHidden = true
            
            // If no error, this block is called from context's queue
            try? weakSelf?.context.save()
            weakSelf?.context.parent?.perform {
                try? weakSelf?.context.parent!.save()
            }
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = frc.sections?[section] {
            return section.numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var group : Group
        group = frc.object(at: indexPath)
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
         cell.groupName.text = group.name
         if group.image != nil{
            cell.groupImage?.image = group.image as? UIImage
         }
        
        if indexPath.row == indexPath.last {
            progressBar.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weak var weakSelf = self
            let group = frc.object(at: indexPath)
            context.delete(group)
            
            CloudKitHelper.deleteGroup(name: group.name, completion: { (error) in
                if error == ""{
                   try? weakSelf?.context.save()
                }else{
                     weakSelf?.showAlert(title: "Error :(", msg: error)
                }
                return
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChatSegue" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let group = frc.object(at: IndexPath(row:row, section:0))
                let nav = segue.destination as! ChatViewController
                nav.group = group
            }
        }
    }
}
