//
//  main.swift
//  s3sum
//
//  Created by Robert Rossmann on 28/09/15.
//  Copyright (c) 2015 Robert Rossmann. All rights reserved.
//

import Cocoa
import Foundation

let fs = NSFileManager.defaultManager()
var path: String? = Process.argc > 1 ? Process.arguments[1] : nil
let part: Int? = Process.argc > 2 ? Int(Process.arguments[2]) : nil

guard path != nil else {
  print("You must provide valid file path as first argument")
  exit(1)
}

guard fs.fileExistsAtPath(path!) else {
  print("No such file: \(path!)")
  exit(2)
}

guard fs.isReadableFileAtPath(path!) else {
  print("File not readable: \(path!)")
  exit(3)
}

guard let data = fs.contentsAtPath(path!) else {
  print("No data has been loaded from file: \(path!)")
  exit(4)
}

let checksum = part != nil ? s3md5(data, partSize: part!)
                           : s3md5(data)

print(checksum)
