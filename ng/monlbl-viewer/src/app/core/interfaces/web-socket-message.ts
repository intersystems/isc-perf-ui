export interface WebSocketMessage {
    message: string;
    RunID?: number;
    type: string;
    suite?: string;
    class?: string;
    method?: string; 
}
