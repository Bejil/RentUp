//
//  NSDirectionalEdgeInsets_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 09/08/2023.
//

import Foundation
import UIKit

extension NSDirectionalEdgeInsets {
	
	init(_ all:CGFloat) {
		
		self.init(top: all, leading: all, bottom: all, trailing: all)
	}
	
	init(horizontal:CGFloat) {
		
		self.init(top: 0, leading: horizontal, bottom: 0, trailing: horizontal)
	}
	
	init(vertical:CGFloat) {
		
		self.init(top: vertical, leading: 0, bottom: vertical, trailing: 0)
	}
	
	init(horizontal:CGFloat, vertical:CGFloat) {
		
		self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}
}
