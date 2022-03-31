//
//  ViewController.swift
//  Cars kz
//
//  Created by Aida Gaziz on 29.03.2022.
//

import UIKit

struct Car: Decodable{
    let modelName: String
    let imageLink: String
    let id: String
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    var cars = [Car]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let url = URL(string: "https://62443a1039aae3e3b74d41e1.mockapi.io/cars")
        URLSession.shared.dataTask(with: url!) { (data, responce, error) in
            if error == nil {
                do{
                    self.cars = try JSONDecoder().decode([Car].self, from: data!)
                }catch{
                    print("parse error")
                }
                DispatchQueue.main.async{
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            }
        }.resume()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carCell", for: indexPath) as! CarCollectionViewCell
        cell.carImageView.downloaded(from: cars[indexPath.row].imageLink)
        cell.carImageView.contentMode = .scaleAspectFill
        cell.carImageView.roundCorners(corners: [.topLeft, .topRight], radius: 8)
        cell.carModelLabel.text = cars[indexPath.row].modelName.capitalized
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = URL(string: cars[indexPath.row].imageLink) else { return }
        if let data = try? Data(contentsOf: url) {
                // Create Image and Update Image View
            let shareSheetViewController = UIActivityViewController(activityItems: [UIImage(data: data) as Any], applicationActivities: nil)
            
            present(shareSheetViewController, animated: true)
        }
    }
}


extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
