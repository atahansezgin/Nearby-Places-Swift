//
//  ViewController.swift
//  NearPlacesApp
//
//  Created by Atahan Sezgin on 1.06.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController,UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
        let resultsVC = searchController.searchResultsController as? ResultViewController else {
            return
        }
        
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query){ result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    resultsVC.update(with:places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    let mapView = MKMapView()
    
    let searchViewController = UISearchController(
        searchResultsController: ResultViewController()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Haritalar"
        view.addSubview(mapView)
        searchViewController.searchBar.placeholder = "Ara"
        searchViewController.searchResultsUpdater = self
        navigationItem.searchController = searchViewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.size.width,
            height: view.frame.size.height
        )
    }


}

extension ViewController: ResultViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchViewController.searchBar.resignFirstResponder()
        searchViewController.dismiss(animated: true,completion: nil)
        // Remove all map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(
            MKCoordinateRegion(
                center: coordinates,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.2,
                    longitudeDelta: 0.2
                )),
            animated: true)
    }
    
    
}
