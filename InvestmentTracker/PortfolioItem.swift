//
//  PortfolioItem.swift
//  InvestmentTracker
//
//  Created by 招耀華 on 3/6/2021.
//

import Foundation
import CoreData

class PortfolioItem: NSManagedObject, Identifiable {
    @NSManaged var name: String?
    @NSManaged var worth: NSDecimalNumber?
}

extension PortfolioItem {
    static func getAllPortfolioItems() -> NSFetchRequest<PortfolioItem> {
        let request: NSFetchRequest<PortfolioItem> =
            PortfolioItem.fetchRequest() as!
            NSFetchRequest<PortfolioItem>
        
        let sort = NSSortDescriptor(key: "worth", ascending: true)
        request.sortDescriptors = [sort]
        
        return request
    }
}
