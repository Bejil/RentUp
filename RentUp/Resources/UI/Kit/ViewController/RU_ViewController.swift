//
//  RU_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit

public class RU_ViewController: UIViewController {

	public var isModal:Bool = false {
		
		didSet {
			
			if navigationController?.viewControllers.count ?? 0 < 2 {
				
				navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "xmark"), primaryAction: .init(handler: { [weak self] _ in
					
					RU_Feedback.shared.make(.Off)
					
					self?.close()
				}))
			}
		}
	}
	public lazy var containerStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins
		return $0
		
	}(RU_StackView(arrangedSubviews: [contentView,bottomButtonsVisualEffectView]))
	public lazy var contentView:UIView = .init()
	private lazy var bottomButtonsVisualEffectView:UIVisualEffectView = { view in
		
		view.isHidden = true
		view.contentView.addSubview(bottomButtonsStackView)
		bottomButtonsStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		view.contentView.addLine(position: .top)
		return view
		
	}(UIVisualEffectView(effect: UIBlurEffect(style: .light)))
	public lazy var bottomButtonsStackView:RU_StackView = {
		
		$0.axis = .horizontal
		$0.alignment = .center
		$0.spacing = UI.Margins
		$0.didUpdate = { [weak self] in
			
			if let self {
				
				self.bottomButtonsVisualEffectView.isHidden = self.bottomButtonsStackView.arrangedSubviews.isEmpty
				
				self.containerStackView.snp.remakeConstraints { make in
					
					make.top.right.left.equalTo(self.view.safeAreaLayoutGuide)
					
					if self.bottomButtonsVisualEffectView.isHidden {
						
						make.bottom.equalTo(self.view.safeAreaLayoutGuide)
					}
					else {
						
						make.bottom.equalToSuperview()
					}
				}
			}
		}
		
		return $0
		
	}(RU_StackView())
	
	public override func loadView() {
		
		super.loadView()
		
		view.backgroundColor = Colors.Background.View
		
		let tapGestureRecognizer:UITapGestureRecognizer = .init { [weak self] sender in
			
			if let weakSelf = self {
				
				let touchLocation = sender.location(in: weakSelf.view)
				
				let view:UIView = .init()
				view.isUserInteractionEnabled = false
				weakSelf.view.addSubview(view)
				view.snp.makeConstraints { make in
					make.centerX.equalTo(touchLocation.x)
					make.centerY.equalTo(touchLocation.y)
					make.size.equalTo(2*UI.Margins)
				}
				view.pulse() {
					
					view.removeFromSuperview()
				}
			}
		}
		tapGestureRecognizer.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGestureRecognizer)
		
		view.addSubview(containerStackView)
		containerStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		UI.MainController.resignFirstResponder()
	}
	
	public func close() {
		
		dismiss()
	}
	
	public func dismiss(_ completion:(()->Void)? = nil) {
		
		if navigationController?.viewControllers.count ?? 0 > 1 {
			
			navigationController?.popViewController(animated: true)
			completion?()
		}
		else {
			
			dismiss(animated: true, completion: completion)
		}
	}
}
