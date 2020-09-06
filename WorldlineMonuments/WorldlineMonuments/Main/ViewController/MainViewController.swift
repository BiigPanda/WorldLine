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
    
    private var viewModel: MainViewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        connection()
        configureView()
        bind()

        // Do any additional setup after loading the view.
    }
    
    private func configureView() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        viewModel.dataArray = viewModel.loadHeroes()
        if viewModel.dataArray.count == 0 {
            viewModel.callStartApi { (monuments, error) in
                if error == nil {
                    viewModel.dataArray = monuments
                }
            }
        }
        hud.dismiss()
        //tbvMainView.keyboardDismissMode = .onDrag
    }

    func connection() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        viewModel.context = delegate.persistentContainer.viewContext
    }
    
    private func bind() {
        viewModel.refreshData = { [weak self] () in
            DispatchQueue.main.async {
                self?.tbvMainView.reloadData()
            }
        }
    }
}
