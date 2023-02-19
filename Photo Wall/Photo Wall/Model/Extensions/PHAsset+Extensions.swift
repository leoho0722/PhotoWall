//
//  PHAsset+Extensions.swift
//  Photo Wall
//
//  Created by Leo Ho on 2022/2/14.
//

import Foundation
import Photos

extension PHAsset {
    
    var fileName: String {
        get { return self.value(forKey: "filename") as! String }
    }
    
    enum MediaSubType: Int {
        
        case photoPanorama
        
        case photoHDR
        
        case photoScreenshot
        
        case photoLive
        
        case photoDepthEffect
        
        case videoStreamed
        
        case videoHighFrameRate
        
        case videoTimelapse
        
        case videoCinematic
    }
}
