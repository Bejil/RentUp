//
//  RU_Reporting_Distribution_Row_StackView.swift
//  RentUp
//

import UIKit
import SnapKit

public class RU_Reporting_Distribution_Row_StackView: RU_StackView {
	
	public var title: String? {
		didSet { updateTitleDisplay() }
	}
	
	public var icon: UIImage? {
		didSet { updateTitleDisplay() }
	}
	
	public var platform: RU_Platform? {
		didSet { updateTitleDisplay() }
	}
	
	private func updateTitleDisplay() {
		if let platform {
			platformLabel.platform = platform
			platformLabel.isHidden = false
			iconView.isHidden = true
			titleLabel.isHidden = true
			titleStack.setContentHuggingPriority(.required, for: .horizontal)
			titleStack.setContentCompressionResistancePriority(.required, for: .horizontal)
		} else {
			platformLabel.isHidden = true
			platformLabel.platform = nil
			titleLabel.text = title
			titleLabel.isHidden = title?.isEmpty ?? true
			iconView.isHidden = icon == nil
			iconView.image = icon?.applyingSymbolConfiguration(.init(scale: .medium))
			titleStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
			titleStack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		}
	}
	
	public var count: Int = 0 {
		didSet { updateCountLabel() }
	}
	
	public var detailText: String? {
		didSet { updateCountLabel() }
	}
	
	private func updateCountLabel() {
		if let detailText {
			countLabel.text = detailText
		} else {
			countLabel.text = String(format: String(key: "reporting.detail.general.countFormat"), count)
		}
	}
	
	public var percentage: Double = 0 {
		didSet {
			percentageLabel.text = String(format: "%.0f %%", percentage)
		}
	}
	
	public var progressAnimationDelay: TimeInterval = 0
	
	private lazy var iconView: UIImageView = {
		$0.contentMode = .scaleAspectFit
		$0.tintColor = Colors.Secondary
		$0.isHidden = true
		$0.snp.makeConstraints { make in
			make.size.equalTo(1.5 * UI.Margins)
		}
		return $0
	}(UIImageView())
	
	private lazy var titleLabel: RU_Label = {
		$0.font = Fonts.Content.Text.Regular
		$0.numberOfLines = 2
		return $0
	}(RU_Label())
	
	private lazy var platformLabel: RU_Platform_Label = {
		$0.isHidden = true
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
	}(RU_Platform_Label())
	
	private lazy var titleStack: RU_StackView = {
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 2
		$0.alignment = .center
		$0.addArrangedSubview(iconView)
		$0.addArrangedSubview(titleLabel)
		$0.addArrangedSubview(platformLabel)
		return $0
	}(RU_StackView())
	
	private lazy var headerSpacer: UIView = {
		$0.setContentHuggingPriority(.defaultLow, for: .horizontal)
		$0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		return $0
	}(UIView())
	
	private lazy var countLabel: RU_Label = {
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
	}(RU_Label())
	
	private lazy var percentageLabel: RU_Label = {
		$0.font = Fonts.Content.Title.H4
		$0.textAlignment = .right
		$0.setContentHuggingPriority(.required, for: .horizontal)
		return $0
	}(RU_Label())
	
	private lazy var headerStackView: RU_StackView = {
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 2
		$0.alignment = .center
		
		$0.addArrangedSubview(titleStack)
		$0.addArrangedSubview(headerSpacer)
		$0.addArrangedSubview(countLabel)
		$0.addArrangedSubview(percentageLabel)
		return $0
	}(RU_StackView())
	
	private lazy var progressTrackView: UIView = {
		$0.backgroundColor = Colors.Primary.withAlphaComponent(0.12)
		$0.layer.cornerRadius = 3
		$0.clipsToBounds = true
		$0.snp.makeConstraints { make in
			make.height.equalTo(6)
		}
		return $0
	}(UIView())
	
	private lazy var progressFillView: UIView = {
		$0.backgroundColor = Colors.Secondary
		$0.layer.cornerRadius = 3
		return $0
	}(UIView())
	
	private var progressFillWidthConstraint: Constraint?
	private var shouldAnimateProgress = true
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins / 2
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(top: UI.Margins / 2, left: 0, bottom: UI.Margins / 2, right: 0)
		
		addArrangedSubview(headerStackView)
		addArrangedSubview(progressTrackView)
		progressTrackView.addSubview(progressFillView)
		progressFillView.snp.makeConstraints { make in
			make.top.bottom.leading.equalToSuperview()
			progressFillWidthConstraint = make.width.equalTo(0).constraint
		}
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		guard progressTrackView.bounds.width > 0 else { return }
		
		if shouldAnimateProgress {
			animateProgressFill()
		} else {
			progressFillWidthConstraint?.update(offset: targetFillWidth())
		}
	}
	
	private func targetFillWidth() -> CGFloat {
		max(0, min(1, percentage / 100)) * progressTrackView.bounds.width
	}
	
	private func animateProgressFill() {
		shouldAnimateProgress = false
		let targetWidth = targetFillWidth()
		
		progressFillWidthConstraint?.update(offset: 0)
		progressTrackView.layoutIfNeeded()
		
		UIView.animate(
			withDuration: 0.55,
			delay: progressAnimationDelay,
			usingSpringWithDamping: 0.82,
			initialSpringVelocity: 0.6,
			options: [.curveEaseOut]
		) {
			self.progressFillWidthConstraint?.update(offset: targetWidth)
			self.progressTrackView.layoutIfNeeded()
		}
	}
}
