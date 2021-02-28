//
//  CoinManager.swift
//  Bitter
//
//  Created by Ethan Smith on 26/02/21.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, _ coinModel: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "FB10A7C8-8F84-462F-9E12-13B9C82F5DB6"
    
    let currencyArray = ["NZD", "AUD", "USD", "GBP"]
    
    func getCoinPrice(forCurrency: String) {
        let exchangeURL = "\(baseURL)/\(forCurrency)?apikey=\(apiKey)"
        performRequest(with: exchangeURL)
    }
    
    func performRequest(with urlString: String) {        
        // Create URL
        if let url = URL.init(string: urlString) {
            
            // Create URL session
            let session = URLSession(configuration: .default)
            
            // Give session a task
            let task = session.dataTask(with: url)
            { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let coinValue = parseJSON(safeData) {
                        self.delegate?.didUpdateCoin(self, coinValue)
                    }
                }
            }
            
            // Start session task JSON retrieval
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let time = decodedData.time
            let rate = decodedData.rate
            
            let coinValue = CoinModel(time: time, rate: rate)
            
            return coinValue
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
