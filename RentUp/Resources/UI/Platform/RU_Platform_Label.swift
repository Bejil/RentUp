//
//  RU_Platform_Label.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit
import SnapKit

public class RU_Platform_Label : RU_Label {
	
	public var isMinimal:Bool = false {
		
		didSet {
			
			update()
		}
	}
	public var platform:RU_Platform? {
		
		didSet {
			
			update()
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		textAlignment = .center
		numberOfLines = 1
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.required, for: .horizontal)
	}
	
	@MainActor required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func update() {
		
		backgroundColor = platform?.type?.backgroundColor
		textColor = platform?.type?.textColor
		text = isMinimal ? platform?.type?.name.first.map({ $0.uppercased() }) : platform?.type?.name
		font = isMinimal ? Fonts.Content.Title.H3 : Fonts.Content.Text.Bold.withSize(Fonts.Size-2)
		
		let minimalSize = 2.5*UI.Margins
		
		layer.cornerRadius = isMinimal ? minimalSize/2 : UI.Margins/2
		contentInsets = isMinimal ? .zero : .init(horizontal: UI.Margins/3, vertical: UI.Margins/7)
		
		if isMinimal {
			
			snp.makeConstraints { make in
				make.size.equalTo(minimalSize)
			}
		}
		else {
			
			snp.removeConstraints()
		}
	}
}
