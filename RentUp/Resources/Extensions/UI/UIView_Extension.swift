//
//  UIView_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import UIKit
import SnapKit

extension UIView {
	
	static func animation(_ duration:TimeInterval? = 0.3, _ animations:@escaping (()->Void), _ completion: (()->Void)? = nil) {
		
		UIView.animate(withDuration: duration ?? 0.3, delay: 0.0, options: [.allowUserInteraction,.curveEaseInOut], animations: animations) { state in
			
			completion?()
		}
	}
	
	func stopPulse(){
		
		layer.removeAllAnimations()
		transform = .identity
	}
	
	func pulse(_ color:UIColor = Colors.Primary, _ completion:(()->Void)? = nil){
		
		stopPulse()
		
		let view:UIView = (self as? UIVisualEffectView)?.contentView ?? self
		view.subviews.first(where: {$0.accessibilityLabel == "pulseView"})?.removeFromSuperview()
		
		let initialScale = transform
		let initialScaleX = initialScale.a
		let initialScaleY = initialScale.d
		
		superview?.layoutIfNeeded()
		
		let pulseView:UIView = .init()
		pulseView.accessibilityLabel = "pulseView"
		pulseView.isUserInteractionEnabled = false
		
		if color != .clear {
			
			pulseView.backgroundColor = color.withAlphaComponent(0.25)
			pulseView.layer.cornerRadius = frame.size.width/2
			pulseView.layer.borderColor = color.cgColor
			pulseView.layer.borderWidth = 2.0
			pulseView.alpha = 0.0
			pulseView.transform = .init(scaleX: initialScaleX * 0.01, y: initialScaleY * 0.01)
			pulseView.clipsToBounds = true
			addSubview(pulseView)
			
			pulseView.snp.makeConstraints { (make) in
				make.centerX.centerY.width.equalTo(self)
				make.height.equalTo(snp.width)
			}
		}
		
		let pulseDuration:TimeInterval = 0.3
		
		UIView.animate(withDuration: pulseDuration, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
			
			pulseView.transform = .init(scaleX: initialScaleX * 2.0, y: initialScaleY * 2.0)
			
		}, completion: nil)
		
		UIView.animate(withDuration: pulseDuration/2, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
			
			pulseView.alpha = 0.5
			self?.transform = .init(scaleX: initialScaleX * 1.15, y: initialScaleY * 1.15)
			
		}) { [weak self] _ in
			
			UIView.animate(withDuration: pulseDuration/2, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
				
				pulseView.alpha=0.0;
				
				self?.transform = initialScale
				
			}) { _ in
				
				if pulseView.superview != nil {
					
					pulseView.removeFromSuperview()
				}
				
				completion?()
			}
		}
	}
	
	func findFirstResponder() -> UIView? {
		
		if isFirstResponder {
			
			return self
		}
		
		for subview in subviews {
			
			if let firstResponder = subview.findFirstResponder() {
				
				return firstResponder
			}
		}
		
		return nil
	}
	
	enum LinePosition {
		
		case top, bottom, leading, trailing, center
	}
	
	public func removeLines() {
		
		subviews.filter({ $0.tag == 999 }).forEach({ $0.removeFromSuperview() })
	}
	
	@discardableResult func addLine(position:LinePosition, color:UIColor? = Colors.Content.Text.withAlphaComponent(0.1), width:Double = 1.0) -> UIView {
		
		let view:UIView = .init()
		view.tag = 999
		view.backgroundColor = color
		addSubview(view)
		
		view.snp.makeConstraints { make in
			
			let topBottomConstraint = {
				
				make.left.right.equalToSuperview()
				make.height.equalTo(width)
			}
			
			let centerConstraint = {
				
				make.left.right.centerY.equalToSuperview()
				make.height.equalTo(width)
			}
			
			let leftRightConstraint = {
				
				make.top.equalToSuperview()
				make.bottom.equalToSuperview()
				make.width.equalTo(width)
			}
			
			switch position {
			case .top:
				topBottomConstraint()
				make.top.equalToSuperview()
			case .bottom:
				topBottomConstraint()
				make.bottom.equalToSuperview()
			case .leading:
				leftRightConstraint()
				make.leading.equalToSuperview()
			case .trailing:
				leftRightConstraint()
				make.trailing.equalToSuperview()
			case .center:
				centerConstraint()
			}
		}
		
		return view
	}
	
	@discardableResult func showPlaceholder(_ style:RU_Placeholder_View.Style? = nil, _ error:Error? = nil, _ handler:RU_Button.Handler = nil) -> RU_Placeholder_View {
		
		dismissPlaceholder()
		
		let view:UIView = (self as? UIVisualEffectView)?.contentView ?? self
		
		let placeholderView:RU_Placeholder_View = .init(style,error,handler)
		placeholderView.isCentered = [.Loading,.Empty].contains(style)
		placeholderView.accessibilityLabel = "placeholderView"
		view.addSubview(placeholderView)
		
		placeholderView.snp.makeConstraints { make in
			
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		return placeholderView
	}
	
	func dismissPlaceholder() {
		
		let view:UIView = (self as? UIVisualEffectView)?.contentView ?? self
		view.subviews.first(where: {$0.accessibilityLabel == "placeholderView"})?.removeFromSuperview()
	}
    
    func showLoadingIndicatorView() {
        
        showLoadingIndicatorView(blurBackground: true)
    }
    
    func showLoadingIndicatorView(blurBackground:Bool, color:UIColor? = nil) {
        
        dismissLoadingIndicatorView()
        
        DispatchQueue.main.async {
            
            var view:UIView = self
            
            if let visualEffectView = self as? UIVisualEffectView {
                
                view = visualEffectView.contentView
            }
            
            let visualEffectView:UIVisualEffectView = .init()
            if blurBackground {
                
                visualEffectView.effect = UIBlurEffect.init(style: self.traitCollection.userInterfaceStyle == .light ? .extraLight : .dark)
            }
            visualEffectView.accessibilityLabel = "loadingView"
            view.addSubview(visualEffectView)
            
            let activityIndicatorView:UIActivityIndicatorView = .init()
            if #available(iOS 13, *) {
                activityIndicatorView.style = .medium
            }
            else{
                activityIndicatorView.style = self.traitCollection.userInterfaceStyle == .light ? .gray : .white
            }
            activityIndicatorView.color = color
            activityIndicatorView.startAnimating()
            visualEffectView.contentView.addSubview(activityIndicatorView)
            
            visualEffectView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            activityIndicatorView.snp.makeConstraints { (make) in
                make.centerX.centerY.equalToSuperview()
            }
        }
    }
    
    func dismissLoadingIndicatorView() {
        
        DispatchQueue.main.async {
            
            var view:UIView = self
            
            if let visualEffectView = self as? UIVisualEffectView {
                
                view = visualEffectView.contentView
            }
            
            view.subviews.first(where: {$0.accessibilityLabel == "loadingView"})?.removeFromSuperview()
        }
    }
}
