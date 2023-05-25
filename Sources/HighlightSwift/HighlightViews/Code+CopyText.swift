//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 5/19/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation


#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension String {
    
    
    @discardableResult
    func copyToClipboard() -> Bool {
        #if os(iOS)
        UIPasteboard.general.string = self
        return true
        #elseif os(macOS)
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        let pasteSuccess = pasteBoard.writeObjects([self as NSString])
        return pasteSuccess
        #endif
        
    }
}


