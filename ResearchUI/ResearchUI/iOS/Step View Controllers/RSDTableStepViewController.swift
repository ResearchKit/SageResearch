//
//  RSDTableStepViewController.swift
//  ResearchUI
//
//  Created by Josh Bruhin on 5/16/17.
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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


/// `RSDTableStepViewController` is a custom instance of `RSDStepViewController`. Its subviews include a
/// `UITableView`, a `RSDNavigationFooterView`, which may or may not be embedded in the tableView as its
/// footerView, and a `RSDNavigationHeaderView`, which is embedded in the tableView as its headerView.
///
/// This class populates the contents and properties of the headerView and navigationView based on the
/// associated `RSDStep`, which is expected to be set before presenting the view controller.
///
/// An instance of `RSDFormStepDataSource` is created by `setupModel()` and assigned to property
/// `tableData`. This method is called by `viewWillAppear()` and serves as the `UITableViewDataSource`. The
/// `tableData` also keeps track of answers that are derived from the user's input and it provides the
/// `RSDResult` that is appended to the `RSDTaskPath` associated with this task.
///
/// This class is responsible for acquiring input from the user, validating it, and supplying it as an
/// answer to to the model (tableData). This is typically done in delegate callbacks from various input
/// views, such as UITableView (didSelectRow) or  UITextField (valueDidChange or
/// shouldChangeCharactersInRange).
///
/// Some RSDSteps, such as `RSDFactory.StepType.instruction`, require no user input (and have no input
/// fields). These steps will result in a `tableData` that has no sections and, therefore, no rows. So the
/// tableView will simply have a headerView, no rows, and a footerView.
///
open class RSDTableStepViewController: RSDStepViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, RSDTableDataSourceDelegate, RSDPickerObserver, RSDButtonCellDelegate {

    /// The table view associated with this view controller. This will be created during `viewDidLoad()`
    /// with a default set up if it is `nil`. If this view controller is loaded from a nib or storyboard,
    /// then it should set this outlet using the interface builder.
    @IBOutlet open var tableView: UITableView!
    
    /// The data source for this table.
    open var tableData: RSDTableDataSource?
    
    /// Convenience property for accessing the form step (if casting the step to a `RSDFormUIStep` is
    /// applicable).
    public var formStep: RSDFormUIStep? {
        return step as? RSDFormUIStep
    }

    /// Static method to determine if this view controller class supports the provided step.
    open class func doesSupport(_ step: RSDStep) -> Bool {
        // Only UI steps are supported
        guard let _ = step as? RSDUIStep else { return false }
        if let tableStep = step as? RSDTableStep {
            // TODO: syoung 02/26/2018 Implement support for image selection.
            // https://github.com/ResearchKit/SageResearch/issues/11
            return !tableStep.hasImageChoices
        } else {
            return true
        }
    }
    
    
    // MARK: View lifecycle
    
    private var navigationViewHeight: CGFloat = 0.0
    private let useStickyNavView = RSDTableStepUIConfig.shouldUseStickyNavigationView()
    private var tableViewInsetBottom: CGFloat {
        return useStickyNavView ? navigationViewHeight + constants.mainViewBottomMargin : constants.mainViewBottomMargin
    }
    
    /// Should the view controller tableview include a header? If `true`, then by default, a
    /// `RSDStepHeaderView` will be added in `viewDidLoad()` if the view controller was not loaded using a
    /// storyboard or nib that included setting the `navigationFooter` property.
    open var shouldShowHeader: Bool = true
    
    /// Should the view controller tableview include a footer? If `true`, then by default, a
    /// `RSDNavigationFooterView` will be added in `viewDidLoad()` if the view controller was not loaded
    /// using a storyboard or nib that included setting the `navigationFooter` property.
    open var shouldShowFooter: Bool = true
    
    /// Override `viewDidLoad()` to add the table view, navigation header, and navigation footer if needed.
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.appBackgroundLight
        
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.backgroundColor = self.view.backgroundColor
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = constants.defaultRowHeight
            tableView.sectionHeaderHeight = UITableViewAutomaticDimension
            tableView.estimatedSectionHeaderHeight = constants.defaultSectionHeight
            
            view.addSubview(tableView)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.rsd_alignAllToSuperview(padding: 0)
        }
        if self.navigationHeader == nil && shouldShowHeader {
            navigationHeader = RSDTableStepUIConfig.instantiateHeaderView()
            tableView.tableHeaderView = navigationHeader
        }
        if self.navigationFooter == nil && shouldShowFooter {
            navigationFooter = RSDTableStepUIConfig.instantiateNavigationView()
        }
        if self.statusBarBackgroundView == nil && shouldShowHeader {
            let statusView = RSDStatusBarBackgroundView()
            statusView.backgroundColor = navigationHeader?.backgroundColor
            view.addSubview(statusView)
            statusView.alignToStatusBar()
            statusBarBackgroundView = statusView
        }
    }
    
    /// Override `viewWillAppear()` to set up the `tableData` data source model and add a keyboard
    /// listener.
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
        // https://github.com/ResearchKit/SageResearch/issues/10
        //
        // If the first row in our tableView has a textField, we want it to become the first responder
        // automatically. We must do this after a delay because of how RSDTaskViewController presents
        // these step view controllers, which is done via a UIPageViewController. Without the delay,
        // the textField will NOT become the firstResponder.
        //
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

    /// Override `viewDidLayoutSubviews()` to set up the navigation footer either as the table footer or as
    /// a "sticky" footer.
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
    
    /// Override to set the background color of the table.
    override open func setColorStyle(for placement: RSDColorPlacement, usesLightStyle: Bool, backgroundColor: UIColor) {
        super.setColorStyle(for: placement, usesLightStyle: usesLightStyle, backgroundColor: backgroundColor)
        if placement == .body {
            self.tableView.backgroundColor = backgroundColor
        }
    }

    
    // MARK: Model setup
    
    /// The UI hints that are supported by this view controller.
    open class var supportedUIHints: Set<RSDFormUIHint> {
        return [.list, .textfield, .picker, .checkbox, .radioButton, .modalButton]
    }
    
    /// Creates and assigns a new instance of the model. The default implementation will instantiate
    /// `RSDFormStepDataSourceObject` and set this as the `tableData`.
    open func setupModel() {
        guard tableData == nil else { return }
        
        // Get the table data source from the step (if applicable)
        let supportedHints = type(of: self).supportedUIHints
        let taskPath = self.taskController.taskPath!
        if let tableStep = self.step as? RSDTableStep,
            let source = tableStep.instantiateDataSource(with: taskPath, for: supportedHints)
            {
            tableData = source
        } else {
            tableData = RSDFormStepDataSourceObject(step: self.step, taskPath: taskPath, supportedHints: supportedHints)
        }
        tableData?.delegate = self
        
        // after setting up the data source, check the enabled state of the forward button.
        self.answersDidChange(in: 0)
    }
    
    /// Register the given reuse identifier.  This is a factory method that is called before dequeuing a
    /// table cell. Overrides of this method should first check to see if the reuse identifier has already
    /// been registered and if not, do so by calling `tableView.register(, forCellReuseIdentifier:)` with
    /// either a nib or a class.
    open func registerReuseIdentifierIfNeeded(_ reuseIdentifier: String) {
        guard !_registeredIdentifiers.contains(reuseIdentifier) else { return }
        _registeredIdentifiers.insert(reuseIdentifier)
        
        if let reuseId = RSDTableItem.ReuseIdentifier(rawValue: reuseIdentifier) {
            switch reuseId {
            case .image:
                tableView.register(RSDImageViewCell.self, forCellReuseIdentifier: reuseIdentifier)
            case .label:
                tableView.register(RSDTextLabelCell.self, forCellReuseIdentifier: reuseIdentifier)
            }
        }
        else {
            let isFeatured = formStep?.inputFields.count ?? 0 <= 1
            let reuseId = RSDFormUIHint(rawValue: reuseIdentifier)
            switch reuseId {
            case .checkbox:
                tableView.register(RSDCheckboxTableCell.self, forCellReuseIdentifier: reuseIdentifier)
            case .radioButton:
                tableView.register(RSDRadioButtonTableCell.self, forCellReuseIdentifier: reuseIdentifier)
            case .list:
                tableView.register(RSDStepChoiceCell.self, forCellReuseIdentifier: reuseIdentifier)
            case .textfield, .picker:
                let cellClass: AnyClass = isFeatured ? RSDStepTextFieldFeaturedCell.self : RSDStepTextFieldCell.self
                tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
            case .modalButton:
                tableView.register(RSDModalButtonCell.self, forCellReuseIdentifier: reuseIdentifier)
            default:
                // Look to see if this does not have a cell registered for the view and register a default
                // instance. This will throw an assert if the cell is not registered, but will **not**
                // crash production code.
                if tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) == nil {
                    assertionFailure("Failed to register the cell reuse identifier: \(reuseIdentifier)")
                    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
                }
            }
        }
    }
    private var _registeredIdentifiers = Set<String>()
    
    /// Register the given reuse identifier for a section header or footer.  This is a factory method that
    /// is called before dequeuing a table section view. Overrides of this method should first check to see
    /// if the reuse identifier has already been registered and if not, do so by calling
    /// `tableView.register(, forHeaderFooterViewReuseIdentifier:)` with either a nib or a class.
    open func registerSectionReuseIdentifierIfNeeded(_ reuseIdentifier: String) {
        guard !_registeredSectionIdentifiers.contains(reuseIdentifier) else { return }
        _registeredSectionIdentifiers.insert(reuseIdentifier)
        
        // Currently the only style of section view supported is the choice section header.
        tableView.register(RSDStepChoiceSectionHeader.self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
    private var _registeredSectionIdentifiers = Set<String>()
    
    
    // MARK: View setup
    
    /// Override the set up of the header to set the background color for the table view and adjust the
    /// minimum height.
    open override func setupHeader(_ header: RSDNavigationHeaderView) {
        super.setupHeader(header)
        guard let stepHeader = header as? RSDStepHeaderView else { return }
        
        if let colorTheme = (step as? RSDThemedUIStep)?.colorTheme, let backgroundColor = colorTheme.backgroundColor(compatibleWith: self.traitCollection) {
            self.tableView.backgroundColor = backgroundColor
        }
        
        if formStep?.inputFields.count ?? 0 > 0 {
            // We have a minimum height for ORKFormSteps because these step usually have just a title and
            // description and the design generally calls for quite a bit of margin above and below the
            // labels. So we set a minimum size
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
    open var constants: RSDTableStepLayoutConstants {
        
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
        
        // If the textfield is valid, check to see if there is another item that is below this one and set
        // that as the next responder if valid.
        if let indexPath = indexPath(for: textField),
            let nextResponder = self.nextResponder(after: indexPath) {
            nextResponder.becomeFirstResponder()
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
    
    /// Return the number of sections. The default implementation returns the section count of the
    /// `tableData` data source.
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
    
    /// Instantiate or dequeue a cell for the given index path. The default implementation will call
    /// `dequeueCell(in:, at:)` to dequeue the cell followed by calling `configure(cell:, in:, at:)`
    /// to configure the cell.
    ///
    /// - parameters:
    ///     - tableView: The table view.
    ///     - indexPath: The given index path.
    /// - returns: The table view cell configured for this index path.
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueCell(in: tableView, for: indexPath)
        configure(cell: cell, in: tableView, at: indexPath)
        return cell
    }
    
    /// Dequeues a section header if the title for the section is non-nil.
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionItem = tableData?.sections[section] else { return nil }
        
        if let title = sectionItem.title {
            // Dequeue with the reuse identifier
            let reuseIdentifier = "TableSectionHeader"
            self.registerSectionReuseIdentifierIfNeeded(reuseIdentifier)
            let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
            if let header = cell as? RSDStepChoiceSectionHeader {
                header.titleLabel.text = title
                header.detailLabel.text = sectionItem.subtitle
            }
            return cell
        }
        else {
            // Add a spacer
            let view =  UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: constants.defaultSectionHeight))
            view.backgroundColor = tableView.backgroundColor
            return view
        }
    }
    
    // UI Implementation
    
    /// Dequeue a cell that is appropriate for the item at the given index path. By default,
    /// this method will call `reuseIdentifier(for:)` followed by `registerReuseIdentifierIfNeeded()`
    /// to register the table view cell reuse identifier before calling `dequeueReusableCell()`
    /// on the given table view.
    ///
    /// - parameters:
    ///     - tableView: The table view.
    ///     - indexPath: The given index path.
    /// - returns: The table view cell dequeued for this index path.
    open func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let reuseId = reuseIdentifier(for: indexPath)
        registerReuseIdentifierIfNeeded(reuseId)
        return tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
    }
    
    /// Returns the cell reuse identifier for a given index path.
    ///
    /// By default, this will look for a `RSDTableItem` at the given index path and return the
    /// `reuseIdentifier` property on that object. If there isn't a table item in the tableData
    /// associated with this index path then this is a failure. The default behavior is to throw
    /// an assertion and return a placeholder cell identifier.
    ///
    /// - parameter indexPath: The given index path.
    /// - returns: The reuse identifier for the given index path.
    open func reuseIdentifier(for indexPath: IndexPath) -> String {
        guard let tableItem = tableData?.tableItem(at: indexPath) else {
            assertionFailure("Failed to get an RSDTableItem for this index path \(indexPath)")
            return "__BasicCell"
        }
        return tableItem.reuseIdentifier
    }
    
    /// Configure a cell that is appropriate for the item at the given index path.
    ///
    /// - parameters:
    ///     - cell: The cell to configure.
    ///     - tableView: The table view.
    ///     - indexPath: The given index path.
    open func configure(cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        
        if let tableCell = cell as? RSDTableViewCell {
            tableCell.indexPath = indexPath
            tableCell.tableItem = tableData!.tableItem(at: indexPath)
            tableCell.tableBackgroundColor = tableView.backgroundColor
            tableCell.usesLightStyle = self.usesLightStyle
        }
        if let buttonCell = cell as? RSDButtonCell {
            buttonCell.delegate = self
        }
        if let styleCell = cell as? RSDViewColorStylable {
            styleCell.usesLightStyle = self.usesLightStyle
        }
        
        if let textFieldCell = cell as? RSDStepTextFieldCell {
            configure(textFieldCell: textFieldCell, at: indexPath)
        }
    }
    
    /// Configure a text field cell.
    func configure(textFieldCell: RSDStepTextFieldCell, at indexPath: IndexPath) {
        guard let itemGroup = tableData?.itemGroup(at: indexPath) as? RSDInputFieldTableItemGroup,
            let tableItem = tableData?.tableItem(at: indexPath) as? RSDTextInputTableItem
            else {
                return
        }
        
        // Always set the index path and delegate
        textFieldCell.textField.indexPath = indexPath
        textFieldCell.textField.delegate = self
        textFieldCell.selectionStyle = .none
        
        // Set up our keyboard accessory view, which is a standard navigationView but only if there
        // isn't already a footer set for this cell.
        if let footer = self.navigationFooter, textFieldCell.textField.inputAccessoryView == nil {
            
            let navView = type(of: footer).init()
            setupFooter(navView)
            navView.backgroundColor = footer.backgroundColor
            navView.usesLightStyle = footer.usesLightStyle
            
            // using auto layout to constrain the navView to fill its superview after adding it to the textfield
            // as its inputAccessoryView doesn't work for whatever reason. So we get the computed height from the
            // navView and manually set its frame before assigning it to the text field
            let navHeight = navView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            let navWidth = UIScreen.main.bounds.size.width
            navView.frame = CGRect(x: 0, y: 0, width: navWidth, height: navHeight)
            
            textFieldCell.textField.inputAccessoryView = navView
        }
        
        // use the keyboard properties defined for this step
        if let textAnswerFormat = tableItem.textFieldOptions {
            textFieldCell.textField.keyboardType = textAnswerFormat.keyboardType.keyboardType()
            textFieldCell.textField.isSecureTextEntry = textAnswerFormat.isSecureTextEntry
            textFieldCell.textField.autocapitalizationType = textAnswerFormat.autocapitalizationType.textAutocapitalizationType()
            textFieldCell.textField.autocorrectionType = textAnswerFormat.autocorrectionType.textAutocorrectionType()
            textFieldCell.textField.spellCheckingType = textAnswerFormat.spellCheckingType.textSpellCheckingType()
        }
        
        // Add support for picker views
        let pickerView = textFieldCell.textField.inputView as? (RSDPickerViewProtocol & UIView)
        if tableItem.uiHint == .picker, pickerView?.indexPath != indexPath {
            let picker = instantiatePickerView(textInputItem: tableItem, indexPath: indexPath)
            textFieldCell.textField.inputView = picker
            picker?.observer = self
        }

        // if we have an answer, populate the text field
        if itemGroup.isAnswerValid {
            textFieldCell.textField.text = tableItem.answerText
            if let picker = textFieldCell.textField.inputView as? RSDPickerViewProtocol {
                picker.answer = tableItem.answer
            }
        }
        
        // populate the field label
        textFieldCell.fieldLabel.text = tableItem.inputField.inputPrompt
        
        // populate the text field placeholder label
        textFieldCell.placeholder = tableItem.placeholder
    }
    
    /// Instantiate the appropriate picker view for the given input item.
    /// - parameters:
    ///     - textInputItem: The table item.
    ///     - indexPath: The index path.
    open func instantiatePickerView(textInputItem: RSDTextInputTableItem, indexPath:IndexPath) -> (RSDPickerViewProtocol & UIView)? {
        if let pickerSource = textInputItem.pickerSource as? RSDDatePickerDataSource {
            return RSDDatePicker(pickerSource: pickerSource, indexPath: indexPath)
        }
        else if let pickerSource = textInputItem.pickerSource as? RSDChoicePickerDataSource {
            return RSDChoicePickerView(pickerSource: pickerSource, indexPath: indexPath)
        }
        else if let pickerSource = textInputItem.pickerSource as? RSDNumberPickerDataSource {
            return RSDNumberPickerView(pickerSource: pickerSource, indexPath: indexPath)
        }
        debugPrint("Could not instantiate an appropriate picker for \(textInputItem.inputField.identifier): \(String(describing: textInputItem.pickerSource))")
        return nil
    }
    
    
    // MARK: UITableView Delegate
    
    /// Handle the selection of a row.
    ///
    /// The base class implementation can handle the following ui hints:
    /// 1. List - Selects the given index path as the current selection. This will also deselect other rows
    ///         if the form data type is single choice.
    /// 2. Textfield - Calls `becomeFirstResponder()` to present the keyboard.
    ///
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableData = self.tableData else { return }
        
        if let item = tableData.tableItem(at: indexPath) as? RSDChoiceTableItem {
            didSelectItem(item, at: indexPath)
        }
        else {
            
            // need to get our cell and tell its textField to become first responder
            if let customCell = tableView.cellForRow(at: indexPath) as? RSDStepTextFieldCell {
                customCell.textField.becomeFirstResponder()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /// Get the next responder (table cell or text field) for the next table item after the given index path.
    /// - parameter indexPath: The index path of the next field.
    /// - returns: The next responder or `nil` if this is the last item.
    open func nextResponder(after indexPath: IndexPath) -> UIResponder? {
        guard let nextItem = tableData?.nextItem(after: indexPath) else {
            return nil
        }
        if let customCell = self.tableView.cellForRow(at: nextItem.indexPath) as? RSDStepTextFieldCell {
            return customCell.textField
        }
        else {
            return nextResponder(after: nextItem.indexPath)
        }
    }
    
    // MARK: didSelect methods
    
    /// Called when a user action on a cell or button is linked to a choice item.
    open func didSelectItem(_ item: RSDTableItem, at indexPath: IndexPath) {
        guard let tableData = self.tableData else { return }

        do {
            let response = try tableData.selectAnswer(item: item, at: indexPath)
            if response.reloadSection {
                // reload the entire table - this will refresh the selection state for the items in this
                // section without confusing the constraints.
                tableView.reloadData()
            } else {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            // Dismiss other textField's keyboard
            if self.activeTextField != nil {
                tableView.endEditing(false)
            }
            
        } catch let err {
            assertionFailure("Unexpected error while selecting table row \(indexPath). \(err)")
        }
    }
    
    /// Called when a user action on a cell or button is linked to a modal item.
    open func didSelectModalItem(_ modalItem: RSDModalStepTableItem, at indexPath: IndexPath) {
        guard let source = tableData as? RSDModalStepDataSource,
            let taskViewController = self.taskController as? RSDTaskViewController
            else {
                assertionFailure("Cannot handle the button tap.")
                return
        }
        let step = source.step(for: modalItem)
        let stepViewController = taskViewController.viewController(for: step)
        source.willPresent(stepViewController, from: modalItem)
        self.present(stepViewController, animated: true, completion: nil)
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
    
    @objc open func pickerValueChanged(_ sender: Any) {
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
    public func validateAndSave(textField: UITextField? = nil) -> Bool {
        // If there isn't an active text field, then return true.
        guard let textField = (textField ?? activeTextField)
            else {
                return true
        }
        
        // If the text field is not an RSDStepTextField then return false.
        guard let customTextField = textField as? RSDStepTextField,
            let indexPath = customTextField.indexPath else {
                return false
        }

        let answer: Any? = {
            if let picker = customTextField.inputView as? RSDPickerViewProtocol {
                return picker.answer
            } else {
                return customTextField.text
            }
        }()
        
        // If this is a custom text field then update the text to match the
        // actual value stored in case it differs from the text entered.
        let success = saveAnswer(newValue: answer ?? NSNull(), at: indexPath)
        if !success, let tableItem = tableItem(for: customTextField) {
            customTextField.text = tableItem.answerText
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
    
    
    /// MARK: RSDButtonCellDelegate
    
    open func didTapButton(on cell: RSDButtonCell) {
        guard let tableItem = tableData?.tableItem(at: cell.indexPath) else {
            assertionFailure("Cannot handle the button tap.")
            return
        }
        
        if let modalItem = tableItem as? RSDModalStepTableItem {
            didSelectModalItem(modalItem, at: cell.indexPath)
        }
        else {
            didSelectItem(tableItem, at: cell.indexPath)
        }
    }

    
    // MARK: RSDFormStepDataSourceDelegate implementation
    
    /// Called when the answers tracked by the data source change.
    /// - parameter section: The section that changed.
    open func answersDidChange(in section: Int) {
        // update enabled state of next button
        navigationFooter?.nextButton?.isEnabled = self.isForwardEnabled
        (activeTextField?.inputAccessoryView as? RSDNavigationFooterView)?.nextButton?.isEnabled = self.isForwardEnabled
    }
    
    /// Called when the answers tracked by the data source change.
    /// - parameters:
    ///     - dataSource: The calling data source.
    ///     - section: The section that changed.
    open func tableDataSource(_ dataSource: RSDTableDataSource, didChangeAnswersIn section: Int) {
        self.answersDidChange(in: section)
    }
    
    /// Called by a `RSDModalStepDataSource` to dismiss the presented step view controller.
    open func tableDataSource(_ dataSource: RSDTableDataSource, didFinishWith stepController: RSDStepController) {
        guard let vc = stepController as? UIViewController else { return }
        vc.dismiss(animated: true) { }
    }
    
    /// Called *before* editing the table rows and sections.
    open func tableDataSourceWillBeginUpdate(_ dataSource: RSDTableDataSource) {
        self.tableView.beginUpdates()
    }
    
    /// Called *after* editing the table rows and sections.
    open func tableDataSourceDidEndUpdate(_ dataSource: RSDTableDataSource, addedRows:[IndexPath], removedRows:[IndexPath]) {
        // finish updating the table
        let animation: UITableViewRowAnimation = self.isVisible ? .automatic : .none
        self.tableView.deleteRows(at: removedRows, with: animation)
        self.tableView.insertRows(at: addedRows, with: animation)
        self.tableView.endUpdates()
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

/// `RSDTableStepUIConfig` is a configuration class. All the methods are defined as `@objc open class func`
/// methods which can be overriden by an application to return different shared implementations. This allows
/// the generic step to override the UI consistently for all step views that use either
/// `RSDTableStepViewController` or a subclass implementation.
public class RSDTableStepUIConfig: NSObject {
}

extension RSDTableStepUIConfig {
    
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
    
    /// Instantiate an instance of the header view used by the `RSDTableStepViewController` table view.
    @objc open class func instantiateHeaderView() -> RSDStepHeaderView {
        let header =  RSDTableStepHeaderView()
        header.backgroundColor = UIColor.appBackgroundDark
        header.usesLightStyle = true
        return header
    }
    
    /// Instantiate an instance of the footer view used by the `RSDTableStepViewController` table view.
    /// The footer is either "sticky", meaning that it is pinned to the bottom of the screen or "scrolling"
    /// meaning that it is set as the footer for the table view.
    ///
    /// A second instance of the navigation footer is set as the `inputAccessoryView` of a text field when
    /// the text field becomes the first responder.
    @objc open class func instantiateNavigationView() -> RSDNavigationFooterView {
        return RSDGenericNavigationFooterView()
    }
}

/// `RSDTableStepLayoutConstants` defines the layout constants used by the `RSDTableStepViewController`.
public protocol RSDTableStepLayoutConstants {
    var mainViewBottomMargin: CGFloat { get }
    var defaultRowHeight: CGFloat { get }
    var defaultSectionHeight: CGFloat { get }
    var formStepMinHeaderHeight: CGFloat { get }
}

/// Default constants.
fileprivate struct RSDDefaultGenericStepLayoutConstants {
    private let kMainViewBottomMargin: CGFloat = 30.0
    
    public let mainViewBottomMargin: CGFloat
    public let defaultRowHeight: CGFloat = 52.0
    public let defaultSectionHeight: CGFloat = 1.0
    public let formStepMinHeaderHeight: CGFloat = 180
    
    init(numberOfSections: Int) {
        mainViewBottomMargin = numberOfSections > 0 ? kMainViewBottomMargin : 0.0
    }
}

extension RSDDefaultGenericStepLayoutConstants : RSDTableStepLayoutConstants {
}
