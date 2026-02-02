//
//  UIStackView_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 18/02/2025.
//

import UIKit

extension UIStackView {
	
	public func animate() {
		
		for i in 0..<arrangedSubviews.count {
			
			let view = arrangedSubviews[i]
			
			if !view.isHidden {
				
				view.isHidden = true
				view.alpha = 0.0
				view.transform = .init(translationX: 0, y: (CGFloat(i)+1)*(2*UI.Margins))
				
				UIView.animate(withDuration: 0.5, delay: Double(i)*0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
					
					view.isHidden = false
					view.alpha = 1.0
					view.superview?.layoutIfNeeded()
					view.transform = .identity
					
				}, completion: nil)
			}
		}
	}
}
