import { Injectable, OnDestroy, OnInit } from '@angular/core';
import { webSocket, WebSocketSubject } from 'rxjs/webSocket';
import { Subscription, ReplaySubject, Subject } from 'rxjs';
import { AuthenticationService } from './authentication.service';

@Injectable({
  providedIn: 'root'
})
export class WebsocketService implements OnDestroy {
  webSocketSubject$!: WebSocketSubject<any>;
  subs: Subscription[] = new Array();

  // messages$: ReplaySubject<MessageType> = new ReplaySubject<MessageType>();

  constructor(private authService: AuthenticationService) {
      this.webSocketSubject$ = webSocket({
        url: this.buildUrl()
      });
      this.subs.push(this.webSocketSubject$.subscribe(
        msg => this.handleMessage(msg), // Called whenever there is a message from the server
        err => console.log(err), // Called if WebSocket API signals some kind of error
        () => console.log('connection closed') // Called when connection is closed (for whatever reason)
      ));
  }

  // getNotifications(): Subject<string> {
  //   const subject = new Subject<string>();
  //   this.subs.push(this.messages$.subscribe(message => {
  //     if ((message != null) && (message.notification)) {
  //       subject.next(message.notification);
  //     }
  //   }));
  //   return subject;
  // }

  // getMessageType<T extends MessageType>(type: new(source: any) => T): ReplaySubject<T> {
  //   const subject = new ReplaySubject<T>();
  //   this.subs.push(this.messages$.subscribe(message => {
  //     if (message != null) {
  //       const realMessage = new type(message);
  //       if (realMessage.isValid()) {
  //         subject.next(realMessage);
  //       }
  //     }
  //   }));
  //   return subject;
  // }

  // sendMessage(message: MessageType): void {
  //   this.webSocketSubject$.next(message);
  // }

  private handleMessage(message: any): void {
    console.log(message)
  }

  ngOnDestroy(): void {
    this.webSocketSubject$.unsubscribe();
    this.subs.forEach((s) => s.unsubscribe());
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
    console.log(url);
    return url;
  }
}