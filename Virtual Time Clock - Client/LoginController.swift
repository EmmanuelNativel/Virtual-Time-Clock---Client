//
//  ViewController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/21/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
    
    //Méthode pour paramétrer les boutons
    private func setupButtons(){
        loginButton.layer.cornerRadius = 20 //Arrodir les bords du bouton login
    }
    
    //Méthode pour paramétrer les TextFiels
    private func setupTextField(){
        //Liaison avec les délégués
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //Tap gesture pour fermer le clavier quand on clique dans le vide
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Actions
    
    //Fonction appelée par le TapGesture : permet de fermer le clavier
    @objc private func hideKeyboard(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //Fonction appelée quand on appui sur le bouton de logIn
    @IBAction func onClickOnLoginButton(_ sender: UIButton) {
        
        // Connexion de l'utilisateur
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (AuthentificationResult, error) in
                if((error) != nil) { // Erreur d'authentification
                    print("⛔️ Erreur lors de la connexion de l'utilisateur : " + error.debugDescription)
                }
                else { // Authentification réussie
                    print("✅ Connexion de l'utilisateur " + self.emailTextField.text!)
                    
                    // On va vérifier que c'est bien un employé
                    let db = Firestore.firestore()          // Instance de la base de données
                    let user = Auth.auth().currentUser      // Récupération de l'utilisateur courrant
                    let userId = user?.uid                  // Id de l'utilisateur courrant
                    
                    // Récupération des données de cet utilisateur dans la BD
                    let documentCurrentUser = db.collection("utilisateurs").document(userId!)
                    
                    documentCurrentUser.getDocument { (document, error) in
                        // On test si le document lié à cet utilisateur existe bien
                        if let document = document, document.exists {
                            let isLeader = document.get("isLeader") as! Bool    // Récupération du champ isLeader
                            if isLeader == false {                              // C'est un employé
                                print("✅ Ce n'est pas un leader, je le redirige vers la liste des missions")
                                self.performSegue(withIdentifier: "loginToMissionManager", sender: self)
                            }
                            else { // Ce n'est pas un employé, c'est un gérant !
                                print("⛔️ C'est un leader, je le déconnecte")
                                // Déconnexion de l'utilisateur
                                do {
                                    try Auth.auth().signOut()
                                } catch let signOutError as NSError {
                                  print ("⛔️ Erreur de déconnexion : \(signOutError)")
                                }
                            }
                        }
                        else {
                            print("⛔️ Erreur : Le document demandé pour cet utilisateur n'existe pas !")
                        }
                    }
                }
            }
        }
        else { // Les champs ne sont pas remplis
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
