type TcpEvent = "connect" | "data" | "error" | "close";
type EventCallback = (payload?: any) => void;
export default class TcpClient {
    private emitter;
    private subscriptions;
    connect(host: string, port: number): void;
    write(data: string): void;
    disconnect(): void;
    on(event: TcpEvent, callback: EventCallback): void;
    off(event: TcpEvent, callback?: EventCallback): void;
    removeAllListeners(): void;
}
export {};
