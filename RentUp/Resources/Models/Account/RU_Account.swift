//
//  RU_Account.swift
//  RentUp
//
//  Created by Michaël Blin on 14/03/2026.
//

import Foundation
import Firebase
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn

public class RU_Account: NSObject {
    
    public enum SignInType : String {
        
        case Email = "password"
        case Apple = "apple.com"
        case Google = "google.com"
    }
    
    static public let shared:RU_Account = .init()
    public var user:User? {
        
        return Auth.auth().currentUser
    }
    public var email:String? {
        
        if let email = user?.email, !email.isEmpty {
            return email
        }
        
        // Fallback: providerData peut parfois être la seule source disponible
        return user?.providerData.first(where: { $0.providerID == SignInType.Email.rawValue })?.email
        ?? user?.providerData.first?.email
    }
    public var isLoggedIn:Bool {
        
        return user != nil
    }
    private var addStateDidChangeListener:AuthStateDidChangeListenerHandle?
    public typealias Error_Completion = ((Error?) -> Void)?
    private var currentAppleSignInNonce:String?
    private var appleSignCompletion:((OAuthCredential?,Error?)->Void)?
    public var signInType:SignInType {
        
        if let providerId = user?.providerData.first?.providerID {
            
            return SignInType(rawValue: providerId) ?? .Email
        }
        
        return .Email
    }
    
    deinit {
        
        if let addStateDidChangeListener = addStateDidChangeListener {
            
            Auth.auth().removeStateDidChangeListener(addStateDidChangeListener)
        }
    }
    
    public override init() {
        
        super.init()
        
        addStateDidChangeListener = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            
            self?.updateUserState()
        }
    }
    
    private func updateUserState() {
        
        RU_Feedback.shared.make(isLoggedIn ? .Success : .Error)
        
        UI.MainController.dismiss(animated: true, completion: nil)
        
        if !isLoggedIn {
            
            let navigationController:RU_NavigationController = .init(rootViewController: RU_Onboarding_Account_ViewController())
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.modalTransitionStyle = .crossDissolve
            UI.MainController.present(navigationController, animated: true)
        }
        
        NotificationCenter.post(.updateAccount)
    }
    
    public func createUser(with email:String?, and password:String?, _ completion:Error_Completion) {
        
        Auth.auth().createUser(withEmail: email ?? "", password: password ?? "") { authDataResult, error in
            
            completion?(error)
        }
    }
    
    public func signIn(with email:String?, and password:String?, _ completion:Error_Completion) {
        
        Auth.auth().signIn(withEmail: email ?? "", password: password ?? "") { authDataResult, error in
            
            completion?(error)
        }
    }
    
    public func reload(_ completion:Error_Completion) {
        
        user?.reload { error in
            
            NotificationCenter.post(.updateAccount)
            completion?(error)
        }
    }
    
    private func signIn(with credential:AuthCredential, _ completion:Error_Completion) {
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            
            UIApplication.wait {
                
                self?.updateUserState()
            }
            
            completion?(error)
        }
    }
    
    private func promptAppleSignIn() {
        
        let nonce = String.randomNonce
        currentAppleSignInNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    public func signInWithApple(_ completion:Error_Completion) {
        
        promptAppleSignIn()
        
        appleSignCompletion = { [weak self] credential, error in
            
            if let error = error {
                
                completion?(error)
            }
            else if let credential = credential {
                
                self?.signIn(with: credential, completion)
            }
        }
    }
    
    public func reauthenticateWithApple(_ completion:Error_Completion) {
        
        promptAppleSignIn()
        
        appleSignCompletion = { [weak self] credential, error in
            
            if let error = error {
                
                completion?(error)
            }
            else if let credential = credential {
                
                self?.user?.reauthenticate(with: credential) { [weak self] authDataResult, error in
                    
                    UIApplication.wait {
                        
                        self?.updateUserState()
                    }
                    
                    completion?(error)
                }
            }
        }
    }
    
    private func promptGoogleSignIn(_ completion:((GIDGoogleUser?,Error?)->Void)?) {
        
        if let clientID = FirebaseApp.app()?.options.clientID {
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            GIDSignIn.sharedInstance.signIn(withPresenting: UI.MainController) { result, error in
                
                completion?(result?.user,error)
            }
        }
    }
    
    public func signInWithGoogle(_ completion:Error_Completion) {
        
        promptGoogleSignIn { [weak self] user, error in
            
            if let error = error {
                
                completion?(error)
            }
            else if let user = user, let idToken = user.idToken {
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)
                
                self?.signIn(with: credential, completion)
            }
        }
    }
    
    public func reauthenticateWithGoogle(_ completion:Error_Completion) {
        
        promptGoogleSignIn { [weak self] user, error in
            
            if let error = error {
                
                completion?(error)
            }
            else if let user = user, let idToken = user.idToken {
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)
                
                self?.user?.reauthenticate(with: credential) { [weak self] authDataResult, error in
                    
                    UIApplication.wait {
                        
                        self?.updateUserState()
                    }
                    
                    completion?(error)
                }
            }
        }
    }
    
    public func sendPasswordReset(for email:String?, _ completion:Error_Completion) {
        
        Auth.auth().sendPasswordReset(withEmail: email ?? "", completion: completion)
    }
    
    public func signOut(_ completion:Error_Completion) {
        
        do {
            
            try Auth.auth().signOut()
            completion?(nil)
        }
        catch let error as NSError {
            
            completion?(error)
        }
    }
    
    public func reauthenticate(with password:String?, _ completion:Error_Completion) {
        
        let credential = EmailAuthProvider.credential(withEmail: email ?? "", password: password ?? "")
        
        user?.reauthenticate(with: credential) { authDataResult, error in
            
            completion?(error)
        }
    }
    
    public func update(email:String?, _ completion:Error_Completion) {
        
        Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email ?? "", actionCodeSettings: nil) { error in
            
            if error == nil {
                
                self.reload(completion)
            }
            else {
                
                NotificationCenter.post(.updateAccount)
                completion?(error)
            }
        }
    }
    
    public func update(password:String?, _ completion:Error_Completion) {
        
        Auth.auth().currentUser?.updatePassword(to: password ?? "") { error in
            
            NotificationCenter.post(.updateAccount)
            completion?(error)
        }
    }
    
    public func delete(_ completion:Error_Completion) {
        
        reset { [weak self] error in
            
            if let error {
                
                completion?(error)
            }
            else {
                
                self?.user?.delete() { error in
                    
                    completion?(error)
                }
            }
        }
    }
}

extension RU_Account: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return UI.MainController.view.window!
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential, let nonce = currentAppleSignInNonce, let appleIDToken = appleIDCredential.identityToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) {
            
            let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: idTokenString, rawNonce: nonce)
            
            appleSignCompletion?(credential,nil)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        appleSignCompletion?(nil,error)
    }
}
