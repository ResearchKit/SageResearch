//
//  CRFHeartRateVideoProcessor.h
//  CardiorespiratoryFitness
//
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

struct CRFPixelSample {
    double presentationTimestamp;
    double red;
    double green;
    double blue;
    double redSD;
    bool isCoveringLens;
};

@class CRFHeartRateVideoProcessor;

@protocol CRFHeartRateVideoProcessorDelegate <NSObject>

@required
- (void)processor:(CRFHeartRateVideoProcessor *)processor didCaptureSample:(struct CRFPixelSample)sample;

@optional
- (void)processor:(CRFHeartRateVideoProcessor *)recorder didFailToRecordWithError:(NSError *)error;

@end

@interface CRFHeartRateVideoProcessor : NSObject

@property (nonatomic, readonly) int frameRate;
@property (nonatomic, readonly) double startSystemUptime;

@property (nonatomic, nullable, readonly) NSURL *videoURL;

- (instancetype)initWithDelegate:(id<CRFHeartRateVideoProcessorDelegate>)delegate frameRate:(int)frameRate callbackQueue:(dispatch_queue_t)queue NS_SWIFT_NAME(init(delegate:frameRate:callbackQueue:));

- (void)startRecordingToURL:(NSURL *)url startTime:(CMTime)time formatDescription:(CMFormatDescriptionRef)formatDescription NS_SWIFT_NAME(startRecording(to:startTime:formatDescription:));

- (void)stopRecordingWithCompletion:(void (^)(void))completion NS_SWIFT_NAME(stopRecording(_:));

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
