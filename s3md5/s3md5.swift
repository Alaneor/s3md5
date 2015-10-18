//
//  s3sum.swift
//  s3sum
//
//  Created by Robert Rossmann on 28/09/15.
//  Copyright (c) 2015 Robert Rossmann. All rights reserved.
//

import Foundation


func s3md5 (data: NSData, partSize: Int = 1048576 * 5) -> String {

  // Get the number of parts we will need to split the file into in order to calculate the hash
  let parts = Int(ceil(Double(data.length) / Double(partSize)))
  let bytes = NSMutableData()

  // Special case: if there would be only single part, just calculate the md5 and be done with it
  if parts == 1 {
    return md5toString(md5(data))
  }

  // Okay, here we go with the crazy hashing logic...
  // We start from 0 because we will use the current index as an offset modifier... See the
  // multiplication below. If we started from 1, the offset would be after first 5 MB on first
  // iteration -> not good, not good!
  for i in 0...(parts - 1) {
    let offset = i * partSize
    let length = min(partSize, data.length - offset)
    // This is the part from which we need to compute the md5 hash
    let part = data.subdataWithRange(NSRange(location: offset, length: length))

    // Hash dude, hash! And maybe some ganja, too...
    let hash = md5(part)
    // Append the bytes to whatever we currently have stored
    bytes.appendData(hash)
  }

  // Now we got one gigantic bunch of bytes which represent the concatenation of md5 hashes of
  // individual parts. Now we need to get md5 of these bytes...
  let hash = md5(bytes)

  // And now, to string with them... The final result also includes the number of parts used
  // to compute the final hash, so let's append that to conform with specs
  return md5toString(hash) + "-\(parts)"
}


// MARK: - Private Shit


private func md5toString(data: NSData) -> String {

  let hex = NSMutableString()
  // What's dis? I guess I am initialising an array of UInt8's with number of elements being
  // the length of the data and all of the elements being set to 0x0?
  var bytes = [UInt8](count: data.length, repeatedValue: 0x0)

  // No idea why this is necessary. Why can't I loop over data.bytes directly??? Copying the
  // data feels bad, performance surely suffers..
  data.getBytes(&bytes, length: data.length)

  for byte in bytes {
    // Shamelessly stole the format string from the internets, no clue really...
    hex.appendFormat("%02x", UInt8(byte))
  }

  return String(hex)
}

// This bugger requires a bridging header with CommonCrypto included:
// #import <CommonCrypto/CommonDigest.h>
// Just FYI. Thought you might want to know.
private func md5(data: NSData) -> NSData {

  let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!

  CC_MD5(
    data.bytes,
    CC_LONG(data.length),
    // No idea what this parameter does. Seriously, what's these < and >? Dafuq...
    UnsafeMutablePointer<UInt8>(result.mutableBytes)
  )

  return NSData(data: result)
}
