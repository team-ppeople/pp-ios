//
//  Persistence.swift
//  pp
//
//  Created by 김지현 on 2024/04/02.
//

import SwiftUI
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DiaryPostModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("코어데이터 로드 실패!", error.localizedDescription)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveChanges() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("코어데이터 저장 실패!", error.localizedDescription)
            }
        }
    }
    
    // MARK: - 나의 일기 작성
    func create(title: String, contents: String, images: [Data]) {
        let entity = DiaryPost(context: container.viewContext)
        
        entity.id = UUID()
        entity.title = title
        entity.contents = contents
        entity.images = images
        entity.date = Date()
        
        
       
        
        
        
        print("entity 생성 \(entity.id),\(entity.title)")
        print("entity 생성 \(entity.contents),\(entity.images),\(entity.date)")
        saveChanges()
    }
    
    // MARK: - 나의 일기 조회
    func read(fetchLimit: Int? = nil) -> [DiaryPost] {
        var results: [DiaryPost] = []
        let request = NSFetchRequest<DiaryPost>(entityName: "DiaryPost")
        
        if fetchLimit != nil {
            request.fetchLimit = fetchLimit!
        }
        
        do {
            results = try container.viewContext.fetch(request)
            print("나의 일기 조회 성공! \(results.count)개")
            
            
        } catch {
            print("나의 일기 조회 실패!")
        }
        
        return results
    }
    
    // MARK: - 나의 일기 삭제
    func delete(_ entity: DiaryPost) {
        container.viewContext.delete(entity)
        saveChanges()
    }
    
    
    func fetchAllEntities() {
        // Persistence Controller의 Context를 가져옵니다.
        let context = PersistenceController.shared.container.viewContext
        
        // NSFetchRequest를 생성합니다. 여기서 'EntityName'은 Core Data 모델에서 사용한 엔티티의 이름입니다.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DiaryPost")
        
        do {
            // 데이터를 조회합니다.
            let results = try context.fetch(fetchRequest)
            
            // 결과를 처리합니다. 예를 들어, 모든 데이터를 출력할 수 있습니다.
            for result in results as! [NSManagedObject] {
                print(result)
            }
        } catch let error as NSError {
            // 오류 처리
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    
    
    
    
}
