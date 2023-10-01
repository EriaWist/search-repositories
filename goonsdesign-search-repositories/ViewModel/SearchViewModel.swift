//
//  SearchViewModel.swift
//  goonsdesign-search-repositories
//
//  Created by 黃子騰 on 2023/9/25.
//

import Foundation
import Combine

class SearchViewModel{
    weak var delegate: ViewModelDelegate?
    var cancellBag = Set<AnyCancellable>()
    var selectRepository:RepositoriesItem? = nil
    var tmpQuery:String? = nil
    private var _repositoriesItem:[RepositoriesItem] = []
    {
        didSet{
            delegate?.update()
        }
    }
    func getImageData(repositoriesItem:[RepositoriesItem]) {
        repositoriesItem.publisher
            .map(\.owner.avatar_url)//過濾url
            .flatMap(maxPublishers:.max(100)) { url in
                URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
                    .map(\.data)
                    .replaceError(with: Data())
            }//抓圖最大同時抓取為100
            .zip(repositoriesItem.publisher)//把抓下來的資料與原本暫存的資料做zip
            .map{ (imageData, item) -> RepositoriesItem in
                item.imageData = imageData
                return item
            }//將暫存的資料與圖像Data合併
            .sink(receiveValue: { item in
                self._repositoriesItem.first(where: {$0.id == item.id})?.imageData = item.imageData
                self.delegate?.update()
                //透過比對id有資料時就塞imageData並且發布更新
            }).store(in: &cancellBag)
    }
    var repositoriesItem:[RepositoriesItem]{
        get{
            _repositoriesItem
        }
    }
    func fetchData(query:String?) {
        _repositoriesItem = []
        if let query = query{
            tmpQuery = query
            repositoriesPublisher(query: query)?
                .sink(receiveCompletion: {error in
                    print(error)
                }, receiveValue: { repositories in
                    self._repositoriesItem = repositories.items//先將文字資料存入
                    self.getImageData(repositoriesItem: repositories.items)
                })
                .store(in: &cancellBag)
        }
    }
    private func repositoriesPublisher(query:String) -> AnyPublisher<Repositories,Error>? {
        guard let urlStr = "https://api.github.com/search/repositories?q=\(query)".addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed),let url = URL(string: urlStr) else{
            return nil
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: Repositories.self, decoder: JSONDecoder())//解碼
            .eraseToAnyPublisher()//轉換成AnyPublisher
    }
}
