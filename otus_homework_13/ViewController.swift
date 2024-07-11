//
//  ViewController.swift
//  otus_homework_13
//
//  Created by Поляков Станислав Денисович on 09.07.2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var pickerView: UIPickerView?
    
    private var currencies: [CurrencyResponse] = []
    private var currencyCodeSelected: String?
    private let repository = NetworkRepositoryImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView?.dataSource = self
        pickerView?.delegate = self
        
        Task {
            do {
                currencies = try await repository.getCurrencies()
                self.pickerView?.reloadAllComponents()
            } catch {
                if let networkError = error as? NetworkError {
                    print(networkError.self)
                }
            }
        }
    }
    
    @IBAction func didTapOnLoadButton() {
        Task {
            do {
                guard let code = currencyCodeSelected else { return }
                let points = try await repository.getPoints(currencyCode: code)
                
                guard !points.isEmpty else {
                    print("no points available")
                    return
                }
                let chartData = try await repository.getChart(points: points)
                
                DispatchQueue.main.async { [weak self] in
                    self?.imageView?.image = UIImage(data: chartData)
                }
            } catch {
                if let networkError = error as? NetworkError {
                    print(networkError.self)
                }
            }
        }
    }
}

extension ViewController : UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        currencies.count
    }
}

extension ViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        currencies[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currencyCodeSelected = currencies[row].code
    }
}

