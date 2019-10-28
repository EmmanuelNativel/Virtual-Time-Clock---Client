//
//  ViewController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/21/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Attributs
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
        setupTextField()
    }
    
    
    // MARK: Méthodes
    private func setupButtons(){
        loginButton.layer.cornerRadius = 20
    }
    
    private func setupTextField(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Actions
    @objc private func hideKeyboard(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func onClickOnLoginButton(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (AuthentificationResult, error) in
                if((error) != nil) { //Erreur d'authentification
                    print("⛔️"+error.debugDescription)
                }
                else { //Authentification réussie
                    print("✅ Connexion de l'utilisateur " + self.emailTextField.text!)
                    self.performSegue(withIdentifier: "LoginToMissionManager", sender: self)
                }
            }
        }
        else { //Champs non remplis
            print("⛔️ Veuillez remplir les champs !")
        }
    }
    
    
}

// MARK: Extensions

//Délégué des TextField
extension LoginController:UITextFieldDelegate{
    
    //Gestion de l'appui sur le bouton return du clavier
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //Permet de fermer le clavier
        return true
    }
}
