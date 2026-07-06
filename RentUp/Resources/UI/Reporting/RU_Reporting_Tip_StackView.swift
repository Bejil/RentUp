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
        
        title = String(key: "bookings.reporting.tips.title")
        
        let label = addLabel(String(key: "bookings.reporting.tips.content"))
        labelsStackView.setCustomSpacing(UI.Margins, after: label)
        
        addButton(String(key: "bookings.reporting.tips.button"), { [weak self] _ in
            
            let alertController:RU_Reporting_Alert_ViewController = .init()
            alertController.bookings = self?.bookings
            alertController.present()
        })
    }
    
    @MainActor required init(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
