//
//  Extensions.swift
//  SimpleMemo
//
//  Created by Jade Yoo on 2023/02/12.
//

import UIKit

extension UIViewController {
    func alert(title: String = "알림", message: String) {
        let alert = UIAlertController(title: "title", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
