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
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.delegate = self
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        //addActionu要iOS14
    }
    @objc func loadData(){
        viewModel.fetchData(query: viewModel.tmpQuery)
        self.refreshControl.endRefreshing()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDetailViewController"{
            if let detailViewController = segue.destination as? DetailViewController{
                detailViewController.repositoriesItem = viewModel.selectRepository
            }
        }
    }

}

extension ViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.repositoriesItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repositoriesCell") as! RepositoriesTableViewCell
        let item = viewModel.repositoriesItem[indexPath.row]
        if let imageData = item.imageData{
            cell.icon?.image = UIImage(data: imageData)
        }
        cell.title.text = item.full_name
        cell.descriptionText.text = item.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        viewModel.selectRepository = viewModel.repositoriesItem[indexPath.row]
        return indexPath
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
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text == ""
        {
            viewModel.fetchData(query: nil)
        }
    }
}
