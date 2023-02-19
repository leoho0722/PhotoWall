//
//  PHAssetResource+Extensions.swift
//  Photo Wall
//
//  Created by Leo Ho on 2023/2/19.
//

import Foundation
import Photos

extension PHAssetResource {
    
    var assetURL: URL {
        return self.value(forKey: "privateFileURL") as! URL
    }
    
    func getPHAssetURL(asset: PHAsset) -> URL {
        let source = PHAssetResource.assetResources(for: asset).last!
        return source.assetURL
    }
}
