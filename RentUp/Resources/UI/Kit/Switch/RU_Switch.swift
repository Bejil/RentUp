//
//  RU_Switch.swift
//  RentUp
//
//  Created by Michaël Blin on 10/07/2026.
//

import UIKit

public class RU_Switch : UISwitch {
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        onTintColor = Colors.Primary
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
