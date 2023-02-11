//
//  ComposeViewController.swift
//  SimpleMemo
//
//  Created by Jade Yoo on 2023/02/12.
//

import UIKit

class ComposeViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var memoTextView: UITextView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Actions
    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let memo = memoTextView.text,
              memo.count > 0 else {
            alert(message: "메모를 입력하세요")
            return
        }
        
        let newMemo = Memo(content: memo)
        Memo.dummyMemoList.append(newMemo)
        
        // 화면 닫기 전 notification 전달
        NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        
        dismiss(animated: true)
    }
    
}

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name("newMemoDidInsert")
}
