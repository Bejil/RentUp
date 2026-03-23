//
//  RU_Account_Extension.swift
//  RentUp
//
//  Created by Michaël Blin on 18/03/2026.
//

import FirebaseAuth
import FirebaseFirestore

extension RU_Account {
    
    public func reset(_ completion:((Error?)->Void)?) {
        
        guard let uid = user?.uid, !uid.isEmpty else {
            
            completion?(RU_Error(String(key: "settings.reset.error")))
            return
        }
        
        Firestore.firestore().collection("classifieds").whereField("uid", isEqualTo: uid).getDocuments { querySnapshot, error in
            
            querySnapshot?.documents.compactMap({ $0.reference }).forEach({ $0.delete() })
            
            Firestore.firestore().collection("bookings").whereField("uid", isEqualTo: uid).getDocuments { querySnapshot, error in
                
                querySnapshot?.documents.compactMap({ $0.reference }).forEach({ $0.delete() })
                
                completion?(nil)
            }
        }
    }
}
