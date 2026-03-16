//
//  CE_Account_SignUp_PasswordValidation_StackView.swift
//  Cadremploi
//
//  Created by BLIN Michael on 05/08/2021.
//

import UIKit

public class RU_Account_PasswordValidation_StackView: UIStackView {

	public var password:String? {
		
		didSet {
			
			UIView.animate {
				
				self.isHidden = self.password?.isEmpty ?? true
				self.alpha = 1.0
				self.superview?.layoutIfNeeded()
			}
			
			let isValidClosure:((UIImageView,Bool?)->Void) = { imageView, state in
				
				if state ?? false && imageView.tintColor == Colors.Content.Text.withAlphaComponent(0.25) {
					
					imageView.pulse(Colors.Secondary)
				}
				
				imageView.tintColor = state ?? false ? Colors.Secondary : Colors.Content.Text.withAlphaComponent(0.25)
				imageView.image = UIImage(systemName: state ?? false ? "checkmark.circle.fill" : "checkmark.circle")
			}
			
			isValidClosure(passwordValidationMinCharactersImageView,password?.isValidPasswordMinCharacters)
			isValidClosure(passwordValidationUppercaseCharacterImageView,password?.isValidPasswordUppercaseCharacter)
			isValidClosure(passwordValidationLowercaseCharacterImageView,password?.isValidPasswordLowercaseCharacter)
			isValidClosure(passwordValidationSpecialCharacterImageView,password?.isValidPasswordSpecialCharacter)
			isValidClosure(passwordValidationNumericCharacterImageView,password?.isValidPasswordNumericCharacter)
		}
	}
	private lazy var passwordValidationMinCharactersImageView:UIImageView = .init()
	private lazy var passwordValidationLowercaseCharacterImageView:UIImageView = .init()
	private lazy var passwordValidationUppercaseCharacterImageView:UIImageView = .init()
	private lazy var passwordValidationSpecialCharacterImageView:UIImageView = .init()
	private lazy var passwordValidationNumericCharacterImageView:UIImageView = .init()
	
	convenience init() {
		
		self.init(frame: .zero)
		
		isHidden = true
		alpha = 0.0
		axis = .vertical
		
		createPasswordValidationFieldStackView(with: passwordValidationMinCharactersImageView, and: String(key: "user.passwordValidation.characters"))
		createPasswordValidationFieldStackView(with: passwordValidationLowercaseCharacterImageView, and: String(key: "user.passwordValidation.lowercase"))
		createPasswordValidationFieldStackView(with: passwordValidationUppercaseCharacterImageView, and: String(key: "user.passwordValidation.uppercase"))
		createPasswordValidationFieldStackView(with: passwordValidationSpecialCharacterImageView, and: String(key: "user.passwordValidation.special"))
		createPasswordValidationFieldStackView(with: passwordValidationNumericCharacterImageView, and: String(key: "user.passwordValidation.number"))
	}
	
	private func createPasswordValidationFieldStackView(with imageView:UIImageView, and string:String) {
		
		imageView.image = UIImage(systemName: "checkmark.circle")
		imageView.contentMode = .scaleAspectFit
		imageView.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
		imageView.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
		imageView.tintColor = Colors.Content.Text.withAlphaComponent(0.25)
		
		let label:UILabel = .init()
		label.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-3)
		label.textColor = Colors.Content.Text
		label.text = string
		label.numberOfLines = 0
		
		let stackView:UIStackView = .init(arrangedSubviews: [imageView,label])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = UI.Margins/2
		addArrangedSubview(stackView)
	}
}
