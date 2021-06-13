//
//  ViewController.swift
//  InvestmentTracker
//
//  Created by 招耀華 on 1/6/2021.
//

import UIKit
import SwiftUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    var portfolioBtn: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = .white
//        button.setTitle("See your portfolio", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        return button
//    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CryptoTableViewCell.self,
                           forCellReuseIdentifier: CryptoTableViewCell.identifier)
        return tableView
    }()
    
    private var viewModels = [CryptoTableViewCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Investment Tracker"
        view.addSubview(tableView)
//        view.addSubview(portfolioBtn)
//        portfolioBtn.addTarget(self, action: #selector(didTapPortoflio), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
        
        APICaller.shared.getAllData { [weak self] result in
            switch result {
            case .success(let models):
                self?.viewModels = models.compactMap({ model in
                    // NumberFormatter
//                    let price = $0.last ?? 0
                    let price = model.price_usd ?? 0
                    let formatter = ViewController.numberFormatter
                    let priceString = formatter.string(from: NSNumber(value: price))
                    
                    let iconUrl = URL(
                        string: APICaller.shared.icons.filter({ icon in
                            icon.asset_id == model.asset_id
                        }).first?.url ?? ""
                        )
                    
                    return CryptoTableViewCellViewModel(
                        name: model.name ?? "N/A",
                        symbol: model.asset_id,
                        price: priceString ?? "N/A",
                        iconUrl: iconUrl
                    )
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        portfolioBtn.frame = CGRect(
//            x: 100,
//            y: view.bounds.minY,
//            width: 40,
//            height: 50
//        )
        tableView.frame = view.bounds
    }
//
//    @objc func didTapPortoflio() {
//        let vc = UIHostingController(rootView: Portfolio())
//        present(vc, animated: true)
//    }
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.allowsFloats = true
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .default
        
        return formatter
    }()

    // TableView
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let frame: CGRect = tableView.frame
        
        let portfolioBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50)) //
        portfolioBtn.setTitle("See your portfolio", for: .normal)
        portfolioBtn.backgroundColor = .systemBackground
        portfolioBtn.addTarget(self, action: #selector(didTapPortoflio), for: .touchUpInside)
        
        let headerView: UIView = UIView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: frame.size.width,
                                                      height: frame.size.height))
        headerView.backgroundColor = .secondarySystemBackground
        headerView.addSubview(portfolioBtn)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    @objc func didTapPortoflio(sender: UIButton) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contentView = Portfolio().environment(\.managedObjectContext, context)
        //Button Tapped and open your another ViewController
        let vc = UIHostingController(rootView: contentView)
        present(vc, animated: true)
    }

        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CryptoTableViewCell.identifier,
                for: indexPath
        ) as? CryptoTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIHostingController(rootView: Charts())
        present(vc, animated: true)
    }
}

