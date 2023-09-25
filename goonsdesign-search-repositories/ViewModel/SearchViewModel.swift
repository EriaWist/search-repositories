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
    private var _repositoriesItem:[RepositoriesItem] = []
    {
        didSet{
            delegate?.update()
        }
    }
    var repositoriesItem:[RepositoriesItem]{
        get{
            _repositoriesItem
        }
    }
    func fetchData(query:String?) {
        _repositoriesItem = []
        if let query = query{
            repositoriesPublisher(query: query)
                .sink(receiveCompletion: {error in
                    print(error)
                }, receiveValue: { [weak self] repositories in
                    self?._repositoriesItem = repositories.items
                })
                .store(in: &cancellBag)
        }
    }
    private func repositoriesPublisher(query:String) -> AnyPublisher<Repositories,Error> {
        return URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.github.com/search/repositories?q=\(query)")!)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("2--")
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: Repositories.self, decoder: JSONDecoder())//解碼
            .eraseToAnyPublisher()//轉換成AnyPublisher
    }
}
