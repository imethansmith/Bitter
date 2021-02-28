//
//  ViewController.swift
//  Bitter
//
//  Created by Ethan Smith on 26/02/21.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var coinManager = CoinManager()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
    }
    
    @IBOutlet weak var currentBTCPrice: UILabel!
    @IBOutlet weak var currentCurrency: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        coinManager.delegate = self
        // Do any additional setup after loading the view.
        
        coinManager.getCoinPrice(forCurrency: "NZD")
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currencyType = coinManager.currencyArray[row]
        currentCurrency.text = "1 \(currencyType)"
        coinManager.getCoinPrice(forCurrency: currencyType)
    }
}

extension ViewController: CoinManagerDelegate {
    
    func didUpdateCoin(_ coinManager: CoinManager, _ coinModel: CoinModel) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
    
        DispatchQueue.main.async {
            self.currentBTCPrice.text = "\(formatter.string(from: NSNumber(value: Int(coinModel.rate))) ?? "0") BTC"
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        print("Failed")
    }
}
