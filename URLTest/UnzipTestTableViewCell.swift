//
//  UnzipTestTableViewCell.swift
//  URLTest
//
//  Created by Seungtae Jang on 2023/02/22.
//

import UIKit

import SnapKit

class UnzipTestTableViewCell: UITableViewCell {

    let unzipImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .yellow
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .cyan
        self.contentView.addSubview(unzipImage)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout() {
        unzipImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview().inset(20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
    
}
