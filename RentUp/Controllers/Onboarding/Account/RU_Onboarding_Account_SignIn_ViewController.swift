//
//  RU_Onboarding_Account_SignIn_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 15/03/2026.
//

import Foundation
import UIKit
import SnapKit

public class RU_Onboarding_Account_SignIn_ViewController : RU_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        navigationItem.title = String(key: "onboarding.signIn.title")
        
        let placeholderView = view.showPlaceholder()
        placeholderView.isCentered = false
        placeholderView.image = UIImage(named: "placeholder_signIn")
        placeholderView.addLabel(String(key: "onboarding.signIn.label"))
        
        let emailTextField:RU_TextField = .init()
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
        emailTextField.layer.cornerRadius = UI.CornerRadius
        emailTextField.snp.remakeConstraints { make in
            
            make.height.equalTo(2*UI.CornerRadius)
        }
        emailTextField.placeholder = String(key: "onboarding.signIn.email.placeholder")
        placeholderView.contentStackView.addArrangedSubview(emailTextField)
        
        let passwordTextField:RU_TextField = .init()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
        passwordTextField.layer.cornerRadius = UI.CornerRadius
        passwordTextField.snp.remakeConstraints { make in
            
            make.height.equalTo(2*UI.CornerRadius)
        }
        passwordTextField.placeholder = String(key: "onboarding.signIn.password.placeholder")
        placeholderView.contentStackView.addArrangedSubview(passwordTextField)
        placeholderView.contentStackView.setCustomSpacing(placeholderView.contentStackView.spacing/2, after: passwordTextField)
        
        let resetPasswordButton:RU_Button = .init(String(key: "onboarding.signIn.password.reset.button")) { _ in
            
            let alertController:RU_Alert_ViewController = .init()
            alertController.title = String(key: "onboarding.signIn.password.reset.alert.title")
            alertController.add(String(key: "onboarding.signIn.password.reset.alert.content"))
            
            let resetEmailTextField:RU_TextField = .init()
            resetEmailTextField.keyboardType = .emailAddress
            resetEmailTextField.placeholder = String(key: "onboarding.signIn.password.reset.alert.email.placeholder")
            resetEmailTextField.text = emailTextField.text
            alertController.add(resetEmailTextField)
            
            let button = alertController.addButton(title: String(key: "onboarding.signIn.password.reset.alert.button")) { button in
                
                button?.isLoading = true
                
                RU_Account.shared.sendPasswordReset(for: resetEmailTextField.text) { error in
                    
                    button?.isLoading = false
                    
                    alertController.close() {
                        
                        if let error = error {
                            
                            RU_Alert_ViewController.present(error)
                        }
                    }
                }
            }
            button.isEnabled = emailTextField.text?.isValidEmail ?? false
            
            resetEmailTextField.addAction(.init(handler: { _ in
                
                button.isEnabled = resetEmailTextField.text?.isValidEmail ?? false
                
            }), for: .editingChanged)
            
            alertController.addCancelButton()
            alertController.present()
        }
        resetPasswordButton.snp.removeConstraints()
        resetPasswordButton.type = .text
        resetPasswordButton.configuration?.contentInsets = .zero
        resetPasswordButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size-4)
        resetPasswordButton.configuration?.titleAlignment = .trailing
        placeholderView.contentStackView.addArrangedSubview(resetPasswordButton)
        
        let button = placeholderView.addButton(String(key: "onboarding.signIn.button")) { button in
            
            button?.isLoading = true
            
            RU_Account.shared.signIn(with: emailTextField.text, and: passwordTextField.text) { error in
                
                button?.isLoading = false
                
                if let error = error {
                    
                    RU_Alert_ViewController.present(error)
                }
            }
        }
        button.isEnabled = false
        
        let validationClosure:(()->Void) = {
            
            button.isEnabled = emailTextField.text?.isValidEmail ?? false && passwordTextField.text?.isValidPassword ?? false
        }
        
        emailTextField.addAction(.init(handler: { _ in
            
            validationClosure()
            
        }), for: .editingChanged)
        
        passwordTextField.addAction(.init(handler: { _ in
            
            validationClosure()
            
        }), for: .editingChanged)
        
        placeholderView.contentStackView.addArrangedSubview(RU_Account_Social_StackView())
    }
}
