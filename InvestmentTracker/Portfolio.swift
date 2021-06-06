//
//  List.swift
//  InvestmentTracker
//
//  Created by 招耀華 on 3/6/2021.
//

import SwiftUI

struct Portfolio: View {
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(fetchRequest: PortfolioItem.getAllPortfolioItems())
    var items: FetchedResults<PortfolioItem>
    
    @State var text: String = ""
    @State var priceStr: String = ""
    @State var price: Double = 0
    @State var quanStr: String = ""
    @State var quantity: Double = 0
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("New investment")) {
                    HStack {
                        VStack {
                            TextField("Enter the stock/crypto you own...", text: $text)
                            TextField("Enter the price at which your bought...",
                                      text: $priceStr
                            ).keyboardType(UIKeyboardType.decimalPad).onChange(of: priceStr) { priceStr in
                                price = Double(priceStr) ?? 0
                            }
                            TextField("Enter the quantity you own...",
                                      text: $quanStr
                            ).keyboardType(UIKeyboardType.decimalPad).onChange(of: quanStr) { quanStr in
                                quantity = Double(quanStr) ?? 0
                            }
                            Text("It cost USD\(price * quantity).")
                        }
                        
                        Button(action: {
                            UIApplication.endEditing()    // << here !!
                            price = Double(priceStr) ?? 0
                            quantity = Double(quanStr) ?? 0
                            
                            if !text.isEmpty {
                                let newItem = PortfolioItem(context: context)
                                newItem.name = text
                                print(price, quantity)
                                newItem.worth = NSDecimalNumber(value: price * quantity)
                                
                                do {
                                    try context.save()
                                }
                                catch {
                                    print(error)
                                }
                                
                                text = ""
                                priceStr = ""
                                quanStr = ""
                            }
                        }, label: {
                            Text("Save")
                        })
                    }
                }
                
                Section {
                    ForEach(items) { portfolioItem in
                        VStack(alignment: .leading) {
                            Text(portfolioItem.name!)
                                .font(.headline)
                            Text("\(portfolioItem.worth!)")
                        }
                    }.onDelete(perform: { indexSst in
                        guard let index = indexSst.first else {
                            return
                        }
                        let itemToDelete = items[index]
                        context.delete(itemToDelete)
                        do {
                            try context.save()
                        }
                        catch {
                            print(error)
                        }
                    })
                }
            }
            .navigationTitle("Input investment")
        }
    }
}

struct Portfolio_Previews: PreviewProvider {
    static var previews: some View {
        Portfolio()
    }
}

extension UIApplication {  // just helper extension
    static func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
