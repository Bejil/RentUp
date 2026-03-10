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

	private let imageSize: CGFloat = 10

	private lazy var iconImageView: UIImageView = {
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.equalTo(imageSize)
		}
		return $0
	}(UIImageView())

	private lazy var textLabel: RU_Label = {
		$0.numberOfLines = 1
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
	}(RU_Label())

	private lazy var contentStackView: UIStackView = {
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 3
		$0.alignment = .center
		return $0
	}(UIStackView(arrangedSubviews: [iconImageView, textLabel]))

	public override init(frame: CGRect) {
		super.init(frame: frame)
		layer.masksToBounds = true
		addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(UI.Margins/3)
            make.top.bottom.equalToSuperview().inset(UI.Margins/7)
		}
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

		if isMinimal {
			textLabel.text = platform?.type?.name.first.map { String($0).uppercased() }
			textLabel.font = Fonts.Content.Title.H3
		} else {
			textLabel.text = platform?.type?.name
			textLabel.font = Fonts.Content.Text.Bold.withSize(Fonts.Size - 2)
		}

		let minimalSize = 2.5 * UI.Margins
		layer.cornerRadius = isMinimal ? minimalSize / 2 : UI.Margins / 2

		if isMinimal {
			contentStackView.layoutMargins = .zero
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.snp.remakeConstraints { make in
				make.edges.equalToSuperview()
			}
			snp.makeConstraints { make in
				make.size.equalTo(minimalSize)
			}
		} else {
			snp.removeConstraints()
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = UIEdgeInsets(horizontal: UI.Margins / 3, vertical: UI.Margins / 7)
		}
	}
}
