//
//  EditGroupViewController.swift
//  StudentHub
//
//  Created by jdumasleon on 11/3/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditGroupViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    var minValue = 0
    var maxValue = 100
    var downloader = Timer()
    
    var group:Group! = nil
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenContainer = appDelegate.persistentContainer
        return persistenContainer.viewContext
    }()
    
    let imagePicker = UIImagePickerController()
    let documentsDirectoryPath:NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.imageTapped(gesture:)))
        
        // add it to the image view;
        imageView.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        imageView.isUserInteractionEnabled = true
        imageView.image = group.image as? UIImage
        groupName.text = group.name
        groupName.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        imageView.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        
        downloader = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: (#selector(ChatViewController.updater)), userInfo: nil, repeats: true)
        progressBar.setProgress(0, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.2,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut], animations: {
                        self.groupName.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.2,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut], animations: {
                        self.imageView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    @objc func updater() {
        if minValue != maxValue {
            minValue += 1
            progressBar.progress = Float(minValue) / Float(maxValue)
        } else {
            minValue = 0
        }
    }
    
    @IBAction func onSaveGroup(_ sender: Any) {
        weak var weakSelf = self
        progressBar.isHidden = false
        if (groupName.text?.isEmpty)!{
            showAlert(title: "Error", msg: "Por favor inserte los campos vacios")
        }else{
            GroupManager.shared.updateGroup(group.recordID , oldName: group.name, newName: groupName.text, image: imageView.image, context, completion: { (result) in
                DispatchQueue.main.async {
                    if result.isEmpty {
                        weakSelf?.progressBar.isHidden = true
                        _ = weakSelf?.navigationController?.popViewController(animated: true)
                    }else{
                        weakSelf?.showAlert(title: "Error :(", msg: result)
                    }
                }
            })
        }
    }
    
}
