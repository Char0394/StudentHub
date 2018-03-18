//
//  ChatViewController.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/2/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {

    var group:Group! = nil
    var observer: AnyObject?
    var appendingOperation: Bool = false
    
    var minValue = 0
    var maxValue = 100
    var downloader = Timer()
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var bottomConstaint: NSLayoutConstraint!
    var originalBottomSpace : CGFloat = 0
    
    lazy var dateFormatter : DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenContainer = appDelegate.persistentContainer
        return persistenContainer.viewContext
    }()
    
    lazy var frc : NSFetchedResultsController<Message>! = { () -> NSFetchedResultsController<Message> in
        
        let req : NSFetchRequest<Message> = Message.fetchRequest()
        req.predicate = NSPredicate(format: "togroup.recordID = %@", group.recordID!)
        req.sortDescriptors = [ NSSortDescriptor(key:"date", ascending:true )]
        
        let controller = NSFetchedResultsController<Message>(fetchRequest: req,
                                                             managedObjectContext: context,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: nil)
        controller.delegate = self
        
        // Start the controller
        try? controller.performFetch()
        
        // And now, start the other controller to listen changes in users
        try? usersFRC.performFetch()
        
        return controller
    }()
    
    lazy var usersFRC: NSFetchedResultsController<User>! = { () -> NSFetchedResultsController<User> in
        let req = User.fetchRequest() as NSFetchRequest<User>
        req.sortDescriptors = [ NSSortDescriptor(key:"recordID", ascending:true )]
        let controller = NSFetchedResultsController<User>(fetchRequest: req, managedObjectContext: context,
                                                          sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        return controller
    }()
    
    @IBAction func sendAction(_ sender: Any) {
        self.sendMessage(textBox.text)
        textBox.text = ""
        textBox.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.isHidden = false
        downloader = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: (#selector(ChatViewController.updater)), userInfo: nil, repeats: true)
        progressBar.setProgress(0, animated: false)
    
        title  = group.name
        originalBottomSpace = bottomConstaint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAnimation(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAnimation(_:)), name: .UIKeyboardWillHide, object: nil)
        
        reloadData()
        //Refresh when getting a new chat
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: NSNotification.Name(rawValue: "refreshView"), object: nil)
        
        // And refresh info of users... perhaps they have changed fullName or image properties
        UserManager(context: context).refreshAllUsersInfo()
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
        scrollToBottom()
    }
        
    @objc func refreshView(notification: NSNotification) {
        reloadData()
    }
    
    func reloadData(){
        MessageManager.shared.downloadMessages(group.recordID! , in: context, { (error) in
            guard error == nil else {
                return
            }
            
            self.progressBar.isHidden = true
            
            // If no error, this block is called from context's queue
            try? self.context.save()
            self.context.parent?.perform {
                try? self.context.parent!.save()
            }
        })
    }

    func scrollToBottom() {
        if let numSections = frc.sections?.count,
            numSections > 0,
            frc.sections![numSections-1].numberOfObjects > 0 {
            let num = frc.sections![numSections-1].numberOfObjects
            let lastIP = IndexPath(row:num-1, section:numSections-1)
            tableView.scrollToRow(at: lastIP, at: .bottom, animated: true)
        }
    }
    
    @objc(tapAction:)
    func tapAction(_ tap: UITapGestureRecognizer) {
        guard tap.state == .ended else { return }
        textBox.resignFirstResponder()
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    @objc func keyboardAnimation(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect)
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        
        let animationCurve = UIViewAnimationOptions(rawValue:curve.uintValue << 16)
        
        let height = view.bounds.size.height - convertedKeyboardEndFrame.origin.y
        
        bottomConstaint.constant = originalBottomSpace - height
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: [.beginFromCurrentState, animationCurve],
                       animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
        
        scrollToBottom()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let nav = segue.destination as! EditGroupViewController
            nav.group = group
        }
    }
    
    func sendMessage(_ text : String ) {
        
        MessageManager.shared.sendMessage(group, text, in: context) { error in
            guard error == nil else { return }
            
            // If no error, this block is called in context's queue
            if self.context.hasChanges {
                try? self.context.save()
            }
        }
    }

}
