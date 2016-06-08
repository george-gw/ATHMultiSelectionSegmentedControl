//
//  ATHMultiSelectionSegmentedControl.swift
//  ATHMultiSelectionSegmentedControl
//
//  Created by Athanasios Theodoridis on 06/06/16.
//
//

import Foundation
import UIKit

@IBDesignable public class MultiSelectionSegmentedControl: UIView {
    
    // MARK: - Private Properties
    private var _segmentButtons: [ATHMultiSelectionControlSegmentButton]?
    private var _items: [String]?
    
    // MARK: - Public Properties
    
    // MARK: Appearance
    @IBInspectable var cornerRadius: CGFloat = 3 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable override public var tintColor: UIColor! {
        didSet {
            layer.borderColor = tintColor.CGColor
        }
    }
    
    /// Returns the number of segments the receiver has. (read-only)
    public var numberOfSegments: Int {
        
        guard let segments = _segmentButtons where segments.count > 0 else {
            return 0
        }
        
        return segments.count
    }
    
    /**
     An array with the currently selected segment indices of the receiver.
    */
    public var selectedSegmentIndices: [Int] {
        
        get {

            guard let segments = _segmentButtons where segments.count > 0 else {
                return []
            }
            
            var indices: [Int] = []
            
            for (index, segmentButton) in segments.enumerate() {
                if segmentButton.isButtonSelected {
                    indices.append(index)
                }
            }
            
            return indices

        }
        
        set {
            
            guard let segments = _segmentButtons where segments.count > 0 else {
                return
            }
            
            _deselectAllSegments()

            for index in newValue {
                segments[index].setButtonSelected(true)
            }
            
        }
        
    }
   
    // MARK: - Initialisers
    
    /**
     Initialises and returns a multiple-selection segmented control having the given titles.
     
     - parameter items: An array of `String` objects with the segments titles
     - returns: An initialised `MultiSelectionSegmentedControl` object
    */
    public init(items: [String]?) {
        
        _items = items
        
        super.init(frame: CGRectZero)
        _configureAppearance()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        _configureAppearance()
    }
    
    // MARK: - Public Methods
    override public func layoutSubviews() {

        guard let items = _items where items.count > 0 else {
            return
        }
        
        if subviews.count == 0 {

            _segmentButtons = []
            
            for (index, segmentTitle) in items.enumerate() {
                
                let buttonWidth = frame.width / CGFloat(items.count)
                let buttonHeight = frame.height
                
                let buttonFrame = CGRectMake(CGFloat(index)*buttonWidth, 0, buttonWidth, buttonHeight)

                let button = ATHMultiSelectionControlSegmentButton(frame: buttonFrame)
                
                button.tintColor = tintColor
                button.backgroundColor = backgroundColor
                button.addTarget(self, action: #selector(self._didTouchUpInsideSegment(_:)), forControlEvents: .TouchUpInside)
                
                button.setTitle(segmentTitle, forState: .Normal)
                
                _segmentButtons?.append(button)
                
                self.addSubview(button)

            }
            
        }
    
    }
    
    // MARK: Managing Segment Content
    /**
     Sets the title of a segment.
     
     - parameter title: A string to display in the segments as its title.
     - parameter segment: An index number identifying a segment in the control. 
     It must be a number between 0 and the number of segments (numberOfSegments) minus 1; values exceeding this upper range are pinned to it.
    */
    public func setTitle(title: String, forSegmentAtIndex segment: Int) {
        
        guard let segments = _segmentButtons where segments.count > 0 && segment >= 0 else {
            return
        }
        
        let index = segment > segments.count - 1 ? segments.count - 1 : segment
        
        segments[index].setTitle(title, forState: .Normal)
        
    }
    
    /**
     Returns the title of the specified segment.
     
     - parameter segment: An index number identifying a segment in the control. It must be a number between 0 and the number of segments (numberOfSegments) 
     minus 1; values exceeding this upper range are pinned to it.
     - returns: Returns the string (title) assigned to the receiver as content.
    */
    public func titleForSegmentAtIndex(segment: Int) -> String? {
       
        guard let segments = _segmentButtons where segments.count > 0 && segment >= 0 else {
            return nil
        }
        
        let index = segment > segments.count - 1 ? segments.count - 1 : segment
        
        return segments[index].titleLabel?.text
        
    }
    
    // MARK: Managing Segment Behavior
    
    /**
     Enables the specified segment.
     
     - parameter enabled: `true` to enable the specified segment or `false` to disable the segment.
     By default all segments are enabled
    */
    public func setEnabled(enabled: Bool, forSegmentAtIndex segment: Int) {
        
    }
    
    /**
     Returns whether the indicated segment is enabled.
     
     - parameter segment: An index number identifying a segment in the control. It must be a number between 0 and the number of segments (numberOfSegments) minus 1; 
     values exceeding this upper range are pinned to it.
     
     - returns: `true` if the given segment is enabled and `false` if the segment is disabled. By default, segments are enabled.
    */
    public func isEnabledForSegmentAtIndex(segment: Int) -> Bool {
        return true
    }
    
    // MARK: Managing Segments
    public func insertSegmentsWithTitles(titles: [String]) {
        
        _items = titles
        _configureAppearance()
        
        self.setNeedsLayout()
    
    }
    
    /**
     Inserts a segment at a specific position in the receiver and gives it a title as content.
     
     - parameter title: A string to use as the segment’s title.
     - parameter segment: An index number identifying a segment in the control. The new segment is inserted just before the designated one.
     - parameter animated: true if the insertion of the new segment should be animated, otherwise false.
    */
    public func insertSegmentWithTitle(title: String, atIndex segment: Int, animated: Bool) {
        
        guard segment >= 0 else {
            return
        }
        
        let index = segment
        
        if _items == nil { _items = [] }
        if _segmentButtons == nil { _segmentButtons = [] }

        if index > _items!.count {
            _items!.append(title)
        } else {
            _items!.insert(title, atIndex: index)
        }
        
        let button = ATHMultiSelectionControlSegmentButton(frame: CGRectMake(self.frame.width, 0, 0, self.frame.height))
       
        button.tintColor = tintColor
        button.backgroundColor = backgroundColor
        button.addTarget(self, action: #selector(self._didTouchUpInsideSegment(_:)), forControlEvents: .TouchUpInside)
        
        button.setTitle(title, forState: .Normal)
        
        addSubview(button)
        
        if index > _segmentButtons!.count {
            _segmentButtons?.append(button)
        } else {
            _segmentButtons!.insert(button, atIndex: index)
        }
        
        let duration = animated ? 0.35 : 0

        UIView.animateWithDuration(duration) {

            for (index, segment) in self._segmentButtons!.enumerate() {
                
                let buttonWidth = self.frame.width / CGFloat(self._items!.count)
                let buttonHeight = self.frame.height
                
                let buttonFrame = CGRectMake(CGFloat(index)*buttonWidth, 0, buttonWidth, buttonHeight)
                segment.frame = buttonFrame
                
            }

        }
        
    }
    
    /**
     Removes the specified segment from the receiver, optionally animating the transition.
     
     - parameter segment: An index number identifying a segment in the control. It must be a number between 0 and the number of segments (numberOfSegments) minus 1; 
     values exceeding this upper range are pinned to it.
     - parameter animated: `true` if the removal of the new segment should be animated, otherwise `false`.
    */
    public func removeSegmentAtIndex(segment: Int, animated: Bool) {
       
        guard var segments = _segmentButtons where segments.count > 0 && segment > 0 else {
            return
        }
        
        // if segment is out of range pin it
        let index = segment > segments.count - 1 ? segments.count - 1 : segment
        
        _items?.removeAtIndex(index)
        
        segments[index].removeFromSuperview()
        segments.removeAtIndex(index)
        
        let duration = animated ? 0.35 : 0
        
        UIView.animateWithDuration(duration) {
            for (index, _) in segments.enumerate() {
               
                let buttonWidth = self.frame.width / CGFloat(segments.count)
                let buttonHeight = self.frame.height
                
                segments[index].frame = CGRectMake(CGFloat(index)*buttonWidth, 0, buttonWidth, buttonHeight)
            
            }
        }

    }
    
    /**
     Removes all segments of the receiver.
    */
    public func removeAllSegments() {
       
        layer.borderWidth = 0

        _segmentButtons?.forEach { segment in
            segment.removeFromSuperview()
        }
        _segmentButtons?.removeAll()
        _items?.removeAll()
    
    }
    
    // MARK: - Private Methods
    private func _configureAppearance() {
        
        backgroundColor = UIColor.clearColor()
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = tintColor.CGColor
    
    }
    
    @objc private func _didTouchUpInsideSegment(segmentButton: ATHMultiSelectionControlSegmentButton) {
        
        guard let segmentButtons = _segmentButtons where segmentButtons.count > 0 else {
            return
        }
        
        if segmentButton.isButtonSelected {
            segmentButton.setButtonSelected(false)
        } else {
            segmentButton.setButtonSelected(true)
        }
        
    }
    
    private func _deselectAllSegments() {
        
        guard let segments = _segmentButtons where segments.count > 0 else {
            return
        }
        
        segments.forEach { segment in
            segment.setButtonSelected(false)
        }
        
    }
}