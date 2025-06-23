"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const react_native_1 = require("react-native");
const { TcpClient: NativeTcpClient } = react_native_1.NativeModules;
class TcpClient {
    constructor() {
        this.emitter = new react_native_1.NativeEventEmitter(NativeTcpClient);
        this.subscriptions = {
            connect: [],
            data: [],
            error: [],
            close: [],
        };
    }
    connect(host, port) {
        NativeTcpClient.connect(host, port);
    }
    write(data) {
        NativeTcpClient.write(data);
    }
    disconnect() {
        NativeTcpClient.disconnect();
        this.removeAllListeners();
    }
    on(event, callback) {
        const sub = this.emitter.addListener(event, callback);
        this.subscriptions[event].push(sub);
    }
    off(event, callback) {
        const subs = this.subscriptions[event];
        if (callback) {
            const index = subs.findIndex((s) => s.listener === callback);
            if (index !== -1) {
                subs[index].remove();
                subs.splice(index, 1);
            }
        }
        else {
            subs.forEach((s) => s.remove());
            this.subscriptions[event] = [];
        }
    }
    removeAllListeners() {
        Object.keys(this.subscriptions).forEach((event) => {
            this.off(event);
        });
    }
}
exports.default = TcpClient;
