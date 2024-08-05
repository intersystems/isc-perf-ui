import { Injectable } from '@angular/core';
import { webSocket, WebSocketSubject } from 'rxjs/webSocket';
import { BehaviorSubject, ReplaySubject } from 'rxjs';
import { AuthenticationService } from './authentication.service';
import { WebSocketMessage } from '../interfaces/web-socket-message';

@Injectable({
  providedIn: 'root'
})
export class WebsocketService {
  webSocketSubject$!: WebSocketSubject<any>; // will hold the websocket connection

  //observable for messages about the RunTest being finished
  //used to notify CoverageResultsDisplay to make a call to populate the dropdown with the routine + testpaths
  private messageReceivedSubject = new BehaviorSubject<WebSocketMessage | null>(null); 
  
  //unit test progress messages
  //surfaced live during the RunTest
  private outputLogSubject = new ReplaySubject<WebSocketMessage>();

  // error messages from the RunTest
  // sent over to the TestCoverageLauncher to surface
  private errorSubject = new BehaviorSubject<WebSocketMessage | null>(null); 
  constructor(private authService: AuthenticationService) {
      this.initializeWebSocket();
  }

  private handleMessage(message: WebSocketMessage): void {
    if (message.type == "RunTestFinish") {
      // Notify with the message and RunID
      this.messageReceivedSubject.next(message);
    }
    else if (message.type == "TestCoverageOutput") {
      this.outputLogSubject.next(message);
    }
    else if (message.type == "error") {
      this.errorSubject.next(message);
    }
  }

  initializeWebSocket() {
    this.webSocketSubject$ = webSocket({
      url: this.buildUrl(),
      openObserver: {
        next: () => {},
      },
      closeObserver: {
        next: () => {
          this.initializeWebSocket()
        }
      }
    });
    this.webSocketSubject$.subscribe({
      next: msg => this.handleMessage(msg),
      error: err => console.log(err),
      complete: () => {}
    });
  }

  getOutputLogObservable() {
    return this.outputLogSubject.asObservable();
  }

  getMessageReceivedObservable() {
    return this.messageReceivedSubject.asObservable();
  }
  getErrorReceivedObservable() {
    return this.errorSubject.asObservable();
  }

  // Reset the log subject when logs are cleared
  resetLogSubject() {
    this.outputLogSubject = new ReplaySubject<WebSocketMessage>();
  }
  
  // disconnect the websocket, called when the window closes
  Cleanup(): void {
    this.webSocketSubject$.complete()
  }

  // get the url for making the websocket connection
  private buildUrl(): string {
    let url = window.location.href 
     // Remove everything after "monlbl-viewer/"
    const targetSegment = 'monlbl-viewer/';
    const targetIndex = url.indexOf(targetSegment);

    if (targetIndex !== -1) {
      url = url.substring(0, targetIndex + targetSegment.length);
    }
    // right now we only use http, not https
    if (url.substr(0, 4) !== 'http') {
      // Need to prepend with the base URL.
      const parts = window.location.href.split('#')[0].split('/');
      parts.pop();
      url = parts.join('/') + '/' + url;
    }
    url = url.replace('http', 'ws');

    // location of the websocket class, see the CSP Application in module.xml
    url += 'socket/pkg.isc.perf.ui.socket.WebSocket.cls';
    return url;
  }
}