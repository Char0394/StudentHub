//
//  ChatViewController+FRCDelegate.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/5/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension ChatViewController: NSFetchedResultsControllerDelegate {
    
    // MARK - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        guard controller == frc else { return }
        
        appendingOperation = false
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        guard controller == frc else { return }
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer:sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        if controller == usersFRC,
            type == .update {
            processUserInfoChange( anObject as! User)
        }
        
        guard  controller == frc else {
            return
        }
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            appendingOperation = true
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            //tableView.reloadRows(at: [indexPath!], with: .automatic)
            if let message = anObject as? Message,
                let cell = tableView.cellForRow(at: indexPath!) as? TextCell {
                UIView.animate(withDuration: 0.2, animations: {
                    self.configure(cell, message: message)
                })
            }
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        guard controller == frc else {
            return
        }
        
        tableView.endUpdates()
        if appendingOperation {
            scrollToBottom()
        }
    }
    
    private func processUserInfoChange( _ user: User ) {
        
        if let ips = tableView.indexPathsForVisibleRows {
            for ip in ips {
                let message = frc.object(at: ip)
                if message.sender == user,
                    let cell = tableView.cellForRow(at: ip) as? TextCell {
                    
                    configure(cell, message: message)
                    
                }
            }
        }
    }
}

