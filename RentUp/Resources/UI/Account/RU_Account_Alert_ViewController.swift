//
//  RU_Account_Alert_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 18/03/2026.
//

import Foundation
import UIKit
import SnapKit

public class RU_Account_Alert_ViewController : RU_Alert_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        title = String(key: "account.placeholder.title")
        add(UIImage(named: "placeholder_account"))
        add(String(key: "account.placeholder.label"))
        
        if RU_Account.shared.signInType == .Email {
            
            var emailDidChange:Bool = false
            
            let emailTextField:RU_TextField = .init()
            emailTextField.layer.borderWidth = 1
            emailTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
            emailTextField.layer.cornerRadius = UI.CornerRadius
            emailTextField.snp.remakeConstraints { make in
                
                make.height.equalTo(2*UI.CornerRadius)
            }
            emailTextField.keyboardType = .emailAddress
            emailTextField.placeholder = String(key: "account.email.placeholder")
            emailTextField.text = RU_Account.shared.email
            add(emailTextField)
            contentStackView.setCustomSpacing(UI.Margins, after: emailTextField)
            
            var passwordDidChange:Bool = false
            let passwordValidationStackView:RU_Account_PasswordValidation_StackView = .init()
            
            let passwordTextField:RU_TextField = .init()
            passwordTextField.layer.borderWidth = 1
            passwordTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
            passwordTextField.layer.cornerRadius = UI.CornerRadius
            passwordTextField.text = .randomPassword
            passwordTextField.snp.remakeConstraints { make in
                
                make.height.equalTo(2*UI.CornerRadius)
            }
            passwordTextField.isSecureTextEntry = true
            passwordTextField.placeholder = String(key: "account.password.placeholder")
            add(passwordTextField)
            
            add(passwordValidationStackView)
            
            let button = addButton(title: String(key: "account.placeholder.button")) { [weak self] button in
                
                let updateClosure:((RU_Button?)->Void) = { button in
                    
                    button?.isLoading = true
                    
                    var errors:[Error?] = .init()
                    let taskGroup = DispatchGroup()
                    
                    if emailDidChange {
                        
                        taskGroup.enter()
                        
                        RU_Account.shared.update(email: emailTextField.text) { error in
                            
                            errors.append(error)
                            taskGroup.leave()
                        }
                    }
                    
                    if passwordDidChange {
                        
                        taskGroup.enter()
                        
                        RU_Account.shared.update(password: passwordTextField.text) { error in
                            
                            errors.append(error)
                            taskGroup.leave()
                        }
                    }
                    
                    taskGroup.notify(queue: .main) {
                        
                        button?.isLoading = false
                        
                        if !errors.allSatisfy({ $0 == nil }) {
                            
                            RU_Alert_ViewController.present(RU_Error(String(key: "account.reautenticate.update.alert.error")))
                        }
                    }
                }
                
                if emailDidChange || passwordDidChange {
                    
                    self?.close {
                        
                        let alertController:RU_Alert_ViewController = .init()
                        alertController.title = String(key: "account.reautenticate.update.alert.title")
                        alertController.add(String(key: "account.reautenticate.update.alert.label"))
                        
                        let reauthenticatePasswordTextField:RU_TextField = .init()
                        reauthenticatePasswordTextField.layer.borderWidth = 1
                        reauthenticatePasswordTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
                        reauthenticatePasswordTextField.layer.cornerRadius = UI.CornerRadius
                        reauthenticatePasswordTextField.snp.remakeConstraints { make in
                            
                            make.height.equalTo(2*UI.CornerRadius)
                        }
                        reauthenticatePasswordTextField.isSecureTextEntry = true
                        reauthenticatePasswordTextField.placeholder = String(key: "account.reautenticate.update.alert.password.placeholder")
                        alertController.add(reauthenticatePasswordTextField)
                        
                        let reauthenticatePasswordValidationStackView:RU_Account_PasswordValidation_StackView = .init()
                        alertController.add(reauthenticatePasswordValidationStackView)
                        
                        let reauthenticateButton = alertController.addButton(title: String(key: "account.reautenticate.update.alert.button")) { reauthenticateButton in
                            
                            reauthenticateButton?.isLoading = true
                            
                            RU_Account.shared.reauthenticate(with: reauthenticatePasswordTextField.text) { error in
                                
                                reauthenticateButton?.isLoading = false
                                
                                alertController.close() {
                                    
                                    if let error = error {
                                        
                                        RU_Alert_ViewController.present(error)
                                    }
                                    else {
                                        
                                        updateClosure(button)
                                    }
                                }
                            }
                        }
                        reauthenticateButton.isEnabled = false
                        
                        reauthenticatePasswordTextField.addAction(.init(handler: { _ in
                            
                            reauthenticatePasswordValidationStackView.password = reauthenticatePasswordTextField.text
                            reauthenticateButton.isEnabled = reauthenticatePasswordTextField.text?.isValidPassword ?? false
                            
                        }), for: .editingChanged)
                        
                        alertController.addCancelButton()
                        alertController.present()
                    }
                }
                else {
                    
                    updateClosure(button)
                }
            }
            button.image = UIImage(systemName: "square.and.arrow.down")
            
            let updateButton:(()->Void) = {
                
                button.isEnabled = emailTextField.text?.isValidEmail ?? false && passwordTextField.text?.isValidPassword ?? false
            }
            
            emailTextField.addAction(.init(handler: { _ in
                
                emailDidChange = true
                updateButton()
                
            }), for: .editingChanged)
            passwordTextField.addAction(.init(handler: { _ in
                
                passwordDidChange = true
                passwordValidationStackView.password = passwordTextField.text
                updateButton()
                
            }), for: .editingChanged)
            
            updateButton()
        }
        
        let deleteButton = addButton(title: String(key: "account.delete.button")) { [weak self] button in
            
            self?.close {
              
                let alertController:RU_Alert_ViewController = .init()
                alertController.title = String(key: "account.delete.alert.title")
                alertController.add(UIImage(named: "placeholder_trash"))
                alertController.add(String(key: "account.delete.alert.label"))
                
                let deleteAlertButton = alertController.addButton(title: String(key: "account.delete.alert.button")) { deleteAlertButton in
                    
                    alertController.close() {
                        
                        let deleteClosure:((RU_Button?)->Void) = { button in
                            
                            button?.isLoading = true
                            
                            RU_Account.shared.delete { error in
                                
                                button?.isLoading = false
                                
                                if let error = error {
                                    
                                    RU_Alert_ViewController.present(error)
                                }
                            }
                        }
                        
                        if RU_Account.shared.signInType == .Email {
                            
                            let alertController:RU_Alert_ViewController = .init()
                            alertController.title = String(key: "account.reautenticate.delete.alert.title")
                            alertController.add(String(key: "account.reautenticate.delete.alert.label"))
                            
                            let reauthenticatePasswordTextField:RU_TextField = .init()
                            reauthenticatePasswordTextField.layer.borderWidth = 1
                            reauthenticatePasswordTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
                            reauthenticatePasswordTextField.layer.cornerRadius = UI.CornerRadius
                            reauthenticatePasswordTextField.snp.remakeConstraints { make in
                                
                                make.height.equalTo(2*UI.CornerRadius)
                            }
                            reauthenticatePasswordTextField.isSecureTextEntry = true
                            reauthenticatePasswordTextField.placeholder = String(key: "account.reautenticate.delete.alert.password.placeholder")
                            alertController.add(reauthenticatePasswordTextField)
                            
                            let reauthenticatePasswordValidationStackView:RU_Account_PasswordValidation_StackView = .init()
                            alertController.add(reauthenticatePasswordValidationStackView)
                            
                            let button = alertController.addButton(title: String(key: "account.reautenticate.delete.alert.button")) { reauthenticateButton in
                                
                                reauthenticateButton?.isLoading = true
                                
                                RU_Account.shared.reauthenticate(with: reauthenticatePasswordTextField.text) { error in
                                    
                                    reauthenticateButton?.isLoading = false
                                    
                                    alertController.close() {
                                        
                                        if let error = error {
                                            
                                            RU_Alert_ViewController.present(error)
                                        }
                                        else {
                                            
                                            deleteClosure(button)
                                        }
                                    }
                                }
                            }
                            button.isEnabled = false
                            
                            reauthenticatePasswordTextField.addAction(.init(handler: { _ in
                                
                                reauthenticatePasswordValidationStackView.password = reauthenticatePasswordTextField.text
                                button.isEnabled = reauthenticatePasswordTextField.text?.isValidPassword ?? false
                                
                            }), for: .editingChanged)
                            
                            alertController.addCancelButton()
                            alertController.present()
                        }
                        else if RU_Account.shared.signInType == .Apple {
                            
                            RU_Account.shared.reauthenticateWithApple { error in
                                
                                if let error = error {
                                    
                                    RU_Alert_ViewController.present(error)
                                }
                                else {
                                    
                                    deleteClosure(deleteAlertButton)
                                }
                            }
                        }
                        else if RU_Account.shared.signInType == .Google {
                            
                            RU_Account.shared.reauthenticateWithGoogle { error in
                                
                                if let error = error {
                                    
                                    RU_Alert_ViewController.present(error)
                                }
                                else {
                                    
                                    deleteClosure(deleteAlertButton)
                                }
                            }
                        }
                    }
                }
                deleteAlertButton.type = .delete
                deleteAlertButton.image = UIImage(systemName: "trash")
                alertController.addCancelButton()
                alertController.present()
            }
        }
        deleteButton.type = .delete
        deleteButton.image = UIImage(systemName: "trash")
    }
}
