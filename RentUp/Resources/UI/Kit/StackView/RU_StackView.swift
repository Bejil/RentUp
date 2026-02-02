//
//  RU_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit

public class RU_StackView : UIStackView {
	
	public var didUpdate:(()->Void)?
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		didUpdate?()
	}
}
