//
//  RSDGenericStepViewController.swift
//  ResearchSuiteUI
//
//  Created by Josh Bruhin on 5/16/17.
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

/**
 RSDGenericStepViewController: A custom instance of RSDStepViewController. Its subviews include a UITableView,
 an RSDStepNavigationView, which may or may not be 'embedded' in the tableView as its footerView, and
 an RSDStepHeaderView, which is 'embedded' in the tableView as its headerView.
 
 This class populates the contents and properties of the headerView and navigationView based on the associated `RSDStep`,
 which is expected to be set before presenting the view controller. This is done in setupViews(), which is also where
 the tableView is created.
 
 An instance of RSDGenericStepDataSource is created upon init() and is the UITableViewDataSource. It's based on
 ORKStep and is assigned to property tableData. The tableData also keeps track of answers that are derived
 from the user's input and it provides the RSDResult to our delegate.
 
 This class is responsible for acquiring input from the user, validating it, and supplying it as an answer to
 to the model (tableData). This is typically done in delegate call backs from various input views, such as
 UITableView (didSelectRow) or UITextField (valueDidChange or shouldChangeCharactersInRange).
 
 Some RSDSteps, such as `RSDFactory.StepType.instruction`, requires no user input (and have no input fields). These steps
 will result in tableData that has no sections and, therefore, no rows. So the tableView will simply have a
 headerView, no rows, and a footerView.
 
 To customize the view elements, subclasses should override the setupViews() method. This will allow
 the use of any custom element (of the appropriate type) to be used instead of the default instances. To just
 customize the appearance or properties of the headerView and navigationView, subclasses can simply override
 setupHeaderView() and setupNavigationView().
 */
open class RSDGenericStepViewController: RSDStepViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, RSDFormStepDataSourceDelegate {

    private let kMainViewBottomMargin: CGFloat = 30.0
    private let kDefaultRowHeight: CGFloat = 75.0
    private let kFormStepMinHeaderHeight: CGFloat = 180
    
    private var navigationViewHeight: CGFloat = 0.0
    private var savedVerticalScrollOffet: CGFloat = 0.0
    private let useStickyNavView = RSDGenericStepUIConfig.shouldUseStickyNavigationView()
    
    private let kEstimatedRowHeight: CGFloat = 100

    open var tableData: RSDFormStepDataSource?
    
    @IBOutlet open var tableView: UITableView!
    
    private var activeTextField: UITextField?
    
    var tableViewInsetBottom: CGFloat {
        get {
            return useStickyNavView ? navigationViewHeight + constants().mainViewBottomMargin : constants().mainViewBottomMargin
        }
    }
    
    /**
     Class method to determine if this view controller class supports the provided step's form input fields. This will vary
     based on the `RSDFormDataType` and `RSDFormUIHint' for each of the input fields in the step.
     */
    open class func doesSupportInputFields(in inputFields: [RSDInputField]) -> Bool {

        for item in inputFields {
            switch item.dataType {
            case .custom(_, _):
                // Custom data types are not supported
                return false
                
            case .collection(let collectionType, _):
                switch collectionType {
                case .multipleComponent:
                    return false // TODO: syoung 10/18/2018 Implement support for multiple component
                default:
                    if let choiceInputField = item as? RSDChoiceInputField {
                        for choice in choiceInputField.choices {
                            if choice.hasIcon {
                                return false // TODO: syoung 10/18/2018 Implement support for image choices
                            }
                        }
                    }
                    else {
                        // If there aren't choices or a range, then cannot create the picker
                        return item.range != nil
                    }
                }
                
            case .measurement(_, _):
                return false // TODO: syoung 10/18/2018 Implement support for measurements
            
            default:
                break
            }
        }
        
        // all input fields are supported
        return true
    }
    
    /**
     Static method to determine if this view controller class supports the provided step.
    */
    open class func doesSupport(_ step: RSDStep) -> Bool {
        // Only UI steps are supported
        guard let _ = step as? RSDUIStep else { return false }
        
        // If this is a form step then need to look to see if there is custom handling
        if let formStep = step as? RSDFormUIStep {
            return doesSupportInputFields(in: formStep.inputFields)
        } else {
            return true
        }
    }
    
    
    // MARK: View lifecycle
    
    /**
     Should the view controller tableview include a header? If `true`, then by default, a `RSDStepHeaderView` will be added in `viewDidLoad()`.
     */
    open var shouldShowHeader: Bool = true
    
    /**
     Should the view controller tableview include a footer? If `false`, then by default, a `RSDStepNavigationView` will be added in `viewDidLoad()`.
     */
    open var shouldShowFooter: Bool = true
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.sectionHeaderHeight = 0.0
            tableView.estimatedSectionHeaderHeight = 0.0
            tableView.separatorStyle = .none
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = constants().defaultRowHeight
            
            view.addSubview(tableView)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.alignAllToSuperview(padding: 0)
        }
        if self.navigationHeader == nil && shouldShowHeader {
            navigationHeader = RSDGenericStepUIConfig.instantiateHeaderView()
            tableView.tableHeaderView = navigationHeader
        }
        if self.navigationFooter == nil && shouldShowFooter {
            navigationFooter = RSDGenericStepUIConfig.instantiatNavigationView()
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup the view to require layout
        self.view.setNeedsLayout()
        
        // register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        // Set up the model and view
        setupModel()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: syoung 10/18/2017 Look into other ways of delaying the first responder call.
        
        // If the first row in our tableView has a textField, we want it to become the first responder automatically.
        // We must do this after a delay because of how RSDTaskViewController presents these step view controllers,
        // which is done via a UIPageViewController. Without the delay, the textField will NOT become the firstResponder. 
        // Use a 0.3 seconds delay to give transitions and animations plenty of time to complete.
        
        let delay = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.checkForFirstCellTextField()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // un-register for keyboard notifications
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // Dismiss all textField's keyboard
        tableView?.endEditing(false)
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // if we have no tableView or navigationView, then nothing to do
        guard let tableView = tableView, let navigationView = self.navigationFooter else {
            return
        }
        
        // need to save height of our nav view so it can be used to calculate the bottom inset (margin)
        navigationViewHeight = navigationView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        let totalHeight = tableView.contentSize.height + tableView.contentInset.top + navigationViewHeight
        let contentSizeExceedsTableHeight = totalHeight > tableView.frame.size.height
        
        if !useStickyNavView && contentSizeExceedsTableHeight {
            
            // put the navView in the tableView as it's footerView
            // we need to add the view as the footer view, get it's height, reset the views frame,
            // then add as the table's footerView again. This is because the view height is dynamic
            // and the tableView won't adjust it's height dynamically otherwise
            
            navigationView.translatesAutoresizingMaskIntoConstraints = true
            tableView.tableFooterView = navigationView
            navigationView.frame = CGRect(x: 0, y: 0, width: navigationView.frame.size.width, height: navigationViewHeight)
            tableView.tableFooterView = navigationView
        }
        else {
            
            // pin navView to bottom of screen
            navigationView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(navigationView)
            navigationView.alignToSuperview([.leading, .trailing, .bottom], padding: 0.0)
            
            // we also need to add an invisible view as the table's footerview so we don't get
            // a bunch of empty rows
            
            let footerView = UIView()
            footerView.backgroundColor = UIColor.clear
            tableView.tableFooterView = footerView
            
            // show the shadow only if our content size is big enough for content to underlap the shadow
            navigationView.shouldShowShadow = contentSizeExceedsTableHeight
        }
        
        // set the tableView bottom inset
        var inset = tableView.contentInset
        inset.bottom = tableViewInsetBottom
        tableView.contentInset = inset
    }
    
    func checkForFirstCellTextField() {
        
        // Don't do anything if viewWillDisappear was called
        guard isVisible else { return }
        
        // If the first row in our tableView has a textField, we want it to become the first responder
        // automatically. So, first see if our first row has a textField.
        guard let tableView = tableView,
            let firstCell = tableView.visibleCells.first,
            let textFieldCell = firstCell as? RSDStepTextFieldCell else {
                return
        }
        
        // Our first row is a textField, so tell it to become firstResponder.
        textFieldCell.textField.becomeFirstResponder()
    }
    
    // MARK: Model setup
    
    open class var supportedUIHints: Set<RSDFormUIHint> {
        return [.standard(.list), .standard(.textfield), .standard(.picker)]
    }
    
    /**
     Creates and assigns a new instance of our model, RSDGenericStepDataSource.
     @param   result   The result that is provided upon init()
     */
    open func setupModel() {
        tableData = RSDFormStepDataSourceObject(step: self.step, taskPath: self.taskController.taskPath, supportedHints: type(of: self).supportedUIHints)
        tableData?.delegate = self
    }
    
    // MARK: View setup
    
    open override func setupHeader(_ header: RSDNavigationHeaderView) {
        super.setupHeader(header)
        
        if formStep?.inputFields.count ?? 0 > 0 {
            // We have a minimum height for ORKFormSteps because these step usually have just a title and
            // description and the design generally calls for quite a bit of margin above and below the labels.
            // So we set a minimum size
            header.minumumHeight = constants().formStepMinHeaderHeight
        }
        
        if header === tableView.tableHeaderView {
            // to get the tableView to size the headerView properly, we have to get the headerView height
            // and manually set the frame with that height. Do so only if the header is actually the
            // tableview's header and not a custom header.
            let headerHeight = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            header.frame = CGRect(x: 0, y: 0, width: header.frame.size.width, height: headerHeight)
            tableView?.tableHeaderView = header
        }
    }
        
    /**
     Auto layout constraint constants for the margin used at the bottom of the main view
     and the default tableView row height.
     @return    A struct with the layout constants
     */
    open func constants() -> (mainViewBottomMargin: CGFloat, defaultRowHeight: CGFloat, formStepMinHeaderHeight: CGFloat) {
        
        // we only need some bottom margin if we have any table data (rows), otherwise, the bottom
        // margin built into the headerView is enough
        return (tableView.numberOfSections > 0 ? kMainViewBottomMargin : 0.0,
                kDefaultRowHeight,
                kFormStepMinHeaderHeight)
    }
    
    /**
     Specifies whether the next button should be enabled based on the validity of the answers for
     all form items.
     
     @return    A Bool indicating if next button should be enabled
     */
    override open var isForwardEnabled: Bool {
        return (tableData?.allAnswersValid() ?? true) && super.isForwardEnabled
    }
    
    // MARK: Actions
    
    override open func goForward() {
        // If there isn't an active text field then just go forward
        guard let textField = activeTextField else {
            super.goForward()
            return
        }

        // Otherwise validate the textfield and cancel the goForward if invalid
        guard validateAndSave(textField: textField)
            else {
                return
        }
        
        // If the textfield is valid, check to see if there is another item that is below this one
        if let indexPath = indexPath(for: textField),
            let nextItem = tableData?.nextItem(after: indexPath),
            let nextPath = tableData?.indexPath(for: nextItem) {
            
            // need to get our cell and tell its textField to become first responder
            // but do *not* go forward.
            if let customCell = tableView.cellForRow(at: nextPath) as? RSDStepTextFieldCell {
                customCell.textField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else {
            // Finally, continue if this is the last field
            super.goForward()
        }
    }
    
    override open func goBack() {
        activeTextField = nil
        goBack()
    }
    
    override open func skipForward() {
        activeTextField = nil
        skipForward()
    }
    
    /**
     The 'RSDStepTextFieldCell' to use. Override to provide a custom instances of this class.
     @param     reuseIdentifier     A String representing the reuse identifier of the cell
     @return                        The 'RSDStepTextFieldCell' class to use
     */
    open func textFieldCell(reuseIdentifier: String) -> RSDStepTextFieldCell {
        
        // if we have just one form item, like for 'externalID' or 'yourAge', we use the 'featured'
        // textField cell, which centers the field in the view and uses a large font. Otherwise, we
        // use the base class
        if formStep?.inputFields.count ?? 0 > 1 {
            return RSDStepTextFieldCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        else {
            return RSDStepTextFieldFeaturedCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }
    
    
    // MARK: UITableView Datasource
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.sections[section].rowCount() ?? 0
    }
    open func numberOfSections(in tableView: UITableView) -> Int {
        return tableData?.sections.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "\(indexPath.section)-\(indexPath.row)"
        let cell = dequeueCell(in: tableView, at: indexPath) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
        configure(cell: cell, in: tableView, at: indexPath)
        return cell
    }
    
    open func dequeueCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell? {
        let identifier = "\(indexPath.section)-\(indexPath.row)"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        guard cell == nil,
            let tableItem = tableData?.tableItem(at: indexPath)
            else {
                return cell
        }
        
        if tableItem is RSDTextTableItem {
            return RSDTextLabelCell(style: .default, reuseIdentifier: identifier)
        } else if tableItem is RSDImageTableItem {
            return RSDImageViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        guard let itemGroup = tableData?.itemGroup(at: indexPath) as? RSDInputFieldTableItemGroup,
            let uiHintType = itemGroup.uiHint.standardType
            else {
                return cell
        }
        
        if tableItem is RSDChoiceTableItem {
            return RSDStepChoiceCell(style: .default, reuseIdentifier: identifier)
        }
        else if uiHintType == .textfield || uiHintType == .picker {
            
            // Create a textField based cell
            let fieldCell = textFieldCell(reuseIdentifier: identifier)
            fieldCell.textField.delegate = self
            fieldCell.selectionStyle = .none
            
            // setup our keyboard accessory view, which is a standard navigationView
            let navView = RSDGenericStepUIConfig.instantiatNavigationView()
            setupFooter(navView)
            
            // using auto layout to constrain the navView to fill its superview after adding it to the textfield
            // as its inputAccessoryView doesn't work for whatever reason. So we get the computed height from the
            // navView and manually set its frame before assigning it to the text field
            
            let navHeight = navView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            let navWidth = UIScreen.main.bounds.size.width
            navView.frame = CGRect(x: 0, y: 0, width: navWidth, height: navHeight)
            
            fieldCell.textField.inputAccessoryView = navView
            
            // use the keyboard properties defined for this step
            if let textAnswerFormat = itemGroup.textFieldOptions {
                fieldCell.textField.keyboardType = textAnswerFormat.keyboardType
                fieldCell.textField.isSecureTextEntry = textAnswerFormat.isSecureTextEntry
                fieldCell.textField.autocapitalizationType = textAnswerFormat.autocapitalizationType
                fieldCell.textField.autocorrectionType = textAnswerFormat.autocorrectionType
                fieldCell.textField.spellCheckingType = textAnswerFormat.spellCheckingType
            }
            
            // TODO: syoung 10/23/2017 Add support for picker views
            
            return fieldCell
        }
        else {
            assertionFailure("tableItem \(String(describing: tableItem)) is not supported. indexPath=\(indexPath)")
            return nil
        }
    }
    
    func configure(cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {

        if let labelCell = cell as? RSDTextLabelCell {
            guard let item = tableData?.tableItem(at: indexPath) as? RSDTextTableItem
                else {
                    return
            }
            labelCell.label.text = item.text
        }
        else if let imageCell = cell as? RSDImageViewCell {
            guard let item = tableData?.tableItem(at: indexPath) as? RSDImageTableItem
                else {
                    return
            }
            imageCell.imageLoader = item
        }
        else if let textFieldCell = cell as? RSDStepTextFieldCell {
            guard let itemGroup = tableData?.itemGroup(at: indexPath) as? RSDInputFieldTableItemGroup
                else {
                    return
            }
            
            if let customField = textFieldCell.textField as? RSDStepTextField {
                customField.indexPath = indexPath
            }
            
            // if we have an answer, populate the text field
            if itemGroup.isAnswerValid {
                textFieldCell.textField.text = itemGroup.answerText
            }
            
            if let text = itemGroup.inputField.prompt {
                // populate the field label
                textFieldCell.fieldLabel.text = text
            }
            
            if let placeholder = itemGroup.inputField.placeholderText {
                // populate the text field placeholder label
                textFieldCell.setPlaceholderText(placeholder)
            }
        }
        else if let choiceCell = cell as? RSDStepChoiceCell {
            guard let tableItem = tableData?.tableItem(at: indexPath) as? RSDChoiceTableItem
                else {
                    return
            }
            
            choiceCell.choiceValueLabel.text = tableItem.choice.text
            choiceCell.isSelected = tableItem.selected
        }
    }
    
    
    // MARK: UITableView Delegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableData = self.tableData else { return }
        
        if let item = tableData.tableItem(at: indexPath) as? RSDChoiceTableItem {
            do {
                try tableData.selectAnswer(item: item, at: indexPath)
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                
                // Dismiss other textField's keyboard
                tableView.endEditing(false)
                
            } catch let err {
                assertionFailure("Unexpected error while selecting table row \(indexPath). \(err)")
            }
        }
        else {
            
            // need to get our cell and tell its textField to become first responder
            if let customCell = tableView.cellForRow(at: indexPath) as? RSDStepTextFieldCell {
                customCell.textField.becomeFirstResponder()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    // MARK: UITextField delegate

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        scroll(to: textField)
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.canResignFirstResponder {
            textField.resignFirstResponder()
        }
        return false
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Always enable the next button once something has been entered
        (textField.inputAccessoryView as? RSDStepNavigationView)?.nextButton?.isEnabled = true
        
        return true
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        
        // clear the activeTextField if this is that textField
        if textField === activeTextField {
            // clear the active state
            activeTextField = nil
            validateAndSave(textField: textField)
        }
        
        // scroll back to our saved offset
        tableView.setContentOffset(CGPoint(x: 0.0, y: savedVerticalScrollOffet), animated: true)
    }
    
    public func indexPath(for textField: UITextField?) -> IndexPath? {
        guard let customTextField = textField as? RSDStepTextField,
            let indexPath = customTextField.indexPath
            else {
                return nil
        }
        return indexPath
    }

    public func itemGroup(for textField: UITextField?) -> RSDInputFieldTableItemGroup? {
        guard let customTextField = textField as? RSDStepTextField,
            let indexPath = customTextField.indexPath,
            let itemGroup = tableData?.itemGroup(at: indexPath) as? RSDInputFieldTableItemGroup
            else {
                return nil
        }
        return itemGroup
    }
    
    @discardableResult
    public func validateAndSave(textField: UITextField) -> Bool {

        // If this is a custom text field then update the text to match the
        // actual value stored in case it differs from the text entered.
        let success = saveAnswer(textField: textField)
        if !success, let itemGroup = itemGroup(for: textField) {
            textField.text = itemGroup.answerText
        }
        return success
    }
    
    @discardableResult
    open func saveAnswer(textField: UITextField) -> Bool {
        guard let customTextField = textField as? RSDStepTextField,
            let indexPath = customTextField.indexPath else {
                return false
        }
        return saveAnswer(newValue: textField.text ?? NSNull(), at: indexPath)
    }
    
    @discardableResult
    open func saveAnswer(newValue: Any, at indexPath: IndexPath) -> Bool {
        guard let tableData = self.tableData else {
            return true
        }
        
        // Try to set the answer to the new answer. This will validate the answer and call `answersDidChange`.
        do {
            try tableData.saveAnswer(newValue, at: indexPath)
            return true
        } catch let err {
            var message: String?
            var context: RSDInputFieldError.Context?
            if let error = err as? RSDInputFieldError {
                context = error.context
                switch error {
                case .invalidFormatter(let formatter, _):
                    if let _ = formatter as? NumberFormatter {
                        message = Localization.localizedString("VALIDATION_ERROR_NUMBER")
                    }
                    else if let dateFormatter = formatter as? DateFormatter {
                        message = Localization.localizedStringWithFormatKey("VALIDATION_ERROR_DATE_%@", dateFormatter.dateFormat)
                    }
                case .invalidRegex(let msg, _):
                    message = msg
                case .exceedsMaxLength(let maxLen, _):
                    message = Localization.localizedStringWithFormatKey("VALIDATION_ERROR_MAXLEN_%@", maxLen)
                case .lessThanMinimumDate(let date, _):
                    message = Localization.localizedStringWithFormatKey("VALIDATION_ERROR_MIN_DATE_%@", date as NSDate)
                case .greaterThanMaximumDate(let date, _):
                    message = Localization.localizedStringWithFormatKey("VALIDATION_ERROR_MAX_DATE_%@", date as NSDate)
                case .lessThanMinimumValue(let num, _):
                    message = Localization.localizedStringWithFormatKey("VALIDATION_ERROR_MIN_NUMBER_%@", num as NSNumber)
                case .greaterThanMaximumValue(let num, _):
                    message = Localization.localizedStringWithFormatKey("VALIDATION_ERROR_MAX_NUMBER_%@", num as NSNumber)
                case .invalidType(_):
                    assertionFailure("Unhandled error when saving text entry: \(err)")
                }
            } else {
                assertionFailure("Unhandled error when saving text entry: \(err)")
            }
            self.showValidationError(title: nil, message: message, context: context, at: indexPath)
        }
        
        return false
    }
    
    open func showValidationError(title: String?, message: String?, context: RSDInputFieldError.Context?, at indexPath: IndexPath) {
        let invalidMessage = (tableData?.itemGroup(at: indexPath) as? RSDInputFieldTableItemGroup)?.textFieldOptions?.invalidMessage
        self.showAlertWithOk(title: nil,
                             message: invalidMessage ?? message ?? Localization.localizedString("VALIDATION_ERROR_GENERIC"),
                             actionHandler: nil)
    }

    func scroll(to textField: UITextField?) {
        guard let customField = textField as? RSDStepTextField, let indexPath = customField.indexPath else { return }
        savedVerticalScrollOffet = tableView.contentOffset.y
        tableView?.scrollToRow(at: indexPath, at: .middle, animated: true)
    }

    
    // MARK: UIScrollView delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateShadows()
    }
    
    open func updateShadows() {
        guard let footer = self.navigationFooter, useStickyNavView else { return }
        let maxY = tableView.contentSize.height - (tableView.bounds.size.height - footer.bounds.size.height)
        footer.shouldShowShadow = (tableView.contentOffset.y < maxY)
    }

    
    // MARK: KeyboardNotification delegate
    
    @objc func keyboardNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        if endFrame.origin.y >= UIScreen.main.bounds.size.height {
            // set the tableView bottom inset to default
            var inset = tableView.contentInset
            inset.bottom = tableViewInsetBottom
            tableView.contentInset = inset
        }
        else {
            // change tableView contentInset bottom to be equal to the height of the keyboard plue
            // our constant for the bottom margin
            var contentInset = tableView.contentInset
            contentInset.bottom = endFrame.size.height + constants().mainViewBottomMargin
            tableView.contentInset = contentInset
        }
        
        UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: {
            // animate our updates
            self.view.layoutIfNeeded()
        }) { (_) in
            if self.isVisible, let textfield = self.activeTextField {
                // need to scroll the tableView to the active textField since our tableView bounds have changed
                self.scroll(to: textfield)
            }
        }
    }
    
    // MARK: RSDGenericStepDataSource delegate
    
    public func answersDidChange(in section: Int) {
        // update enabled state of next button
        navigationFooter?.nextButton?.isEnabled = self.isForwardEnabled
    }
}

public class RSDGenericStepUIConfig: NSObject {
}

extension RSDGenericStepUIConfig {
    
    /**
     Defines whether or not a drop shadow is shown below the top edge of the navigation view. The shadow
     is only shown if content is underlapping the navigation view.
     */
    @objc open class func shouldShowNavigationViewShadow() -> Bool {
        return true
    }
    
    /**
     Defines whether or not the navigation view is always pinned to the bottom of the screen, with content
     scrolling underneath it, or it's embedded in the footerView of the tableView, in which case it
     scrolls with the content.
     */
    @objc open class func shouldUseStickyNavigationView() -> Bool {
        return true
    }
    
    /**
     Defines if the progress view, which shows the number of steps completed in a multi-step task,
     should be shown at the top of the screen underneath the navigation bar.
     */
    @objc open class func shouldShowProgressView() -> Bool {
        return true
    }
    
    @objc open class func instantiateHeaderView() -> RSDNavigationHeaderView {
        return RSDGenericStepHeaderView()
    }
    
    @objc open class func instantiatNavigationView() -> RSDNavigationFooterView {
        return RSDGenericStepNavigationView()
    }
}

