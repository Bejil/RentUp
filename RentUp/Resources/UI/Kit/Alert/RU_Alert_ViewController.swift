//
//  RU_Alert_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 08/06/2022.
//

import Foundation
import UIKit
import SnapKit

public class RU_Alert_ViewController : UIViewController {
	
	public enum Style {
		
		case Alert
		case Sheet
		case Popover
	}
	
	private var style:Style = .Alert
	public var dismissHandler:(()->Void)?
	public lazy var backgroundView:UIView = {
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .regular))
		$0.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		$0.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			self?.close()
		}))
		
		return $0
		
	}(UIView())
	public lazy var containerView:UIView = {
		
		$0.clipsToBounds = true
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		$0.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		$0.addSubview(dismissIndicatorView)
		dismissIndicatorView.snp.makeConstraints { make in
			make.top.right.left.equalToSuperview()
		}
		return $0
		
	}(UIView())
	public lazy var contentStackView:RU_StackView = {
		
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins.top = UI.Margins
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		return $0
		
	}(RU_StackView(arrangedSubviews: [titleLabel]))
	public lazy var titleLabel:RU_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.textColor = .white
		$0.textAlignment = .center
		return $0
		
	}(RU_Label())
	public override var title: String? {
		
		didSet {
			
			titleLabel.text = title
		}
	}
	private lazy var dismissIndicatorView:UIView = {
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .regular))
		visualEffectView.clipsToBounds = true
		visualEffectView.layer.cornerRadius = (UI.Margins/2)/2
		$0.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.top.bottom.centerX.equalToSuperview().inset(UI.Margins/2)
			make.width.equalToSuperview().multipliedBy(1.0/3.0)
			make.height.equalTo(UI.Margins/2)
		}
		$0.addGestureRecognizer(UIPanGestureRecognizer(block: { [weak self] gestureRecognizer in
			
			if let strongSelf = self, let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
				
				let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
				
				if gestureRecognizer.state == .began {
					
					RU_Feedback.shared.make(.On)
				}
				else if gestureRecognizer.state == .changed {

					let translation  = gestureRecognizer.translation(in: strongSelf.view)

					if abs(velocity.y) > abs(velocity.x) {

						if translation.y >= 0 {

							strongSelf.containerView.snp.updateConstraints({ (make) in

								make.bottom.equalToSuperview().offset(translation.y)
							})
						}
					}
				}
				else if gestureRecognizer.state == .ended {

					let translation  = gestureRecognizer.translation(in: strongSelf.view)

					if velocity.y > 1300 || strongSelf.containerView.frame.size.height - translation.y < strongSelf.containerView.frame.size.height/2 {
						
						strongSelf.close()
					}
					else{
						
						RU_Feedback.shared.make(.On)
						
						UIView.animation {
							
							strongSelf.containerView.snp.updateConstraints({ (make) in
								
								make.bottom.equalToSuperview()
							})
							
							strongSelf.view.layoutIfNeeded()
						}
					}
				}
			}
		}))
		return $0
		
	}(UIView())
	public var popoverSourceView:UIView? = nil
	public var popoverSourceBarButtonItem:UIBarButtonItem? = nil
	public lazy var containerScrollView:UIScrollView = {
		
		$0.delegate = self
		return $0
		
	}(UIScrollView())
	private lazy var stickyButtonsStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins
		return $0
		
	}(RU_StackView())
	private var containerHeightConstraint: Constraint?
	private var keyboardHeightConstraint: Constraint?
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .overFullScreen
		
		view.backgroundColor = .clear
		
		view.addSubview(backgroundView)
		backgroundView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		view.addSubview(containerView)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		let stackView:RU_StackView = .init(arrangedSubviews: [containerScrollView,stickyButtonsStackView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		
		containerView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			
			make.top.bottom.equalToSuperview().inset(2*UI.Margins)
			make.left.right.equalToSuperview().inset(UI.Margins)
		}
		
		containerScrollView.addSubview(contentStackView)
		
		contentStackView.snp.makeConstraints { (make) in
			
			make.top.bottom.equalToSuperview()
			make.leading.trailing.width.equalToSuperview().inset(UI.Margins)
			make.height.equalToSuperview().priority(700)
		}
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public func present(as style:Style = .Alert, withAnimation animated:Bool = true, _ completion:(()->Void)? = nil) {
		
		self.style = style
		
		backgroundView.alpha = 0.0
		
		if style == .Alert {
			
			containerView.layer.cornerRadius = UI.CornerRadius * 3
			dismissIndicatorView.isHidden = true
			
			containerView.snp.makeConstraints { make in
				
				containerHeightConstraint = make.height.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(4*UI.Margins).constraint
				make.center.equalTo(view.safeAreaLayoutGuide)
				make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.85)
			}
			
			containerView.transform = .init(translationX: 0, y: 3*UI.Margins)
			containerView.alpha = 0.0
			
			UI.MainController.present(self, animated: false) { [weak self] in
				
				UIView.animation {
					
					self?.containerView.transform = .identity
					self?.containerView.alpha = 1.0
					self?.backgroundView.alpha = 0.75
					
				} _: {
					
					completion?()
				}
			}
		}
		else if style == .Sheet {
			
			containerView.layer.cornerRadius = UI.CornerRadius * 3
			containerView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
			dismissIndicatorView.isHidden = false
			
			containerView.snp.makeConstraints { make in
				
				containerHeightConstraint = make.height.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(4*UI.Margins).constraint
				make.left.right.equalTo(view)
				make.top.equalTo(view.snp.bottom)
			}
			
			UI.MainController.present(self, animated: false) {
				
				UIView.animation {
					
					self.backgroundView.alpha = 0.5
					
					self.containerView.snp.remakeConstraints { make in
						
						make.height.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).inset(4*UI.Margins)
						make.left.bottom.right.equalTo(self.view)
					}
					
					self.containerView.superview?.layoutIfNeeded()
				} _: {
					
					completion?()
				}
			}
		}
		else if style == .Popover {
			
			modalPresentationStyle = .popover
			popoverPresentationController?.delegate = self
			modalTransitionStyle = .crossDissolve
			
			if let popoverSourceView = popoverSourceView {
				
				popoverPresentationController?.sourceView = UI.MainController.presentedViewController?.view ?? UI.MainController.view
				popoverPresentationController?.sourceRect = .zero
				
				if var lc_frame = popoverSourceView.superview?.convert(popoverSourceView.frame, to: UI.MainController.presentedViewController?.view ?? UI.MainController.view) {
					
					lc_frame.origin = .init(x: lc_frame.midX, y: lc_frame.midY)
					lc_frame.size = .zero
					popoverPresentationController?.sourceRect = lc_frame
				}
			}
			else if let popoverSourceBarButtonItem = popoverSourceBarButtonItem {
				
				popoverPresentationController?.barButtonItem = popoverSourceBarButtonItem
			}
			
			dismissIndicatorView.isHidden = true
			
			containerView.snp.makeConstraints { make in
				
				make.edges.equalTo(view)
			}
			
			UI.MainController.present(self, animated: false) {
				
				self.preferredContentSize = .init(width: 0, height: 1)
				self.preferredContentSize = .init(width: 0, height: self.contentStackView.frame.size.height + (4*UI.Margins))
				
				completion?()
			}
		}
		
		if animated {
			
			contentStackView.isHidden = true
			
			UIApplication.wait(0.001) { [weak self] in
				
				self?.contentStackView.isHidden = false
				self?.contentStackView.animate()
			}
		}
	}
	
	@discardableResult public static func present(_ error:Error, canDismiss:Bool = true, handler:(()->Void)? = nil) -> RU_Alert_ViewController {
		
		RU_Feedback.shared.make(.Error)
		
		let viewController:RU_Alert_ViewController = .init()
		viewController.titleLabel.text = String(key: "alert.error.title")
		viewController.add(error.localizedDescription)
		if let handler = handler {
			
			viewController.addButton(title: String(key: "alert.error.button")) { _ in
				
				viewController.close() {
					
					handler()
				}
			}
		}
        if canDismiss {
            
            viewController.addDismissButton()
        }
		viewController.present()
		return viewController
	}
	
	public static func presentLoading(_ completion:((RU_Alert_ViewController?)->Void)? = nil) {
		
		let viewController:RU_Alert_ViewController = .init()
		viewController.backgroundView.isUserInteractionEnabled = false
		viewController.titleLabel.text = String(key: "alert.loading.title")
		viewController.add(String(key: "alert.loading.content"))
		viewController.present() {
			
			completion?(viewController)
		}
	}
	
	public func close(_ completion:(()->Void)? = nil) {
		
		RU_Feedback.shared.make(.Off)
		
		view.endEditing(true)
		
		UIView.animation(0.3) {
			
			self.containerView.transform = .init(translationX: 0, y: 3*UI.Margins)
			self.containerView.alpha = 0.0
			self.backgroundView.alpha = 0.0
			
		} _: {
			
			self.presentingViewController?.dismiss(animated: false) { [weak self] in
				
				self?.dismissHandler?()
				completion?()
			}
		}
	}
	
	@objc private func keyboardWillShow(_ notification: Notification) {
		
		guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
			  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
		
		let keyboardHeight = keyboardFrame.height
		let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
		let availableHeight = safeAreaHeight - keyboardHeight - (4 * UI.Margins)
		
		containerHeightConstraint?.deactivate()
		
		containerView.snp.makeConstraints { make in
			
			keyboardHeightConstraint = make.height.lessThanOrEqualTo(availableHeight).constraint
		}
		
		UIView.animate(withDuration: duration) {
			
			self.containerView.transform = .init(translationX: 0, y: -keyboardHeight / 2)
			self.view.layoutIfNeeded()
			
		} completion: { _ in
			
			self.scrollToFirstResponder()
		}
	}
	
	private func scrollToFirstResponder() {
		
		guard let firstResponder = containerScrollView.findFirstResponder() else { return }
		
		let frame = firstResponder.convert(firstResponder.bounds, to: containerScrollView)
		
		containerScrollView.setContentOffset(.init(x: 0, y: min(frame.origin.y,containerScrollView.contentSize.height-containerScrollView.frame.size.height)), animated: true)
	}
	
	@objc private func keyboardWillHide(_ notification: Notification) {
		
		guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
		
		keyboardHeightConstraint?.deactivate()
		keyboardHeightConstraint = nil
		containerHeightConstraint?.activate()
		
		UIView.animate(withDuration: duration) {
			
			self.containerView.transform = .identity
			self.view.layoutIfNeeded()
		}
	}
	
	public func add(_ view:UIView) {
		
		contentStackView.addArrangedSubview(view)
	}
	
	@discardableResult public func add(_ string:String?) -> RU_Label {
		
		let label:RU_Label = .init(string)
		label.textAlignment = .center
		label.textColor = .white
		add(label)
		
		return label
	}
	
	@discardableResult public func add(_ image:UIImage?) -> UIImageView {
		
		let imageView:UIImageView = .init(image: image)
		imageView.contentMode = .scaleAspectFit
		
		add(imageView)
		
		imageView.snp.makeConstraints { (make) in
			make.height.equalTo(10*UI.Margins)
		}
		
		contentStackView.setCustomSpacing(2*contentStackView.spacing, after: imageView)
		
		return imageView
	}
	
	@discardableResult public func addButton(sticky:Bool = false, title:String, subtitle:String? = nil,image:UIImage? = nil, _ handler:RU_Button.Handler = nil) -> RU_Button {
		
		let button:RU_Button = .init(title,handler)
		button.subtitle = subtitle
		button.image = image
		
		if sticky {
			
			stickyButtonsStackView.addArrangedSubview(button)
		}
		else {
			
			add(button)
		}
		
		return button
	}
	
	@discardableResult public func addCancelButton(sticky:Bool = false, _ handler:RU_Button.Handler = nil) -> RU_Button {
		
		let button:RU_Button = addButton(sticky:sticky, title: String(key: "alert.cancel.button")) { [weak self] button in
			
			self?.close({
				
				handler?(button)
			})
			
		}
		button.style = .transparent
		button.configuration?.contentInsets = .zero
		button.snp.makeConstraints { make in
			
			make.size.equalTo(2*UI.Margins)
		}
		return button
	}
	
	@discardableResult public func addDismissButton(sticky:Bool = false, _ handler:RU_Button.Handler = nil) -> RU_Button {
		
		let button:RU_Button = addButton(sticky:sticky, title: String(key: "alert.dismiss.button")) { [weak self] button in
			
			self?.close({
				
				handler?(button)
			})
		}
		button.style = .tinted
		let inset = UI.Margins
		button.configuration?.contentInsets = .init(top: inset, leading: inset, bottom: inset, trailing: inset)
		return button
	}
}

extension RU_Alert_ViewController : UIScrollViewDelegate {
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		containerScrollView.contentOffset.x = 0
	}
}

extension RU_Alert_ViewController : UIPopoverPresentationControllerDelegate {
	
	public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		
		return .none
	}
}
