//
//  OperationDataManager.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import UIKit

class WriteOperation: Operation {
    
    let profile: Profile
    let fileName: String
    var successFlag = false // to check if operation is over
    init(fileName: String, profile: Profile) {
        self.fileName = fileName
        self.profile = profile
    }
    
    override func main() {
        successFlag = false
        if NSKeyedArchiver.archiveRootObject(profile, toFile: fileName) {
            successFlag = true
        }
    }
}

class ReadOperation: Operation {
    //
    var profile = Profile()
    //
    let fileName: String
    init(fileName: String) {
        self.fileName = fileName
    }
    
    override func main() {
        if let savedProfile = NSKeyedUnarchiver.unarchiveObject(withFile: fileName) as? Profile {
            profile = savedProfile
        }
    }
}

class OperationDataManager: DataManagerProtocol {
    // operation queue initialization
    var operationQueue: OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }
    
    func write(profile: Profile, completion: @escaping (Bool) -> ()) {
        let writeOperation = WriteOperation(fileName: fileName, profile: profile)
        writeOperation.completionBlock = {
            OperationQueue.main.addOperation {
                completion(writeOperation.successFlag)
            }
        }
        operationQueue.addOperation(writeOperation)
    }
    
    func read(completion: @escaping (Profile) -> ()) {
        let readOperation = ReadOperation(fileName: fileName)
        readOperation.completionBlock = {
            OperationQueue.main.addOperation {
                completion(readOperation.profile)
            }
        }
        operationQueue.addOperation(readOperation)
    }
}

