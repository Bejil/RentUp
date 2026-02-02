//
//  RU_Placeholder_View.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit
import SnapKit

public class RU_Placeholder_View: UIView {
	
	public class ScrollView: UIScrollView {
		
		public var isCentered:Bool = false {
			
			didSet {
				
				updateContentInset()
			}
		}
		
		public override var bounds: CGRect {
			
			didSet {
				
				updateContentInset()
			}
		}
		
		public override var contentSize: CGSize {
			
			didSet {
				
				updateContentInset()
			}
		}
		
		private func updateContentInset() {
			
			if isCentered {
				
				var top = CGFloat(0)
				var left = CGFloat(0)
				
				if contentSize.width < bounds.width {
					
					left = (bounds.width - contentSize.width) / 2
				}
				
				if contentSize.height < bounds.height {
					
					top = (bounds.height - contentSize.height) / 2
				}
				
				contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
			}
		}
	}
	
	public var isCentered:Bool = true {
		
		didSet {
			
			scrollView.isCentered = isCentered
		}
	}
	
	public enum Style {
		
		case Empty
		case Loading
		case Error
	}
	public var style:Style?
	public lazy var scrollView:ScrollView = {
		
		$0.clipsToBounds = false
		$0.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.width.equalToSuperview().inset(2*UI.Margins)
		}
		return $0
		
	}(ScrollView())
	public var title:String? {
		
		didSet {
			
			titleLabel.text = title
			titleLabel.isHidden = title == nil || title?.isEmpty ?? false
		}
	}
	private lazy var titleLabel:RU_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.textColor = Colors.Content.Title
		$0.textAlignment = .center
		$0.isHidden = true
		return $0
		
	}(RU_Label(title))
	public var image:UIImage? {
		
		didSet {
			
			imageView.image = image
			imageView.isHidden = image == nil
		}
	}
	public lazy var imageView:UIImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.isHidden = true
		return $0
		
	}(UIImageView(image: image))
	public lazy var contentStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = 1.5*UI.Margins
		return $0
		
	}(RU_StackView(arrangedSubviews: [imageView,titleLabel]))
	
	convenience init(_ style:Style? = nil, _ error:Error? = nil, _ handler:RU_Button.Handler = nil) {
		
		self.init(frame: .zero)
		
		defer {
			
			if style == .Empty {
				
				image = UIImage(named: "placeholder_empty")
				title = String(key: "placeholder.empty.title")
				addLabel(String(key: "placeholder.empty.content"))
			}
			else if style == .Loading {
				
				image = UIImage(named: "placeholder_loading")
				title = String(key: "placeholder.loading.title")
				addLabel(String(key: "placeholder.loading.content"))
			}
			else if style == .Error || error != nil {
				
				image = UIImage(named: "placeholder_error")
				title = String(key: "placeholder.error.title")
				
				if let error = error {
					
					addLabel(error.localizedDescription)
				}
				
				let button = addButton(String(key: "placeholder.error.button"), handler)
				button.isHidden = handler == nil
			}
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		backgroundColor = Colors.Background.View
		
		addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		imageView.snp.makeConstraints { make in
			make.height.equalTo(contentStackView.snp.width).multipliedBy(0.5)
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public func scrollToTop(animated:Bool = true) {
		
		scrollView.setContentOffset(.zero, animated: animated)
	}
	
	@discardableResult public func addLabel(_ string:String) -> RU_Label {
		
		let label:RU_Label = .init(string)
		label.textAlignment = .center
		contentStackView.addArrangedSubview(label)
		
		return label
	}
	
	@discardableResult public func addButton(_ string:String? = nil, _ handler:RU_Button.Handler = nil) -> RU_Button {
		
		let button:RU_Button = .init(string,handler)
		contentStackView.addArrangedSubview(button)
		
		return button
	}
}
