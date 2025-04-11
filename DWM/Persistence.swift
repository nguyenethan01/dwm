//
//  Persistence.swift
//  DWM
//
//  Created by Ethan  Nguyen on 4/11/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DWM")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Add mock data if needed
        let count = try? container.viewContext.count(for: Transaction.fetchRequest())
        if count == 0 {
            createSampleData(in: container.viewContext)
        }
    }
    
    // Create sample transaction data
    private func createSampleData(in context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let today = Date()
        
        // Create transactions for today
        createTransaction(amount: 12.99, daysAgo: 0, in: context)
        createTransaction(amount: 25.50, daysAgo: 0, in: context)
        
        // Create transactions for this week (but not today)
        createTransaction(amount: 42.75, daysAgo: 2, in: context)
        createTransaction(amount: 18.35, daysAgo: 3, in: context)
        createTransaction(amount: 65.20, daysAgo: 5, in: context)
        
        // Create transactions for this month (but not this week)
        createTransaction(amount: 89.99, daysAgo: 10, in: context)
        createTransaction(amount: 34.50, daysAgo: 15, in: context)
        createTransaction(amount: 120.00, daysAgo: 20, in: context)
        
        // Create a transaction from previous month (should not be counted)
        createTransaction(amount: 150.00, daysAgo: 35, in: context)
        
        // Save the context
        try? context.save()
    }
    
    private func createTransaction(amount: Double, daysAgo: Int, in context: NSManagedObjectContext) {
        let transaction = Transaction(context: context)
        transaction.amount = amount
        
        if daysAgo > 0 {
            let calendar = Calendar.current
            transaction.date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
        } else {
            transaction.date = Date()
        }
    }
    
    // Preview helper
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Ensure we have sample data for previews
        result.createSampleData(in: viewContext)
        
        return result
    }()
}
