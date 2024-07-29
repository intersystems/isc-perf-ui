import { Injectable, OnDestroy, OnInit } from '@angular/core';
import { webSocket, WebSocketSubject } from 'rxjs/webSocket';
import { BehaviorSubject } from 'rxjs';
import { AuthenticationService } from './authentication.service';
import { WebSocketMessage } from '../interfaces/web-socket-message';

@Injectable({
  providedIn: 'root'
})
export class WebsocketService {
  webSocketSubject$!: WebSocketSubject<any>;

  private messageReceivedSubject = new BehaviorSubject<WebSocketMessage | null>(null); // Use the interface

  constructor(private authService: AuthenticationService) {
      this.webSocketSubject$ = webSocket({
        url: this.buildUrl()
      });
      this.webSocketSubject$.subscribe({
        next: msg => this.handleMessage(msg),
        error: err => console.log(err),
        complete: () => this.Cleanup()
      })
  }

  private handleMessage(message: WebSocketMessage): void {
    console.log(message);
    if (message.message === "Finished RunTest" && message.RunID !== undefined) {
      // Notify with the message and RunID
      this.messageReceivedSubject.next(message);
    }
  }

  getMessageReceivedObservable() {
    return this.messageReceivedSubject.asObservable();
  }
  
  Cleanup(): void {
    this.webSocketSubject$.complete()
    this.webSocketSubject$.unsubscribe();
    
  }

  Check(): void {
    console.log(this.webSocketSubject$);
  }

  private buildUrl(): string {
    let url = window.location.href 
    if (url.substr(0, 4) !== 'http') {
      // Need to prepend with the base URL.
      const parts = window.location.href.split('#')[0].split('/');
      parts.pop();
      url = parts.join('/') + '/' + url;
    }
    url = url.replace('http', 'ws');
    url += 'socket/pkg.isc.perf.ui.socket.WebSocket.cls';
    return url;
  }
}