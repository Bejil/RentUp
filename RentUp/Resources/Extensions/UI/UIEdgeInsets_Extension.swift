//
//  UIEdgeInsets_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 23/06/2023.
//

import Foundation
import UIKit

extension UIEdgeInsets {
	
	init(_ all:CGFloat) {
		
		self.init(top: all, left: all, bottom: all, right: all)
	}
	
	init(horizontal:CGFloat) {
		
		self.init(top: 0, left: horizontal, bottom: 0, right: horizontal)
	}
	
	init(vertical:CGFloat) {
		
		self.init(top: vertical, left: 0, bottom: vertical, right: 0)
	}
	
	init(horizontal:CGFloat, vertical:CGFloat) {
		
		self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
	}
}
