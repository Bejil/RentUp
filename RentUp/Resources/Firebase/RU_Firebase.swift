//
//  RU_Firebase.swift
//  RentUp
//
//  Created by BLIN Michael on 07/03/2025.
//

import Firebase
import GoogleSignIn

public class RU_Firebase {
	
	public static let shared:RU_Firebase = .init()
	
	public func start() {
		
		FirebaseApp.configure()
	}
    
    public func handle(_ url:URL) -> Bool {
        
        return GIDSignIn.sharedInstance.handle(url)
    }
}
