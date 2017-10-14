//
//  Collection+Extensions.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 10.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
extension Collection where Index: Strideable {//, Indices == CountableRange<Index> {
    func safeNextIndex(for index: Index, cyclic: Bool) -> Index {
        if self.startIndex == self.endIndex {
            return self.startIndex
        }
        
        let lastIndex = self.endIndex.advanced(by: -1)
        
        var currentIndex = index >= lastIndex ? lastIndex : index
        currentIndex = index <= self.startIndex ? self.startIndex : index

        // asks for acyclic
        if cyclic {
            return lastIndex == currentIndex ? self.startIndex : currentIndex.advanced(by: 1)
        }
        else {
            return currentIndex
        }
    }
    
    func safePreviousIndex(for index: Index, cyclic: Bool) -> Index {
        if self.startIndex == self.endIndex {
            return self.startIndex
        }
        
        let lastIndex = self.endIndex.advanced(by: -1)
        
        var currentIndex = index >= lastIndex ? lastIndex : index
        currentIndex = index <= self.startIndex ? self.startIndex : index

        // asks for acyclic
        if cyclic {
            return self.startIndex == index ? lastIndex : currentIndex.advanced(by: -1)
        }
        else {
            return currentIndex
        }
    }
}
