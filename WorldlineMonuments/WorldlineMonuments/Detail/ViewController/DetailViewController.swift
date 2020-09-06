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
    
    @IBOutlet weak var txtEmail: UITextView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
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
                self.configureMap(detailMonument: self.detailViewModel.dataDetailMonument)
                hud.dismiss()
            }
        }
    }
    @IBAction func backToMain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureElements(detailMonument: DetailMonumentModel) {
        if detailMonument.email == "null" || detailMonument.email == "undefined" {
            txtEmail.text = ""
        } else {
            txtEmail.text = detailMonument.email
            txtEmail.isEditable = false;
            txtEmail.dataDetectorTypes = UIDataDetectorTypes.all;
        }
        
        if detailMonument.address == "null" || detailMonument.address == "undefined" {
            lblAdress.text = ""
        } else {
            lblAdress.text = detailMonument.address
        }
        
        if detailMonument.phone == "null" || detailMonument.phone == "undefined" {
            lblPhone.text = ""
        } else {
            lblPhone.text = detailMonument.phone
        }
        
        if detailMonument.transport == "null" || detailMonument.transport == "undefined" {
            lblTransport.text = ""
        } else {
            lblTransport.text = detailMonument.transport
        }
        
        lblTitleMonument.text = detailMonument.title
        lblDescription.text = detailMonument.description
    }
    
    func configureMap(detailMonument: DetailMonumentModel) {
        let monument = MKPointAnnotation()
        monument.title = detailViewModel.dataDetailMonument.title
        guard let coordinates = detailViewModel.dataDetailMonument.geocoordinates else {
            return
        }
        let coordinatesMap = detailViewModel.convertStringLocation(locations: coordinates)
        monument.coordinate = CLLocationCoordinate2D(latitude: coordinatesMap[0], longitude: coordinatesMap[1])
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: monument.coordinate, span: span)
        mapMonument.addAnnotation(monument)
        mapMonument.setRegion(region, animated: true)
    }
    
    
}


