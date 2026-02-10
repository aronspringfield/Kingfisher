//
//  OrderedOperationQueue.swift
//  Kingfisher
//
//  Created by Aron Springfield on 10/02/2026.
//  Copyright © 2026 Wei Wang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public final class OrderedOperationQueue: @unchecked Sendable {
    public enum QueueOrder {
        case firstInFirstOut
        case lastInFirstOut
    }

    private let queue: OperationQueue
    private var lastOperation: Operation?

    private let order: QueueOrder

    public var maxConcurrentOperationCount: Int {
        set {
            queue.maxConcurrentOperationCount = newValue
        }
        get {
            queue.maxConcurrentOperationCount
        }
    }

    var underlyingQueue: dispatch_queue_t? {
        queue.underlyingQueue
    }

    public init(qualityOfService: QualityOfService, order: QueueOrder, maxConcurrentOperationCount: Int) {
        queue = OperationQueue()
        queue.name = "KF.OrderedOperationQueue"
        queue.qualityOfService = qualityOfService
        queue.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.order = order
    }

    func add(_ block: @Sendable @escaping () -> Void) {
        let op = BlockOperation(block: block)

        if order == .lastInFirstOut, let lastOperation {
            lastOperation.addDependency(op)
        }

        lastOperation = op
        queue.addOperation(op)
    }
}
