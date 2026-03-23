//
//  RU_Liquid_View.swift
//  RentUp
//
//  Created by Michaël Blin on 18/03/2026.
//

import Foundation
import UIKit

public class RU_Liquid_View: UIView {
    
    private let maskLayer = CAShapeLayer()
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var duration: CFTimeInterval = 0.75
    private var completion: (() -> Void)?
    private var didFinish: Bool = false
    
    private var fillProgress: CGFloat = 0 // 0...1
    private var phase1: CGFloat = 0
    private var phase2: CGFloat = 0
    private var phase3: CGFloat = 0
    private var sloshPhase: CGFloat = 0
    
    private let bubblesLayer = CAEmitterLayer()
    private let dropletsLayer = CAEmitterLayer()
    private static let particleImage: CGImage? = {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(ovalIn: rect).fill()
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }()
    
    init(color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color
        layer.mask = maskLayer
        isUserInteractionEnabled = false
        
        configureEmitters()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startFill(duration: CFTimeInterval, completion: @escaping () -> Void) {
        self.duration = max(0.1, duration)
        self.startTime = CACurrentMediaTime()
        self.fillProgress = 0
        self.phase1 = 0
        self.phase2 = 1.2
        self.phase3 = 2.4
        self.sloshPhase = 0
        self.completion = completion
        self.didFinish = false
        
        bubblesLayer.birthRate = 0
        dropletsLayer.birthRate = 0
        
        displayLink?.invalidate()
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        self.displayLink = displayLink
        displayLink.add(to: .main, forMode: .common)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        bubblesLayer.emitterSize = CGSize(width: bounds.width, height: 1)
        dropletsLayer.emitterSize = CGSize(width: bounds.width, height: 1)
        updateMaskPath()
    }
    
    @objc private func step() {
        let t = CACurrentMediaTime() - startTime
        let p = min(1, max(0, t / duration))
        
        // Ease-out pour un rendu plus "liquide"
        let eased = 1 - pow(1 - p, 3)
        fillProgress = CGFloat(eased)
        
        // La vague ralentit/atténue en fin d’animation
        let speed = (1 - CGFloat(p) * 0.35)
        phase1 += 0.55 * speed
        phase2 += 0.36 * speed
        phase3 += 0.78 * speed
        sloshPhase += 0.08 + 0.06 * speed
        
        updateMaskPath(updateParticles: true)
        
        if p >= 1, didFinish == false {
            didFinish = true
            displayLink?.invalidate()
            displayLink = nil
            updateMaskPath(final: true, updateParticles: true)
            bubblesLayer.birthRate = 0
            dropletsLayer.birthRate = 0
            completion?()
            completion = nil
        }
    }
    
    private func updateMaskPath(final: Bool = false, updateParticles: Bool = false) {
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }
        
        let progress = final ? CGFloat(1) : fillProgress
        let sloshAmount = final ? 0 : (1 - progress) * 1.0
        let sloshY = sin(sloshPhase) * (h * 0.012) * sloshAmount
        let sloshX = cos(sloshPhase * 0.9) * (w * 0.018) * sloshAmount
        let baselineY = (h * (1 - progress)) + sloshY
        
        let amplitudeMax = max(18, min(46, h * 0.065))
        let amplitudeBase = final ? 0 : amplitudeMax * (1 - progress) * 0.95
        let amplitudePulse = final ? 0 : (0.18 * amplitudeBase * sin(sloshPhase * 1.7 + 0.6))
        let amplitude = max(0, amplitudeBase + amplitudePulse)
        
        let wavelength1 = max(140, w * 0.85)
        let wavelength2 = max(90, w * 0.55)
        let wavelength3 = max(55, w * 0.32)
        let step: CGFloat = max(8, w / 30)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: baselineY))
        
        var x: CGFloat = 0
        while x <= w + step {
            let xx = x + sloshX
            let a1 = (2 * .pi * xx / wavelength1) + phase1
            let a2 = (2 * .pi * xx / wavelength2) + phase2
            let a3 = (2 * .pi * xx / wavelength3) + phase3
            
            // 3 composantes => mouvement plus riche, sans être “bruité”
            let y =
            baselineY
            + (sin(a1) * amplitude * 0.70)
            + (sin(a2) * amplitude * 0.38)
            + (sin(a3) * amplitude * 0.14)
            + (cos(a3 * 0.7) * amplitude * 0.06)
            
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        
        path.addLine(to: CGPoint(x: w, y: h))
        path.close()
        
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        
        if updateParticles {
            // Particules: bulles dans le liquide + gouttes au niveau de la crête
            let bubbleY = max(0, min(h, baselineY + amplitude * 0.2))
            bubblesLayer.emitterPosition = CGPoint(x: w / 2, y: bubbleY + 18)
            
            let dropletsY = max(0, min(h, baselineY))
            dropletsLayer.emitterPosition = CGPoint(x: w / 2, y: dropletsY)
            
            if progress > 0.12 && progress < 0.98 {
                bubblesLayer.birthRate = 1
                // Plus on s’approche du haut, plus ça "éclabousse"
                dropletsLayer.birthRate = progress > 0.65 ? 1 : 0
            } else {
                bubblesLayer.birthRate = 0
                dropletsLayer.birthRate = 0
            }
        }
    }
    
    private func configureEmitters() {
        guard let particle = Self.particleImage else { return }
        
        // Bulles (dans le liquide)
        bubblesLayer.emitterShape = .line
        bubblesLayer.emitterMode = .surface
        bubblesLayer.renderMode = .additive
        bubblesLayer.birthRate = 0
        
        let bubbles = CAEmitterCell()
        bubbles.contents = particle
        bubbles.birthRate = 14
        bubbles.lifetime = 1.2
        bubbles.velocity = -26
        bubbles.velocityRange = 18
        bubbles.yAcceleration = -10
        bubbles.scale = 0.05
        bubbles.scaleRange = 0.06
        bubbles.alphaSpeed = -0.55
        bubbles.emissionRange = .pi
        bubbles.color = UIColor.white.withAlphaComponent(0.28).cgColor
        bubblesLayer.emitterCells = [bubbles]
        layer.addSublayer(bubblesLayer)
        
        // Gouttes / éclaboussures (au niveau de la crête)
        dropletsLayer.emitterShape = .line
        dropletsLayer.emitterMode = .surface
        dropletsLayer.renderMode = .additive
        dropletsLayer.birthRate = 0
        
        let droplet = CAEmitterCell()
        droplet.contents = particle
        droplet.birthRate = 18
        droplet.lifetime = 0.7
        droplet.velocity = -120
        droplet.velocityRange = 80
        droplet.yAcceleration = 220
        droplet.emissionRange = .pi * 0.95
        droplet.scale = 0.08
        droplet.scaleRange = 0.07
        droplet.alphaSpeed = -1.0
        droplet.color = UIColor.white.withAlphaComponent(0.22).cgColor
        
        let mist = CAEmitterCell()
        mist.contents = particle
        mist.birthRate = 10
        mist.lifetime = 0.45
        mist.velocity = -60
        mist.velocityRange = 50
        mist.yAcceleration = 160
        mist.emissionRange = .pi
        mist.scale = 0.035
        mist.scaleRange = 0.03
        mist.alphaSpeed = -1.4
        mist.color = UIColor.white.withAlphaComponent(0.14).cgColor
        
        dropletsLayer.emitterCells = [droplet, mist]
        layer.addSublayer(dropletsLayer)
    }
}

