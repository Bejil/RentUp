//
//  RU_Reporting_Tip_StackView.swift
//  RentUp
//
//  Created by Michaël Blin on 01/04/2026.
//

import UIKit

public class RU_Reporting_Tip_StackView : RU_Tip_StackView {
    
    public var bookings:[RU_Booking]? {
        
        didSet {
            
            isHidden = bookings?.isEmpty ?? true
        }
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        icon = UIImage(systemName: "list.clipboard.fill")
        title = String(key: "Votre bilan du mois est dispo")
        
        let label = add(String(key: "Consultez le bilan et les chiffres clefs du mois qui vient de s'écouler"))
        contentStackView.setCustomSpacing(UI.Margins, after: label)
        
        add(RU_Button(String(key: "Consulter le bilan")) { [weak self] _ in
            
            let alertController:RU_Reporting_Alert_ViewController = .init()
            alertController.bookings = self?.bookings
            alertController.present()
        })
    }
    
    @MainActor required init(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
