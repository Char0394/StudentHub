//
//  SettingsViewController.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/2/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

class SettingsViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenContainer = appDelegate.persistentContainer
        return persistenContainer.viewContext
    }()
    

    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notifications: UISwitch!
    
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
        
        name.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        password.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        email.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        imageView.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        loadProfileData()
    }
    
    func loadProfileData(){
         let user = UserDefaults.standard.object(forKey: "ME") as! String
        if let myInfo = UserManager(context: context).getProfile(user){
             name.text = myInfo.name
             imageView.image = myInfo.image as? UIImage
             email.text = myInfo.email
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.2,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut], animations: {
                        self.name.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.2,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut], animations: {
                        self.password.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.2,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut], animations: {
                        self.email.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.2,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut], animations: {
                        self.imageView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "ME")
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "logout", sender: nil)
    }
    
    @IBAction func saveEditUser(_ sender: Any) {
        weak var weakSelf = self
        UserManager(context: context).saveAnAcount(name: name.text, password: password.text, email: email.text, image: imageView.image, completion: { (result) in
            DispatchQueue.main.async {
                if result.isEmpty {
                    _ = weakSelf?.navigationController?.popViewController(animated: true)
                }else{
                    weakSelf?.showAlert(title: "Error :(", msg: result)
                }
            }
        })
    }
    
    @IBAction func swicthNotifications(_ sender: UISwitch) {
        if notifications.isOn {
            print("ON")
            //Enable push notifications
            if #available(iOS 10.0, *) {
                // For iOS 10.0 +
                let center  = UNUserNotificationCenter.current()
                center.delegate = self
                center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                    if error == nil{
                        DispatchQueue.main.async(execute: {
                            UIApplication.shared.registerForRemoteNotifications()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshView"), object: nil)
                        })
                    }
                }
            }else{
                // Below iOS 10.0
                
                let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshView"), object: nil)
                //or
                //UIApplication.shared.registerForRemoteNotifications()
            }
        }
        else {
            print ("OFF")
            //Disable push notification
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
