//
//  RU_Home_CurrentStay_StickyView.swift
//  RentUp
//
//  Created by BLIN Michael on 23/07/2026.
//

import UIKit
import SnapKit

public class RU_Home_CurrentStay_StickyView: UIView {
	
	private static let progressHeight = UI.Margins * 0.5
	/// Période du motif (stripe + écart) — plus petit = stries plus fines / denses.
	private static let stripePeriod: CGFloat = 5
	private static let stripeWidth: CGFloat = 2
	private static let endpointIconSize: CGFloat = UI.Margins
	
	public var booking: RU_Booking? {
		didSet {
			updateContent()
		}
	}
	
	public var onVisibilityChange: ((Bool) -> Void)?
	
	/// Identifiant de la résa dont le sticky a été dismiss (réapparaît pour une autre résa en cours).
	private var dismissedBookingKey: String?
	
	private var bookingIdentityKey: String? {
		guard let booking else { return nil }
		if let id = booking.id, !id.isEmpty { return id }
		return booking.uuid.isEmpty ? nil : booking.uuid
	}
	
	private var targetProgress: CGFloat = 0
	private var shouldAnimateProgress = false
	/// Si vrai, l'animation part de 0 (première apparition). Sinon, interpolation depuis la position actuelle.
	private var shouldResetProgressBeforeAnimation = false
	private var progressFillWidthConstraint: Constraint?
	private var dotCenterXConstraint: Constraint?
	private var progressTimer: Timer?
	private var foregroundObserver: NSObjectProtocol?
	
	private lazy var dismissIndicatorView: UIView = {
		
		$0.alpha = 0.55
		
		let pillView = UIView()
		pillView.backgroundColor = Colors.Button.Primary.Content
		pillView.layer.cornerRadius = (UI.Margins / 3) / 2
		$0.addSubview(pillView)
		pillView.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(UI.Margins / 2)
			make.bottom.equalToSuperview()
			make.centerX.equalToSuperview()
			make.width.equalTo(UI.Margins * 2.5)
			make.height.equalTo(UI.Margins / 3)
		}
		
		return $0
		
	}(UIView())
	
	private lazy var classifiedLabel: RU_Label = {
		$0.font = Fonts.Content.Title.H4
		$0.textColor = Colors.Button.Primary.Content
		$0.numberOfLines = 1
		return $0
	}(RU_Label())
	
	private lazy var platformLabel: RU_Platform_Label = .init()
	private lazy var statusLabel: RU_Booking_Status_Label = .init()
	
	private lazy var headerStackView: RU_StackView = {
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 2
		$0.alignment = .center
		$0.addArrangedSubview(classifiedLabel)
		$0.addArrangedSubview(UIView())
		$0.addArrangedSubview(platformLabel)
		$0.addArrangedSubview(statusLabel)
		return $0
	}(RU_StackView())
	
	private lazy var progressTrackView: UIView = {
		$0.backgroundColor = Colors.Button.Primary.Content.withAlphaComponent(0.18)
		$0.layer.cornerRadius = Self.progressHeight / 2
		$0.clipsToBounds = true
		$0.snp.makeConstraints { make in
			make.height.equalTo(Self.progressHeight)
		}
		return $0
	}(UIView())
	
	private lazy var remainingStripesView: UIView = {
		$0.clipsToBounds = true
		$0.isUserInteractionEnabled = false
		return $0
	}(UIView())
	
	private lazy var stripesPatternView: UIView = {
		$0.isUserInteractionEnabled = false
		return $0
	}(UIView())
	
	private lazy var progressFillView: UIView = {
		$0.backgroundColor = Colors.Button.Primary.Content
		$0.layer.cornerRadius = Self.progressHeight / 2
		return $0
	}(UIView())
	
	private lazy var dayMarkersContainerView: UIView = {
		$0.isUserInteractionEnabled = false
		$0.backgroundColor = .clear
		return $0
	}(UIView())
	
	private lazy var pulseRingView: UIView = {
		$0.backgroundColor = Colors.Button.Primary.Content.withAlphaComponent(0.3)
		$0.layer.cornerRadius = UI.Margins * 0.75
		$0.isUserInteractionEnabled = false
		$0.snp.makeConstraints { make in
			make.size.equalTo(UI.Margins * 1.5)
		}
		return $0
	}(UIView())
	
	private lazy var progressDotView: UIView = {
		$0.backgroundColor = Colors.Button.Primary.Content
		$0.layer.cornerRadius = UI.Margins * 0.5
		$0.layer.borderWidth = 2.5
		$0.layer.borderColor = Colors.Primary.cgColor
		$0.layer.shadowColor = UIColor.black.cgColor
		$0.layer.shadowOpacity = 0.22
		$0.layer.shadowOffset = CGSize(width: 0, height: 2)
		$0.layer.shadowRadius = 3
		$0.snp.makeConstraints { make in
			make.size.equalTo(UI.Margins)
		}
		return $0
	}(UIView())
	
	private lazy var timelineContainerView: UIView = {
		$0.snp.makeConstraints { make in
			make.height.equalTo(UI.Margins * 2)
		}
		return $0
	}(UIView())
	
	private lazy var arrivalImageView = Self.makeEndpointIcon(systemName: "figure.walk.departure")
	private lazy var departureImageView = Self.makeEndpointIcon(systemName: "figure.walk.departure")
	
	private lazy var progressRowStackView: RU_StackView = {
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 2
		$0.alignment = .center
		$0.addArrangedSubview(arrivalImageView)
		$0.addArrangedSubview(timelineContainerView)
		$0.addArrangedSubview(departureImageView)
		return $0
	}(RU_StackView())
	
	private lazy var contentStackView: RU_StackView = {
		$0.axis = .vertical
		$0.spacing = UI.Margins / 2
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = UIEdgeInsets(top: 0, left: UI.Margins, bottom: UI.Margins, right: UI.Margins)
		$0.addArrangedSubview(dismissIndicatorView)
		$0.addArrangedSubview(headerStackView)
		$0.addArrangedSubview(progressRowStackView)
		$0.setCustomSpacing(UI.Margins / 3, after: dismissIndicatorView)
		return $0
	}(RU_StackView())
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		isHidden = true
		alpha = 0
		backgroundColor = Colors.Primary
		layer.cornerRadius = UI.CornerRadius
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 4)
		layer.shadowOpacity = 0.18
		layer.shadowRadius = UI.Margins
		isUserInteractionEnabled = true
		
		addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		timelineContainerView.addSubview(progressTrackView)
		progressTrackView.snp.makeConstraints { make in
			make.left.right.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		progressTrackView.addSubview(remainingStripesView)
		remainingStripesView.addSubview(stripesPatternView)
		remainingStripesView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		progressTrackView.addSubview(progressFillView)
		progressFillView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			progressFillWidthConstraint = make.width.equalTo(0).constraint
		}
		
		progressTrackView.addSubview(dayMarkersContainerView)
		dayMarkersContainerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		timelineContainerView.addSubview(pulseRingView)
		timelineContainerView.addSubview(progressDotView)
		progressDotView.snp.makeConstraints { make in
			make.centerY.equalTo(progressTrackView)
			dotCenterXConstraint = make.centerX.equalTo(progressTrackView.snp.left).constraint
		}
		pulseRingView.snp.makeConstraints { make in
			make.center.equalTo(progressDotView)
		}
		
		addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			self?.openDetail()
		}))
		
		let panGesture = UIPanGestureRecognizer(block: { [weak self] gesture in
			guard let self, let pan = gesture as? UIPanGestureRecognizer else { return }
			self.handleDismissPan(pan)
		})
		addGestureRecognizer(panGesture)
		
		foregroundObserver = NotificationCenter.default.addObserver(
			forName: UIApplication.didBecomeActiveNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.refreshProgress(animated: true)
		}
	}
	
	deinit {
		stopProgressTimer()
		if let foregroundObserver {
			NotificationCenter.default.removeObserver(foregroundObserver)
		}
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		updateStripesPattern()
		updateDayMarkers()
		applyProgressLayout(animated: shouldAnimateProgress)
	}
	
	public override func didMoveToWindow() {
		super.didMoveToWindow()
		if window != nil, shouldDisplaySticky, !isHidden {
			startPulse()
			startStripesAnimation()
			startProgressTimer()
		} else {
			removePulse()
			stopStripesAnimation()
			stopProgressTimer()
		}
	}
	
	public func restoreAfterDismiss() {
		guard booking != nil, dismissedBookingKey != nil else { return }
		dismissedBookingKey = nil
		updateContent()
	}
	
	private func updateContent() {
		let shouldShow = shouldDisplaySticky
		
		if let booking, shouldShow {
			classifiedLabel.text = booking.classified?.name
			platformLabel.platform = booking.platform
			statusLabel.booking = booking
			targetProgress = booking.stayProgress
			shouldAnimateProgress = true
			shouldResetProgressBeforeAnimation = true
			transform = .identity
			isHidden = false
			setNeedsLayout()
			layoutIfNeeded()
			startProgressTimer()
		} else {
			removePulse()
			stopStripesAnimation()
			stopProgressTimer()
		}
		
		onVisibilityChange?(shouldShow)
		
		UIView.animation(0.25, {
			self.alpha = shouldShow ? 1 : 0
			if !shouldShow {
				self.transform = .identity
			}
		}, {
			if !shouldShow {
				self.isHidden = true
			}
			if shouldShow {
				self.startPulse()
				self.startStripesAnimation()
			}
			self.onVisibilityChange?(shouldShow)
		})
	}
	
	private var shouldDisplaySticky: Bool {
		guard booking != nil else { return false }
		guard let key = bookingIdentityKey else { return true }
		return dismissedBookingKey != key
	}
	
	private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
		guard shouldDisplaySticky, !isHidden else { return }
		
		let translation = gesture.translation(in: self)
		let velocity = gesture.velocity(in: self)
		
		switch gesture.state {
		case .began:
			RU_Feedback.shared.make(.On)
			
		case .changed:
			guard abs(velocity.y) >= abs(velocity.x) || translation.y > 0 else { return }
			let offsetY = max(0, translation.y)
			transform = CGAffineTransform(translationX: 0, y: offsetY)
			let dismissDistance = max(bounds.height, 1)
			alpha = max(0.35, 1 - offsetY / dismissDistance)
			
		case .ended, .cancelled:
			let shouldDismiss = velocity.y > 900 || translation.y > bounds.height * 0.35
			if shouldDismiss {
				dismissByUser()
			} else {
				RU_Feedback.shared.make(.On)
				UIView.animation(0.25) {
					self.transform = .identity
					self.alpha = 1
				}
			}
			
		default:
			break
		}
	}
	
	private func dismissByUser() {
		dismissedBookingKey = bookingIdentityKey
		RU_Feedback.shared.make(.On)
		
		removePulse()
		stopStripesAnimation()
		stopProgressTimer()
		
		UIView.animation(0.22, {
			self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height + UI.Margins * 2)
			self.alpha = 0
		}, {
			self.isHidden = true
			self.transform = .identity
			self.onVisibilityChange?(false)
		})
	}
	
	private func refreshProgress(animated: Bool) {
		guard let booking, !isHidden, shouldDisplaySticky else { return }
		
		let newProgress = booking.stayProgress
		guard abs(newProgress - targetProgress) > 0.0005 else { return }
		
		targetProgress = newProgress
		shouldAnimateProgress = animated
		shouldResetProgressBeforeAnimation = false
		platformLabel.platform = booking.platform
		statusLabel.booking = booking
		setNeedsLayout()
	}
	
	private func startProgressTimer() {
		stopProgressTimer()
		guard booking != nil, shouldDisplaySticky else { return }
		
		let timer = Timer(timeInterval: 30, repeats: true) { [weak self] _ in
			self?.refreshProgress(animated: true)
		}
		RunLoop.main.add(timer, forMode: .common)
		progressTimer = timer
	}
	
	private func stopProgressTimer() {
		progressTimer?.invalidate()
		progressTimer = nil
	}
	
	private func applyProgressLayout(animated: Bool) {
		guard progressTrackView.bounds.width > 0 else { return }
		
		let trackWidth = progressTrackView.bounds.width
		let progress = max(0, min(1, targetProgress))
		let fillWidth = progress * trackWidth
		let dotOffset = progress * trackWidth
		
		if animated {
			shouldAnimateProgress = false
			if shouldResetProgressBeforeAnimation {
				shouldResetProgressBeforeAnimation = false
				progressFillWidthConstraint?.update(offset: 0)
				dotCenterXConstraint?.update(offset: 0)
				timelineContainerView.layoutIfNeeded()
			}
			
			UIView.animate(
				withDuration: 0.65,
				delay: 0.05,
				usingSpringWithDamping: 0.78,
				initialSpringVelocity: 0.55,
				options: [.curveEaseOut, .beginFromCurrentState]
			) {
				self.progressFillWidthConstraint?.update(offset: fillWidth)
				self.dotCenterXConstraint?.update(offset: dotOffset)
				self.timelineContainerView.layoutIfNeeded()
			}
		} else {
			progressFillWidthConstraint?.update(offset: fillWidth)
			dotCenterXConstraint?.update(offset: dotOffset)
		}
	}
	
	private func updateDayMarkers() {
		dayMarkersContainerView.subviews.forEach { $0.removeFromSuperview() }
		
		guard let booking else { return }
		
		let trackWidth = progressTrackView.bounds.width
		guard trackWidth > 0 else { return }
		
		let progresses = booking.stayDayBoundaryProgresses
		guard !progresses.isEmpty else { return }
		
		let minSpacing: CGFloat = 4
		var lastX: CGFloat = -.greatestFiniteMagnitude
		
		for progress in progresses {
			let x = progress * trackWidth
			guard x - lastX >= minSpacing else { continue }
			lastX = x
			
			let tick = UIView()
			tick.backgroundColor = Colors.Primary
			tick.layer.cornerRadius = 0.75
			dayMarkersContainerView.addSubview(tick)
			tick.snp.makeConstraints { make in
				make.top.bottom.equalToSuperview().inset(1)
				make.width.equalTo(1.5)
				make.centerX.equalTo(dayMarkersContainerView.snp.left).offset(x)
			}
		}
	}
	
	private func updateStripesPattern() {
		let bounds = remainingStripesView.bounds
		guard bounds.width > 0, bounds.height > 0 else {
			stripesPatternView.frame = .zero
			return
		}
		
		let period = Self.stripePeriod
		// Largeur largement supérieure à la zone restante pour permettre le défilement sans trou.
		let neededWidth = bounds.width + period * 4
		
		if stripesPatternImageNeedsRefresh(for: bounds.height),
		   let image = Self.makeStripePatternImage(
			period: period,
			stripeWidth: Self.stripeWidth,
			color: Colors.Button.Primary.Content.withAlphaComponent(0.35)
		   ) {
			stripesPatternView.backgroundColor = UIColor(patternImage: image)
			stripesPatternView.tag = Int(bounds.height.rounded())
		}
		
		stripesPatternView.frame = CGRect(x: -period, y: 0, width: neededWidth, height: bounds.height)
		
		if stripesPatternView.layer.animation(forKey: "stripes.slide") == nil, window != nil, !isHidden {
			startStripesAnimation()
		}
	}
	
	private func stripesPatternImageNeedsRefresh(for height: CGFloat) -> Bool {
		stripesPatternView.backgroundColor == nil || stripesPatternView.tag != Int(height.rounded())
	}
	
	private func startStripesAnimation() {
		stopStripesAnimation()
		
		let period = Self.stripePeriod
		let animation = CABasicAnimation(keyPath: "transform.translation.x")
		animation.fromValue = 0
		animation.toValue = -period
		animation.duration = 0.55
		animation.repeatCount = .infinity
		animation.timingFunction = CAMediaTimingFunction(name: .linear)
		stripesPatternView.layer.add(animation, forKey: "stripes.slide")
	}
	
	private func stopStripesAnimation() {
		stripesPatternView.layer.removeAnimation(forKey: "stripes.slide")
	}
	
	private func startPulse() {
		removePulse()
		
		let scale = CABasicAnimation(keyPath: "transform.scale")
		scale.fromValue = 1
		scale.toValue = 1.55
		scale.duration = 1.1
		scale.autoreverses = true
		scale.repeatCount = .infinity
		scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		
		let opacity = CABasicAnimation(keyPath: "opacity")
		opacity.fromValue = 0.55
		opacity.toValue = 0.1
		opacity.duration = 1.1
		opacity.autoreverses = true
		opacity.repeatCount = .infinity
		opacity.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		
		pulseRingView.layer.add(scale, forKey: "pulse.scale")
		pulseRingView.layer.add(opacity, forKey: "pulse.opacity")
	}
	
	private func removePulse() {
		pulseRingView.layer.removeAnimation(forKey: "pulse.scale")
		pulseRingView.layer.removeAnimation(forKey: "pulse.opacity")
	}
	
	private func openDetail() {
		guard let booking else { return }
		
		RU_Feedback.shared.make(.On)
		
		UIView.animation(0.12, {
			self.alpha = 0.72
		}, {
			UIView.animation(0.12) {
				self.alpha = 1
			}
		})
		
		let viewController = RU_Bookings_Detail_ViewController()
		viewController.booking = booking
		UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
	}
	
	private static func makeEndpointIcon(systemName: String) -> UIImageView {
		let imageView = UIImageView(
			image: UIImage(systemName: systemName)?.applyingSymbolConfiguration(
				.init(pointSize: endpointIconSize * 0.75, weight: .semibold)
			)
		)
		imageView.tintColor = Colors.Button.Primary.Content
		imageView.contentMode = .scaleAspectFit
		imageView.setContentHuggingPriority(.required, for: .horizontal)
		imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
		imageView.snp.makeConstraints { make in
			make.size.equalTo(endpointIconSize)
		}
		return imageView
	}
	
	private static func makeStripePatternImage(period: CGFloat, stripeWidth: CGFloat, color: UIColor) -> UIImage? {
		let size = CGSize(width: period, height: period)
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { context in
			let cgContext = context.cgContext
			cgContext.setFillColor(color.cgColor)
			
			// Bande diagonale à 45° qui se répète sans jointure sur toute la hauteur.
			let half = stripeWidth / 2
			cgContext.move(to: CGPoint(x: -half, y: size.height + half))
			cgContext.addLine(to: CGPoint(x: half, y: size.height + half))
			cgContext.addLine(to: CGPoint(x: size.width + half, y: -half))
			cgContext.addLine(to: CGPoint(x: size.width - half, y: -half))
			cgContext.closePath()
			cgContext.fillPath()
			
			// Raccord haut-gauche / bas-droit pour un tiling seamless.
			cgContext.move(to: CGPoint(x: -size.width - half, y: size.height + half))
			cgContext.addLine(to: CGPoint(x: -size.width + half, y: size.height + half))
			cgContext.addLine(to: CGPoint(x: half, y: -half))
			cgContext.addLine(to: CGPoint(x: -half, y: -half))
			cgContext.closePath()
			cgContext.fillPath()
			
			cgContext.move(to: CGPoint(x: size.width - half, y: size.height + half))
			cgContext.addLine(to: CGPoint(x: size.width + half, y: size.height + half))
			cgContext.addLine(to: CGPoint(x: size.width * 2 + half, y: -half))
			cgContext.addLine(to: CGPoint(x: size.width * 2 - half, y: -half))
			cgContext.closePath()
			cgContext.fillPath()
		}
	}
}
