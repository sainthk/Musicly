//
//  DetailView.swift
//  Musicly
//
//  Created by Christopher Webb-Orenstein on 4/23/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

class DetailView: UIView {
    
    var playlistNameField: UITextField = {
        var playlistNameField = UITextField()
        playlistNameField.layer.borderColor = DetailViewConstants.mainColor.cgColor
        playlistNameField.layer.cornerRadius = DetailViewConstants.largeCornerRadius
        playlistNameField.layer.borderWidth = DetailViewConstants.borderWidth
        return playlistNameField
    }()
    
    var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.backgroundColor = DetailViewConstants.mainColor
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = DetailViewConstants.titleFont
        return titleLabel
    }()
    
    var detailsTextView: UITextView = {
        var detailsTextView = UITextView()
        detailsTextView.sizeToFit()
        detailsTextView.textAlignment = .center
        detailsTextView.isScrollEnabled = true
        return detailsTextView
    }()
    
    let doneButton: UIButton = {
        var button = ButtonType.system(title: "Done", color: UIColor.white)
        var uiButton = button.newButton
        return uiButton
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isUserInteractionEnabled = true
        backgroundColor = UIColor.white
        layer.cornerRadius = DetailViewConstants.cornerRadius
        layer.borderWidth = DetailViewConstants.borderWidth
        layer.borderColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowRadius = DetailViewConstants.borderWidth
        layer.shadowOpacity = DetailViewConstants.shadowOpacity
        layer.masksToBounds = true
        layer.shadowPath = UIBezierPath(roundedRect:bounds, cornerRadius:layer.cornerRadius).cgPath
    }
    
    func configureView() {
        titleLabel.text = "Create Playlist"
        layoutSubviews()
        setupConstraints()
    }
    
    func setupConstraints() {
        addSubview(playlistNameField)
        playlistNameField.translatesAutoresizingMaskIntoConstraints = false
        playlistNameField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playlistNameField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playlistNameField.heightAnchor.constraint(equalTo: heightAnchor, multiplier: DetailViewConstants.heightMultiplier).isActive = true
        playlistNameField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: DetailViewConstants.fieldWidth).isActive = true

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: DetailViewConstants.heightMultiplier).isActive = true

        addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        doneButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: DetailViewConstants.heightMultiplier).isActive = true
        doneButton.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}

