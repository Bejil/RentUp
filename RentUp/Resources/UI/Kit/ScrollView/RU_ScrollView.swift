//
//  RU_ScrollView.swift
//  LettroLine
//
//  Created by BLIN Michael on 10/09/2025.
//

import UIKit

public class RU_ScrollView: UIScrollView {

	public var isCentered: Bool = false {
		didSet {
			if isCentered {
				contentInsetAdjustmentBehavior = .never
			} else {
				contentInsetAdjustmentBehavior = .automatic
			}
			setNeedsLayout()
		}
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		updateContentInset()
	}

	private func updateContentInset() {
		guard isCentered else { return }
		let safe = safeAreaInsets
		let visibleWidth = bounds.width - safe.left - safe.right
		let visibleHeight = bounds.height - safe.top - safe.bottom
		let left = contentSize.width < visibleWidth ? (visibleWidth - contentSize.width) / 2 : 0
		let top = contentSize.height < visibleHeight ? (visibleHeight - contentSize.height) / 2 : 0
		contentInset = UIEdgeInsets(
			top: safe.top + top,
			left: safe.left + left,
			bottom: safe.bottom + top,
			right: safe.right + left
		)
	}
}
