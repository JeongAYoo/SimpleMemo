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
    // Detail화면에서 편집버튼을 눌러 전달한 (수정할) 메모를 저장
    var editTarget: Memo?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // editTarget 속성에 메모 값이 들어있다면, 편집 모드
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
        } else {
            // editTarget 속성에 전달된 값이 없다면, 쓰기 모드
            navigationItem.title = "새 메모"
            memoTextView.text = ""  // 빈 문자열로 초기화
        }
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
        
//        let newMemo = Memo(content: memo)
//        Memo.dummyMemoList.append(newMemo)
        
        // editTarget을 기준으로 값이 있으면, 편집 모드
        if let target = editTarget {
            target.content = memo
            DataManager.shared.saveContext()    // saveContext() 호출
            // 현재 화면을 닫은 뒤, DetailVC에도 수정사항 바로 업데이트하기 위해 노티
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil)
        } else {
            // 새 메모 쓰기 모드라면
            DataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        }
        
        // 화면 닫기 전 notification 전달

        
        dismiss(animated: true)
    }
    
}

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name("newMemoDidInsert")
    static let memoDidChange = Notification.Name("memoDidChange")
}
