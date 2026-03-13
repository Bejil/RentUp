//
//  RU_Classified_Extension.swift
//  RentUp
//
//  Created by BLIN Michael on 26/01/2026.
//

import UIKit

extension RU_Classified {
	
	public var canSave:Bool {
		
		return name != nil && configuration.capacity ?? 0 >= 1 && !tarification.filter({ $0.price ?? 0 > 0 }).isEmpty && (configuration.beds.doubles ?? 0 >= 1 || configuration.beds.singles ?? 0 >= 1)
	}
	
	public static func getAll(_ completion:((Error?,[RU_Classified]?)->Void)?) {
		
		if let data = UserDefaults.get(.classifieds) as? Data {
			
			do {
				
				let bookings = try JSONDecoder().decode([RU_Classified].self, from: data)
				completion?(nil,bookings.sorted(by: { $0.creationDate > $1.creationDate }))
			}
			catch {
				
				completion?(RU_Error(String(key: "classifieds.error.getAll")),nil)
			}
		}
		else {
			
			completion?(nil,[])
		}
	}
	
	public func save(_ completion:((Error?)->Void)?) {
		
		RU_Classified.getAll { [weak self] error, classifieds in
			
			if error != nil {
				
				completion?(RU_Error(String(key: "classifieds.error.save")))
			}
			else if let self, var classifieds {
				
				if let index = classifieds.firstIndex(of: self) {
					
					self.modificationDate = Date()
					classifieds[index] = self
				}
				else {
					
					classifieds.append(self)
				}
				
				do {
					
					let data = try JSONEncoder().encode(classifieds)
					UserDefaults.set(data, .classifieds)
					
					completion?(nil)
				}
				catch {
					
					completion?(RU_Error(String(key: "classifieds.error.save")))
				}
			}
			else {
				
				completion?(RU_Error(String(key: "classifieds.error.save")))
			}
		}
	}
	
	public func delete(_ completion:((Error?)->Void)?) {
		
		RU_Classified.getAll { [weak self] error, classifieds in
			
			if error != nil {
				
				completion?(RU_Error(String(key: "classifieds.error.delete")))
			}
			else if let self, var classifieds {
				
				if classifieds.contains(self) {
					
					classifieds.removeAll { $0.id == self.id }
					
					do {
						
						let data = try JSONEncoder().encode(classifieds)
						UserDefaults.set(data, .classifieds)
						
						completion?(nil)
					}
					catch {
						
						completion?(RU_Error(String(key: "classifieds.error.delete")))
					}
				}
				else {
					
					completion?(RU_Error(String(key: "classifieds.error.delete")))
				}
			}
			else {
				
				completion?(RU_Error(String(key: "classifieds.error.delete")))
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
