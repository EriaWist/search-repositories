//
//  ViewController.swift
//  goonsdesign-search-repositories
//
//  Created by 黃子騰 on 2023/9/25.
//

import UIKit

class ViewController: UIViewController {
    private var viewModel = SearchViewModel()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.delegate = self
    }


}

extension ViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.repositoriesItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.imageView?.image = UIImage(data: viewModel.repositoriesItem[indexPath.row].imageData!)
        return cell
    }
    
}

extension ViewController:ViewModelDelegate{
    func update() {
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
}

extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.fetchData(query: searchBar.text)
        searchBar.resignFirstResponder()
    }
}
