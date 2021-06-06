//
//  Charts.swift
//  InvestmentTracker
//
//  Created by 招耀華 on 2/6/2021.
//
import SwiftUICharts
import SwiftUI
import CoreData

class FetchedPortfolio {
    var portfolio: [Double] = []

    func fetchData() -> [Double]{

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PortfolioItem")

        do {
            let results = try context.fetch(fetchRequest)
            let dateCreated = results as! [PortfolioItem]

            for portfolioItem in dateCreated {
                print(portfolioItem.worth)
                portfolio.append(portfolioItem.worth as! Double)
            }
            print(portfolio)
        }catch let err as NSError {
            print(err.debugDescription)
        }
        return(portfolio)
    }
    
    
}

struct Charts: View {

    @State var quantity: Double = 0
    @State var price: Double = 0
    
    var body: some View {
        VStack {
            // Total Investment Value Change(Line)
            // Total Investment Portfolio change in %(Pie)
            Spacer()
            // Line
            LineChartView(data: [12, 22, 6, 1, 2, 18, 7], title: "Line Chart")
            
            Spacer()

            // Bar
            BarChartView(data: ChartData(values: [
                ("Jan", 12),
                ("Feb", 7),
                ("Mar", 3),
                ("Apr", 22),
                ("May", 15),
            ]),
            title: "Bar Chart")
            Spacer()

            // Pie
            PieChartView(
                data: FetchedPortfolio().fetchData(),
                title: "Pie Chart"
            )
            Spacer()
        }
    }
}

struct Charts_Previews: PreviewProvider {
    static var previews: some View {
        Charts()
    }
}
