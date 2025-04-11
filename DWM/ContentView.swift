//
//  ContentView.swift
//  DWM
//
//  Created by Ethan  Nguyen on 4/11/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch all transactions
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Summary Cards
                VStack(spacing: 16) {
                    SummaryCard(title: "Today", amount: dailySpending)
                    SummaryCard(title: "This Week", amount: weeklySpending)
                    SummaryCard(title: "This Month", amount: monthlySpending)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Finance Tracker")
        }
    }
    
    // MARK: - Computed Properties for Spending Summaries
    
    private var dailySpending: Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= startOfDay
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var weeklySpending: Double {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= startOfWeek
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var monthlySpending: Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: components)!
        return transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= startOfMonth
        }.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Supporting Views

struct SummaryCard: View {
    let title: String
    let amount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00")
                .font(.system(size: 28, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Formatters

private let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD" // Change this to your preferred currency
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
