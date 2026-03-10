//
//  RU_Booking_UI_Extension.swift
//  RentUp
//
//  Created by Michaël Blin on 10/03/2026.
//

import UIKit

extension RU_Booking {
    
    public static func create() {
        
        RU_Alert_ViewController.presentLoading { controller in
            
            RU_Classified.getAll { error, classifieds in
                
                controller?.close {
                  
                    if let error {
                        
                        RU_Alert_ViewController.present(error)
                    }
                    else if classifieds?.isEmpty ?? true {
                        
                        RU_Alert_ViewController.present(RU_Error(String(key: "bookings.create.noClassifieds")))
                    }
                    else {
                        
                        UI.MainController.present(RU_NavigationController(rootViewController: RU_Bookings_Edit_ViewController()), animated: true)
                    }
                }
            }
        }
    }
}
