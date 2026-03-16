//
//  RU_User.swift
//  RentUp
//
//  Created by Michaël Blin on 14/03/2026.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

nonisolated
public class RU_User : Codable {
    
    static public var current:RU_User?
    @DocumentID public var id: String?
    public var uid:String?
}

extension RU_User {
    
    public static func get(_ uid:String?, _ completion:((RU_User?,Error?)->Void)?) {
        
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: uid ?? "").getDocuments { querySnapshot, error in
            
            if let user = querySnapshot?.documents.compactMap({ try?$0.data(as: RU_User.self) }).first {
                
                RU_User.current = user
                completion?(user,error)
            }
            else {
                
                let user:RU_User = .init()
                user.uid = RU_Account.shared.user?.uid
                user.save { error in
                    
                    if let error = error {
                        
                        completion?(nil,error)
                    }
                    else {
                        
                        RU_User.current = user
                        completion?(user,error)
                    }
                }
            }
        }
    }
    
    public func save(_ completion:((Error?)->Void)?) {
        
        do {
            
            let documentReference = try Firestore.firestore().collection("users").addDocument(from: self)
            id = documentReference.documentID
            RU_User.current = self
            completion?(nil)
        }
        catch {
            
            completion?(error)
        }
    }
}
