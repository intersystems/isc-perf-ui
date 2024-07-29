import { Injectable, OnDestroy, OnInit } from '@angular/core';
import { webSocket, WebSocketSubject } from 'rxjs/webSocket';
import { Subscription, ReplaySubject, Subject } from 'rxjs';
import { AuthenticationService } from './authentication.service';

@Injectable({
  providedIn: 'root'
})
export class WebsocketService {
  webSocketSubject$!: WebSocketSubject<any>;

  // messages$: ReplaySubject<MessageType> = new ReplaySubject<MessageType>();

  constructor(private authService: AuthenticationService) {
      this.webSocketSubject$ = webSocket({
        url: this.buildUrl()
      });
      this.webSocketSubject$.subscribe({
        next: msg => this.handleMessage(msg),
        error: err => console.log(err),
        complete: () => this.Cleanup()
      })
      console.log("new websocket connection created")
  }

  private handleMessage(message: any): void {
    console.log(message)
  }
  
  
  Cleanup(): void {
    localStorage.setItem("destroyed_webservice", new Date().toISOString());
    this.webSocketSubject$.complete()
    console.log(this.webSocketSubject$)
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