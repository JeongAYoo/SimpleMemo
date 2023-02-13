//
//  DetailViewController.swift
//  SimpleMemo
//
//  Created by Jade Yoo on 2023/02/12.
//

import UIKit

class DetailViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var memoTableView: UITableView!
    
    var memo: Memo?     // 이전 화면에서 전달한 데이터 저장

    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        //f.locale = Locale(identifier: "Ko_kr")    // 알아서 한국어로 나옴
        return f
    }()
    
    var token: NSObjectProtocol?
    // MARK: - Life cycle
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // notification observer 추가
        token = NotificationCenter.default.addObserver(forName: ComposeViewController.memoDidChange, object: nil, queue: OperationQueue.main, using: { [weak self] noti in
            self?.memoTableView.reloadData()
        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 네비게이션 컨트롤러를 거쳐서 연결된 첫번째 ComposeVC로 수정할 메모 데이터를 전달
        if let vc = segue.destination.children.first as? ComposeViewController {
            vc.editTarget = memo
        }
    }
    
    // MARK: - Actions
    @IBAction func deleteMemo(_ sender: Any) {
        let alert = UIAlertController(title: "삭제 확인", message: "메모를 삭제할까요?", preferredStyle: .alert)
        
        // destructive: 빨간색 텍스트로 표시
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] action in
            // 현재 화면에 표시되어있는 메모를 전달 (메모 삭제)
            DataManager.shared.deleteMemo(self?.memo)
            // 현재 화면 닫기
            self?.navigationController?.popViewController(animated: true)
        }
        
        // 어떤 액션을 선택하든지, 경고창은 사라지므로 취소액션에는 핸들러 구현X
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}

// MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath)
            
            cell.textLabel?.text = memo?.content
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
            // string(for:) 메서드: string(from:)메서드는 옵셔널값 전달불가. 얘는 Any?타입을 문자열로 변환
            cell.textLabel?.text = formatter.string(for: memo?.insertDate)
            
            return cell
        default:
            fatalError()    // crash발생(새로운 코드 추가해야한다고 알리기위해)
        }
    }
}
