//
//  DataManager.swift
//  SimpleMemo
//
//  Created by Jade Yoo on 2023/02/14.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    private init() {
        
    }
    
    // 코어데이터에서 실행하는 대부분의 작업은 context객체가 담당
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// 메모를 저장할 배열 (빈 배열로 초기화)
    var memoList = [Memo]()
    
    /// 데이터를 읽어오는 함수
    func fetchMemo() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        // 코어데이터가 리턴해주는 데이터는 기본적으로 정렬되어있지 않음 -> SortDescriptor
        // 최근 메모가 위에 표시되도록 날짜를 내림차순으로 정렬
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        // context객체가 제공하는 fetch메서드 사용
        do {
            memoList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }
    
    /// 데이터를 저장하는 함수
    func addNewMemo(_ memo: String?) {
        // 여기서 Memo는 우리가 만든 클래스가 아닌 코어데이터가 만들어준 클래스
        // -> 생성자로 객체를 만들때, context를 전달해야함
        let newMemo = Memo(context: mainContext)
        newMemo.content = memo
        newMemo.insertDate = Date()
        
        // 메모 추가 후 (DB뿐만 아니라 테이블뷰에도 표시하기 위해 배열에도 저장
        memoList.insert(newMemo, at: 0)
        
        // 새 메모를 저장하기 위해선 context를 저장해야함
        // AppDelegate에서 가져온 saveContext() 호출
        saveContext()
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "SimpleMemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
