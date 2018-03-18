//
//  MessageManager.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/5/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit

class MessageManager {
    
    struct ManagerError: Error {
        let msg: String
    }
    
    // Create a singleton
    static let shared = MessageManager()
    
    func downloadMessages(_ groupId:String, in moc:NSManagedObjectContext, _ completion:@escaping (_ error:Error?)->Void ) {
        
        if let last = getMessageOlderDate(groupId, in: moc) {
            CloudKitHelper.queryForMessages(groupId, from: last) { results, error in
                guard error == nil , results != nil else {
                    completion(ManagerError(msg:"Error performing messages query"))
                    return
                }
                self.processMessages(results!, in: moc, completion: completion)
            }
        } else {
            CloudKitHelper.queryForMessages(groupId){ results, error in
                guard error == nil , results != nil else {
                    completion(ManagerError(msg:"Error performing messages query"))
                    return
                }
                self.processMessages(results!, in: moc, completion: completion)
            }
        }
    }
    
    private func getMessageOlderDate(_ groupId:String,  in context:NSManagedObjectContext)-> Date?{
        let request:NSFetchRequest = Message.fetchRequest()
        request.predicate = NSPredicate(format: "togroup.recordID = %@", groupId)
        let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor1]
        request.fetchLimit = 1
        
        do {
            let message = try context.fetch(request)
            return message.first?.date
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func processMessages(_ records:[CKRecord], in context:NSManagedObjectContext, completion:@escaping (Error?)->Void) {
        
        context.perform {
            // Prebuilt requests and predicates to avoid creation of a lot of objects in the loop
            let req = Message.fetchRequest() as NSFetchRequest<Message>
            let predicate = NSPredicate(format: "recordID == $RECORDID")
            let userReq = User.fetchRequest() as NSFetchRequest<User>

            var usersPendingToDownload = [String]()
            
            for recordMessage in records {
                let recordID = recordMessage.recordID.recordName
                let substitutions = ["RECORDID":recordID]
                req.predicate = predicate.withSubstitutionVariables(substitutions)
                if let results = try? context.fetch(req) {
                    if results.count == 0 {
                        // If no results, the message is new and must be saved in Core Data
                        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
                        message.recordID = recordID
                        if let senderName = recordMessage["creatorPeopleId"] as! String? {
                            message.senderID = senderName
                            
                            // And set the user to the message:
                            userReq.predicate = predicate.withSubstitutionVariables(["RECORDID": senderName])
                            if let users = try? context.fetch(userReq) {
                                if let user = users.first {
                                    message.sender = user
                                } else {
                                    usersPendingToDownload.append(senderName)
                                }
                            }
                        }
                        message.text = recordMessage["text"] as? String
                        message.date =  recordMessage["creationDate"] as? Date
                        message.togroup = GroupManager.shared.getGroup(recordMessage["groupRecordID"] as? String, context)
                        
                    }
                }
            }
            
            // Download pending users:
            for user in usersPendingToDownload {
                // write from the main context (viewContext) to ensure we don't duplicate users
                // .
                UserManager(context: context).downloadUser(user, in: context.parent ?? context)
            }
            
            completion(nil)
        }
    }
    
    func sendMessage(_ group: Group, _ text: String, in context:NSManagedObjectContext, completion:@escaping (Error?)->Void) {
        
          if let userId = UserDefaults.standard.object(forKey: "ME") {
            let me = UserManager(context: context).getProfile(userId as! String)
            CloudKitHelper.createMessage(text, group.recordID!, userId as! String) { (record) in
                    guard record != nil else {
                        completion(MessageManager.ManagerError(msg: "Error saving message"))
                        return
                    }
                    
                    context.perform {
                        let recordID = record!.recordID.recordName
                        let req = NSFetchRequest<Message>(entityName: "Message")
                        req.predicate = NSPredicate(format:"recordID == %@", recordID)
                        let message: Message
                        if let res = try? context.fetch(req),
                            let msg = res.first {
                            message = msg
                            // this must be an error!!!!! The message doesn't exist yet
                        } else {
                            message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
                            message.recordID = recordID
                        }
                        message.text = record!["text"] as? String
                        message.togroup = group
                        message.sender = me
                        message.date = record!["creationDate"] as? Date
                        message.senderID = userId as? String
                        completion(nil)
                        
                }
            }
        }
    }
}

