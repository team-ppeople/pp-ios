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
        container = NSPersistentContainer(name: "DiaryPost")
        
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
}
