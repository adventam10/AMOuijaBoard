// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  AMOuijaBoard, https://github.com/adventam10/AMOuijaBoard
//
//  Created by am10 on 2019/10/22.
//  Copyright © 2019年 am10. All rights reserved.
//

import PackageDescription

let package = Package(name: "AMOuijaBoard",
                      platforms: [.iOS(.v11)],
                      products: [.library(name: "AMOuijaBoard",
                                          targets: ["AMOuijaBoard"])],
                      targets: [.target(name: "AMOuijaBoard",
                                        path: "Source")],
                      swiftLanguageVersions: [.v5])
