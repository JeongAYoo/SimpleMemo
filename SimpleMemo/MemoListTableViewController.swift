//
//  MemoListTableViewController.swift
//  SimpleMemo
//
//  Created by Jade Yoo on 2023/02/12.
//

import UIKit

class MemoListTableViewController: UITableViewController {
    // MARK: - Properties
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.fetchMemo()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 옵저버 등록: 한번만 등록하면됨. 오퍼레이션큐: 메인큐. 클로저에서 메인큐에서 실행할 코드 입력
        // addObserver 함수는 옵저버를 해제할때 사용하는 객체를 리턴해줌 (token)
        // 뷰가 사라지기 전 or 소멸자에서 해제
        token = NotificationCenter.default.addObserver(forName: ComposeViewController.newMemoDidInsert, object: nil, queue: OperationQueue.main) { [weak self] noti in
            self?.tableView.reloadData()
        }

    }
    
    // 세그웨이가 연결된 화면을 생성하고 화면을 전환하기 직전에 호출되는 메서드
    // segue: 현재 실행중인 세그웨이(source와 destination으로 VC접근 가능)
    // sender: 여기서는 테이블뷰 셀이므로 타입캐스팅
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 셀로 타입캐스팅 후 바인딩된 셀을 통해 indexPath 가져오기. 가져온 indexPath상수로 몇번째 셀인지 확인
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            // UIViewController타입인 source를 타입캐스팅
            if let vc = segue.destination as? DetailViewController {
                vc.memo = DataManager.shared.memoList[indexPath.row]
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.shared.memoList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = DataManager.shared.memoList[indexPath.row]
        cell.textLabel?.text = target.content
        cell.detailTextLabel?.text = formatter.string(for: target.insertDate)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
