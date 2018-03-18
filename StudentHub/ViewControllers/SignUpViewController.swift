//
//  SignUpViewController.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/1/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SignUpViewController: UIViewController, NSFetchedResultsControllerDelegate {

    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenContainer = appDelegate.persistentContainer
        return persistenContainer.viewContext
    }()
    
    let imagePicker = UIImagePickerController()
    let documentsDirectoryPath:NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.hideKeyboardOnTap(#selector(self.dismissKeyboard))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.imageTapped(gesture:)))
        
        // add it to the image view;
        imageView.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        imageView.isUserInteractionEnabled = true
        
        name.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        password.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        email.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        imageView.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
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
    
    @IBAction func onSignUp(_ sender: Any) {
         weak var weakSelf = self
        if (name.text?.isEmpty)! || (password.text?.isEmpty)! || (email.text?.isEmpty)!{
            showAlert(title: "Error", msg: "Por favor inserte los campos vacios")
        }else{
            UserManager(context: context).createAnAcount(name: name.text, password: password.text, email: email.text, image: imageView.image, completion: { (result) in
                DispatchQueue.main.async {
                    if result.isEmpty {
                        weakSelf?.performSegue(withIdentifier: "goToHomeFromRegisterSegue", sender: nil)
                    }else{
                        weakSelf?.showAlert(title: "Error :(", msg: result)
                    }
                }
            })
        }
    }
    
    func hideKeyboardOnTap(_ selector: Selector) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
