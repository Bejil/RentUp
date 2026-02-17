//
//  RU_Button.swift
//  LettroLine
//
//  Created by BLIN Michael on 19/03/2023.
//

import Foundation
import UIKit
import SnapKit

public class RU_Button : UIButton {
	
	public enum ButtonType {
		case primary
		case secondary
		case tertiary
		case text
		case navigation
		case delete
	}
	
	public enum ButtonStyle {
		case solid
		case tinted
		case transparent
		case bordered
        case inverted
	}
	
	// MARK: - Properties
	public var type: ButtonType = .primary {
		didSet {
			
			if type == .navigation || type == .text {
				
				style = .transparent
			}
			else {
				
				updateAppearance()
			}
		}
	}
	
	public var style: ButtonStyle = .solid {
		didSet { updateAppearance() }
	}
	
	public var showTouchEffect: Bool = true
	
	public override var isEnabled: Bool {
		didSet {
			alpha = isEnabled ? 1.0 : 0.45
		}
	}
	
	public var isLoading: Bool = false {
		didSet {
			isUserInteractionEnabled = !isLoading
			configuration?.showsActivityIndicator = isLoading
		}
	}
	
	public var title: String? {
		didSet { updateContent() }
	}
	
	public var titleFont: UIFont = Fonts.Content.Button.Title {
		didSet { updateContent() }
	}
	
	public var subtitle: String? {
		didSet { updateContent() }
	}
	
	public var subtitleFont: UIFont = Fonts.Content.Button.Subtitle {
		didSet { updateContent() }
	}
	
	public var image: UIImage? {
		didSet { updateContent() }
	}
	
	public typealias Handler = ((RU_Button?) -> Void)?
	public var action: Handler = nil
	
	public var badge: String? {
		didSet {
			badgeView.text = badge
			badgeView.isHidden = badge?.isEmpty ?? true
			
			if badge?.count ?? 0 == 1 {
				badgeView.snp.remakeConstraints { make in
					make.height.equalTo(badgeView.snp.width)
					make.width.greaterThanOrEqualTo(UI.Margins)
					make.top.right.equalToSuperview().inset(-UI.Margins/3)
				}
			} else {
				badgeView.snp.remakeConstraints { make in
					make.height.equalTo(1.5*UI.Margins)
					make.width.greaterThanOrEqualTo(badgeView.snp.height)
					make.top.right.equalToSuperview().inset(-UI.Margins/3)
				}
			}
			
			badgeView.layoutIfNeeded()
			badgeView.layer.cornerRadius = badgeView.frame.size.height/2
		}
	}
	
	// MARK: - UI Components
	private lazy var badgeView: RU_Label = {
		$0.backgroundColor = Colors.Button.Badge
		$0.textColor = .white
		$0.textAlignment = .center
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-2)
		$0.layer.cornerRadius = UI.Margins/2
		$0.clipsToBounds = true
		$0.contentInsets = .init(2)
		$0.isHidden = true
		return $0
	}(RU_Label())
	
	private lazy var gradientBackgroundLayer: CAGradientLayer = {
		$0.startPoint = CGPoint(x: 1, y: 1) // Dégradé inversé
		$0.endPoint = CGPoint(x: 0, y: 0)
		return $0
	}(CAGradientLayer())
	
	private lazy var borderGradientLayer: CAGradientLayer = {
		$0.mask = borderShapeLayer
		return $0
	}(CAGradientLayer())
	
	private lazy var borderShapeLayer: CAShapeLayer = {
		$0.lineWidth = 3
		$0.strokeColor = UIColor.black.cgColor
		$0.fillColor = UIColor.clear.cgColor
		return $0
	}(CAShapeLayer())
	
	// MARK: - Initialization
	convenience init(_ title: String? = nil, _ handler: Handler = nil) {
		self.init(frame: .zero)
		defer {
			self.title = title
			self.action = handler
		}
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupButton()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	private func setupButton() {
		
		// Configuration de base (sera mise à jour par updateAppearance)
		configuration = .filled()
		configuration?.background.cornerRadius = (4*UI.Margins)/2.5
		
		// Ajouter les layers de dégradé
		layer.insertSublayer(gradientBackgroundLayer, at: 0)
		layer.insertSublayer(borderGradientLayer, at: 0)
		
		// Contraintes de taille minimale
		snp.makeConstraints { make in
			make.size.greaterThanOrEqualTo(5*UI.Margins)
		}
		
		// Ajouter le badge
		addSubview(badgeView)
		
		// Action du bouton
		addAction(.init(handler: { [weak self] _ in
			RU_Feedback.shared.make(.On)
			self?.action?(self)
		}), for: .touchUpInside)
		
		// Appliquer l'apparence initiale
		updateAppearance()
	}
	
	// MARK: - Layout
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		// Mettre à jour les frames des layers de dégradé
		gradientBackgroundLayer.frame = CGRect(origin: .zero, size: frame.size)
		borderGradientLayer.frame = CGRect(origin: .zero, size: frame.size)
		
		// Mettre à jour les corner radius
        gradientBackgroundLayer.cornerRadius = configuration?.background.cornerRadius ?? (4*UI.Margins)/2.5
		borderGradientLayer.cornerRadius = configuration?.background.cornerRadius ??  (4*UI.Margins)/2.5
		
		// Créer le chemin de la bordure
		borderShapeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 1.5*UI.Margins).cgPath
	}
	
	// MARK: - Touch Effects
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		RU_Feedback.shared.make(.On)
		
		if showTouchEffect, let touch = event?.allTouches?.first, let touchView = touch.view {
			createTouchEffect(at: touch.location(in: touchView), in: touchView)
		}
	}
	
	private func createTouchEffect(at location: CGPoint, in view: UIView) {
		let effectContainerView = UIView()
		effectContainerView.isUserInteractionEnabled = false
		effectContainerView.clipsToBounds = true
		view.addSubview(effectContainerView)
		
		effectContainerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		view.layoutIfNeeded()
		
		let effectView = UIView()
		effectView.backgroundColor = .white
		effectView.alpha = 0.25
		effectContainerView.addSubview(effectView)
		
		effectView.snp.makeConstraints { make in
			make.width.height.equalTo(0)
			make.center.equalTo(location)
		}
		
		let radius = max(view.frame.size.width, view.frame.size.height)
		
		UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
			effectView.layer.cornerRadius = radius
			effectView.snp.updateConstraints { make in
				make.width.height.equalTo(2*radius)
			}
			effectView.layoutIfNeeded()
			effectView.alpha = 0.0
		} completion: { _ in
			effectContainerView.removeFromSuperview()
		}
	}
	
	// MARK: - Appearance Updates
	private func updateAppearance() {
		let colors = getColorsForTypeAndStyle()
		
		// Configuration selon le style
		switch style {
		case .solid:
			configuration = .filled()
			configuration?.baseBackgroundColor = .clear // Fond transparent car on utilise le dégradé
			configuration?.baseForegroundColor = colors.text
			// Dégradé inversé pour le fond
			gradientBackgroundLayer.colors = [colors.background.cgColor, colors.background.cgColor]
			gradientBackgroundLayer.isHidden = false
		case .tinted:
			configuration = .tinted()
			configuration?.baseBackgroundColor = .clear // Fond transparent car on utilise le dégradé
			configuration?.baseForegroundColor = colors.text
			// Dégradé inversé pour le fond
			gradientBackgroundLayer.colors = [colors.background.cgColor, colors.background.withAlphaComponent(0.1).cgColor]
			gradientBackgroundLayer.isHidden = false
		case .transparent:
			configuration = .plain()
			configuration?.baseBackgroundColor = .clear
			configuration?.baseForegroundColor = colors.text
			gradientBackgroundLayer.isHidden = true
		case .bordered:
			configuration = .plain()
			configuration?.baseBackgroundColor = .clear
			configuration?.baseForegroundColor = colors.text
			gradientBackgroundLayer.isHidden = true
		case .inverted:
			configuration = .filled()
			configuration?.baseBackgroundColor = .clear
			configuration?.baseForegroundColor = colors.text
			gradientBackgroundLayer.colors = [colors.background.cgColor, colors.background.withAlphaComponent(0.8).cgColor]
			gradientBackgroundLayer.isHidden = false
		}

		// Configuration du corner radius
		configuration?.background.cornerRadius = (4*UI.Margins)/2.5
		
		// Configuration de la bordure avec dégradé
		if style == .bordered {
			borderGradientLayer.colors = [colors.borderLight.cgColor, colors.borderDark.cgColor]
			borderGradientLayer.isHidden = false
		} else if style != .transparent {
			borderGradientLayer.colors = [colors.borderLight.cgColor, colors.borderDark.cgColor]
			borderGradientLayer.isHidden = false
		} else {
			borderGradientLayer.isHidden = true
		}
		
		if type == .navigation {
			
			titleFont = Fonts.Navigation.Button
		}
		else if type == .text {
			titleFont = Fonts.Content.Button.Title
		}
		
		updateContent()
	}
	
	private func updateContent() {
		let colors = getColorsForTypeAndStyle()
		
		// Configuration du titre
		if let title = title {
			var titleAttributedString = AttributedString(title)
			titleAttributedString.font = titleFont
			titleAttributedString.foregroundColor = colors.text
			configuration?.attributedTitle = titleAttributedString
		}
		
		// Configuration du sous-titre
		if let subtitle = subtitle {
			var subtitleAttributedString = AttributedString(subtitle)
			subtitleAttributedString.font = subtitleFont
			subtitleAttributedString.foregroundColor = colors.text
			configuration?.attributedSubtitle = subtitleAttributedString
		}
		
		// Configuration de l'image
		configuration?.image = image
		configuration?.imagePadding = UI.Margins
		
		// Configuration des marges
		configuration?.contentInsets = .init(UI.Margins)
		configuration?.titleAlignment = .center
		contentHorizontalAlignment = .center
		
		snp.makeConstraints { make in
			make.size.greaterThanOrEqualTo(5*UI.Margins)
		}
		
		if type == .navigation {
			
			snp.removeConstraints()
			configuration?.contentInsets = .zero
			configuration?.imagePadding = UI.Margins/3
		}
		else if type == .text {
			
			snp.remakeConstraints { make in
				make.height.greaterThanOrEqualTo(3*UI.Margins)
				make.width.greaterThanOrEqualTo(5*UI.Margins)
			}
		}
	}
	
	// MARK: - Color Management
	private struct ButtonColors {
		let background: UIColor
		let text: UIColor
		let borderLight: UIColor
		let borderDark: UIColor
	}
	
	private func getColorsForTypeAndStyle() -> ButtonColors {
		
		let baseColor = getBaseColorForType()
		let textColor = getTextColorForType()
		
		switch style {
		case .solid:
			return ButtonColors(
				background: baseColor,
				text: textColor,
				borderLight: baseColor.withAlphaComponent(0.8),
				borderDark: baseColor.withAlphaComponent(1.2)
			)
			
		case .tinted:
			return ButtonColors(
				background: baseColor.withAlphaComponent(0.75),
				text: textColor,
				borderLight: baseColor.withAlphaComponent(0.25),
				borderDark: baseColor.withAlphaComponent(0.25)
			)
			
		case .transparent:
			return ButtonColors(
				background: .clear,
				text: textColor,
				borderLight: baseColor.withAlphaComponent(0.8),
				borderDark: baseColor.withAlphaComponent(1.2)
			)
			
		case .bordered:
			return ButtonColors(
				background: .clear,
				text: textColor,
				borderLight: baseColor.withAlphaComponent(0.8),
				borderDark: baseColor.withAlphaComponent(1.2)
			)

		case .inverted:
			return ButtonColors(
				background: textColor,
				text: baseColor,
				borderLight: textColor.withAlphaComponent(0.8),
				borderDark: textColor.withAlphaComponent(1.2)
			)
		}
	}
	
	private func getBaseColorForType() -> UIColor {
		switch type {
		case .primary:
			return Colors.Button.Primary.Background
		case .secondary:
			return Colors.Button.Secondary.Background
		case .tertiary:
			return Colors.Button.Tertiary.Background
		case .navigation:
			return Colors.Button.Navigation.Background
		case .delete:
			return Colors.Button.Delete.Background
		case .text:
			return Colors.Button.Text.Background
		}
	}
	
	private func getTextColorForType() -> UIColor {
		switch type {
		case .primary:
			return Colors.Button.Primary.Content
		case .secondary:
			return Colors.Button.Secondary.Content
		case .tertiary:
			return Colors.Button.Tertiary.Content
		case .navigation:
			return Colors.Button.Navigation.Content
		case .delete:
			return Colors.Button.Delete.Content
		case .text:
			return Colors.Button.Text.Content
		}
	}
}
