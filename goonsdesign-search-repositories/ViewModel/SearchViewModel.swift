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
            .map(\.owner.avatar_url)
            .flatMap(maxPublishers:.max(1)) { url in
                URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
                    .map(\.data)
                    .replaceError(with: Data())
            }
            .zip(repositoriesItem.publisher)
            .map{ (imageData, item) -> RepositoriesItem in
                item.imageData = imageData
                return item
            }
            .collect()
            .sink(receiveValue: {
                self._repositoriesItem = $0
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
                }, receiveValue: { [weak self] repositories in
                    self?.getImageData(repositoriesItem: repositories.items)
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
