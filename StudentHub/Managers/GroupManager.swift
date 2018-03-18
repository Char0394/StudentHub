//
//  GroupManager.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/2/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit

class GroupManager {

    struct ManagerError: Error {
        let msg: String
    }
    static let shared = GroupManager()

    func downloadGroups(in moc:NSManagedObjectContext, _ completion:@escaping (_ error:Error?)->Void ) {
        
        CloudKitHelper.getGroups (){ results, error in
            guard error == nil , results != nil else {
                completion(ManagerError(msg:"Error performing messages query"))
                return
            }
            self.processGroup(results!, in: moc, completion: completion)
        }
        
    }
    
    private func processGroup(_ records:[CKRecord], in context:NSManagedObjectContext, completion:@escaping (Error?)->Void) {
        weak var weakSelf = self
        context.perform {
            for record in records {
                if (weakSelf?.getGroup(record.recordID.recordName, context)) == nil{
                    let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context) as! Group
                    group.name = record["name"] as? String
                    group.recordID = record.recordID.recordName
                    let image = record["image"] as? CKAsset
                    if image != nil{
                        group.image = image?.toUIImage()
                    }
                }
            }
            
            completion(nil)
        }
    }
    
    func getGroup(_ recordId: String?, _ bxContext: NSManagedObjectContext) -> Group? {
        let req = NSFetchRequest<Group>(entityName: "Group")
        req.predicate = NSPredicate(format: "recordID = %@", recordId!)
        
        var results: [NSManagedObject] = []
        do {
            results = try bxContext.fetch(req)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.first as? Group
    }
    
    func deleteGroup(_ recordId: String?, _ bxContext: NSManagedObjectContext) -> Group? {
        let req = NSFetchRequest<Group>(entityName: "Group")
        req.predicate = NSPredicate(format: "recordID = %@", recordId!)
        
        var results: [NSManagedObject] = []
        do {
            results = try bxContext.fetch(req)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.first as? Group
    }
    
    func updateGroup(_ recordId: String?, oldName: String?, newName : String?, image: UIImage? = nil, _ context: NSManagedObjectContext, completion:@escaping (String)->Void ) {
        CloudKitHelper.saveGroup(oldName: oldName, name: newName, image: image, completion: { (result) in
            if result.isEmpty {
                let bkContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                bkContext.parent = context
                
                bkContext.perform {
                    let group = self.getGroup(recordId, bkContext)
                    group?.name = newName
                    if image != nil {
                        group?.image = image
                    }
                    if bkContext.hasChanges {
                        try? bkContext.save()
                        context.perform {
                            try? context.save()
                        }
                    }
                }
            }
            completion(result)
        })
    }
    
    func createGroup(groupName: String?, image: UIImage? = nil, _ context: NSManagedObjectContext, completion:@escaping (String?)->Void ) {
        
        CloudKitHelper.createGroup(name: groupName, image: image, completion: { (record) in
            guard record != nil else {
                completion("Error creando grupo")
                return
            }
            context.perform {
                let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context) as! Group
               
                group.name = record!["name"] as? String
                group.recordID = record?.recordID.recordName
                let image = record!["image"] as? CKAsset
                if image != nil{
                    group.image = image?.toUIImage()
                }
                completion(nil)
            }
        })
    }
}

