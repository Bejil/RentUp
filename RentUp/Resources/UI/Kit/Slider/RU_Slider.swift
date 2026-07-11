//
//  RU_Slider.swift
//  RentUp
//
//  Created by Michaël Blin on 10/07/2026.
//

import UIKit

public class RU_Slider : UISlider {
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        tintColor = Colors.Primary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
