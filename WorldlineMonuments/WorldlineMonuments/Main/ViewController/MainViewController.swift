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
                }
            }
        }
        hud.dismiss()
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

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvMonuments.dequeueReusableCell(withIdentifier: "mainMonumentCell") as! MainMonumentTableViewCell
        
    }
    
    
}
