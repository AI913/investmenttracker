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
    @State var feeStr: String = ""
    @State var fee: Double = 0
    
    @State var predictableStocks: Array<String> = ["BTC", "ETH", "ADA", "AAPL"]
    @State var predictedValue: Array<String> = []
    
    @State var isPresented = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Input new investment")) {
                        VStack {
                            HStack {
                                Text("Name:")
                                TextField("Stock/crypto you own", text: $text)
                                    .multilineTextAlignment(.trailing)
                                //                                .frame(width: nil, height: nil, alignment: .trailing)
                            }
                        }
                        HStack {
                            Text("Name:")
                            PredictingTextField(predictableStocks: self.$predictableStocks, predictedValues: self.$predictedValue, textFieldInput: self.$text)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            Text("Price: USD")
                            TextField("Price at which your bought",
                                      text: $priceStr
                            ).keyboardType(UIKeyboardType.decimalPad).onChange(of: priceStr) { priceStr in
                                price = Double(priceStr) ?? 0
                            }
                            .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Quantity:")
                            TextField("Quantity you own",
                                      text: $quanStr
                            ).keyboardType(UIKeyboardType.decimalPad).onChange(of: quanStr) { quanStr in
                                quantity = Double(quanStr) ?? 0
                            }
                            .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Transaction fee: USD")
                            TextField("Transaction fee",
                                      text: $feeStr
                            ).keyboardType(UIKeyboardType.decimalPad).onChange(of: feeStr) { feeStr in
                                fee = Double(feeStr) ?? 0
                            }
                            .multilineTextAlignment(.trailing)
                            
                        }
                        
                        Text("Total cost USD\(price * quantity + fee).")
                        
                        //   Text("Total cost of your portfolio: USD\( )")
                        
                        Button(action: {
                            UIApplication.endEditing()    // << here !!
                            
                            price = Double(priceStr) ?? 0
                            quantity = Double(quanStr) ?? 0
                            fee = Double(feeStr) ?? 0
                            
                            if !text.isEmpty {
                                let newItem = PortfolioItem(context: context)
                                newItem.name = text
                                print(price, quantity)
                                newItem.priceBought = NSDecimalNumber(value: price)
                                newItem.quantity = NSDecimalNumber(value: quantity)
                                newItem.fee = NSDecimalNumber(value: fee)
                                newItem.cost = NSDecimalNumber(value: price * quantity + fee)
                                
                                do {
                                    try context.save()
                                }
                                catch {
                                    print(error)
                                }
                                
                                text = ""
                                priceStr = ""
                                quanStr = ""
                                feeStr = ""
                            }
                        }, label: {
                            Text("Save")
                        })
                    }
                                        
                    Spacer()
                    
                    Section(header: Text("Investment record")) {
                        ForEach(items) { portfolioItem in
//                            Section(header: Text("\(portfolioItem.name)")) {
                                VStack(alignment: .leading) {
                                    Text(portfolioItem.name!)
                                        .font(.headline)
                                    Text("Price when you bought: \(portfolioItem.priceBought!)")
                                    Text("Quantity: \(portfolioItem.quantity!)")
                                    Text("Fee: \(portfolioItem.fee!)")
                                    Text("Cost: \(portfolioItem.cost!)")
                                    // Text("Cost: \(portfolioItem.priceNow!)")
                                    // Text("Cost: \(portfolioItem.worth!)")
                                }
//                            }
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
                    
                    Button(action: {
                        self.isPresented.toggle()
                    }, label: {
                        Text("See charts")
                    })
                    .sheet(
                        isPresented: $isPresented,
                        content: {
                            Charts()
                        }
                    )
                    
                }.navigationTitle("Portfolio")
                
                VStack {
                    Section {
                        ForEach(self.predictedValue, id: \.self){ value in
                            Text(value)
                                .onTapGesture {
                                    text = value
                                }
                        }
                        
                    }
                    .background(Color(UIColor.systemBackground))
                }
                .position(x: 300, y: 120)
            }

        }
    }
}

struct Portfolio_Previews: PreviewProvider {
    static var previews: some View {
        Portfolio()
            .previewDevice("iPhone 12")
    }
}

extension UIApplication {  // just helper extension
    static func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}

/// TextField capable of making predictions based on provided predictable values
struct PredictingTextField: View {
    
    /// All possible predictable values. Can be only one.
    @Binding var predictableStocks: Array<String>
    
    /// This returns the values that are being predicted based on the predictable values
    @Binding var predictedValues: Array<String>
    
    /// Current input of the user in the TextField. This is Binded as perhaps there is the urge to alter this during live time. E.g. when a predicted value was selected and the input should be cleared
    @Binding var textFieldInput: String
    
    /// The time interval between predictions based on current input. Default is 0.1 second. I would not recommend setting this to low as it can be CPU heavy.
    @State var predictionInterval: Double?
    
    /// Placeholder in empty TextField
    @State var textFieldTitle: String?
    
    @State private var isBeingEdited: Bool = false
    
    init(predictableStocks: Binding<Array<String>>, predictedValues: Binding<Array<String>>, textFieldInput: Binding<String>, textFieldTitle: String? = "", predictionInterval: Double? = 0.1){
        
        self._predictableStocks = predictableStocks
        self._predictedValues = predictedValues
        self._textFieldInput = textFieldInput
        
        self.textFieldTitle = textFieldTitle
        self.predictionInterval = predictionInterval
    }
    
    var body: some View {
        TextField(self.textFieldTitle ?? "", text: self.$textFieldInput, onEditingChanged: { editing in self.realTimePrediction(status: editing)}, onCommit: { self.makePrediction()})
    }
    
    /// Schedules prediction based on interval and only a if input is being made
    private func realTimePrediction(status: Bool) {
        self.isBeingEdited = status
        if status == true {
            Timer.scheduledTimer(withTimeInterval: self.predictionInterval ?? 1, repeats: true) { timer in
                self.makePrediction()
                
                if self.isBeingEdited == false {
                    timer.invalidate()
                }
            }
        }
    }
    
    /// Capitalizes the first letter of a String
    private func capitalizeFirstLetter(smallString: String) -> String {
        return smallString.prefix(1).capitalized + smallString.dropFirst()
    }
    
    /// Makes prediciton based on current input
    private func makePrediction() {
        self.predictedValues = []
        if !self.textFieldInput.isEmpty{
            for value in self.predictableStocks {
                if self.textFieldInput.split(separator: " ").count > 1 {
                    self.makeMultiPrediction(value: value)
                }else {
                    if value.contains(self.textFieldInput) || value.contains(self.capitalizeFirstLetter(smallString: self.textFieldInput)){
                        if !self.predictedValues.contains(String(value)) {
                            self.predictedValues.append(String(value))
                        }
                    }
                }
            }
        }
    }
    
    /// Makes predictions if the input String is splittable
    private func makeMultiPrediction(value: String) {
        for subString in self.textFieldInput.split(separator: " ") {
            if value.contains(String(subString)) || value.contains(self.capitalizeFirstLetter(smallString: String(subString))){
                if !self.predictedValues.contains(value) {
                    self.predictedValues.append(value)
                }
            }
        }
    }
}
