//
//  RU_TextView.swift
//  RentUp
//
//  Created by BLIN Michael on 04/02/2026.
//

import UIKit
import SnapKit

public class RU_TextView : UITextView {
	
	public var inset:UIEdgeInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/3) {
		
		didSet {
			
			textContainerInset = inset
		}
	}
	
	public override init(frame: CGRect, textContainer: NSTextContainer?) {
		
		super.init(frame: frame, textContainer: textContainer)
		
		layer.cornerRadius = UI.CornerRadius
		layer.borderWidth = 1.0
		layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
		font = Fonts.Content.Text.Regular
		textContainerInset = .init(UI.Margins)
		
		snp.makeConstraints { make in
			make.height.equalTo(UI.Margins*10)
		}
		
		let doneButton:RU_Button = .init(String(key: "textview.done.button")) { [weak self] _ in
			
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
}
