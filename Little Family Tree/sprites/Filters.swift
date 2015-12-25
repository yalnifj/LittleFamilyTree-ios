//
//  AlphaOutlineFilter.swift
//  Little Family Tree
//
//  Created by Melissa on 12/16/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import CoreImage

class EdgeMaskFilter: CIFilter {
    var edgeFilter:CIFilter?
    var maskFilter:WhiteMaskFilter?
    var inputImage: CIImage?
    
    override init() {
        super.init()
        edgeFilter = CIFilter(name: "CIEdgeWork")!
        maskFilter = WhiteMaskFilter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        edgeFilter = CIFilter(name: "CIEdgeWork")!
        maskFilter = WhiteMaskFilter()
    }
    
    override var outputImage : CIImage! {
        if let inputImage = inputImage {
            edgeFilter?.setValue(inputImage, forKey: "inputImage")
            maskFilter?.inputImage = edgeFilter?.outputImage
            return maskFilter?.outputImage
        }
        return nil
    }
}

class WhiteMaskFilter : CIFilter {
    var kernel: CIColorKernel?
    var inputImage: CIImage?
    
    override init() {
        super.init()
        kernel = createKernel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        kernel = createKernel()
    }
    
    override var outputImage : CIImage! {
        if let inputImage = inputImage,
            let kernel = kernel {
                let dod = inputImage.extent
                let args = [inputImage as AnyObject]
                return kernel.applyWithExtent(dod, arguments: args)
        }
        return nil
    }
    
    private func createKernel() -> CIColorKernel {
        let kernelString =
        "kernel vec4 maskFilterKernel(sampler src) {\n" +
            "    vec4 t = sample(src, destCoord());\n" +
            "    t.w = (t.x >= 0.90 ? (t.y >= 0.90 ? (t.z >= 0.90 ? 0.0 : 1.0) : 1.0) : 1.0);\n" +
            "    return t;\n" +
        "}"
        return CIColorKernel(string: kernelString)!
    }
}

class MaskFilter : CIFilter {
    var kernel: CIColorKernel?
    var inputImage: CIImage?
    
    override init() {
        super.init()
        kernel = createKernel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        kernel = createKernel()
    }
    
    override var outputImage : CIImage! {
        if let inputImage = inputImage,
            let kernel = kernel {
                let dod = inputImage.extent
                let args = [inputImage as AnyObject]
                return kernel.applyWithExtent(dod, arguments: args)
        }
        return nil
    }
    
    private func createKernel() -> CIColorKernel {
        let kernelString =
        "kernel vec4 maskFilterKernel(sampler src) {\n" +
            "    vec4 t = sample(src, destCoord());\n" +
            "    t.w = (t.w < 25 ? 0.0 : 1.0);\n" +
            "    t.x = 0.0;\n" +
            "    t.y = 0.0;\n" +
            "    t.z = 0.0;\n" +
            "    return t;\n" +
        "}"
        return CIColorKernel(string: kernelString)!
    }
}