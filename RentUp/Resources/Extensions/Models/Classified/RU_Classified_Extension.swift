//
//  RU_Classified_Extension.swift
//  RentUp
//
//  Created by BLIN Michael on 26/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth 

extension RU_Classified {
	
	public var canSave:Bool {
		
		return name != nil && configuration.capacity ?? 0 >= 1 && !tarification.filter({ $0.price ?? 0 > 0 }).isEmpty && (configuration.beds.doubles ?? 0 >= 1 || configuration.beds.singles ?? 0 >= 1)
	}
	
	public static func getAll(_ completion:((Error?,[RU_Classified]?)->Void)?) {
		
		Firestore.firestore().collection("classifieds").whereField("uid", isEqualTo: RU_Account.shared.user?.uid ?? "").getDocuments { querySnapshot, error in
			
			if error != nil {
				
				completion?(RU_Error(String(key: "classifieds.error.getAll")), nil)
			}
			else {
				
                Task { @MainActor in
                    
                    let classifieds = querySnapshot?.documents.compactMap { try? $0.data(as: RU_Classified.self) }
                    let sorted = classifieds?.sorted(by: { $0.creationDate > $1.creationDate }) ?? []
                    completion?(nil, sorted)
                }
			}
		}
	}
	
	public func save(_ completion:((Error?)->Void)?) {
		
		modificationDate = Date()
		
		let collection = Firestore.firestore().collection("classifieds")
		
		if let id = id, !id.isEmpty {
			
			do {
				
				try collection.document(id).setData(from: self)
				completion?(nil)
			}
			catch {
				
				completion?(RU_Error(String(key: "classifieds.error.save")))
			}
		}
		else {
			
			do {
				
				let documentReference = try collection.addDocument(from: self)
				id = documentReference.documentID
				completion?(nil)
			}
			catch {
				
				completion?(RU_Error(String(key: "classifieds.error.save")))
			}
		}
	}
	
	public func delete(_ completion:((Error?)->Void)?) {
		
		guard let id = id, !id.isEmpty else {
			
			completion?(RU_Error(String(key: "classifieds.error.delete")))
			return
		}
        
        Firestore.firestore().collection("classifieds").document(id).delete { error in
			
			if error != nil {
				
				completion?(RU_Error(String(key: "classifieds.error.delete")))
			}
			else {
				
				completion?(nil)
			}
		}
	}
    
    public static func compare() {
        
        RU_Alert_ViewController.presentLoading { controller in
            
            RU_Classified.getAll { error, classifieds in
                
                controller?.close {
                    
                    if let error {
                        
                        RU_Alert_ViewController.present(error)
                    }
                    else {
                        
                        let alertController:RU_Classified_Select_Alert_ViewController = .init()
                        alertController.classifieds = classifieds
                        alertController.selectHandler = { classified in
                            
                            let viewController:RU_Classifieds_Comparator_ViewController = .init()
                            viewController.classified = classified
                            UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
                        }
                        alertController.present(as: .Sheet)
                    }
                }
            }
        }
    }
}
