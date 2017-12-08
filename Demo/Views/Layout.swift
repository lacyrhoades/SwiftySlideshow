//
//  Layout.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

extension UIView {
    func addAutoSubview(_ view: UIView?) {
        guard let view = view else {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
    }
    
    func border(_ width: CGFloat, _ color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}

struct Layout {
    static func doNotCompress(_ view: UIView, onAxis axis: UILayoutConstraintAxis) {
        view.setContentCompressionResistancePriority(.required, for: axis)
    }
    
    @discardableResult static func pinHorizontal(_ view: UIView) -> [NSLayoutConstraint] {
        return Layout.pinHorizontal(view, withMargins: 0)
    }
    
    @discardableResult static func pinHorizontal(_ view: UIView, withMargins margin: CGFloat) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-margin-[view]-margin-|",
            options: [], metrics: ["margin": margin], views: ["view": view]
        )
        view.superview!.addConstraints(
            constraints
        )
        return constraints
    }
    
    @discardableResult static func pinVertical(_ view: UIView, withMargins margin: CGFloat, withPriorityString priority: String = "1000") -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(margin@priority)-[view]-(margin@priority)-|",
            options: [], metrics: ["margin": margin, "priority": priority], views: ["view": view]
        )
        view.superview!.addConstraints(
            constraints
        )
        return constraints
    }
    
    @discardableResult static func pinVertical(_ view: UIView) -> [NSLayoutConstraint] {
        return Layout.pinVertical(view, withMargins: 0)
    }
    
    static func pinToTop(_ view: UIView) {
        view.superview!.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[view]",
                options: [], metrics: [:], views: ["view": view])
        )
    }
    
    @discardableResult static func pinTop(_ view: UIView, byAmount amt: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview!, attribute: .top, multiplier: 1, constant: amt)
        view.superview!.addConstraint(
            constraint
        )
        return constraint
    }
    
    @discardableResult static func pinTrailing(_ view: UIView, byAmount amt: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: view.superview!, attribute: .trailing, multiplier: 1, constant: -1 * amt)
        view.superview!.addConstraint(
            constraint
        )
        return constraint
    }
    
    @discardableResult static func pinTrailing(_ view: UIView, withMultiplier mult: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: view.superview!, attribute: .trailing, multiplier: mult, constant: 0)
        view.superview!.addConstraint(
            constraint
        )
        return constraint
    }
    
    
    @discardableResult static func pinBottom(_ view: UIView, byAmount amt: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: view.superview!, attribute: .bottom, multiplier: 1, constant: -1 * amt)
        
        view.superview!.addConstraint(
            constraint
        )
        
        return constraint
    }
    
    static func pinLeading(_ view: UIView, byAmount amt: CGFloat) {
        view.superview!.addConstraint(
            NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: view.superview!, attribute: .leading, multiplier: 1, constant: amt)
        )
    }
    
    static func pinToBottom(_ view: UIView) {
        view.superview!.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[view]|",
                options: [], metrics: [:], views: ["view": view])
        )
    }
    
    static func pinVertical(_ layout: String, withViews views: [String: AnyObject]) {
        (views.first!.1 as! UIView).superview!.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: layout, options: [], metrics: [:], views: views
            )
        )
    }
    
    static func pinVertical(_ layout: String, withViews views: [String: AnyObject], andMetrics metrics: [String: CGFloat]) {
        (views.first!.1 as! UIView).superview!.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: layout, options: [], metrics: metrics, views: views
            )
        )
    }
    
    static func pinLayout(_ layout: String, withViews views: [String: AnyObject], andMetrics metrics: [String: CGFloat]) {
        (views.first!.1 as! UIView).superview!.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: layout, options: [], metrics: metrics, views: views
            )
        )
    }
    
    @discardableResult static func pin(topOf bottomView: UIView, toBottomOf topView: UIView) -> NSLayoutConstraint {
        return self.pin(topOf: bottomView, toBottomOf: topView, withSpace: 0)
    }
    
    @discardableResult static func pin(topOf bottomView: UIView, toBottomOf topView: UIView, withSpace space: CGFloat) -> NSLayoutConstraint {
        return self.pin(topOf: bottomView, toBottomOf: topView, inView: topView.superview!, withSpace: space, withPriority: .required)
    }
    
    @discardableResult static func pin(topOf bottomView: UIView, toBottomOf topView: UIView, inView: UIView, withSpace space: CGFloat) -> NSLayoutConstraint {
        return self.pin(topOf: bottomView, toBottomOf: topView, inView: inView, withSpace: space, withPriority: .required)
    }
    
    @discardableResult static func pin(topOf bottomView: UIView, toBottomOf topView: UIView, inView: UIView, withSpace space: CGFloat, withPriority priority: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: bottomView, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1, constant: space)
        constraint.priority = priority
        inView.addConstraint(constraint)
        return constraint
    }
    
    static func pin(bottomOf view: UIView, toBottomOf otherView: UIView, inView: UIView) {
        inView.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: otherView, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    static func pinHorizontalSides(of ofView: UIView, to toView: UIView, in inView: UIView, withSpace space: CGFloat) {
        inView.addConstraints([
            NSLayoutConstraint(item: ofView, attribute: .leading, relatedBy: .equal, toItem: toView, attribute: .leading, multiplier: 1, constant: space),
            NSLayoutConstraint(item: ofView, attribute: .trailing, relatedBy: .equal, toItem: toView, attribute: .trailing, multiplier: 1, constant: -1 * space)
            ])
    }
    
    @discardableResult static func pinAllSides(of ofView: UIView, to toView: UIView, in inView: UIView) -> [NSLayoutConstraint] {
        let constraints = [
            NSLayoutConstraint(item: ofView, attribute: .top, relatedBy: .equal, toItem: toView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ofView, attribute: .bottom, relatedBy: .equal, toItem: toView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ofView, attribute: .leading, relatedBy: .equal, toItem: toView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ofView, attribute: .trailing, relatedBy: .equal, toItem: toView, attribute: .trailing, multiplier: 1, constant: 0)
        ]
        inView.addConstraints(constraints)
        return constraints
    }
    
    static func pinBaselines(of ofView: UIView, to toView: UIView, in inView: UIView, by yOffset: CGFloat) {
        inView.addConstraint(NSLayoutConstraint(item: ofView, attribute: .firstBaseline, relatedBy: .equal, toItem: toView, attribute: .firstBaseline, multiplier: 1, constant: yOffset))
    }
    
    static func pinCenter(of ofView: UIView, to toView: UIView, in inView: UIView, by yOffset: CGFloat) {
        inView.addConstraint(NSLayoutConstraint(item: ofView, attribute: .centerY, relatedBy: .equal, toItem: toView, attribute: .centerY, multiplier: 1, constant: yOffset))
    }
    
    static func pinBottom(of ofView: UIView, to toView: UIView, in inView: UIView, by yOffset: CGFloat) {
        inView.addConstraint(NSLayoutConstraint(item: ofView, attribute: .bottom, relatedBy: .equal, toItem: toView, attribute: .bottom, multiplier: 1, constant: -1 * yOffset))
    }
    
    static func verticallyPin(view: UIView, toCenterOf otherView: UIView, withYOffset offset: CGFloat, inView: UIView) {
        inView.addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: otherView, attribute: .centerY, multiplier: 1, constant: offset))
    }
    
    static func horizontallyPin(view: UIView, toCenterOf otherView: UIView, withXOffset offset: CGFloat, inView: UIView) {
        inView.addConstraint(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: otherView, attribute: .centerX, multiplier: 1, constant: offset))
    }
    
    @discardableResult static func setHeight(of: UIView, to: CGFloat, withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: of, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: to)
        constraint.priority = priority
        of.superview!.addConstraint(
            constraint
        )
        return constraint
    }
    
    @discardableResult static func setWidth(of: UIView, to: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: of, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: to)
        of.superview!.addConstraint(
            constraint
        )
        return constraint
    }
    
    static func matchHeight(ofView: UIView, toView: UIView, inView: UIView, byFactorOf multiplier: CGFloat) {
        Layout.matchHeight(ofView: ofView, toView: toView, inView: inView, byFactorOf: multiplier, withPriority: .required)
    }
    
    @discardableResult static func matchHeight(ofView: UIView, toView: UIView, inView: UIView, byFactorOf multiplier: CGFloat, withPriority priority: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: ofView, attribute: .height, relatedBy: .equal, toItem: toView, attribute: .height, multiplier: multiplier, constant: 0)
        constraint.priority = priority
        inView.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult static func matchWidth(ofView: UIView, toView: UIView, inView: UIView, byFactorOf multiplier: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: ofView, attribute: .width, relatedBy: .equal, toItem: toView, attribute: .width, multiplier: multiplier, constant: 0)
        inView.addConstraint(constraint)
        return constraint
    }
    
    static func square(_ view: UIView, toSize size: CGFloat) {
        view.superview!.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size))
        view.superview!.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size))
    }
    
    @discardableResult static func setRatio(ofView view: UIView, inView: UIView, withWidthToHeightRatio ratio: CGFloat, withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: ratio, constant: 0)
        constraint.priority = priority
        inView.addConstraint(constraint)
        return constraint
    }
    
    static func squareUp(view: UIView, inView: UIView) {
        inView.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
    }
    @discardableResult static func centerX(_ view: UIView) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: view.superview!, attribute: .centerX, multiplier: 1, constant: 0)
        view.superview!.addConstraint(constraint)
        return constraint
    }
    @discardableResult static func centerY(_ view: UIView) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: view.superview!, attribute: .centerY, multiplier: 1, constant: 0)
        view.superview!.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult static func centerY(_ view: UIView, offsetBy offset: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: view.superview!, attribute: .centerY, multiplier: 1, constant: offset)
        view.superview!.addConstraint(constraint)
        return constraint
    }
    
    static func pin(leading: UIView, toTrailing: UIView, inView: UIView, withMargin: CGFloat) {
        inView.addConstraint(NSLayoutConstraint(item: leading, attribute: .leading, relatedBy: .equal, toItem: toTrailing, attribute: .trailing, multiplier: 1, constant: withMargin))
    }
    
    static func matchCenterY(of: UIView, and: UIView) {
        of.superview!.addConstraint(NSLayoutConstraint(item: of, attribute: .centerY, relatedBy: .equal, toItem: and, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    @discardableResult static func matchCenterX(of: UIView, and: UIView) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: of, attribute: .centerX, relatedBy: .equal, toItem: and, attribute: .centerX, multiplier: 1, constant: 0)
        of.superview!.addConstraint(constraint)
        return constraint
    }
}

