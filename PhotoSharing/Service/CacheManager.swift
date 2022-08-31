//
//  ImageCacheManager.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/30.
//

import Foundation

enum CacheConfig {
    static let maxNumberOfObjects = 100
    static let maxTotalSize = 50 * 1024 * 1024
}

class CacheManager {
    
    static let shared: CacheManager = CacheManager()
    
    init() {}

    var cache: NSCache<NSString, AnyObject> = {
        let cache = NSCache<NSString, AnyObject>()
        cache.countLimit = CacheConfig.maxNumberOfObjects
        cache.totalCostLimit = CacheConfig.maxTotalSize
        
        return cache
    }()
    
    func saveInCache(obj: AnyObject, key: String) {
        CacheManager.shared.cache.setObject(obj, forKey: key as NSString)
    }
    
    func loadFromCache(key: String) -> AnyObject? {
        return CacheManager.shared.cache.object(forKey: key as NSString)
    }
}
