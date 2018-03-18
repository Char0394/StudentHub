//
//  UserDefaults.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/2/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import CloudKit

public extension UserDefaults {
    
    private static let keyBase : String = "ServerToken"
    static private func userDefaultKey(zone: CKRecordZoneID) -> String {
        return keyBase + "<" + zone.zoneName + ">"
    }
    
    public func serverChangeToken(zone: CKRecordZoneID) -> CKServerChangeToken? {
        let key = UserDefaults.userDefaultKey(zone: zone)
        guard let data = self.value(forKey: key) as? Data else {
            return nil
        }
        guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken else {
            return nil
        }
        return token
    }
    
    public func setServerChangeToken( _ token : CKServerChangeToken?, zone: CKRecordZoneID) {
        let key = UserDefaults.userDefaultKey(zone: zone)
        if token != nil {
            let data = NSKeyedArchiver.archivedData(withRootObject: token!)
            self.set(data, forKey:key)
        } else {
            self.removeObject(forKey: key)
        }
    }
}

