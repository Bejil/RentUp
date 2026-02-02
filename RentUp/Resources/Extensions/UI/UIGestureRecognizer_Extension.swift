//
//  UIGestureRecognizer_Extension.swift
//  BarcodeBattler
//
//  Created by BLIN Michael on 12/08/2022.
//

import Foundation
import UIKit

extension UIGestureRecognizer {
	
	typealias Action = ((UIGestureRecognizer) -> ())
	
	private struct Keys {
		
		static var actionKey: UInt8 = 0
	}
	
	private var block: Action? {
		set {
			if let newValue = newValue {
				objc_setAssociatedObject(self, &Keys.actionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			}
		}
		get {
			return objc_getAssociatedObject(self, &Keys.actionKey) as? Action
		}
	}
	
	@objc private func handleAction(recognizer: UIGestureRecognizer) {
		block?(recognizer)
	}
	
	public convenience init(block: @escaping ((UIGestureRecognizer) -> ())) {
		self.init()
		self.block = block
		self.addTarget(self, action: #selector(handleAction(recognizer:)))
	}
}
