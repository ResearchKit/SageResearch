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





/// `RSDGenericStepViewController` is a custom instance of `RSDStepViewController`. Its subviews include a `UITableView`,
/// a `RSDNavigationFooterView`, which may or may not be embedded in the tableView as its footerView, and a `RSDNavigationHeaderView`,
/// which is embedded in the tableView as its headerView.
///
/// This class populates the contents and properties of the headerView and navigationView based on the associated `RSDStep`,
/// which is expected to be set before presenting the view controller.
///
/// An instance of `RSDFormStepDataSource` is created by `setupModel()` and assigned to property `tableData`. This method is
/// called by `viewWillAppear()` and serves as the `UITableViewDataSource`. The `tableData` also keeps track of answers that
/// are derived from the user's input and it provides the `RSDResult` that is appended to the `RSDTaskPath` associated with this
/// task.
///
/// This class is responsible for acquiring input from the user, validating it, and supplying it as an answer to to the model
/// (tableData). This is typically done in delegate callbacks from various input views, such as UITableView (didSelectRow) or
/// UITextField (valueDidChange or shouldChangeCharactersInRange).
///
/// Some RSDSteps, such as `RSDFactory.StepType.instruction`, require no user input (and have no input fields). These steps
/// will result in a `tableData` that has no sections and, therefore, no rows. So the tableView will simply have a headerView,
/// no rows, and a footerView.
///
open class RSDGenericStepViewController: RSDStepViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, RSDFormStepDataSourceDelegate {
    
    /// The table view associated with this view controller. This will be created during `viewDidLoad()` with a default
    /// set up if it is `nil`. If this view controller is loaded from a nib or storyboard, then it should set this outlet
    /// using the interface builder.
    @IBOutlet open var tableView: UITableView!
    
    /// The data source for this table.
    open var tableData: RSDFormStepDataSource?
    
    /// Convenience property for accessing the form step (if casting the step to a `RSDFormUIStep` is applicable).
    public var formStep: RSDFormUIStep? {
        return step as? RSDFormUIStep
    }
    
    /// Class method to determine if this view controller class supports the provided step's form input fields. This will vary
    /// based on the `RSDFormDataType` and `RSDFormUIHint' for each of the input fields in the step.
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
    
    /// Static method to determine if this view controller class supports the provided step.
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
    
    private var navigationViewHeight: CGFloat = 0.0
    private let useStickyNavView = RSDGenericStepUIConfig.shouldUseStickyNavigationView()
    private var tableViewInsetBottom: CGFloat {
        return useStickyNavView ? navigationViewHeight + constants.mainViewBottomMargin : constants.mainViewBottomMargin
    }
    
    /// Should the view controller tableview include a header? If `true`, then by default, a `RSDStepHeaderView` will be added in
    /// `viewDidLoad()` if the view controller was not loaded using a storyboard or nib that included setting the `navigationFooter`
    /// property.
    open var shouldShowHeader: Bool = true
    
    /// Should the view controller tableview include a footer? If `true`, then by default, a `RSDNavigationFooterView` will be added in
    /// `viewDidLoad()` if the view controller was not loaded using a storyboard or nib that included setting the `navigationFooter`
    /// property.
    open var shouldShowFooter: Bool = true
    
    /// Override `viewDidLoad()` to add the table view, navigation header, and navigation footer if needed.
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.sectionHeaderHeight = 0.0
            tableView.estimatedSectionHeaderHeight = 0.0
            tableView.separatorStyle = .none
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = constants.defaultRowHeight
            
            view.addSubview(tableView)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.rsd_alignAllToSuperview(padding: 0)
        }
        if self.navigationHeader == nil && shouldShowHeader {
            navigationHeader = RSDGenericStepUIConfig.instantiateHeaderView()
            tableView.tableHeaderView = navigationHeader
        }
        if self.navigationFooter == nil && shouldShowFooter {
            navigationFooter = RSDGenericStepUIConfig.instantiateNavigationView()
        }
    }
    
    /// Override `viewWillAppear()` to set up the `tableData` data source model and add a keyboard listener.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup the view to require layout
        self.view.setNeedsLayout()
        
        // register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        // Set up the model and view
        setupModel()
    }
    
    /// Override `viewDidAppear()` to focus on the first text field if applicable.
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
    
    /// Override `viewWillDisappear()` to remove listeners and dismiss the keyboard.
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // un-register for keyboard notifications
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // Dismiss all textField's keyboard
        tableView?.endEditing(false)
    }

    /// Override `viewDidLayoutSubviews()` to set up the navigation footer either as the table footer or as a "sticky" footer.
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
            navigationView.rsd_alignToSuperview([.leading, .trailing, .bottom], padding: 0.0)
            
            // we also need to add an invisible view as the table's footerview so we don't get
            // a bunch of empty rows
            let footerView = UIView()
            footerView.backgroundColor = UIColor.clear
            tableView.tableFooterView = footerView
        }
        
        // set the tableView bottom inset
        var inset = tableView.contentInset
        inset.bottom = tableViewInsetBottom
        tableView.contentInset = inset
        
        // update the shadow (if needed)
        updateShadows()
    }

    
    // MARK: Model setup
    
    /// The UI hints that are supported by this view controller.
    open class var supportedUIHints: Set<RSDFormUIHint> {
        return [.list, .textfield, .picker]
    }
    
    /// Creates and assigns a new instance of the model. The default implementation will instantiate `RSDFormStepDataSourceObject`
    /// and set this as the `tableData`.
    open func setupModel() {
        tableData = RSDFormStepDataSourceObject(step: self.step, taskPath: self.taskController.taskPath, supportedHints: type(of: self).supportedUIHints)
        tableData?.delegate = self
        
        // after setting up the data source, check the enabled state of the forward button.
        self.answersDidChange(in: 0)
    }
    
    // MARK: View setup
    
    /// Override the set up of the header to set the background color for the table view and adjust the minimum height.
    open override func setupHeader(_ header: RSDNavigationHeaderView) {
        super.setupHeader(header)
        guard let stepHeader = header as? RSDStepHeaderView else { return }
        
        if let colorTheme = (step as? RSDThemedUIStep)?.colorTheme, let backgroundColor = colorTheme.backgroundColor(compatibleWith: self.traitCollection) {
            self.tableView.backgroundColor = backgroundColor
        }
        
        if formStep?.inputFields.count ?? 0 > 0 {
            // We have a minimum height for ORKFormSteps because these step usually have just a title and
            // description and the design generally calls for quite a bit of margin above and below the labels.
            // So we set a minimum size
            stepHeader.minumumHeight = constants.formStepMinHeaderHeight
        }
        
        if stepHeader === tableView.tableHeaderView {
            // to get the tableView to size the headerView properly, we have to get the headerView height
            // and manually set the frame with that height. Do so only if the header is actually the
            // tableview's header and not a custom header.
            let headerHeight = stepHeader.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            stepHeader.frame = CGRect(x: 0, y: 0, width: tableView!.frame.size.width, height: headerHeight)
            tableView!.tableHeaderView = stepHeader
        }
    }
        
    /// Auto layout constraint constants for the margin used at the bottom of the main view
    /// and the default tableView row height.
    /// - returns: A struct with the layout constants
    open var constants: RSDGenericStepLayoutConstants {
        
        // we only need some bottom margin if we have any table data (rows), otherwise, the bottom
        // margin built into the headerView is enough
        return RSDDefaultGenericStepLayoutConstants(numberOfSections: tableView.numberOfSections)
    }

    /// Specifies whether the next button should be enabled based on the validity of the answers for
    /// all form items.
    override open var isForwardEnabled: Bool {
        if !super.isForwardEnabled {
            // If super has forward disabled then return false
            return false
        } else if let allAnswersValid = tableData?.allAnswersValid() {
            // Else if the tabledata has been set up then go with that answer
            return allAnswersValid
        } else if let inputFields = self.formStep?.inputFields, inputFields.count > 0 {
            // are all the input fields optional?
            return inputFields.reduce(true, { $0 && $1.isOptional })
        } else {
            // All checks pass. forward is enabled.
            return true
        }
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
    
    override open func stop() {
        activeTextField = nil
        super.stop()
    }

    
    // MARK: UITableView Datasource
    
    /// Return the number of sections. The default implementation returns the section count of the `tableData`
    /// data source.
    /// - parameter tableView: The table view.
    /// - returns: The number of sections.
    open func numberOfSections(in tableView: UITableView) -> Int {
        return tableData?.sections.count ?? 0
    }
    
    /// Return the number of rows in a given section. The default implementation returns the row count of
    /// the `tableData` data source.
    /// - parameters:
    ///     - tableView: The table view.
    ///     - section: The section for the table view.
    /// - returns: The number of rows in the given section.
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.sections[section].rowCount() ?? 0
    }
    
    /// Instantiate or dequeue a cell for the given index path. The default implementation will use a unique identifier
    /// as the reuse identifier. It will then call `dequeueCell(in:, at:)` to dequeue the cell followed by calling
    /// `configure(cell:, in:, at:)` to configure the cell.
    ///
    /// - parameters:
    ///     - tableView: The table view.
    ///     - indexPath: The given index path.
    /// - returns: The table view cell configured for this index path.
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "\(indexPath.section)-\(indexPath.row)"
        let cell = dequeueCell(in: tableView, at: indexPath) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
        configure(cell: cell, in: tableView, at: indexPath)
        return cell
    }
    
    // UI Implementation
    
    /// Dequeue a cell that is appropriate for the item at the given index path.
    ///
    /// - parameters:
    ///     - tableView: The table view.
    ///     - indexPath: The given index path.
    /// - returns: The table view cell dequeued for this index path.
    open func dequeueCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell? {
        let identifier = "\(indexPath.section)-\(indexPath.row)"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        // If the cell is dequeued then we are done. return the cell.
        guard cell == nil else { return cell }
        
        return instantiateCell(with: identifier, at: indexPath)
    }
    
    /// Instantiate a cell that is appropriate for the item at the given index path.
    ///
    /// - note: This is a factory method and it will assert if a cell cannot be instantiated. Developers must
    /// overrride the default method and test for conditions *not* supported by this implementations *before*
    /// calling through to super if and only if the subclass does not instantiate different cell.
    ///
    /// - parameters:
    ///     - reuseIdentifier: A String representing the reuse identifier of the cell.
    ///     - indexPath: The given index path.
    /// - returns: The table view cell dequeued for this index path.
    open func instantiateCell(with reuseIdentifier: String, at indexPath: IndexPath) -> UITableViewCell? {
        
        // If there isn't a table item in the tableData associated with this index path then this is a failure.
        // Assert and return a placeholder cell.
        guard let tableItem = tableData?.tableItem(at: indexPath) else {
            assertionFailure("Failed to get an RSDTableItem for this index path \(indexPath)")
            return nil
        }
        
        // Look to see if this is a UI element that does not require user interaction.
        // If so, exit early with an appropriate instantiated cell.
        if tableItem is RSDTextTableItem {
            return RSDTextLabelCell(style: .default, reuseIdentifier: reuseIdentifier)
        } else if tableItem is RSDImageTableItem {
            return RSDImageViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        
        // Look to see that there is an input field item group and standard UI hint type
        // associated with this index path.
        guard let uiHintType = (tableItem as? RSDInputFieldTableItem)?.uiHint.standardType else {
            assertionFailure("Failed to dequeue a cell for \(indexPath).")
            return nil
        }
        
        // If the table item is a choice table item then an `RSDStepChoiceCell`.
        if tableItem is RSDChoiceTableItem {
            return RSDStepChoiceCell(uiHint: uiHintType, reuseIdentifier: reuseIdentifier)
        }
        else if let textInputItem = tableItem as? RSDTextInputTableItem, uiHintType == .textfield || uiHintType == .picker {
            
            // Create a textField based cell
            let fieldCell = instantiateTextFieldCell(with: reuseIdentifier, at: indexPath)
            fieldCell.textField.delegate = self
            fieldCell.selectionStyle = .none
            
            // setup our keyboard accessory view, which is a standard navigationView
            if let footer = self.navigationFooter, fieldCell.textField.inputAccessoryView == nil {
                
                let navView = type(of: footer).init()
                setupFooter(navView)
                
                // using auto layout to constrain the navView to fill its superview after adding it to the textfield
                // as its inputAccessoryView doesn't work for whatever reason. So we get the computed height from the
                // navView and manually set its frame before assigning it to the text field
                let navHeight = navView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                let navWidth = UIScreen.main.bounds.size.width
                navView.frame = CGRect(x: 0, y: 0, width: navWidth, height: navHeight)
                
                fieldCell.textField.inputAccessoryView = navView
            }
            
            // use the keyboard properties defined for this step
            if let textAnswerFormat = textInputItem.textFieldOptions {
                fieldCell.textField.keyboardType = textAnswerFormat.keyboardType.keyboardType()
                fieldCell.textField.isSecureTextEntry = textAnswerFormat.isSecureTextEntry
                fieldCell.textField.autocapitalizationType = textAnswerFormat.autocapitalizationType.textAutocapitalizationType()
                fieldCell.textField.autocorrectionType = textAnswerFormat.autocorrectionType.textAutocorrectionType()
                fieldCell.textField.spellCheckingType = textAnswerFormat.spellCheckingType.textSpellCheckingType()
            }
            
            // Add support for picker views
            if uiHintType == .picker {
                if let pickerSource = textInputItem.pickerSource as? RSDDatePickerDataSource {
                    let picker = RSDDatePicker(pickerSource: pickerSource, indexPath: indexPath)
                    fieldCell.textField.inputView = picker
                    picker.addTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)
                }
            }
            
            return fieldCell
        }
        else {
            assertionFailure("tableItem \(String(describing: tableItem)) is not supported. indexPath=\(indexPath)")
            return nil
        }
    }
    
    /// Configure a cell that is appropriate for the item at the given index path.
    ///
    /// - parameters:
    ///     - cell: The cell to configure.
    ///     - tableView: The table view.
    ///     - indexPath: The given index path.
    open func configure(cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {

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
            imageCell.imageLoader = item.imageTheme
        }
        else if let textFieldCell = cell as? RSDStepTextFieldCell {
            guard let itemGroup = tableData?.itemGroup(at: indexPath) as? RSDInputFieldTableItemGroup,
                let tableItem = tableData?.tableItem(at: indexPath) as? RSDTextInputTableItem
                else {
                    return
            }
            
            if let customField = textFieldCell.textField as? RSDStepTextField {
                customField.indexPath = indexPath
            }
            
            // if we have an answer, populate the text field
            if itemGroup.isAnswerValid {
                textFieldCell.textField.text = tableItem.answerText
                if let picker = textFieldCell.textField.inputView as? RSDPickerViewProtocol {
                    picker.answer = tableItem.answer
                }
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
    
    /// The 'RSDStepTextFieldCell' to use. Override to provide a custom instance of this class.
    ///
    /// If this step has just one form item, like for 'externalID' or 'yourAge', then use the `RSDStepTextFieldFeaturedCell`
    /// textField cell, which centers the field in the view and uses a large font. Otherwise, use `RSDStepTextFieldCell`.
    ///
    /// - parameters:
    ///     - reuseIdentifier: A String representing the reuse identifier of the cell.
    ///     - indexPath: The given index path.
    /// - returns: The 'RSDStepTextFieldCell' class to use.
    open func instantiateTextFieldCell(with reuseIdentifier: String, at indexPath: IndexPath) -> RSDStepTextFieldCell {
        if formStep?.inputFields.count ?? 0 > 1 {
            return RSDStepTextFieldCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        else {
            return RSDStepTextFieldFeaturedCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }
    
    // MARK: UITableView Delegate
    
    /// Handle the selection of a row.
    ///
    /// The base class implementation can handle the following ui hints:
    /// 1. List - Selects the given index path as the current selection. This will also deselect other rows if the form data type
    ///           is single choice.
    /// 2. Textfield - Calls `becomeFirstResponder()` to present the keyboard.
    ///
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
    
    /// When a text field gets focus, assign it as the active text field (to allow resigning active if the user taps the forward button)
    /// and scroll it into view above the keyboard.
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        (activeTextField?.inputAccessoryView as? RSDNavigationFooterView)?.nextButton?.isEnabled = self.isForwardEnabled
        pickerValueChanged(textField)
        scroll(to: textField)
    }
    
    /// Resign first responder on "Enter" key tapped.
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.canResignFirstResponder {
            textField.resignFirstResponder()
        }
        return false
    }
    
    /// Enable the next button as soon as the text field entry has changed.
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        didChangeTextField(textField)
        return true
    }
    
    /// Validate and save the text field result.
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
    
    // Picker management
    
    @objc func pickerValueChanged(_ sender: Any) {
        guard let picker = ((sender as? UITextField)?.inputView ?? sender) as? RSDPickerViewProtocol,
            let textField = activeTextField as? RSDStepTextField,
            picker.indexPath == textField.indexPath,
            let inputItem = self.tableData?.tableItem(at: picker.indexPath) as? RSDTextInputTableItem
            else {
                return
        }
        textField.text = inputItem.answerText(for: picker.answer)
        if picker.answer != nil {
            didChangeTextField(textField)
        }
    }
    
    // Text field management
    
    private var savedVerticalScrollOffet: CGFloat = 0.0
    private var activeTextField: UITextField?
    
    private func didChangeTextField(_ textField: UITextField) {
        // Always enable the next button once something has been entered
        (textField.inputAccessoryView as? RSDStepNavigationView)?.nextButton?.isEnabled = true
    }
    
    /// Check if the first cell is a text field and if so, set it as the first responder.
    private func checkForFirstCellTextField() {
        
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
    
    /// scroll the text field into view above the keyboard.
    private func scroll(to textField: UITextField?) {
        guard let customField = textField as? RSDStepTextField, let indexPath = customField.indexPath else { return }
        savedVerticalScrollOffet = tableView.contentOffset.y
        tableView?.scrollToRow(at: indexPath, at: .middle, animated: true)
    }

    /// Get the index path associated with a given text field.
    public func indexPath(for textField: UITextField?) -> IndexPath? {
        guard let customTextField = textField as? RSDStepTextField,
            let indexPath = customTextField.indexPath
            else {
                return nil
        }
        return indexPath
    }

    /// Get the table item associated with a given text field.
    public func tableItem(for textField: UITextField?) -> RSDTextInputTableItem? {
        guard let customTextField = textField as? RSDStepTextField,
            let indexPath = customTextField.indexPath,
            let tableItem = tableData?.tableItem(at: indexPath) as? RSDTextInputTableItem?
            else {
                return nil
        }
        return tableItem
    }
    
    /// Validate the text field value and save the answer if valid.
    @discardableResult
    public func validateAndSave(textField: UITextField) -> Bool {
        
        guard let customTextField = textField as? RSDStepTextField,
            let indexPath = customTextField.indexPath else {
                return false
        }
        
        let answer: Any? = {
            if let picker = textField.inputView as? RSDPickerViewProtocol {
                return picker.answer
            } else {
                return textField.text
            }
        }()
        
        // If this is a custom text field then update the text to match the
        // actual value stored in case it differs from the text entered.
        let success = saveAnswer(newValue: answer ?? NSNull(), at: indexPath)
        if !success, let tableItem = tableItem(for: textField) {
            textField.text = tableItem.answerText
        }
        return success
    }
    
    // MARK: Save answer back to the data source
    
    /// Save answer back to the data source.
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
    
    /// Show a validation error message that is appropriate for the given context.
    open func showValidationError(title: String?, message: String?, context: RSDInputFieldError.Context?, at indexPath: IndexPath) {
        let invalidMessage = (tableData?.tableItem(at: indexPath) as? RSDTextInputTableItem)?.textFieldOptions?.invalidMessage
        self.presentAlertWithOk(title: nil,
                             message: invalidMessage ?? message ?? Localization.localizedString("VALIDATION_ERROR_GENERIC"),
                             actionHandler: nil)
    }

    
    // MARK: RSDFormStepDataSourceDelegate implementation
    
    /// Called when the answers tracked by the data source change.
    /// - parameter section: The section that changed.
    open func answersDidChange(in section: Int) {
        // update enabled state of next button
        navigationFooter?.nextButton?.isEnabled = self.isForwardEnabled
        (activeTextField?.inputAccessoryView as? RSDNavigationFooterView)?.nextButton?.isEnabled = self.isForwardEnabled
    }
    
    // MARK: UIScrollView delegate
    
    /// Base class implementation will call `updateShadows()`.
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateShadows()
    }
    
    /// Base class implementation will call `updateShadows()` if not decelerating.
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateShadows()
        }
    }
    
    /// Base class implementation will call `updateShadows()`.
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateShadows()
    }
    
    /// Update the footer shadow that is used to indicate that there is additional information below the fold.
    open func updateShadows() {
        guard let footer = self.navigationFooter, useStickyNavView else { return }
        let maxY = tableView.contentSize.height - (tableView.bounds.size.height - footer.bounds.size.height)
        let hasShadow = (tableView.contentOffset.y < maxY)
        guard hasShadow != shouldShowFooterShadow else { return }
        shouldShowFooterShadow = hasShadow
    }

    private var shouldShowFooterShadow: Bool = false {
        didSet {
            guard let footer = self.navigationFooter, useStickyNavView else { return }
            footer.shouldShowShadow = shouldShowFooterShadow
        }
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
            contentInset.bottom = endFrame.size.height + constants.mainViewBottomMargin
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
}

/// `RSDGenericStepUIConfig` is a configuration class. All the methods are defined as `@objc open class func`
/// methods which can be overriden by an application to return different shared implementations. This allows
/// the generic step to override the UI consistently for all step views that use either
/// `RSDGenericStepViewController` or a subclass implementation.
public class RSDGenericStepUIConfig: NSObject {
}

extension RSDGenericStepUIConfig {
    
    /// Defines whether or not a drop shadow is shown below the top edge of the navigation view. The shadow
    /// is only shown if content is underlapping the navigation view.
    @objc open class func shouldShowNavigationViewShadow() -> Bool {
        return true
    }
    
    /// Defines whether or not the navigation view is always pinned to the bottom of the screen, with content
    /// scrolling underneath it, or it's embedded in the footerView of the tableView, in which case it
    /// scrolls with the content.
    @objc open class func shouldUseStickyNavigationView() -> Bool {
        return true
    }
    
    /// Instantiate an instance of the header view used by the `RSDGenericStepViewController` table view.
    @objc open class func instantiateHeaderView() -> RSDStepHeaderView {
        return RSDGenericStepHeaderView()
    }
    
    /// Instantiate an instance of the footer view used by the `RSDGenericStepViewController` table view.
    /// The footer is either "sticky", meaning that it is pinned to the bottom of the screen or "scrolling"
    /// meaning that it is set as the footer for the table view.
    ///
    /// A second instance of the navigation footer is set as the `inputAccessoryView` of a text field when
    /// the text field becomes the first responder.
    @objc open class func instantiateNavigationView() -> RSDNavigationFooterView {
        return RSDGenericNavigationFooterView()
    }
}

/// `RSDGenericStepLayoutConstants` defines the layout constants used by the `RSDGenericStepViewController`.
public protocol RSDGenericStepLayoutConstants {
    var mainViewBottomMargin: CGFloat { get }
    var defaultRowHeight: CGFloat { get }
    var formStepMinHeaderHeight: CGFloat { get }
}

/// Default constants.
fileprivate struct RSDDefaultGenericStepLayoutConstants {
    private let kMainViewBottomMargin: CGFloat = 30.0
    
    public let mainViewBottomMargin: CGFloat
    public let defaultRowHeight: CGFloat = 75.0
    public let formStepMinHeaderHeight: CGFloat = 180
    
    init(numberOfSections: Int) {
        mainViewBottomMargin = numberOfSections > 0 ? kMainViewBottomMargin : 0.0
    }
}

extension RSDDefaultGenericStepLayoutConstants : RSDGenericStepLayoutConstants {
}

