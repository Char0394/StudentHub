//
//  LoginViewController.swift
//  StudentHub
//
//  Created by Charlin Agramonte on 3/1/18.
//  Copyright © 2018 Universidad San Jorge. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class LoginViewController: UIViewController, NSFetchedResultsControllerDelegate {

    lazy var context : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenContainer = appDelegate.persistentContainer
        return persistenContainer.viewContext
    }()
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text  = "char"
        password.text  = "1234"
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.hideKeyboardOnTap(#selector(self.dismissKeyboard))
        
        userName.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        password.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        UIView.animate(withDuration: 0.5, delay: 0.2,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0.5,
                                   options: [.curveEaseOut], animations: {
                                   self.userName.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.2,
                                   usingSpringWithDamping: 0.3,
                                   initialSpringVelocity: 0.5,
                                   options: [.curveEaseOut], animations: {
                                     self.password.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }

    @IBAction func onLogin(_ sender: Any) {
        weak var weakSelf = self
        if (userName.text?.isEmpty)! || (password.text?.isEmpty)!{
            showAlert(title: "Error", msg: "Por favor inserte los campos vacios")
        }else{
            UserManager(context: context).dologin(email: userName.text, password: password.text, completion: { (result) in
                DispatchQueue.main.async {
                    if result != nil {
                       weakSelf?.performSegue(withIdentifier: "goToHomeSegue", sender: nil)
                    }else{
                        weakSelf?.showAlert(title: "Error :(", msg: "Usuario y contraseña incorrectos")
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
