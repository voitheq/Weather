//
//  TownViewController.swift
//  Weather
//
//  Created by Wojciech Karaś on 02/02/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit

protocol TownViewControllerDelegate: class {
    func townViewControllerHasNewTown(town: String)
}

class TownViewController: UIViewController {

    weak var delegate: TownViewControllerDelegate?
    
    @IBOutlet weak var townTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        townTextField.delegate = self
        townTextField.becomeFirstResponder()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getWeatherButtonTapped(_ sender: UIButton) {
        if let text = townTextField.text, !text.isEmpty {
            delegate?.townViewControllerHasNewTown(town: text)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - TextField Methods
extension TownViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
