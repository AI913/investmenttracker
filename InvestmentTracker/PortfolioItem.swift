//
//  PortfolioItem.swift
//  InvestmentTracker
//
//  Created by 招耀華 on 3/6/2021.
//
import UIKit
import Foundation
import CoreData

class PortfolioItem: NSManagedObject, Identifiable {
    @NSManaged var name: String?
    @NSManaged var priceBought: NSDecimalNumber?
    @NSManaged var quantity: NSDecimalNumber?
    @NSManaged var fee: NSDecimalNumber?
    @NSManaged var cost: NSDecimalNumber?
}

extension PortfolioItem {
    static func getAllPortfolioItems() -> NSFetchRequest<PortfolioItem> {
        let request: NSFetchRequest<PortfolioItem> =
            PortfolioItem.fetchRequest() as!
            NSFetchRequest<PortfolioItem>
        
        let sort = NSSortDescriptor(key: "cost", ascending: true)
        request.sortDescriptors = [sort]
        
        return request
    }
    
    func inputInvestmentItems(entity: String, name: String, idAttributeName:String) -> [String] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        
//        fetchRequest.predicate = NSPredicate(format: "name IN %@", names)

        var inputItems: [NSManagedObject] = []
        var names: [String] = []

        do {
            inputItems = try context.fetch(fetchRequest)
            for inputItem in inputItems {
                names.append(inputItem.value(forKey: name) as! String)
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }

        return names
    }
}
