//
//  SJRippleLayer.swift
//  参考 Material Design 的 ripple 效果
//  ref: https://github.com/material-components/material-components-ios/blob/develop/components/Ripple/src/MDCRippleView.m
//  ScreenJumper
//
//  Created by tiou on 2020/9/17.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import Foundation
import Cocoa


private let kExpandRippleBeyondSurface:CGFloat = 10
private let kRippleStartingScale:CGFloat = 0.3
private let kRippleTouchDownDuration:CGFloat = 0.225
private let kRippleTouchUpDuration:CGFloat = 0.15
private let kRippleFadeInDuration:CGFloat = 0.075
private let kRippleFadeOutDuration : CGFloat = 0.225
private let kRippleFadeOutDelay : CGFloat = 0.15

private let kRippleLayerOpacityString = "opacity"
private let kRippleLayerPositionString = "position"
private let kRippleLayerScaleString = "transform.scale"

class SJRippleLayer : CAShapeLayer{
    var startAnimationActive:Bool = false
    var maximumRadius:CGFloat = 0.0
    
    override init() {
        super.init()    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// - Returns: 取对角线作为最终半径
    private static func  getFinalRippleRadius(_ rect:CGRect) ->  CGFloat {
        return (CGFloat)(hypot(rect.midX, rect.midY) + kExpandRippleBeyondSurface);
    }
    
    private static func getInitialRippleRadius(_ rect:CGRect) -> CGFloat {
        return max(rect.width, rect.height)*kRippleStartingScale / 2.0
    }
    
    private func calculateRadius() -> CGFloat{
        return self.maximumRadius > 0 ? self.maximumRadius : SJRippleLayer.getFinalRippleRadius(self.bounds);
    }
    
    
    private func setPathFrom(radius:CGFloat){
        let ovalRect = CGRect(x: bounds.midX - radius,  y: bounds.midY - radius, width: radius*2, height: radius*2)
        let circle = CGPath(ellipseIn: ovalRect, transform: nil)
        self.path = circle
    }
    
    func startRipple(at point:CGPoint, animated:Bool, completion: (()->Void)?){
        print("layer:\(bounds)")
        let finalRadius = calculateRadius()
        setPathFrom(radius: finalRadius)
        position = CGPoint(x:bounds.midX, y:bounds.midY)
        if(!animated){
            completion?()
        }else{
            startAnimationActive = true
        }
        let startingScale = SJRippleLayer.getInitialRippleRadius(bounds) / finalRadius
        let scaleAnim = CABasicAnimation(keyPath: kRippleLayerScaleString)
        scaleAnim.fromValue = startingScale
        scaleAnim.toValue = 1
        scaleAnim.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.4, 0, 0.6, 1)
        
        let centerPath = CGMutablePath()
        let startPoint = point
        let endPoint = CGPoint.init(x: bounds.midX, y: bounds.midY)
        centerPath.move(to: startPoint)
        centerPath.addLine(to: endPoint)
        centerPath.closeSubpath()

        let positionAnim = CAKeyframeAnimation(keyPath: kRippleLayerPositionString)
        positionAnim.path = centerPath
        positionAnim.keyTimes = [0, 1]
        positionAnim.values = [0, 1]
        positionAnim.timingFunction =  CAMediaTimingFunction.init(controlPoints: 0.4, 0, 0.6, 1)
        
        let fadeOutAnim = CABasicAnimation(keyPath: kRippleLayerOpacityString)
        fadeOutAnim.fromValue = 1
        fadeOutAnim.toValue = 0
        fadeOutAnim.duration = CFTimeInterval(kRippleFadeOutDuration)
        fadeOutAnim.timingFunction = .init(name: .linear)
        
        CATransaction.begin()
        let animGroup = CAAnimationGroup()
        animGroup.animations = [scaleAnim, positionAnim, fadeOutAnim]
        animGroup.duration = CFTimeInterval(kRippleTouchDownDuration)
        CATransaction.setCompletionBlock({
            self.startAnimationActive = false
            completion?()
        })
        self.add(animGroup, forKey: nil)
        CATransaction.commit()
    }
}
