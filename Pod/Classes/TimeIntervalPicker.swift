import UIKit

private let secondsInMinute = 60
private let minutesInHour = 60
private let secondsInHour = minutesInHour * secondsInMinute
private let hoursInDay = 24

internal class DigitsLabel: UIView {
    internal var text: String = "" { didSet { label.text = text } }
    
    fileprivate let textAlignment = NSTextAlignment.right
    fileprivate var label: UILabel!
    
    internal init(width: CGFloat, height: CGFloat, labelWidth: CGFloat, font: UIFont, textColor: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        createLabel(width: labelWidth, height: height, font: font, textColor: textColor)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createLabel(width: CGFloat, height: CGFloat, font: UIFont, textColor: UIColor) {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        addSubview(label)
        label.textAlignment = textAlignment
        label.adjustsFontSizeToFitWidth = false
        label.font = font
        label.textColor = textColor
    }
    
}

open class TimeIntervalPicker: UIControl, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Value access
    
    /// Value indicated by the picker in seconds
    open var countDownDuration: TimeInterval {
        get {
            let secondsFromHoursComponent = pickerView.selectedRow(inComponent: Components.hour.rawValue) * secondsInHour
            let secondsFromMinutesComponent = pickerView.selectedRow(inComponent: Components.minute.rawValue) % minutesInHour * secondsInMinute
            return TimeInterval(secondsFromHoursComponent + secondsFromMinutesComponent)
        }
        set(value) {
            let hours = Int(value) / secondsInHour
            let minutes = (Int(value) - hours * secondsInHour) / secondsInMinute
            
            pickerView.selectRow(hours % hoursInDay, inComponent: Components.hour.rawValue, animated: false)
            pickerView.selectRow(minuteRowsCount / 2 + minutes, inComponent: Components.minute.rawValue, animated: false)
        }
    }
    
    open var date: Date {
        get {
            var components = DateComponents()
            components.second = Int(countDownDuration)
            return Calendar.current.date(from: components)!
        }
        set(newDate) {
            let components = (Calendar.current as NSCalendar).components([.hour, .minute, .second], from: newDate)
            countDownDuration = TimeInterval(components.hour! * 3600 + components.minute! * 60 + components.second!)
        }
    }
    
    open func setDate(_ newDate: Date, animated: Bool) {
        // TODO: implement animation
        date = newDate
    }
    
    open var datePickerMode: UIDatePickerMode {
        get { return .countDownTimer }
        set(newMode) { assert(newMode == .countDownTimer) }
    }
    
    // MARK: Layout and geometry
    // The defaults values aim to resemble the look of UIDataPicker
    
    /// Width of a picker component
    open var componentWidth: CGFloat = 102
    
    /// Size of a label that shows hours/minutes digits within a component
    open var digitsLabelSize = CGSize(width: 30, height: 30)
    
    /// Font of labels that show hours/minutes digits within a component
    open var digitsLabelFont = UIFont.systemFont(ofSize: 23.5) {
        didSet { setNeedsDisplay() }
    }
    
    /// Text color of labels that show hours/minutes digits within a component
    open var digitsLabelTextColor = UIColor.black {
        didSet { setNeedsDisplay() }
    }
    
    /// Font of "hours" and "min" labels
    open var minutesHoursLabelFont = UIFont.boldSystemFont(ofSize: 17) {
        didSet {
            minutesFloatingLabel.font = minutesHoursLabelFont
            hoursFloatingLabel.font = minutesHoursLabelFont
        }
    }
    
    /// Text color of "hours" and "min" labels
    open var minutesHoursLabelTextColor = UIColor.black {
        didSet {
            minutesFloatingLabel.textColor = minutesHoursLabelTextColor
            hoursFloatingLabel.textColor = minutesHoursLabelTextColor
        }
    }
    
    // MARK: Private details
    
    fileprivate let componentsNumber = 2
    
    fileprivate enum Components: Int {
        case hour = 0
        case minute = 1
    }
    
    fileprivate let minuteRowsCount = minutesInHour * 1000
    fileprivate var pickerView: UIPickerView!
    fileprivate var hoursFloatingLabel: UILabel!
    fileprivate var minutesFloatingLabel: UILabel!
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createPickerView()
        createFloatingLabels()
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // Creates an illusion of an infinitly-looped minute: selector
        let middleMinutesRow = minuteRowsCount / 2
        pickerView.selectRow(middleMinutesRow, inComponent: Components.minute.rawValue, animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        createPickerView()
        createFloatingLabels()
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // Creates an illusion of an infinitly-looped minute: selector
        let middleMinutesRow = minuteRowsCount / 2
        pickerView.selectRow(middleMinutesRow, inComponent: Components.minute.rawValue, animated: false)
    }
    
    fileprivate func createPickerView() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickerView)
        
        // Fill the whole container:
        let width = NSLayoutConstraint(
            item: pickerView,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.width,
            multiplier: 1.0,
            constant: 0)
        
        let height = NSLayoutConstraint(
            item: pickerView,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.height,
            multiplier: 1.0,
            constant: 0)
        
        let top = NSLayoutConstraint(
            item: pickerView,
            attribute:NSLayoutAttribute.top,
            relatedBy:NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.top,
            multiplier: 1.0,
            constant: 0)
        
        let leading = NSLayoutConstraint(
            item: pickerView,
            attribute: NSLayoutAttribute.leading,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.leading,
            multiplier: 1.0,
            constant: 0)
        
        addConstraint(width)
        addConstraint(height)
        addConstraint(top)
        addConstraint(leading)
    }
    
    fileprivate func createFloatingLabels() {
        func createLabel(_ text: String) -> UILabel {
            let label = UILabel()
            label.font = self.minutesHoursLabelFont
            label.text = text
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isUserInteractionEnabled = false
            label.adjustsFontSizeToFitWidth = false
            label.sizeToFit()
            return label
        }
        
        hoursFloatingLabel = createLabel("hours")
        minutesFloatingLabel = createLabel("min")
        
        addSubview(hoursFloatingLabel)
        addSubview(minutesFloatingLabel)
    }
    
    override open func layoutSubviews() {
        func alignToBaselineOfSelectedRow(_ label: UILabel) {
            let pickerViewMiddleY = pickerView.frame.origin.y + (pickerView.frame.height / 2)
            let digitsBaseline = pickerViewMiddleY + (digitsLabelFont.capHeight / 2)
            label.frame.origin.y = digitsBaseline - label.font.lineHeight - label.font.descender
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
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        assert(pickerView == self.pickerView)
        return componentsNumber
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        assert(pickerView == self.pickerView)
        switch Components(rawValue: component)! {
        case Components.hour:
            return hoursInDay
        case Components.minute:
            return minuteRowsCount // a high number to create an illusion of an infinitly-looped selector
        }
    }
    
    // MARK: UIPickerViewDelegate methods
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        assert(pickerView == self.pickerView)
        sendActions(for: UIControlEvents.valueChanged)
    }
    
    open func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return componentWidth;
    }
    
    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: DigitsLabel = view is DigitsLabel ? view as! DigitsLabel : DigitsLabel(width: componentWidth, height: digitsLabelSize.height, labelWidth: digitsLabelSize.width, font: digitsLabelFont, textColor: digitsLabelTextColor)
        label.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)!
        return label
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        assert(pickerView == self.pickerView)
        switch Components(rawValue: component)! {
        case Components.hour:
            return row.description
        case Components.minute:
            return (row % minutesInHour).description
        }
    }
}
