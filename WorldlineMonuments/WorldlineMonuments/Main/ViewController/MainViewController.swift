//
//  MainViewController.swift
//  WorldlineMonuments
//
//  Created by Marc Gallardo on 06/09/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit
import SDWebImage
import CoreData
import JGProgressHUD


class MainViewController: UIViewController {
    
    @IBOutlet weak var tbvMonuments: UITableView!
    @IBOutlet weak var srchBarMonuments: UISearchBar!
    private var viewModel: MainViewModel = MainViewModel()
    private var monumentMain: MonumentModel = MonumentModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connection()
        configureView()
        bind()
    }
    
    private func configureView() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        viewModel.dataArray = viewModel.loadMonuments()
        if viewModel.dataArray.count == 0 {
            viewModel.callStartApi { (monuments, error) in
                if error == nil {
                    self.viewModel.dataArray = monuments
                    hud.dismiss()
                }
            }
        } else {
            hud.dismiss()
        }
        
        tbvMonuments.register(UINib(nibName: "MainMonumentTableViewCell", bundle: nil), forCellReuseIdentifier: "mainMonumentCell")
        tbvMonuments.keyboardDismissMode = .onDrag
    }
    
    func connection() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        viewModel.context = delegate.persistentContainer.viewContext
    }
    
    private func bind() {
        viewModel.refreshData = { [weak self] () in
            DispatchQueue.main.async {
                self?.tbvMonuments.reloadData()
            }
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.filterArray.count > 0 {
            return viewModel.filterArray.count
        } else {
            return viewModel.dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvMonuments.dequeueReusableCell(withIdentifier: "mainMonumentCell") as! MainMonumentTableViewCell
        
        var object : MonumentModel
        
        if viewModel.filterArray.count != 0 {
            object = viewModel.filterArray[indexPath.row]
        } else {
            object = viewModel.dataArray[indexPath.row]
        }
        
        cell.lblMainMonument.text = object.title
        
        return cell
    }
    
    //         self.performSegue(withIdentifier: "todetail", sender: nil)

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewModel.filterArray.count == 0 {
             monumentMain = viewModel.dataArray[indexPath.row]
         } else {
             monumentMain = viewModel.filterArray[indexPath.row]
         }
        tbvMonuments.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "toDetail", sender: nil)
        
    }
    
    
    // MARK: Search Bar Delegate Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty  else {
            viewModel.filterArray.removeAll()
            tbvMonuments.reloadData()
            return
        }
        viewModel.searchMonumentByName(nameMonument: searchText)
        bind()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        viewModel.searchMonumentByName(nameMonument: text)
        
        if viewModel.filterArray.count == 0 && searchBar.searchTextField.text?.isEmpty == false {
            self.showAlert()
        }
        
        bind()
        srchBarMonuments.resignFirstResponder()
        
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Not Found", message: "Monument its not found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Navigation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let detailVC = segue.destination as! DetailViewController
            guard let identifierMain = monumentMain.id else {
                return
            }
            detailVC.identifier = identifierMain
        }
    }
}
