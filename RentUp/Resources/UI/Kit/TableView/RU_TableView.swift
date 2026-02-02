//
//  RU_TableView.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit
import SnapKit

public class RU_TableView: UITableView {
	
	public var isHeightDynamic:Bool = false
	public override var contentSize: CGSize {
		
		didSet {
			
			isScrollEnabled = !isHeightDynamic
			
			if isHeightDynamic {
				
				self.invalidateIntrinsicContentSize()
			}
		}
	}
	public override var intrinsicContentSize: CGSize {
		
		if isHeightDynamic {
			
			return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
		}
		
		return super.intrinsicContentSize
	}
	public var headerView:UIView? {
		
		didSet {
			
			tableHeaderView = headerView
			
			if let headerView = headerView {
				
				tableHeaderView?.snp.makeConstraints { make in
					make.edges.width.equalToSuperview()
				}
				headerView.layoutIfNeeded()
			}
			
			tableHeaderView?.layoutIfNeeded()
		}
	}
	
	public override init(frame: CGRect, style: UITableView.Style) {
		
		super.init(frame: frame, style: style)
		
		backgroundColor = .clear
		contentInset = .init(top: 0, left: 0, bottom: 3*UI.Margins, right: 0)
		register(RU_TableViewCell.self, forCellReuseIdentifier: RU_TableViewCell.identifier)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func reloadData() {
		
		super.reloadData()
		
		if isHeightDynamic {
			
			invalidateIntrinsicContentSize()
			layoutIfNeeded()
		}
	}
}
