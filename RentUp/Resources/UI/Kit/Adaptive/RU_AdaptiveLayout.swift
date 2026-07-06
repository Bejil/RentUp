//
//  RU_AdaptiveLayout.swift
//  RentUp
//

import UIKit
import SnapKit

enum RU_AdaptiveLayout {
	
	static func installScrollContent(
		scrollView: UIScrollView,
		contentView: UIView,
		in containerView: UIView,
		traitCollection: UITraitCollection,
		maxWidth: CGFloat = UI.ContentMaxWidth
	) {
		containerView.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		scrollView.addSubview(contentView)
		contentView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.centerX.equalToSuperview()
			make.width.lessThanOrEqualTo(maxWidth)
			make.width.equalToSuperview().priority(traitCollection.isRegularWidth ? .high : .required)
			make.leading.greaterThanOrEqualToSuperview()
			make.trailing.lessThanOrEqualToSuperview()
		}
	}
	
	static func adaptiveModalStyle(for traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		traitCollection.isRegularWidth ? .formSheet : .fullScreen
	}
}

extension UIViewController {
	
	public var isRegularWidth: Bool {
		traitCollection.isRegularWidth
	}
	
	public func presentAdaptive(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
		if traitCollection.isRegularWidth {
			viewController.modalPresentationStyle = .formSheet
			if let sheet = viewController.sheetPresentationController {
				sheet.detents = [.large()]
				sheet.prefersGrabberVisible = true
				sheet.prefersEdgeAttachedInCompactHeight = true
				sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
			}
		}
		present(viewController, animated: animated, completion: completion)
	}
}
