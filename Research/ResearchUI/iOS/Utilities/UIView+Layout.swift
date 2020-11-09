//
//  UIView+Layout.swift
//  ResearchUI
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
import Research

extension CGFloat {
    
    /// Occasionally we do want UI elements to be a little bigger or wider on bigger screens,
    /// such as with label widths. This can be used to increase values based on screen size. It
    /// uses the small screen (320 wide) as a baseline. This is a much simpler alternative to
    /// defining a matrix with screen sizes and constants and achieves much the same result
    /// - parameter max: A maximum size to apply to the returned value.
    public func rsd_proportionalToScreenWidth(max: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        let baseline = CGFloat(320.0)
        let ret = ceil((UIScreen.main.bounds.size.width / baseline) * self)
        return ret < max ? ret : max
    }
    
    /// Occasionally we want padding to be a little bigger or longer on bigger screens.
    /// This can be used to increase values based on screen size. It uses the small screen
    /// (568 high) as a baseline. This is a much simpler alternative to defining a matrix
    /// with screen sizes and constants and achieves much the same result.
    /// - parameter max: A maximum size to apply to the returned value.
    public func rsd_proportionalToScreenHeight(max: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        let baseline = CGFloat(568.0)
        let ret = ceil((UIScreen.main.bounds.size.height / baseline) * self)
        return ret < max ? ret : max
    }
    
    /// Occasionally we want padding to be a little bigger or longer on bigger screens.
    /// This method will apply the `multiplier` if and only if this is an iPad.
    /// - note: This does not check the size class of the view.
    /// - parameter multiplier: The value to multiply by if this is an iPad.
    public func rsd_iPadMultiplier(_ multiplier: CGFloat) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return self * multiplier
        } else {
            return self
        }
    }
}

extension UIView {

    /// A convenience method to align all edges of the view to the edges of another view. Note: this method
    /// does not use the 'margin' attributes, such as .topMargin, but uses the 'edge' attributes, such as .top
    ///
    /// - parameters:
    ///     - relation:    The 'NSLayoutRelation' to apply to all constraints.
    ///     - view:        The 'UIView' to which the view will be aligned.
    ///     - padding:     The padding (or inset) to be applied to each constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignAll(_ relation: NSLayoutConstraint.Relation, to view: UIView!, padding: CGFloat) -> [NSLayoutConstraint] {
        let attributes: [NSLayoutConstraint.Attribute] = [.leading, .top, .trailing, .bottom]
        return rsd_align(attributes, relation, to: view, attributes, padding: padding)
    }
    
    /// A convenience method to align all edges of the view to the edges of another view. Note: this method
    /// uses the 'margin' attributes, such as .topMargin, and not the 'edge' attributes, such as .top
    ///
    /// - parameters:
    ///     - relation:    The 'NSLayoutRelation' to apply to all constraints.
    ///     - view:        The 'UIView' to which the view will be aligned.
    ///     - padding:     The padding (or inset) to be applied to each constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignAllMargins(_ relation: NSLayoutConstraint.Relation, to view: UIView!, padding: CGFloat) -> [NSLayoutConstraint] {
        let attributes: [NSLayoutConstraint.Attribute] = [.leadingMargin, .topMargin, .trailingMargin, .bottomMargin]
        return rsd_align(attributes, relation, to: view, attributes, padding: padding)
    }

    /// A convenience method to align an array of attributes of the view to the same attributes of it's superview.
    ///
    /// - parameters:
    ///     - attribute:   The 'NSLayoutAttribute' to align to the view's superview.
    ///     - padding:     The padding (or inset) to be applied to the constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignToSuperview(_ attributes: [NSLayoutConstraint.Attribute], padding: CGFloat, priority: UILayoutPriority = UILayoutPriority(1000.0)) -> [NSLayoutConstraint] {
        return rsd_align(attributes, .equal, to: self.superview, attributes, padding: padding, priority: priority)
    }

    /// A convenience method to align all edges of the view to the edges of its superview. Note: this method
    /// does not use the 'margin' attributes, such as .topMargin, but uses the 'edge' attributes, such as .top
    ///
    /// - parameter padding: The padding (or inset) to be applied to each constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignAllToSuperview(padding: CGFloat) -> [NSLayoutConstraint] {
        return rsd_alignAll(.equal, to: self.superview, padding: padding)
    }
    
    /// A convenience method to align all edges of the view to the edges of its superview. Note: this method
    /// does not use the 'margin' attributes, such as .topMargin, but uses the 'edge' attributes, such as .top
    ///
    /// - parameter padding: The padding (or inset) to be applied to each constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignAllMarginsToSuperview(padding: CGFloat) -> [NSLayoutConstraint] {
        return rsd_alignAllMargins(.equal, to: self.superview, padding: padding)
    }

    /// A convenience method to position the view below another view.
    ///
    /// - parameters:
    ///     - view:        The 'UIView' to which the view will be aligned.
    ///     - padding:     The padding (or inset) to be applied to the constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignBelow(view: UIView, padding: CGFloat, priority: UILayoutPriority = UILayoutPriority(1000.0)) -> [NSLayoutConstraint] {
        return rsd_align([.top], .equal, to: view, [.bottom], padding: padding, priority: priority)
    }

    /// A convenience method to position the view above another view.
    ///
    /// - parameters:
    ///     - view:        The 'UIView' to which the view will be aligned.
    ///     - padding:     The padding (or inset) to be applied to the constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignAbove(view: UIView, padding: CGFloat, priority: UILayoutPriority = UILayoutPriority(1000.0)) -> [NSLayoutConstraint] {
        return rsd_align([.bottom], .equal, to: view, [.top], padding: padding, priority: priority)
    }

    /// A convenience method to position the view to the left of another view.
    ///
    /// - parameters:
    ///     - view:        The 'UIView' to which the view will be aligned.
    ///     - padding:     The padding (or inset) to be applied to the constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignLeftOf(view: UIView, padding: CGFloat, priority: UILayoutPriority = UILayoutPriority(1000.0)) -> [NSLayoutConstraint] {
        return rsd_align([.trailing], .equal, to: view, [.leading], padding: padding, priority: priority)
    }

    ///A convenience method to position the view to the right of another view.
    ///
    /// - parameters:
    ///     - view:        The 'UIView' to which the view will be aligned.
    ///     - padding:     The padding (or inset) to be applied to the constraint.
    ///     - priority:    The layout priority of the constraint. By default, this is `1000`.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignRightOf(view: UIView, padding: CGFloat, priority: UILayoutPriority = UILayoutPriority(1000.0)) -> [NSLayoutConstraint] {
        return rsd_align([.leading], .equal, to: view, [.trailing], padding: padding, priority: priority)
    }
    
    /// A convenience method to create a NSLayoutConstraint for the purpose of aligning views within
    /// their 'superview'. As such, the view must have a 'superview'.
    ///
    /// - parameters:
    ///     - attributes:      An array of 'NSLayoutAttribute' to be applied to the 'firstItem' (self) in the constraints.
    ///     - relation:        The 'NSLayoutRelation' used for the constraint.
    ///     - view:            The 'UIView' that the view is being constrained to.
    ///     - toAttributes:    An array of 'NSLayoutAttribute' to be applied to the 'secondItem' (to View) in the constraints.
    ///     - padding:         The padding (or inset) to be applied to the constraints.
    ///     - priority:        The layout priority of the constraint. By default, this is `1000`.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_align(_ attributes: [NSLayoutConstraint.Attribute]!, _ relation: NSLayoutConstraint.Relation, to view:UIView!, _ toAttributes: [NSLayoutConstraint.Attribute]!, padding: CGFloat, priority: UILayoutPriority = UILayoutPriority(1000.0)) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return []
        }
        
        guard attributes.count > 0 else {
            assertionFailure("'attributes' must contain at least one 'NSLayoutAttribute'")
            return []
        }

        guard attributes.count == toAttributes.count else {
            assertionFailure("The number of 'attributes' must match the number of 'toAttributes'")
            return []
        }
        
        var constraints: [NSLayoutConstraint] = []
        attributes.forEach({
            
            let toAttribute = toAttributes[attributes.firstIndex(of: $0)!]
            let _padding = $0 == .trailing || $0 == .bottom ? -1 * padding : padding
            let constraint = NSLayoutConstraint(item: self,
                               attribute: $0,
                               relatedBy: relation,
                               toItem: view,
                               attribute: toAttribute,
                               multiplier: 1.0,
                               constant: _padding)
            constraint.priority = priority
            constraints.append(constraint)
            superview.addConstraint(constraint)
        })
        
        return constraints
    }

    /// A convenience method to center the view vertically within its 'superview'. The view must have
    /// a 'superview'.
    /// - parameter padding: The padding (or offset from center) to be applied to the constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignCenterVertical(padding: CGFloat) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return []
        }

        let constraint = NSLayoutConstraint(item: self,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: superview,
                                                   attribute: .centerY,
                                                   multiplier: 1.0,
                                                   constant: padding)
        superview.addConstraint(constraint)
        return [constraint]
    }
    
    /// A convenience method to center the view horizontally within it's 'superview'. The view must have
    /// a 'superview'.
    /// - parameter padding: The padding (or offset from center) to be applied to the constraint.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_alignCenterHorizontal(padding: CGFloat) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return []
        }

        let constraint = NSLayoutConstraint(item: self,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: superview,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: padding)
        superview.addConstraint(constraint)
        return [constraint]
    }
    
    /// A convenience method to constrain the view's width.
    ///
    /// - parameters:
    ///     - relation:    The 'NSLayoutRelation' used in the constraint.
    ///     - width:       A 'CGFloat' constant for the width.
    ///     - priority:    The layout priority of the constraint. By default, this is `1000`.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_makeWidth(_ relation: NSLayoutConstraint.Relation, _ width : CGFloat, priority: UILayoutPriority = UILayoutPriority(1000.0)) -> [NSLayoutConstraint] {
        let constraint = NSLayoutConstraint(item: self,
                                              attribute: .width,
                                              relatedBy: relation,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: width)
        self.addConstraint(constraint)
        return [constraint]
    }
    
    /// A convenience method to constrain the view's height.
    ///
    /// - parameters:
    ///     - relation:    The 'NSLayoutRelation' used in the constraint.
    ///     - height:       A 'CGFloat' constant for the height.
    ///     - priority:    The layout priority of the constraint. By default, this is `1000`.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_makeHeight(_ relation: NSLayoutConstraint.Relation, _ height : CGFloat, priority: UILayoutPriority = UILayoutPriority(1000.0)) -> [NSLayoutConstraint] {
        let constraint = NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: relation,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: height)
        self.addConstraint(constraint)
        return [constraint]
    }
    
    /// A convenience method to constraint the view's width relative to its superview.
    /// - parameter multiplier: A `CGFloat` constant for the constraint multiplier.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_makeWidthEqualToSuperview(multiplier: CGFloat) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return []
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: superview,
                                                    attribute: .width,
                                                    multiplier: multiplier,
                                                    constant: 0.0)
        superview.addConstraint(constraint)
        return [constraint]
    }
    
    /// A convenience method to constrain the view's height relative to its superview.
    /// - parameter multiplier: A `CGFloat` constant for the constraint multiplier.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_makeHeightEqualToSuperview(multiplier: CGFloat) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return []
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: superview,
                                            attribute: .height,
                                            multiplier: multiplier,
                                            constant: 0.0)
        superview.addConstraint(constraint)
        return [constraint]
    }
    
    /// A convenience method to constraint the view's width relative to its superview.
    /// - parameter multiplier: A `CGFloat` constant for the constraint multiplier.
    /// - returns: The layout constraints that were added.
    @discardableResult
    public func rsd_makeWidthEqualToView(_ view: UIView) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else {
            assertionFailure("Trying to set constraints without first setting superview")
            return []
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                                   attribute: .width,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .width,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        superview.addConstraint(constraint)
        return [constraint]
    }
    
    /// A convenience method to remove all the view's constraints that exist between it and its superview
    /// or its superview's other child views. It does NOT remove constraints between the view and its child views.
    public func rsd_removeSiblingAndAncestorConstraints() {
        for constraint in self.constraints {
            
            // iOS automatically creates special types of constraints, like for intrinsicContentSize,
            // and we don't want these. So test here for that and skip.
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
                // and we don't want to remove these. So test here for that and skip.
                if type(of: constraint) != NSLayoutConstraint.self {
                    continue
                }
                
                if constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self {
                    superview.removeConstraint(constraint)
                }
            }
        }
    }
    
    /// A convenience method to remove all the view's constraints that exist between it and its superview. It does
    /// NOT remove constraints between the view and its child views or constraints on itself (such as width and height).
    public func rsd_removeSuperviewConstraints() {
        guard let superview = superview else { return }
        for constraint in superview.constraints {
            
            // iOS automatically creates special types of constraints, like for intrinsicContentSize,
            // and we don't want these. So test here for that and skip.
            if type(of: constraint) != NSLayoutConstraint.self {
                continue
            }
            
            if constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self {
                superview.removeConstraint(constraint)
            }
        }
    }
    
    fileprivate func isChildView(item : AnyObject?) -> Bool {
        
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
    
    /// A convenience method to return a constraint on the view that matches the supplied constraint properties.
    /// If multiple constraints matching those properties are found, it returns the constraint with the highest priority.
    ///
    /// - parameters:
    ///     - attribute:   The 'NSLayoutAttribute' of the constaint to be returned.
    ///     - relation:    The 'NSLayoutRelation' of the constraint to be returned.
    /// - returns: The 'NSLayoutConstraint' matching the supplied constraint properties, if any.
    public func rsd_constraint(for attribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint? {
        
        var theConstraints = Array<NSLayoutConstraint>()
        
        // Iterate the view constraints and superview constraints. In most cases, we should have only one that has the 'firstItem',
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
