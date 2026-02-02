//
//  String_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import Foundation

extension String {
	
	init(key:String) {
		
		self = NSLocalizedString(key, comment:"localizable string")
	}
}
