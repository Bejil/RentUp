//
//  RU_Platform_SegmentedControl.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit

public class RU_Platform_SegmentedControl : RU_SegmentedControl {
	
	public var classified:RU_Classified? {
		
		didSet {
			
			if let platforms = classified?.tarification.compactMap({ $0.platform }) {
				
				removeAllSegments()
				
				for (index, platform) in platforms.enumerated() {
					
					insertSegment(withTitle: platform.type?.name, at: index, animated: false)
				}
			}
		}
	}
	
	convenience public init() {
		
		self.init(frame: .zero)
		
		if let platforms = RU_Platform.all {
			
			for (index, platform) in platforms.enumerated() {
				
				insertSegment(withTitle: platform.type?.name, at: index, animated: false)
			}
		}
		
		addAction(.init(handler: { [weak self] _ in
			
			if let selectedSegmentIndex = self?.selectedSegmentIndex {
				
				self?.selectedSegmentTintColor = RU_Platform.all?[selectedSegmentIndex].type?.backgroundColor
			}
			
		}), for: .valueChanged)
	}
}
