//
//  ViewController.swift
//  Bitter
//
//  Created by Ethan Smith on 26/02/21.
//

import UIKit

class BitcoinViewController: UIViewController {
    let formatter = NumberFormatter()
    
    var displayLink = CADisplayLink()
    
    var coinManager = CoinManager()
    
    var currentPrice = 1000
    
    var destinationNumber = 30
    var timer: Timer!
    
    @IBOutlet weak var currentBTCPrice: UILabel!
    @IBOutlet weak var currentCurrency: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Prepare delegates and UIPickerView data source
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        coinManager.delegate = self
        
        // Prepare number formatter
        formatter.numberStyle = .decimal
        
        // Get default currency as app loads
        coinManager.getCoinPrice(forCurrency: "NZD")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currencyType = coinManager.currencyArray[row]
        currentCurrency.text = "1 \(currencyType)"
        coinManager.getCoinPrice(forCurrency: currencyType)
    }
    
    
    // Load updated BTC count with animation
    func updateBTCCount() {
        if currentPrice < destinationNumber {
            self.displayLink = CADisplayLink(target: self, selector: #selector(tickUp))
        } else {
            self.displayLink = CADisplayLink(target: self, selector: #selector(tickDown))
        }
        self.displayLink.add(to: .current, forMode: .default)
    }
    
    //MARK: - UI Animation Section
    
    // Increase to higher value BTC
    @objc func tickUp() {
        if currentPrice < destinationNumber {
            let priceGain = Double(currentPrice / destinationNumber)
            switch priceGain {
            case ..<0.85:
                currentPrice = Int(Double(currentPrice) + (Double(destinationNumber) * 0.01))
            default:
                currentPrice += 1
            }
            currentBTCPrice.text = "\(formatter.string(from: NSNumber(value: Int(currentPrice))) ?? "0") BTC"
        } else {
            endUpdates()
        }
    }
    
    // Decrease to lower value BTC
    @objc func tickDown() {
        if destinationNumber < currentPrice {
            let priceGain = Double(destinationNumber / currentPrice)
            switch priceGain {
            case ..<0.85:
                currentPrice = Int(Double(currentPrice) - (Double(destinationNumber) * 0.01))
            default:
                currentPrice -= 1
            }
            currentBTCPrice.text = "\(formatter.string(from: NSNumber(value: Int(currentPrice))) ?? "0") BTC"
        } else {
            endUpdates()
        }
    }
    
    func endUpdates(){
        self.displayLink.invalidate()
        self.displayLink = CADisplayLink()
    }
}

//MARK: - CoinManagerDelegate

extension BitcoinViewController: CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, _ coinModel: CoinModel) {
        DispatchQueue.main.async {
            self.destinationNumber = Int(coinModel.rate)
            self.updateBTCCount()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        print("Failed")
    }
}

//MARK: - UIPickerViewDelegate

extension BitcoinViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
    }
}
