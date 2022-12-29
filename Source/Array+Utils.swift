//
//  Array+Utils.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 12/7/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func after(where elementQuery: (Element) -> (Bool)) -> Element? {
        if let index = self.firstIndex(where: elementQuery), index + 1 < self.count {
            return self[index + 1]
        }
        return nil
    }
    
    func after(_ item: Element) -> Element? {
        if let index = self.firstIndex(of: item) , index + 1 < self.count {
            return self[index + 1]
        }
        return nil
    }
    
    func before(_ item: Element) -> Element? {
        if let index = self.firstIndex(of: item) , index > 0 {
            return self[index - 1]
        }
        return nil
    }
}
