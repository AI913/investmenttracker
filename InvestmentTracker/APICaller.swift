//
//  APICaller.swift
//  InvestmentTracker
//
//  Created by 招耀華 on 1/6/2021.
//

import Foundation

final class APICaller {

    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "BA9A1CFF-CA6D-4108-A822-AEAFEBBDE5CC"
        static let assetsEndpoint = "https://rest-sandbox.coinapi.io/v1/assets/"
//        static let apiKey = "CvPqGFvAXSHb8h9KDRWgOCVXcHyP5pqeA1D0ud_6"
//        static let assetsEndpoint = "https://ftx.com/api"
    }
    
    private init() {}
    
    public var icons: [Icon] = []
    
    private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void)?
    
    // MARK: - Public
    
    public func getAllData(completion: @escaping (Result<[Crypto], Error>) -> Void) {
        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }
        
        guard let url = URL(string: Constants.assetsEndpoint + "?apikey=" + Constants.apiKey) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                // Decode response
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                completion(.success(cryptos.sorted{ first, second -> Bool in
                    return first.price_usd ?? 0 > second.price_usd ?? 0
                }))
            }
            catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    public func getAllIcons() {
        guard let url = URL(string: Constants.assetsEndpoint + "icons/55/?apikey=" + Constants.apiKey) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                self?.icons = try JSONDecoder().decode([Icon].self, from: data)
                if let completion = self?.whenReadyBlock {
                    self?.getAllData(completion: completion)
                }
            }
            catch {
                print(error)
            }
        }
        
        task.resume()
    }
}
