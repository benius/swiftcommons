//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

import UIKit

class KeyboardNotification {
    
    var notification: Notification
    
    init(notification: Notification!) {
        self.notification = notification
    }
    
    /**
     The method moves up the root view of the viewController so the benchmark is not blocked,
     entirely or partially, by the keyboard.
     If the sender is out of the top screen or blocked by the navigation bar, entirely or partially,
     after the root view moved up, the root view then moves up only to the extend that the sender is
     inside the top screen and is not blocked by the navigation bar, if any.
     - parameters:
       - benchmark: The view moves up when the keyboard blocks, entirely or partially, this view.
                    The benchmark could be the sender or not.
       - sender: If the sender is blocked, entirely or partially by the top of the screen or the navigation bar
                 after the benchmark view moved up, the view of the viewController moves up to the location where
                 this sender is not blocked. The sender could be the same view of benchmark or not.
       - viewController: The root view of this viewController is the superview (or superview of superview, etc.)
                         of the benchmark and the sender.
     */
    func keyboardDidShow(withBenchmark benchmark: UIView!, sender: UIView!, viewController: UIViewController!) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return;
        }
        
        let rootView = viewController.view!
        
        // Get the location of benchmark relative to self.view
        let benchmarkRelativeFrame = benchmark.convert(benchmark.frame, to: rootView)
        
        let benchmarkDefaultMoveUp = (benchmarkRelativeFrame.origin.y + benchmarkRelativeFrame.height) - keyboardSize.origin.y
        
        // The benchmark is not moved because it is not blocked by the keyboard.
        if benchmarkDefaultMoveUp <= 0 {
            return;
        }
        
        // When benchmarkDefaultMoveUp > 0, the benchmark is blocked, entirely or partially, by the keyboard.
        // If the sender is in the range of the top screen and not blocked by the navigation bar, if any,
        // the root view moves up to the value of benchmarkDefaultMoveUp; otherwise, the root view moves up
        // to the the extend that the sender is NOT out of the range of the top screen.
        
        // Get the location of the sender relative to self.view
        let senderRelativeOrigin = sender.convert(sender.frame.origin, to: rootView)
        
        let senderNewOriginY = senderRelativeOrigin.y - benchmarkDefaultMoveUp
        
        // test if navigation controller exists
        // If navigationViewHeight > 0, then height of the navigation bar will be tested;
        // otherwise, the location of the top screen will be tested instead.
        let navigationViewHeight = viewController.navigationController?.navigationBar.frame.height ?? 0
        
        if (senderNewOriginY < navigationViewHeight) {
            // The navigation bar (or the top the screen) blocks the sender, entirely or partially after the view moved up.
            // The root view of the view controller can only be moved up to the extend that the sender is not blocked.
            rootView.frame.origin.y = -(navigationViewHeight - (navigationViewHeight - senderNewOriginY))
        } else {
            // The navigation bar (or the top the screen) does not block the sender at all and the root view of the
            // controller moves up so that the benchmark is not bloced by the keyboard.
            rootView.frame.origin.y = -benchmarkDefaultMoveUp
        }
    }
    
    /**
     The method pairs with #keyboardDidShow(withBenchmark benchmark: UIView!, sender: UIView!, viewController: UIViewController!).
     When you invoke method #keyboardDidShow(...) on NSNotification.Name.UIKeyboardDidShow, you should invoke this method on
     NSNotification.Name.UIKeyboardDidHide.
     */
    func keyboardDidHide(withViewController viewController: UIViewController!) {
        viewController.view.frame.origin.y = 0
    }
}
