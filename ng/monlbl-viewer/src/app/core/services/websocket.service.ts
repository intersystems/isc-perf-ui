import { Injectable } from '@angular/core';
import { webSocket, WebSocketSubject } from 'rxjs/webSocket';
import { BehaviorSubject, ReplaySubject, interval, Subscription, take } from 'rxjs';
import { AuthenticationService } from './authentication.service';
import { WebSocketMessage } from '../interfaces/web-socket-message';
import { CoverageService } from 'src/app/generated';
import { CoverageStatusOutput } from 'src/app/generated';
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

  private readonly KEEP_ALIVE_INTERVAL_MS = 60000; // Set this to your desired interval in milliseconds
  private readonly RUN_TEST_TIMEOUT_MS = 5000; // Timeout for receiving "Finished RunTest" message

  private keepAliveInterval: Subscription | null = null;
  private runTestTimeoutHandle: any;

  constructor(private authService: AuthenticationService, private covService: CoverageService) {
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
    else if (message.type == "ConnectionTest") {
      if (this.runTestTimeoutHandle) {
        clearTimeout(this.runTestTimeoutHandle);
        this.runTestTimeoutHandle = null;
      }
    }
  }

  initializeWebSocket() {
    this.webSocketSubject$ = webSocket({
      url: this.buildUrl(),
      openObserver: {
        next: () => { this.startKeepAlive();},
      },
      closeObserver: {
        next: () => {
          this.stopKeepAlive();
          this.initializeWebSocket()
        }
      }
    });
    this.webSocketSubject$.subscribe({
      next: msg => this.handleMessage(msg),
      error: err => console.log(err),
      complete: () => {this.stopKeepAlive()}
    });
  }

  // Starts sending keep-alive messages
  private startKeepAlive() {
    this.stopKeepAlive(); // Ensure no previous interval is running
    this.keepAliveInterval = interval(this.KEEP_ALIVE_INTERVAL_MS).subscribe(() => {
      if (this.webSocketSubject$ && !this.webSocketSubject$.closed) {
        this.webSocketSubject$.next('Testing connection');
        // Set a timeout to check if we receive the "Finished RunTest" message
        this.runTestTimeoutHandle = setTimeout(() => {
          window.location.reload(); // forces a hard reload to re-show the iris login page
        }, this.RUN_TEST_TIMEOUT_MS);

        this.checkAPIAlive().pipe(take(1)).subscribe({
          next: (status: CoverageStatusOutput) => {
          },
          error: (error) => {
            window.location.reload(); // forces a hard reload to re-show the iris login page
          }
        })
      }
    });
  }

  // Stops sending keep-alive messages
  private stopKeepAlive() {
    if (this.keepAliveInterval) {
      this.keepAliveInterval.unsubscribe();
      this.keepAliveInterval = null;
    }
    if (this.runTestTimeoutHandle) {
      clearTimeout(this.runTestTimeoutHandle);
      this.runTestTimeoutHandle = null;
    }
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

  checkAPIAlive() {
    return this.covService.coverageActiveGet()
  }

  // Reset the log subject when logs are cleared
  resetLogSubject() {
    this.outputLogSubject = new ReplaySubject<WebSocketMessage>();
  }
  
  // disconnect the websocket, called when the window closes
  Cleanup(): void {
    this.stopKeepAlive();
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