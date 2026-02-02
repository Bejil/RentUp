//
//  RU_ScrollView.swift
//  LettroLine
//
//  Created by BLIN Michael on 10/09/2025.
//

import UIKit

public class RU_ScrollView: UIScrollView {
	
	public var isCentered:Bool = true {
		
		didSet {
			
			updateContentInset()
		}
	}
	
	public override var bounds: CGRect {
		
		didSet {
			
			updateContentInset()
		}
	}
	
	public override var contentSize: CGSize {
		
		didSet {
			
			updateContentInset()
		}
	}
	
	private func updateContentInset() {
		
		if isCentered {
			
			var top = CGFloat(0)
			var left = CGFloat(0)
			
			if contentSize.width < bounds.width {
				
				left = (bounds.width - contentSize.width) / 2
			}
			
			if contentSize.height < bounds.height {
				
				top = (bounds.height - contentSize.height) / 2
			}
			
			contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
		}
	}
}
