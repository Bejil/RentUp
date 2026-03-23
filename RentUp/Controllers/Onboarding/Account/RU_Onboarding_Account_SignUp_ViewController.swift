//
//  RU_Onboarding_Account_SignUp_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 15/03/2026.
//

import Foundation
import UIKit
import SnapKit

public class RU_Onboarding_Account_SignUp_ViewController : RU_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        navigationItem.title = String(key: "onboarding.signUp.title")
        
        let placeholderView = view.showPlaceholder()
        placeholderView.isCentered = false
        placeholderView.image = UIImage(named: "placeholder_signUp")
        placeholderView.addLabel(String(key: "onboarding.signUp.label"))
        
        let emailTextField:RU_TextField = .init()
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
        emailTextField.layer.cornerRadius = UI.CornerRadius
        emailTextField.snp.remakeConstraints { make in
            
            make.height.equalTo(2*UI.CornerRadius)
        }
        emailTextField.placeholder = String(key: "onboarding.signUp.email.placeholder")
        placeholderView.contentStackView.addArrangedSubview(emailTextField)
        
        let passwordTextField:RU_TextField = .init()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
        passwordTextField.layer.cornerRadius = UI.CornerRadius
        passwordTextField.snp.remakeConstraints { make in
            
            make.height.equalTo(2*UI.CornerRadius)
        }
        passwordTextField.placeholder = String(key: "onboarding.signUp.password.placeholder")
        placeholderView.contentStackView.addArrangedSubview(passwordTextField)
        
        let passwordValidationStackView:RU_Account_PasswordValidation_StackView = .init()
        placeholderView.contentStackView.addArrangedSubview(passwordValidationStackView)
        
        let button = placeholderView.addButton(String(key: "onboarding.signUp.button")) { button in
            
            button?.isLoading = true
            
            RU_Account.shared.createUser(with: emailTextField.text, and: passwordTextField.text) { error in
                
                button?.isLoading = false
                
                if let error = error {
                    
                    RU_Alert_ViewController.present(error)
                }
            }
        }
        button.isEnabled = false
        
        let validationClosure:(()->Void) = {
            
            button.isEnabled = emailTextField.text?.isValidEmail ?? true && passwordTextField.text?.isValidPassword ?? true
        }
        
        emailTextField.addAction(.init(handler: { _ in
            
            validationClosure()
            
        }), for: .editingChanged)
        
        passwordTextField.addAction(.init(handler: { _ in
            
            passwordValidationStackView.password = passwordTextField.text
            validationClosure()
            
        }), for: .editingChanged)
        
        placeholderView.contentStackView.addArrangedSubview(RU_Account_Social_StackView())
    }
}
