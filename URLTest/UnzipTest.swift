//
//  UnzipTest.swift
//  URLTest
//
//  Created by Seungtae Jang on 2023/02/20.
//

import UIKit

import SnapKit
import ZIPFoundation


class UnzipTest: UIViewController {
    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .lightGray
        tableView.register(UnzipTestTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var imageDataSource: [UIImage] = []
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setting()
        addSubview()
        layout()
    }
    
    func setting() {
        //guard let url = URL(string: "http://medicalip.synology.me:30003/attachments/download/3086/pictures.zip") else { return }
        guard let url = URL(string: "http://medicalip.synology.me:30003/attachments/download/3101/archive.zip") else { return }
        zipDownload(url: url)
        view.backgroundColor = .brown
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func addSubview() {
        self.view.addSubview(tableView)
    }
    
    func layout() {
        tableView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(self.view.safeAreaLayoutGuide).inset(10)
        }
    }
    
    // MARK: - by URLSession
    
    func zipDownload(url: URL) {
        var request = URLRequest(url: url)
        let id = "stjang"
        let password = "wkdtmdxo"
        let myAuth = "\(id):\(password)"
        let authEncoded = myAuth.data(using: .utf8)?.base64EncodedString() ?? ""
        
        request.httpMethod = "GET"
        request.setValue("Basic \(authEncoded)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            guard let httpURLResponse = response as? HTTPURLResponse else {
                print("HTTP URL Response Error")
                return
            }
            guard let mimeType = response?.mimeType, mimeType.hasPrefix("application/zip") else {
                print("MimeType Error, \(String(describing: response?.mimeType))")
                return
            }
            guard (200...299).contains(httpURLResponse.statusCode) else {
                print("Error , Status Code : \(httpURLResponse.statusCode)")
                return
            }
            guard let data = data else {
                print("Data Error")
                return
            }
            
            // 파일 저장
            //
            // Info.plist 에서
            // Supports opening documents in place -> Yes
            // Application supports iTunes file sharing -> Yes
            
            let fileManager = FileManager.default
            guard let docsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileName = url.lastPathComponent
            let path: URL = docsUrl.appendingPathComponent(fileName)
            
            do {
                try data.write(to: path)
            } catch let e {
                print(e.localizedDescription)
            }
            
            let lastIndex = fileName.lastIndex(of: ".") ?? fileName.endIndex
            let dirName = String(fileName[..<lastIndex])
            
            // 압축 풀기
            self.unzip(url: docsUrl, file: fileName, dir: dirName)
            
            // 압축 해제된 폴더 읽고 테이블뷰에 나타내기
            DispatchQueue.main.async {
                self.readDir(url: docsUrl.appendingPathComponent(dirName))
            }
        }.resume()
    }
    
    func unzip(url: URL, file: String, dir: String) {
        let fileManager = FileManager()
        var sourceURL = url
        sourceURL.appendPathComponent(file)
        var destinationURL = url
        destinationURL.appendPathComponent(dir)
        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: sourceURL, to: destinationURL)
        } catch {
            //print("UnZip failed with error: \(error)")
        }
    }
    
    func readDir(url: URL) {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)

            for file in files {
                if ["jpeg", "png"].contains(file.pathExtension) {
                    guard let image = UIImage(contentsOfFile: file.path()) else { continue }
                    imageDataSource.append(image)
                }
            }
            imageDataSource.shuffle()
            tableView.reloadData()
            
        } catch {
            print(error)
        }
    }
    
}

// MARK: - TableView
extension UnzipTest: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UnzipTestTableViewCell else {
            return UnzipTestTableViewCell()
        }
        cell.unzipImage.image = imageDataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }

    
}
