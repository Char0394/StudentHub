//
//  ChatViewController+UITableView.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/5/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import UIKit

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return frc.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = frc.object(at: indexPath)
        let user = UserDefaults.standard.object(forKey: "ME") as! String
        let identifier = message.senderID == user ? "rightCell" : "leftCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TextCell
        
        configure(cell, message: message)
        
        if indexPath.row == indexPath.last {
            progressBar.isHidden = true
        }
        
        return cell
    }
    
    internal func configure(_ cell: TextCell, message:Message) {
        cell.messageText?.text = message.text
        cell.userIcon.image = message.sender?.image as! UIImage?
        let dateStr = (message.date != nil) ? self.dateFormatter.string(from: message.date!) : ""
        cell.subtext.text = (message.sender?.name ?? "") + " " + dateStr
    }
    
}

