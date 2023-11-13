//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

extension URL {
    static func debugFolderLocation() throws -> URL {
        try URL.appLibraryDirectory()
            .appendingPathComponent("debug")
            .create()
    }

    static func xcdebugSettingsFolderLocation() throws -> URL {
        try debugFolderLocation()
            .appendingPathComponent(".xcdebug")
            .create()
    }

    static func appStatusFileLocation() throws -> URL {
        try xcdebugSettingsFolderLocation()
            .add("status.json")
    }

    static func appLibraryDirectory(in fileManager: FileManager = FileManager.default) throws -> URL {
        try fileManager.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent(Bundle.main.appName)
    }

    @discardableResult
    func create(_ create: Bool = true, in fileManager: FileManager = FileManager.default) throws -> Self {
        guard !fileManager.fileExists(atPath: self.relativePath) else {
            return self
        }
        try fileManager.createDirectory(
            at: self,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return self
    }

    func exists(in fileManager: FileManager = FileManager.default) -> Bool {
        fileManager.fileExists(atPath: self.relativePath)
    }

    func add(_ pathComponent: String) -> Self {
        self.appendingPathComponent(pathComponent)
    }

    var subdirectories: [URL]? {
        guard isDirectory else {
            return nil
        }
        do {
            return try FileManager.default.contentsOfDirectory(
                at: self,
                includingPropertiesForKeys: nil,
                options: FileManager.DirectoryEnumerationOptions.includesDirectoriesPostOrder
            )
        } catch {
            return nil
        }
    }

    var fileName: String {
        deletingPathExtension().lastPathComponent
    }

    var fileExtension: String {
        pathExtension
    }

    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

struct DefaultCoders {
    static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

extension Bundle {
    var appName: String {
        bundleIdentifier?.components(separatedBy: ".").last ?? ""
    }
}
