//
//  RU_Reporting_General_Distribution_View.swift
//  RentUp
//

import UIKit
import SnapKit

public class RU_Reporting_General_Distribution_View: RU_StackView {
	
	private var bookings: [RU_Booking] = []
	private var currentDimension: RU_Reporting_BookingDistribution.Dimension = .travelers
	
	private lazy var summaryLabel: RU_Label = {
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		$0.numberOfLines = 0
		return $0
	}(RU_Label())
	
	private lazy var dimensionButton: RU_Button = {
        $0.image = UIImage(systemName: "arrowtriangle.down.square")?.applyingSymbolConfiguration(.init(scale: .small))
        $0.configuration?.imagePadding = UI.Margins/2
        $0.configuration?.imagePlacement = .trailing
		$0.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
		$0.showsMenuAsPrimaryAction = true
        $0.snp.remakeConstraints { make in
            make.height.equalTo(4*UI.Margins)
        }
        
		return $0
	}(RU_Button())
	
	private lazy var distributionStackView: RU_StackView = {
		$0.axis = .vertical
		$0.spacing = 0
		return $0
	}(RU_StackView())
	
	private lazy var distributionSection: RU_Section_StackView = {
		$0.title = String(key: "reporting.section.distribution")
		$0.subtitle = String(key: "reporting.detail.general.distribution.subtitle")
		$0.accessoryView = dimensionButton
		$0.addArrangedSubview(summaryLabel)
		$0.addArrangedSubview(distributionStackView)
		return $0
	}(RU_Section_StackView())
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins
		
		addArrangedSubview(distributionSection)
		
		updateDimensionButton()
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func didMoveToSuperview() {
		super.didMoveToSuperview()
		guard superview != nil else { return }
		dimensionButton.configuration?.titleLineBreakMode = .byTruncatingTail
        updateDimensionButton()
	}
	
	public func update(bookings: [RU_Booking]) {
		self.bookings = bookings
		refreshUI()
	}
	
	private func refreshUI() {
		let total = bookings.count
		summaryLabel.text = String(format: String(key: "reporting.detail.general.summary.format"), total)
		summaryLabel.isHidden = total == 0
		
		let items = RU_Reporting_BookingDistribution.sort(
			RU_Reporting_BookingDistribution.compute(for: currentDimension, bookings: bookings),
			by: .percentageDesc
		)
		
		distributionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		for (index, item) in items.enumerated() {
			let row = RU_Reporting_Distribution_Row_StackView()
			row.progressAnimationDelay = Double(index) * 0.07
			if let platform = item.platform {
				row.platform = platform
			} else {
				row.title = item.title
				if let icon = item.icon {
					row.icon = UIImage(systemName: icon)
				}
			}
			row.count = item.count
			row.detailText = item.detailText
			row.percentage = item.percentage
			distributionStackView.addArrangedSubview(row)
		}
	}
	
	private func updateDimensionButton() {
		dimensionButton.title = currentDimension.title
		distributionSection.subtitle = currentDimension.distributionSubtitle
        dimensionButton.image = UIImage(systemName: "arrowtriangle.down.square")?.applyingSymbolConfiguration(.init(scale: .small))
        dimensionButton.configuration?.imagePadding = UI.Margins/2
        dimensionButton.configuration?.imagePlacement = .trailing
		dimensionButton.menu = UIMenu(title: String(key: "reporting.detail.general.dimension.menu"), children: RU_Reporting_BookingDistribution.Dimension.allCases.map { dimension in
			UIAction(title: dimension.title, image: UIImage(systemName: dimension.icon), state: dimension == self.currentDimension ? .on : .off) { [weak self] _ in
				guard let self else { return }
				self.currentDimension = dimension
				self.updateDimensionButton()
				self.refreshUI()
			}
		})
	}
}
