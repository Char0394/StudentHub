//
//  UserManager.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/5/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CloudKit

class UserManager {
    
    let context: NSManagedObjectContext
    
    init(context moc:NSManagedObjectContext) {
        context = moc
    }
    
    func dologin(email: String!, password: String!, completion:@escaping (String?)->Void) {
        CloudKitHelper.login(email: email, password: password, completion: { (result) in
            if result != nil {
                //Save UserID in settings
                UserDefaults.standard.set(result, forKey: "ME")
                UserDefaults.standard.synchronize()
                self.getProfile(result!)
                completion(result)
            }
        })
    }
    
    
    func createAnAcount(name: String? = nil, password: String? = nil, email: String? = nil,  image: UIImage? = nil, completion:@escaping (String)->Void ) {
        CloudKitHelper.createAnAcount(name: name, password: password, email: email, image: image, completion: { (result) in
                if result.isEmpty {
                    self.downloadUser(UserDefaults.standard.object(forKey: "ME") as! String, in: self.context)
                }
            completion(result)

        })
    }
    
    func saveAnAcount(name: String? = nil, password: String? = nil, email: String? = nil,  image: UIImage? = nil, completion:@escaping (String)->Void ) {
        CloudKitHelper.saveAnAcount(name: name, password: password, email: email, image: image, completion: { (result) in
            if result.isEmpty {
                self.downloadUser(UserDefaults.standard.object(forKey: "ME") as! String, in: self.context)
            }
            completion(result)
            
        })
    }
    
        
    func getProfile(_ userId: String) -> User? {
        let req = NSFetchRequest<User>(entityName: "User")
        req.predicate = NSPredicate(format: "recordID = %@", userId)
        
        var results: [NSManagedObject] = []
        do {
            results = try self.context.fetch(req)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        if results.count == 0{
            downloadUser(userId, in: context)
        }
        
        return results.first as? User
    }

    func refreshAllUsersInfo() {
        
        // get info for all other-users
        let req = User.fetchRequest() as NSFetchRequest<User>
        if let allUsers = try? context.fetch(req) {
            for user in allUsers {
                if user.recordID != nil{
                    downloadUser(user.recordID!, in: context)
                }
            }
        }
    }
    
    func downloadUser(_ recordName: String, in context: NSManagedObjectContext) {
        
        CloudKitHelper.getUser(userId: recordName) { record in
            guard record != nil else {
                return
            }
            
            let bkContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            bkContext.parent = context
            
            bkContext.perform {
                
                // first, check if user exist previously
                let req = User.fetchRequest() as NSFetchRequest<User>
                req.predicate = NSPredicate(format: "recordID == %@", recordName)
                let user: User
                if let res = try? bkContext.fetch(req),
                    let theUser = res.first {
                    user = theUser
                } else {
                    user = NSEntityDescription.insertNewObject(forEntityName: "User", into: bkContext) as! User
                    user.recordID = recordName
                }
                
                user.name = record!["fullName"] as? String
                user.email =  record!["email"] as? String
                
                if let imageAsset = record!["image"] as? CKAsset {
                    user.image = imageAsset.resizedRoundedImage
                }
                // Actualize every message from this sender
                let req1 = Message.fetchRequest() as NSFetchRequest<Message>
                req1.predicate = NSPredicate(format: "sender.recordID == %@", recordName )
                if let messages = try? bkContext.fetch(req1) {
                    for messagem in messages {
                        messagem.sender = user
                    }
                }
                
                user.recordID = recordName
                
                if bkContext.hasChanges {
                    try? bkContext.save()
                    context.perform {
                        try? context.save()
                    }
                }
            }
        }
    }
}
