//
//  RU_Platform_Label.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit
import SnapKit

public class RU_Platform_Label: UIView {

	public var isMinimal: Bool = false {
		didSet { update() }
	}

	public var platform: RU_Platform? {
		didSet { update() }
	}

	public var text: String? {
		get { textLabel.text }
		set { textLabel.text = newValue }
	}

	private lazy var iconImageView: UIImageView = {
		$0.contentMode = .scaleAspectFit
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
	}(UIImageView())

	private lazy var textLabel: RU_Label = {
		$0.numberOfLines = 1
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
	}(RU_Label())

	private lazy var contentStackView: RU_StackView = {
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 3
		$0.alignment = .center
		$0.isLayoutMarginsRelativeArrangement = true
		$0.insetsLayoutMarginsFromSafeArea = false
		return $0
	}(RU_StackView(arrangedSubviews: [iconImageView, textLabel]))

	public override init(frame: CGRect) {
		super.init(frame: frame)
		layer.masksToBounds = true
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.required, for: .horizontal)
		addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		update()
	}

	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func update() {
		backgroundColor = platform?.type?.backgroundColor
		textLabel.textColor = platform?.type?.textColor
		iconImageView.image = platform?.type?.icon
		iconImageView.tintColor = platform?.type?.textColor
		iconImageView.isHidden = isMinimal || platform?.type?.icon == nil

		let minimalSize = 2.5 * UI.Margins
		layer.cornerRadius = isMinimal ? minimalSize / 2 : UI.Badge.cornerRadius

		if isMinimal {
			textLabel.text = platform?.type?.name.first.map { String($0).uppercased() }
			textLabel.font = Fonts.Content.Title.H3
			contentStackView.layoutMargins = .zero
			contentStackView.spacing = 0
			snp.remakeConstraints { make in
				make.size.equalTo(minimalSize)
			}
		} else {
			textLabel.text = platform?.type?.name
			textLabel.font = UI.Badge.font
			contentStackView.layoutMargins = UI.Badge.contentInsets
			contentStackView.spacing = UI.Margins / 3
			iconImageView.snp.remakeConstraints { make in
				make.size.equalTo(ceil(UI.Badge.font.pointSize))
			}
			snp.remakeConstraints { make in
				make.height.equalTo(UI.Badge.height)
			}
		}
	}
}
