//
//  RU_Section_ImageView.swift
//  RentUp
//
//  Created by BLIN Michael on 23/01/2026.
//

import UIKit
import SnapKit

public class RU_Section_ImageView : UIImageView {
	
	public override init(image: UIImage?) {
		
		super.init(image: image)
		
		setUp()
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		setUp()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setUp() {
		
		tintColor = Colors.Primary
		contentMode = .scaleAspectFit
		snp.makeConstraints { make in
			make.size.equalTo(UI.Margins)
		}
	}
}
