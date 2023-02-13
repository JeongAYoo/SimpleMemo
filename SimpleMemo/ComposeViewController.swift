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
    /// Detail화면에서 편집버튼을 눌러 전달한 (수정할) 메모를 저장
    var editTarget: Memo?
    /// 편집 이전의 메모 내용을 저장 (modal로 띄워진 화면에서 수정후 그대로 창을 내렸을때 위해)
    var originalMemoContent: String?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // editTarget 속성에 메모 값이 들어있다면, 편집 모드
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
        } else {
            // editTarget 속성에 전달된 값이 없다면, 쓰기 모드
            navigationItem.title = "새 메모"
            memoTextView.text = ""  // 빈 문자열로 초기화
        }
        
        memoTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 편집화면이 표시되기 직전에 뷰컨이 델리게이트로 설정됨
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 편집화면이 사라지기 직전에 델리게이트 해제
        navigationController?.presentationController?.delegate = nil
    }
    
    // MARK: - Actions
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
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

extension ComposeViewController: UITextViewDelegate {
    // 텍스트뷰의 내용이 바뀔때마다 반복적으로 호출
    func textViewDidChange(_ textView: UITextView) {
        if let original = originalMemoContent, let edited = textView.text {
            // 모달방식으로 동작해야하는지 설정하는 플래그(Bool)
            // pull down으로 시트를 닫기 전에 델리게이트 함수를 호출
            isModalInPresentation = original != edited
            // 오리지널 메모와 편집된 메모가 다를 때 true를 저장
            // -> presentationControllerDidAttemptToDismiss함수가 호출됨
        }
    }
}

extension ComposeViewController: UIAdaptivePresentationControllerDelegate {
    // (메모를 수정 후) pull down으로 사용자가 시트를 닫기 전 호출
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        // 경고창 띄우기
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.save(action)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] action in
            self?.close(action)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name("newMemoDidInsert")
    static let memoDidChange = Notification.Name("memoDidChange")
}
