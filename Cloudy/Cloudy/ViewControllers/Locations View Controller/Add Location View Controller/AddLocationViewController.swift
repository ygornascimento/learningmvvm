//
//  AddLocationViewController.swift
//  Cloudy
//
//  Created by Bart Jacobs on 10/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit
import CoreLocation

protocol AddLocationViewControllerDelegate: AnyObject {
    func controller(_ controller: AddLocationViewController, didAddLocation location: Location)
}

class AddLocationViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    // MARK: -

    private var viewModel: AddLocationViewModel!
    private var locations: [Location] = []

    // MARK: -

    private lazy var geocoder = CLGeocoder()

    // MARK: -

    weak var delegate: AddLocationViewControllerDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Title
        title = "Add Location"
        
        viewModel = AddLocationViewModel()
        
        viewModel.queryingDidChange = { [weak self] (querying) in
            if querying {
                self?.activityIndicatorView.startAnimating()
            } else {
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Show Keyboard
        searchBar.becomeFirstResponder()
    }

    // MARK: - Helper Methods

    private func geocode(addressString: String?) {
        guard let addressString = addressString else {
            // Clear Locations
            locations = []

            // Update Table View
            tableView.reloadData()

            return
        }

        // Geocode City
        geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
            DispatchQueue.main.async {
                // Process Forward Geocoding Response
                self?.processResponse(withPlacemarks: placemarks, error: error)
            }
        }
    }

    // MARK: -

    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")

        } else if let matches = placemarks {
            // Update Locations
            locations = matches.compactMap({ (match) -> Location? in
                guard let name = match.name else { return nil }
                guard let location = match.location else { return nil }
                return Location(name: name, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            })

            // Update Table View
            tableView.reloadData()
        }
    }

}

extension AddLocationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLocations
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseIdentifier, for: indexPath) as? LocationTableViewCell else { fatalError("Unexpected Table View Cell") }

        // Create View Model
        if let viewModel = viewModel.viewModelForLocation(at: indexPath.row) {
            cell.configure(withViewModel: viewModel)
        }

        return cell
    }

}

extension AddLocationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Fetch Location
        guard let location = viewModel?.location(at: indexPath.row) else { return }

        // Notify Delegate
        delegate?.controller(self, didAddLocation: location)

        // Pop View Controller From Navigation Stack
        navigationController?.popViewController(animated: true)
    }

}

extension AddLocationViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide Keyboard
        searchBar.resignFirstResponder()

        // Forward Geocode Address String
        viewModel.query = searchBar.text ?? ""
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Hide Keyboard
        searchBar.resignFirstResponder()

        viewModel.query = ""
    }

}
