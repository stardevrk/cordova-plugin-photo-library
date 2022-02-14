import Foundation

@objc(PhotoLibrary) class PhotoLibrary : CDVPlugin {

    lazy var concurrentQueue: DispatchQueue = DispatchQueue(label: "photo-library.queue.plugin", qos: DispatchQoS.utility, attributes: [.concurrent])

    override func pluginInitialize() {

        // Do not call PhotoLibraryService here, as it will cause permission prompt to appear on app start.

        URLProtocol.registerClass(PhotoLibraryProtocol.self)

    }

    override func onMemoryWarning() {
        // self.service.stopCaching()
        NSLog("-- MEMORY WARNING --")
    }


    func isAuthorized(_ command: CDVInvokedUrlCommand) {
        concurrentQueue.async {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: PhotoLibraryService.hasPermission())
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }

    func requestAuthorization(_ command: CDVInvokedUrlCommand) {

        let service = PhotoLibraryService.instance

        service.requestAuthorization({
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId	)
        }, failure: { (err) in
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId	)
        })

    }

    func saveImage(_ command: CDVInvokedUrlCommand) {
        concurrentQueue.async {

            if !PhotoLibraryService.hasPermission() {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: PhotoLibraryService.PERMISSION_ERROR)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                return
            }

            let service = PhotoLibraryService.instance

            let url = command.arguments[0] as! String
            let album = command.arguments[1] as! String

            service.saveImage(url, album: album) { (assetId: String?, error: String?) in
                if (error != nil) {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                } else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: assetId)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId	)
                }
            }

        }
    }

    func saveVideo(_ command: CDVInvokedUrlCommand) {
        concurrentQueue.async {

            if !PhotoLibraryService.hasPermission() {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: PhotoLibraryService.PERMISSION_ERROR)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                return
            }

            let service = PhotoLibraryService.instance

            let url = command.arguments[0] as! String
            let album = command.arguments[1] as! String

            service.saveVideo(url, album: album) { (assetId: String?, error: String?) in
                if (error != nil) {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                } else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: assetId)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId	)
                }
            }

        }
    }

}
