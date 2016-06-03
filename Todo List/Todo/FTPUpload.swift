//
//  FTPUpload.swift
//  Todo
//
//  Created by User on 3/12/16.
//  Copyright © 2016 Xincun Li. All rights reserved.
//

import Foundation


class FTPupload : NSObject, NSStreamDelegate {
    
    static func upload(localFileName:String){
        let data    = NSData(contentsOfFile: localFileName)!
        let buf     = (UnsafePointer<UInt8>(data.bytes))
        let buf2    = (UnsafePointer<Void>(data.bytes))
        let buf3    = (UnsafeMutablePointer<Void>(data.bytes))
        print(data.length)
        
        var leftOverSize        = data.length
        let bytesFile           = data.length
        var totalBytesWritten   = 0
        var bytesWritten        = 0
        
        let user = ""
        let password = ""
        let host = ""
        let port = ""
        
        let ftpUrl      = NSURL(string: "ftp://\(user):\(password)@\(host):\(port)/\(TodoDBParameters.dbName)")
        let stream      = CFWriteStreamCreateWithFTPURL(nil,ftpUrl!).takeUnretainedValue()
        let cfstatus    = CFWriteStreamOpen(stream)
        // connection fail
        if cfstatus {
            print("Not connected")
        }
        
        
        repeat{
            // Write the data to the write stream
            bytesWritten = CFWriteStreamWrite(stream, buf, leftOverSize)
            print("bytesWritten: \(bytesWritten)")
            if (bytesWritten > 0) {
                totalBytesWritten += bytesWritten
                // Store leftover data until kCFStreamEventCanAcceptBytes event occurs again
                if (bytesWritten < bytesFile) {
                    leftOverSize = bytesFile - totalBytesWritten
                    memmove(buf3, buf2 + bytesWritten, leftOverSize)
                }else{
                    leftOverSize = 0
                }
                
            }else{
                print("CFWriteStreamWrite returned \(bytesWritten)")
                break
            }
            
            if CFWriteStreamCanAcceptBytes(stream) {
                sleep(1)
            }
        }while((totalBytesWritten < bytesFile))
        
        print("totalBytesWritten: \(totalBytesWritten)")
        
        CFWriteStreamClose(stream)
    }
    
}