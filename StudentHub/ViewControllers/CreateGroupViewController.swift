//
//  CreateGroupViewController.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/2/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import UIKit
import CoreData

class CreateGroupViewController: UIViewController, NSFetchedResultsControllerDelegate {

    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenContainer = appDelegate.persistentContainer
        return persistenContainer.viewContext
    }()
    
    @IBOutlet weak var progressBar: UIProgressView!
    var minValue = 0
    var maxValue = 100
    var downloader = Timer()
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
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
        
        groupName.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        imageView.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        
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
    
    @IBAction func onCreateGroup(_ sender: Any) {
          weak var weakSelf = self
        progressBar.isHidden = false
        if (groupName.text?.isEmpty)!{
            showAlert(title: "Error", msg: "Por favor inserte los campos vacios")
        }else{
            GroupManager.shared.createGroup(groupName: groupName.text, image: imageView.image, context, completion: { (result) in
                DispatchQueue.main.async {
                    if result == nil {
                        weakSelf?.progressBar.isHidden = true
                        _ = weakSelf?.navigationController?.popViewController(animated: true)
                    }else{
                        weakSelf?.showAlert(title: "Error :(", msg: result!)
                    }
                }
            })
        }
    }

}
