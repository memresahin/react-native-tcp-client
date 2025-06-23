import {
  NativeModules,
  NativeEventEmitter,
  EmitterSubscription,
} from "react-native";

const { TcpClient: NativeTcpClient } = NativeModules;

type TcpEvent = "connect" | "data" | "error" | "close";
type EventCallback = (payload?: any) => void;

export default class TcpClient {
  private emitter = new NativeEventEmitter(NativeTcpClient);
  private subscriptions: Record<TcpEvent, EmitterSubscription[]> = {
    connect: [],
    data: [],
    error: [],
    close: [],
  };

  connect(host: string, port: number) {
    console.log("NativeTcpClient", NativeTcpClient);
    NativeTcpClient.connect(host, port);
  }

  write(data: string) {
    NativeTcpClient.write(data);
  }

  disconnect() {
    NativeTcpClient.disconnect();
    this.removeAllListeners();
  }

  on(event: TcpEvent, callback: EventCallback) {
    const sub = this.emitter.addListener(event, callback);
    this.subscriptions[event].push(sub);
  }

  off(event: TcpEvent, callback?: EventCallback) {
    const subs = this.subscriptions[event];
    if (callback) {
      const index = subs.findIndex((s) => s.listener === callback);
      if (index !== -1) {
        subs[index].remove();
        subs.splice(index, 1);
      }
    } else {
      subs.forEach((s) => s.remove());
      this.subscriptions[event] = [];
    }
  }

  removeAllListeners() {
    (Object.keys(this.subscriptions) as TcpEvent[]).forEach((event) => {
      this.off(event);
    });
  }
}
