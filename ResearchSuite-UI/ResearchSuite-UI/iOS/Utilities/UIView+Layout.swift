//
//  UIView+LayoutExtensions.swift
//  ResearchSuite-UI
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

extension UIView {

    
    /**
     A convenience method to align all edges of the view to the edges of another view. Note: this method
     does not use the 'margin' attributes, such as .topMargin, but uses the 'edge' attributes, such as .top
     
     @param relation    The 'NSLayoutRelation' to apply to all constraints.
     @param view        The 'UIView' to which the view will be aligned.
     @param padding     The padding (or inset) to be applied to each constraint.
     */
    public func alignAll(_ relation: NSLayoutRelation, to view: UIView!, padding: CGFloat) {
        let attributes: [NSLayoutAttribute] = [.leading, .top, .trailing, .bottom]
        align(attributes, relation, to: view, attributes, padding: padding)
    }

    /**
     A convenience method to align an array of attributes of the view to the same attributes of it's superview.
     
     @param attribute   The 'NSLayoutAttribute' to align to the view's superview.
     @param padding     The padding (or inset) to be applied to the constraint.
     */
    public func alignToSuperview(_ attributes: [NSLayoutAttribute], padding: CGFloat) {
        align(attributes, .equal, to: self.superview, attributes, padding: padding)
    }

    /**
     A convenience method to align all edges of the view to the edges of its superview. Note: this method
     does not use the 'margin' attributes, such as .topMargin, but uses the 'edge' attributes, such as .top
     
     @param padding     The padding (or inset) to be applied to each constraint.
     */
    public func alignAllToSuperview(padding: CGFloat) {
        alignAll(.equal, to: self.superview, padding: padding)
    }

    /**
     A convenience method to position the view below another view.
     
     @param view        The 'UIView' to which the view will be aligned.
     @param padding     The padding (or inset) to be applied to the constraint.
     */
    public func alignBelow(view: UIView, padding: CGFloat) {
        align([.top], .equal, to: view, [.bottom], padding: padding)
    }

    /**
     A convenience method to position the view above another view.
     
     @param view        The 'UIView' to which the view will be aligned.
     @param padding     The padding (or inset) to be applied to the constraint.
     */
    public func alignAbove(view: UIView, padding: CGFloat) {
        align([.bottom], .equal, to: view, [.top], padding: padding)
    }

    /**
     A convenience method to position the view to the left of another view.
     
     @param view        The 'UIView' to which the view will be aligned.
     @param padding     The padding (or inset) to be applied to the constraint.
     */
    public func alignLeftOf(view: UIView, padding: CGFloat) {
        align([.trailing], .equal, to: view, [.leading], padding: padding)
    }

    /**
     A convenience method to position the view to the right of another view.
     
     @param view        The 'UIView' to which the view will be aligned.
     @param padding     The padding (or inset) to be applied to the constraint.
     */
    public func alignRightOf(view: UIView, padding: CGFloat) {
        align([.leading], .equal, to: view, [.trailing], padding: padding)
    }
    
    /**
     A convenience method to create a NSLayoutConstraint for the purpose of aligning views within
     their 'superview'. As such, the view must have a 'superview'.
     
     @param attributes      An array of 'NSLayoutAttribute' to be applied to the 'firstItem' (self) in the constraints.
     @param relation        The 'NSLayoutRelation' used for the constraint.
     @param view            The 'UIView' that the view is being constrained to.
     @param toAttributes    An array of 'NSLayoutAttribute' to be applied to the 'secondItem' (to View) in the constraints.
     @param padding         The padding (or inset) to be applied to the constraints.
     */
    public func align(_ attributes: [NSLayoutAttribute]!, _ relation: NSLayoutRelation, to view:UIView!, _ toAttributes: [NSLayoutAttribute]!, padding: CGFloat) {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return
        }
        
        guard attributes.count > 0 else {
            assertionFailure("'attributes' must contain at least one 'NSLayoutAttribute'")
            return
        }

        guard attributes.count == toAttributes.count else {
            assertionFailure("The number of 'attributes' must match the number of 'toAttributes'")
            return
        }
        
        attributes.forEach({
            
            let toAttribute = toAttributes[attributes.index(of: $0)!]
            let _padding = $0 == .trailing || $0 == .bottom ? -1 * padding : padding
            superview.addConstraint(NSLayoutConstraint(item: self,
                                                       attribute: $0,
                                                       relatedBy: relation,
                                                       toItem: view,
                                                       attribute: toAttribute,
                                                       multiplier: 1.0,
                                                       constant: _padding))

        })


    }

    /**
     A convenience method to center the view vertically within its 'superview'. The view must have
     a 'superview'.
     
     @param padding     The padding (or offset from center) to be applied to the constraint.
     */
    public func allignCenterVertical(padding: CGFloat) {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return
        }

        superview.addConstraint(NSLayoutConstraint(item: self,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: superview,
                                                   attribute: .centerY,
                                                   multiplier: 1.0,
                                                   constant: padding))
    }
    
    /**
     A convenience method to center the view horizontally within it's 'superview'. The view must have
     a 'superview'.
     
     @param padding     The padding (or offset from center) to be applied to the constraint.
     */
    public func alignCenterHorizontal(padding: CGFloat) {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return
        }

        superview.addConstraint(NSLayoutConstraint(item: self,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: superview,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: padding))
    }
    
    /**
     A convenience method to constrain the view's width.
     
     @param relation    The 'NSLayoutRelation' used in the constraint.
     @param width       A 'CGFloat' constant for the width.
     */
    public func makeWidth(_ relation: NSLayoutRelation, _ width : CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .width,
                                              relatedBy: relation,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: width))
    }
    
    /**
     A convenience method to constrain the view's height.
     
     @param relation    The 'NSLayoutRelation' used in the constraint.
     @param height       A 'CGFloat' constant for the height.
     */
    public func makeHeight(_ relation: NSLayoutRelation, _ height : CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: relation,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: height))
    }
    
    /**
     A convenience method to constraint the view's width relative to its superview.
     
     @param multiplier       A 'CGFloat' constant for the constraint multiplier.
     */
    public func makeWidthEqualToSuperview(multiplier: CGFloat) {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return
        }
        
        superview.addConstraint(NSLayoutConstraint(item: self,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: superview,
                                                    attribute: .width,
                                                    multiplier: multiplier,
                                                    constant: 0.0))
    }
    
    
    /**
     A convenience method to remove all the view's constraints that exist between it and its superview
     or its superview's other child views. It does NOT remove constraints between the view and its child views.
     */
    public func removeSiblingAndAncestorConstraints() {
        for constraint in self.constraints {
            
            // iOS automatically creates special types of constraints, like for intrinsicContentSize,
            // and we don'e want these. So test here for that and skip
            if type(of: constraint) != NSLayoutConstraint.self {
                continue
            }
            
            if constraint.firstItem as? UIView == self && !isChildView(item: constraint.secondItem) {
                self.removeConstraint(constraint)
            }
        }
        if let superview = superview {
            for constraint in superview.constraints {
                
                // iOS automatically creates special types of constraints, like for intrinsicContentSize,
                // and we don'e want these. So test here for that and skip
                if type(of: constraint) != NSLayoutConstraint.self {
                    continue
                }
                
                if constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self {
                    superview.removeConstraint(constraint)
                }
            }
        }
    }
    
    func isChildView(item : AnyObject?) -> Bool {
        
        var isChild = false
        
        if let item = item {
            if item is UIView {
                for subView in self.subviews {
                    if subView == item as! NSObject {
                        isChild = true
                        break
                    }
                }
            }
        }
        return isChild
    }
    
    /**
     A convenience method to return a constraint on the view that matches the supplied constraint properties.
     If multiple constraints matching those properties are found, it returns the constraint with the highest priority.
     
     @param attribute   The 'NSLayoutAttribute' of the constaint to be returned.
     @param relation    The 'NSLayoutRelation' of the constraint to be returned.
     
     @return            The 'NSLayoutConstraint' matching the supplied constraint properties, if any.
     */
    open func constraint(for attribute: NSLayoutAttribute, relation: NSLayoutRelation) -> NSLayoutConstraint? {
        
        var theConstraints = Array<NSLayoutConstraint>()
        
        // iterate the view constraints and superview constraints. In most cases, we should have only one that has the 'firstItem',
        // 'firstAttribute' and 'relation' values that we're looking for. It's possible there could be more than one with
        // different priorities. So, we collect all of them and return the one with highest priority.
        
        [self, self.superview ?? nil].forEach({
            
            if let constraints = $0?.constraints {
                
                for constraint in constraints {
                    
                    // iOS automatically creates special types of constraints, like for intrinsicContentSize,
                    // and we don't want these. So we make sure we have a 'NSLayoutConstraint' base class.
                    if type(of: constraint) != NSLayoutConstraint.self {
                        continue
                    }
                                        
                    if RSDObjectEquality(constraint.firstItem, self) && constraint.firstAttribute == attribute && constraint.relation == relation {
                        theConstraints.append(constraint)
                    }
                }
            }
        })
        
        return theConstraints.max { $0.priority.rawValue < $1.priority.rawValue } ?? nil
    }
}
