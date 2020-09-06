//
//  DetailViewController.swift
//  WorldlineMonuments
//
//  Created by Marc Gallardo on 06/09/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit
import SDWebImage
import CoreData
import JGProgressHUD
import MapKit

class DetailViewController: UIViewController {
    
    var identifier: String = ""
    private var detailViewModel: DetailViewModel = DetailViewModel()
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblTransport: UILabel!
    @IBOutlet weak var lblAdress: UILabel!
    @IBOutlet weak var mapMonument: MKMapView!
    @IBOutlet weak var lblTitleMonument: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        detailViewModel.callDetailApi(idDetail: identifier) { (detailMonument, error) in
            if error == nil {
                self.detailViewModel.dataDetailMonument = detailMonument
                self.configureElements(detailMonument: self.detailViewModel.dataDetailMonument)
                hud.dismiss()
            }
        }
    }
    @IBAction func backToMain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureElements(detailMonument: DetailMonumentModel) {
        lblEmail.text = detailMonument.email
        lblPhone.text = detailMonument.phone
        lblAdress.text = detailMonument.address
        lblTransport.text = detailMonument.transport
        lblTitleMonument.text = detailMonument.title
        lblDescription.text = detailMonument.description
    }
    
    
}
