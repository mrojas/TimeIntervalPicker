//
//  Copyright (c) 2015 Dawid Drechny
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

private let secondsInMinute = 3600.0

internal class DigitsLabel: UIView {
    internal var text: String = "" { didSet { label.text = text } }
    
    private let textAlignment = NSTextAlignment.Right
    private var label: UILabel!
    
    internal init(width: CGFloat, height: CGFloat, labelWidth: CGFloat, font: UIFont) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        createLabel(width: labelWidth, height: height, font: font)
    }
    
    internal required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLabel(#width: CGFloat, height: CGFloat, font: UIFont) {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        addSubview(label)
        label.textAlignment = textAlignment
        label.adjustsFontSizeToFitWidth = false
        label.font = font
    }
    
}

@objc(DPTimeIntervalPicker)
public class TimeIntervalPicker: UIControl, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Value access
    
    /// Value indicated by the picker in seconds
    public var timeInterval: NSTimeInterval {
        get {
            let secondsFromHoursComponent = Double(pickerView.selectedRowInComponent(Components.Hour.rawValue)) * secondsInMinute
            let secondsFromMinutesComponent = Double(pickerView.selectedRowInComponent(Components.Minute.rawValue) % 60 * 60)
            return secondsFromHoursComponent + secondsFromMinutesComponent
        }
        set(value) {
            let hours = Int(value / secondsInMinute)
            let minutes = Int(value % secondsInMinute)
            
            pickerView.selectRow(hours, inComponent: Components.Hour.rawValue, animated: false)
            pickerView.selectRow(minuteRowsCount / 2 + minutes, inComponent: Components.Minute.rawValue, animated: false)
        }
    }
    
    // MARK: Layout and geometry
    // The defaults values aim to resemble the look of UIDataPicker
    
    /// Width of a picker component
    public let componentWidth: CGFloat = 102
    
    /// Size of a label that shows hours/minutes digits within a component
    public let digitsLabelSize = CGSize(width: 26, height: 30)
    
    /// Font of a labels that show hours/minutes digits within a component
    public let digitsLabelFont = UIFont.systemFontOfSize(23.5)

    /// Font for "hours" and "min" labels
    public let minHoursFloatingLabelFont = UIFont(name: "HelveticaNeue-Medium", size: 17) ??
        UIFont.systemFontOfSize(17)
    
    // MARK: Private details
    
    private let componentsNumber = 2
    
    private enum Components: Int {
        case Hour = 0
        case Minute = 1
    }
    
    private let minuteRowsCount = 60 * 1000
    private var pickerView: UIPickerView!
    private var hoursFloatingLabel: UILabel!
    private var minutesFloatingLabel: UILabel!
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createPickerView()
        createFloatingLabels()
        
        // Creates an illusion of an infinitly-looped minute: selector
        let middleMinutesRow = minuteRowsCount / 2
        pickerView.selectRow(middleMinutesRow, inComponent: Components.Minute.rawValue, animated: false)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createPickerView()
        createFloatingLabels()
        
        // Creates an illusion of an infinitly-looped minute: selector
        let middleMinutesRow = minuteRowsCount / 2
        pickerView.selectRow(middleMinutesRow, inComponent: Components.Minute.rawValue, animated: false)
    }
    
    private func createPickerView() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(pickerView)
        
        // Fill the whole container:
        var width = NSLayoutConstraint(
            item: pickerView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 0)
        
        var height = NSLayoutConstraint(
            item: pickerView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1.0,
            constant: 0)
        
        var top = NSLayoutConstraint(
            item: pickerView,
            attribute:NSLayoutAttribute.Top,
            relatedBy:NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 0)
        
        var leading = NSLayoutConstraint(
            item: pickerView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: 0)
        
        addConstraint(width)
        addConstraint(height)
        addConstraint(top)
        addConstraint(leading)
    }
    
    private func createFloatingLabels() {
        func createLabel(text: String) -> UILabel {
            var label = UILabel()
            label.font = minHoursFloatingLabelFont
            label.text = text
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            label.userInteractionEnabled = false
            label.adjustsFontSizeToFitWidth = false
            label.sizeToFit()
            return label
        }
        
        hoursFloatingLabel = createLabel("hours")
        minutesFloatingLabel = createLabel("min")
        
        addSubview(hoursFloatingLabel)
        addSubview(minutesFloatingLabel)
    }
    
    override public func layoutSubviews() {
        func alignToBaselineOfSelectedRow(label: UILabel) {
            let rowBaseline = pickerView.frame.origin.y + (pickerView.frame.height / 2) - digitsLabelFont.descender
            label.frame.origin.y = rowBaseline - label.frame.size.height - label.font.descender
        }
        
        super.layoutSubviews()
        alignToBaselineOfSelectedRow(hoursFloatingLabel)
        alignToBaselineOfSelectedRow(minutesFloatingLabel)
        
        let componentViewLabelMargin: CGFloat = 4
        let componentSpace: CGFloat = 5
        
        let componentsSeparatorX = pickerView.frame.origin.x + (pickerView.frame.size.width / 2)
        let hoursComponentX = componentsSeparatorX - componentWidth
        hoursFloatingLabel.frame.origin.x = hoursComponentX + digitsLabelSize.width + componentViewLabelMargin
        
        let minutesComponentX = componentsSeparatorX + componentSpace
        minutesFloatingLabel.frame.origin.x = minutesComponentX + digitsLabelSize.width + componentViewLabelMargin
    }
    
    // MARK: UIPickerViewDataSource methods
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        assert(pickerView == self.pickerView)
        return componentsNumber
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        assert(pickerView == self.pickerView)
        switch Components(rawValue: component)! {
        case Components.Hour:
            return 24
        case Components.Minute:
            return minuteRowsCount // a high number to create an illusion of an infinitly-looped selector
        }
    }
    
    // MARK: UIPickerViewDelegate methods
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        assert(pickerView == self.pickerView)
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    public func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return componentWidth;
    }
    
    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var x = DigitsLabel(width: componentWidth, height: digitsLabelSize.height, labelWidth: digitsLabelSize.width, font: digitsLabelFont)
        
        var label: DigitsLabel = view is DigitsLabel ? view as DigitsLabel : DigitsLabel(width: componentWidth, height: digitsLabelSize.height, labelWidth: digitsLabelSize.width, font: digitsLabelFont)
        label.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        return label
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        assert(pickerView == self.pickerView)
        switch Components(rawValue: component)! {
        case Components.Hour:
            return row.description
        case Components.Minute:
            return (row % 60).description
        }
    }
}