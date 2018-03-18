//
//  CloudKitHelper.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/1/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//
import Foundation
import CloudKit
import CoreData
import UIKit

struct CloudKitHelper {
    
    static let subscriptionName = "MessageChanges"
    
    static var publicDatabase : CKDatabase {
        let container = CKContainer.default()
        return container.publicCloudDatabase
    }
    
    // Get my user record
    static func login(email: String!, password: String!, completion:@escaping (String?)->Void) {
        let predicate = NSPredicate(format: "email = %@ AND password = %@", email!, password!)
        let query = CKQuery(recordType: "People", predicate: predicate)
        
        publicDatabase.fetchAllRecordZones { (zones, error) in
            if error != nil {
                debugPrint("Error, no zones \( error!.localizedDescription )")
                return
            }
            
            if let zone = zones?.first {
                self.publicDatabase.perform(query, inZoneWith: zone.zoneID,
                                            completionHandler: { (records, error) in
                                                
                                                completion(records?.first?["creatorPeopleId"] as? String)
                })
            }
        }
    }
    
    // Create an account
    static func createAnAcount(name: String? = nil, password: String? = nil, email: String? = nil,  image: UIImage? = nil, completion:@escaping (String)->Void ) {
        login(email: email, password: password) { (record) in
            guard record == nil else {
                completion("Este usuario ya existe.")
                return
            }
            let user = CKRecord(recordType: "People")

            if name != nil {
                user["fullName"] = name! as NSString
            }
            
            if password != nil {
                user["password"] = password! as NSString
            }
            
            if email != nil {
                user["email"] = email! as NSString
            }
            
            user["creatorPeopleId"] = NSUUID().uuidString as NSString
            
           if image != nil {
                let data = UIImagePNGRepresentation(image!)
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MyPhoto.png")!
                do {
                    try data?.write(to: url)
                    user["image"] = CKAsset(fileURL: url)
                } catch {
                    debugPrint("Error coudn't save image \(error.localizedDescription)")
                }
            }
            self.publicDatabase.save(user, completionHandler: { (user, error) in
                guard error == nil, user != nil else {
                    completion("No se pudo crear usuario.")
                    return
                }
                //Save UserID in settings
                UserDefaults.standard.set(user!["creatorPeopleId"] as? String, forKey: "ME")
                UserDefaults.standard.synchronize()
                completion("")
            })
        }
    }
    
    // Save an account
    static func saveAnAcount(name: String? = nil, password: String? = nil, email: String? = nil,  image: UIImage? = nil, completion:@escaping (String)->Void ) {
        let predicate = NSPredicate(format: "creatorPeopleId = %@ ", (UserDefaults.standard.object(forKey: "ME") as? String)! )
        let query = CKQuery(recordType: "People", predicate: predicate)
        
        publicDatabase.fetchAllRecordZones { (zones, error) in
            if error != nil {
                debugPrint("Error, no zones \( error!.localizedDescription )")
                return
            }
            
            if let zone = zones?.first {
                self.publicDatabase.perform(query, inZoneWith: zone.zoneID, completionHandler: { (records, error) in
                    if let record = records?.first {
                        if name != nil {
                            record["fullName"] = name! as NSString
                        }
                        
                        if password != nil {
                            record["password"] = password! as NSString
                        }
                        
                        if email != nil {
                            record["email"] = email! as NSString
                        }
                        
                        if image != nil {
                            let data = UIImagePNGRepresentation(image!)
                            let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MyPhoto.png")!
                            do {
                                try data?.write(to: url)
                                record["image"] = CKAsset(fileURL: url)
                            } catch {
                                debugPrint("Error coudn't save image \(error.localizedDescription)")
                            }
                        }
                        
                        self.publicDatabase.save(record, completionHandler: { (user, error) in
                            guard error == nil, user != nil else {
                                completion("No se pudo crear usuario.")
                                return
                            }
                            //Save UserID in settings
                            UserDefaults.standard.set(user!["creatorPeopleId"] as? String, forKey: "ME")
                            UserDefaults.standard.synchronize()
                            completion("")
                        })
                    }
                })
            }
        }
    }
    
    //Get groups
    static func getGroups(completion:@escaping (_ groups:[CKRecord]?, _ error:Error?)->Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Group", predicate: predicate)
        publicDatabase.fetchAllRecordZones { (zones, error) in
            if error != nil {
                debugPrint("Error, no zones \( error!.localizedDescription )")
                return
            }
            
            if let zone = zones?.first {
                self.publicDatabase.perform(query, inZoneWith: zone.zoneID,
                                            completionHandler: { (records, error) in
                                                
                                                completion(records, error)
                })
            }
        }
    }
    
    // Create group
    static func createGroup(name: String? = nil, image: UIImage? = nil, completion:@escaping (CKRecord?)->Void) {
        getGroupByName(name: name) { (record) in
            guard record == nil else {
                completion(nil)
                return
            }
            let group = CKRecord(recordType: "Group")
            group["name"] = name! as NSString
            
            if image != nil {
                let data = UIImagePNGRepresentation(image!)
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MyPhoto.png")!
                do {
                    try data?.write(to: url)
                    group["image"] = CKAsset(fileURL: url)
                } catch {
                    debugPrint("Error coudn't save image \(error.localizedDescription)")
                }
            }
            self.publicDatabase.save(group, completionHandler: { (groupResult, error) in
                guard error == nil, groupResult != nil else {
                    completion(nil)
                    return
                }
                completion(groupResult!)
            })
        }
    }
    

    static func saveGroup(oldName: String? = nil, name: String? = nil, image: UIImage? = nil, completion:@escaping (String)->Void ) {
        getGroupByName(name: oldName) { (record) in
            if let group = record {
                group["name"] = name! as NSString
                
                if image != nil {
                    let data = UIImagePNGRepresentation(image!)
                    let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MyPhoto.png")!
                    do {
                        try data?.write(to: url)
                        group["image"] = CKAsset(fileURL: url)
                    } catch {
                        debugPrint("Error coudn't save image \(error.localizedDescription)")
                    }
                }
                self.publicDatabase.save(group, completionHandler: { (group, error) in
                    guard error == nil, group != nil else {
                        completion("No se pudo editar grupo")
                        return
                    }
                    completion("")
                })
            }
        }
    }
    
    // Delete group
    static func deleteGroup(name: String? , completion:@escaping (String)->Void ) {
        getGroupByName(name: name) { (record) in
            if let group = record {
                publicDatabase.delete(withRecordID: group.recordID, completionHandler: { (group, error) in
                    guard error == nil, group != nil else {
                        completion("No se pudo eliminar grupo.")
                        return
                    }
                    completion("")
                })
            }
        }
    }

    
    // Check if group exist
    static func getGroupByName(name: String!, completion:@escaping (CKRecord?)->Void) {
        let predicate = NSPredicate(format: "name = %@", name)
        let query = CKQuery(recordType: "Group", predicate: predicate)
        
        publicDatabase.fetchAllRecordZones { (zones, error) in
            if error != nil {
                debugPrint("Error, no zones \( error!.localizedDescription )")
                return
            }
            
            if let zone = zones?.first {
                self.publicDatabase.perform(query, inZoneWith: zone.zoneID,
                                            completionHandler: { (records, error) in
                                                
                                                completion(records?.first)
                })
            }
        }
    }
    
    static func getUser(userId: String!, completion:@escaping (CKRecord?)->Void) {
        let predicate = NSPredicate(format: "creatorPeopleId = %@", userId)
        let query = CKQuery(recordType: "People", predicate: predicate)
        
        publicDatabase.fetchAllRecordZones { (zones, error) in
            if error != nil {
                debugPrint("Error, no zones \( error!.localizedDescription )")
                return
            }
            
            if let zone = zones?.first {
                self.publicDatabase.perform(query, inZoneWith: zone.zoneID,
                                            completionHandler: { (records, error) in
                                                
                                                completion(records?.first)
                })
            }
        }
    }
    
    static func createMessage( _ text: String, _ groupID: String, _ creator: String, completion:@escaping (CKRecord?)->Void) {
        
        let message = CKRecord(recordType: "Message")
        message["text"] = text as NSString
        message["groupRecordID"] = groupID as NSString
        message["creatorPeopleId"] = creator as NSString
        self.publicDatabase.save(message) { (record, error) in
            guard error == nil, record != nil else {
                completion(nil)
                return
            }
            
            completion(record!)
        }
    }
    
    /// Subscripción para recibir notificaciones push cuando hay cambios en CloudKit
    static func subscribeToChanges() {
        
        self.publicDatabase.fetchAllSubscriptions { (subscriptions, error) in
            if error != nil {
                debugPrint("Error \(error!.localizedDescription )")
                return
            }
            
            if subscriptions?.count ?? 0 == 0 {
                self.saveSubscription()
            }
        }
    }
    
    static private func saveSubscription() {
        
        let options:CKQuerySubscriptionOptions
        options = [.firesOnRecordUpdate,.firesOnRecordCreation,.firesOnRecordDeletion]
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let subscription = CKQuerySubscription(recordType: "Message",
                                               predicate: predicate,
                                               subscriptionID: "mySubscription",
                                               options: options)
        
        let info = CKNotificationInfo()
        info.soundName = "chan.aiff"
        info.alertBody = "New message"
        
        subscription.notificationInfo = info
        
        publicDatabase.save(subscription) { (subscription, error) in
            if error != nil {
                debugPrint("Error saving subscription \( error!.localizedDescription)")
                return
            }
        }
    }
    
    static func queryForMessages(_ groupId : String, from date: Date = Date(timeIntervalSince1970: 0.0), completion:@escaping (_ messages:[CKRecord]?, _ error:Error?)->Void) {
        
        let predicate = NSPredicate(format: "creationDate >= %@ AND groupRecordID = %@", date as NSDate, groupId)
        let query = CKQuery(recordType: "Message", predicate: predicate)
        query.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        publicDatabase.fetchAllRecordZones { (zones, error) in
            if error != nil {
                debugPrint("Error, no zones \( error!.localizedDescription )")
                return
            }
            
            if let zone = zones?.first {
                self.publicDatabase.perform(query, inZoneWith: zone.zoneID,
                                            completionHandler: { (records, error) in
                                                
                                                completion(records, error)
                })
            }
            
        }
    }
    
    static func fetchUser(_ user: CKRecordID, completion:@escaping (CKRecord?)->Void ) {
        self.publicDatabase.fetch(withRecordID: user) { (record, error) in
            completion(error != nil ? nil : record)
        }
    }
}

