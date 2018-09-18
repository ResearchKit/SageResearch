//
//  RSDImagePickerStepViewController.swift
//  ResearchUI (iOS)
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
import Photos
import AVFoundation

extension RSDImagePickerStepObject : RSDStepViewControllerVendor {
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        return RSDImagePickerStepViewController(step: self, parent: parent)
    }
}

open class RSDImagePickerStepViewController: RSDStepViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /// A label that can be used to display a message to the user if the image picker cannot open.
    @IBOutlet weak public var errorMessageLabel: UILabel?
    
    private let picker = UIImagePickerController()
    private let processingQueue = DispatchQueue(label: "org.sagebase.Research.camera.processing")
    
    /// The source for the image picker.
    open var sourceType: UIImagePickerController.SourceType {
        return ((self.step as? RSDImagePickerStep)?.sourceType == .photoLibrary) ? .photoLibrary : .camera
    }
    
    /// The camera capture mode for the picker.
    open var cameraCaptureMode: UIImagePickerController.CameraCaptureMode {
        return mediaTypes.contains(.photo) ? .photo : .video
    }
    
    /// The compression quality to use to save the image data to a file.
    open var compressionQuality: CGFloat {
        return 0.5
    }
    
    /// The camera capture mode for the picker.
    open var mediaTypes: [MediaType] {
        guard let types = UIImagePickerController.availableMediaTypes(for: self.sourceType) else { return [] }
        debugPrint(types)
        let rsdTypes = (self.step as? RSDImagePickerStep)?.mediaTypes ?? [.photo]
        let mediaTypes = types.compactMap { (typeString) -> MediaType? in
            guard let mediaType = MediaType(rawValue: typeString), rsdTypes.contains(mediaType.rsdType)
                else {
                    return nil
            }
            return mediaType
        }
        return mediaTypes
    }
    
    /// Override viewDidLoad to insert the image picker.
    open override func viewDidLoad() {
        super.viewDidLoad()

        if mediaTypes.count > 0 {
            _addImagePicker()
        } else {
            errorMessageLabel?.text = Localization.localizedString("CAMERA_NOT_AVAILABLE")
        }
    }
    
    public enum MediaType : String {
        case photo = "public.image"
        case video = "public.movie"
        
        var rsdType : RSDImagePickerMediaType {
            switch self {
            case .photo:
                return .photo
            case .video:
                return .video
            }
        }
    }
    
    private func _addImagePicker() {
        // Check permissions
        let (status, permission) = self.checkAuthorizationStatus()
        switch status {
        case .authorized, .notDetermined, .previouslyDenied:
            self.errorMessageLabel?.isHidden = true
            self.navigationFooter?.isHidden = true
            _insertPickerViewController()
            
        case .restricted:
            errorMessageLabel?.text = permission?.restrictedMessage
        case .denied:
            errorMessageLabel?.text = permission?.deniedMessage
        }
    }
    
    private func _insertPickerViewController() {
        
        // Set up the picker.
        picker.delegate = self
        picker.allowsEditing = false
        picker.mediaTypes = mediaTypes.map { $0.stringValue }
        picker.sourceType = sourceType
        if sourceType == .camera {
            picker.cameraCaptureMode = cameraCaptureMode
        }
                
        // Embed the picker in this view.
        picker.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.addChild(picker)
        picker.view.frame = self.view.bounds
        self.view.addSubview(picker.view)
        picker.view.rsd_alignAllToSuperview(padding: 0)
        picker.didMove(toParent: self)
    }
    
    /// Overridable method for creating a file identifier to use for saving the photo or video to the
    /// output directory.
    open func fileIdentifier() -> String {
        let sectionIdentifier = self.stepViewModel.sectionIdentifier()
        return "\(sectionIdentifier)\(self.step.identifier)_\(UUID().uuidString.prefix(4))"
    }
    
    /// Overridable method for saving the image result. The default behavior is to replace any existing
    /// results associated with this step with the new result.
    open func saveImageResult(_ result: RSDFileResult) {
        self.stepViewModel.taskResult.appendStepHistory(with: result)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    /// Default behavior when the user taps cancel is to go back if there is a step to go back to. Otherwise,
    /// the view controller will cancel the task.
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if self.stepViewModel.parentTaskPath?.hasStepBefore ?? false {
            goBack()
        } else {
            cancel()
        }
    }
    
    /// When the image picker selects the image, the callback will save the image as an `RSDFileResult` and continue.
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let mType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String, let mediaType = MediaType(rawValue: mType)
            else {
                _captureFailed(info)
                return
        }
        
        switch mediaType {
        case .photo:
            _didSelectImage(info)
        case .video:
            _didSelectVideo(info)
        }
    }
    
    private func _captureFailed(_ info: [String : Any]) {
        debugPrint("Failed to capture image: \(info)")
        self.goForward()
    }
    
    private func _didSelectVideo(_ info: [String : Any]) {
        guard let chosenVideoURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL else {
            _captureFailed(info)
            return
        }
        
        var url: URL?
        do {
            url = try RSDFileResultUtility.createFileURL(identifier: fileIdentifier(), ext: "mov",
                                                         outputDirectory: self.stepViewModel.outputDirectory)
            _copyURL(at: chosenVideoURL, to: url!)
        } catch let error {
            debugPrint("Failed to save the camera image: \(error)")
        }
        
        _addFileResult(url)
    }
    
    private func _didSelectImage(_ info: [String : Any]) {
        guard let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            _captureFailed(info)
            return
        }
        
        var url: URL?
        do {
            if let imageData = chosenImage.jpegData(compressionQuality: compressionQuality) {
                url = try RSDFileResultUtility.createFileURL(identifier: fileIdentifier(), ext: "jpeg",
                                                             outputDirectory: self.stepViewModel.outputDirectory)
                _saveImage(imageData, to: url!)
            }
        } catch let error {
            debugPrint("Failed to save the camera image: \(error)")
        }
        
        _addFileResult(url)
    }
    
    func _addFileResult(_ url: URL?) {
        
        // Create the result and set it as the result for this step
        var result: RSDFileResult = (self.stepViewModel.taskResult.findResult(for: self.step) as? RSDFileResult) ?? RSDFileResultObject(identifier: self.step.identifier)
        result.url = url
        saveImageResult(result)
        
        // Go to the next step.
        self.goForward()
    }
    
    private func _saveImage(_ imageData: Data, to url: URL) {
        processingQueue.async {
            do {
                try imageData.write(to: url)
            } catch let error {
                debugPrint("Failed to save the camera image: \(error)")
            }
        }
    }
    
    private func _copyURL(at fromURL: URL, to toURL: URL) {
        processingQueue.async {
            do {
                try FileManager.default.copyItem(at: fromURL, to: toURL)
            } catch let error {
                debugPrint("Failed to copy the url: \(error)")
            }
        }
    }
    
    
    // MARK: Initialization
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: RSDImagePickerStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    open class var bundle: Bundle {
        return Bundle(for: RSDImagePickerStepViewController.self)
    }
    
    /// Default initializer. This initializer will initialize using the `nibName` and `bundle` defined on this class.
    /// - parameter step: The step to set for this view controller.
    public override init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: type(of: self).nibName, bundle: type(of: self).bundle)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
    }
    
    /// Initialize the class using the given nib and bundle.
    /// - note: If this initializer is used with a `nil` nib, then it must assign the expected outlets.
    /// - parameters:
    ///     - nibNameOrNil: The name of the nib or `nil`.
    ///     - nibBundleOrNil: The name of the bundle or `nil`.
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Required initializer. This is the initializer used by a `UIStoryboard`.
    /// - parameter aDecoder: The decoder used to initialize this view controller.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
