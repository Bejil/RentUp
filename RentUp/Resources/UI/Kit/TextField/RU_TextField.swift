//
//  RU_TextField.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit
import SnapKit

public class RU_TextField : UITextField {
	
	public var inset:UIEdgeInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/3) {
		
		didSet {
			
			layoutSubviews()
		}
	}
	public override var placeholder: String? {
		
		didSet {
			
			if let placeholder {
				
				attributedPlaceholder = NSAttributedString(string: placeholder, attributes:[.foregroundColor: Colors.Content.Text.withAlphaComponent(0.5)])
			}
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		delegate = self
		tintColor = Colors.TextField.TintColor
		textColor = Colors.Content.Text
		font = Fonts.Content.Text.Regular
		snp.makeConstraints { make in
            make.height.equalTo(2*UI.Margins)
		}
		
		let doneButton:RU_Button = .init(String(key: "textfield.done.button")) { [weak self] _ in
			
			self?.resignFirstResponder()
		}
		doneButton.type = .navigation
		doneButton.configuration?.contentInsets = .zero
		doneButton.snp.removeConstraints()
		
		let inputAccessoryStackView:RU_StackView = .init(arrangedSubviews: [.init(),doneButton])
		inputAccessoryStackView.axis = .horizontal
		inputAccessoryStackView.alignment = .center
		
		let accessoryHeight = 3*UI.Margins
		let lc_inputAccessoryView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .regular))
		lc_inputAccessoryView.frame = CGRect(x: 0, y: 0, width: UI.MainController.view.window?.windowScene?.screen.bounds.size.width ?? 0, height: accessoryHeight)
		lc_inputAccessoryView.contentView.addLine(position: .top)
		lc_inputAccessoryView.contentView.addSubview(inputAccessoryStackView)
		inputAccessoryStackView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(UI.Margins/2)
			make.left.right.equalToSuperview().inset(UI.Margins)
		}
		
		inputAccessoryView = lc_inputAccessoryView
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func textRect(forBounds bounds: CGRect) -> CGRect {
		
		let rect = super.textRect(forBounds: bounds)
		return rect.inset(by: inset)
	}
	
	public override func editingRect(forBounds bounds: CGRect) -> CGRect {
		
		let rect = super.editingRect(forBounds: bounds)
		return rect.inset(by: inset)
	}
}

extension RU_TextField : UITextFieldDelegate {
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		resignFirstResponder()
		
		return true
	}
}
