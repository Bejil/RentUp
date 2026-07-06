//
//  UITraitCollection_Extension.swift
//  RentUp
//

import UIKit

extension UITraitCollection {
	
	public var isRegularWidth: Bool {
		horizontalSizeClass == .regular
	}
}

extension UIUserInterfaceIdiom {
	
	public var isLargeScreen: Bool {
		self == .pad || self == .mac
	}
}
