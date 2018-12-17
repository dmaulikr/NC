//
//  NPPinCodeField.swift
//  NPPinCodeField
//
//  Created by Nestor Popko on 2/14/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import UIKit

@IBDesignable
open class NPPinCodeField: UIControl, UITextInputTraits {
    
    /** The text entered by user. */
    @IBInspectable open var text: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** Length of the pin code */
    @IBInspectable open var length: Int = 4 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** Color of the dots. */
    @IBInspectable open var color: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** Diameter of the dots. */
    @IBInspectable open var diameter: CGFloat = 20.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** Spacing between the dots. */
    @IBInspectable open var spacing: CGFloat = 16.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** Line thickness. */
    @IBInspectable open var thickness: CGFloat = 2.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** Tells whether the pin code is empty. */
    open var isEmpty: Bool {
        return text.isEmpty
    }
    
    /** Tells whether all characters were entered. */
    open var isFilled: Bool {
        return text.characters.count == length
    }
    
    
    // MARK: UITextInputTraits protocol properties
    open var autocapitalizationType = UITextAutocapitalizationType.none
    open var autocorrectionType = UITextAutocorrectionType.no
    open var spellCheckingType = UITextSpellCheckingType.no
    open var keyboardType = UIKeyboardType.numberPad
    open var keyboardAppearance = UIKeyboardAppearance.default
    open var returnKeyType = UIReturnKeyType.done
    open var enablesReturnKeyAutomatically = true
    
    
    // MARK: initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    fileprivate func initialSetup() {
        addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
    }
    
    
    // MARK: UIResponder
    override open var canBecomeFirstResponder : Bool {
        return true
    }
    
    fileprivate var accessoryView: UIView?
    
    override open var inputAccessoryView: UIView? {
        get {
            return accessoryView
        }
        set(value) {
            accessoryView = value
        }
    }
    
    
    //MARK: UIView
    override open var intrinsicContentSize : CGSize {
        let width = CGFloat(length) * (diameter + spacing) - spacing + thickness
        let height = diameter + thickness
        return CGSize(width: width, height: height)
    }
    
    override open func draw(_ rect: CGRect) {
        var origin = CGPoint.zero
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(thickness)
        
        // Draw circles
        for i in 0..<length {
            
            let isDotFilled = i < text.characters.count
            if isDotFilled {
                let dotRect = CGRect(origin: origin, size: CGSize(width: diameter + thickness, height: diameter + thickness))
                context?.fillEllipse(in: dotRect)
            } else {
                let position = CGPoint(x: origin.x + thickness/2, y: origin.y + thickness/2)
                let dotRect = CGRect(origin: position, size: CGSize(width: diameter, height: diameter))
                context?.strokeEllipse(in: dotRect)
            }
            
            origin.x += diameter + spacing
        }
    }
    
}

// MARK: UIKeyInput
extension NPPinCodeField : UIKeyInput {
    
    public var hasText : Bool {
        return !text.isEmpty
    }
    
    public func insertText(_ textToInsert: String) {
        if self.isEnabled && text.characters.count + textToInsert.characters.count <= length {
            text.append(textToInsert)
            sendActions(for: .editingChanged)
        }
    }
    
    public func deleteBackward() {
        if self.isEnabled && !text.isEmpty {
            text.remove(at: text.characters.index(before: text.endIndex))
            sendActions(for: .editingChanged)
        }
    }
    
}
