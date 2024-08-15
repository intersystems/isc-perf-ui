import { Component, OnInit, OnDestroy } from '@angular/core';
import { BehaviorSubject, Subscription } from 'rxjs';
import { WebsocketService } from '../../services/websocket.service';
import { WebSocketMessage } from '../../interfaces/web-socket-message';
import { OutputMessage } from '../../interfaces/output-message';
@Component({
  selector: 'app-output-log',
  templateUrl: './output-log.component.html',
  styleUrls: ['./output-log.component.scss']
})
export class OutputLogComponent implements OnInit, OnDestroy {
  logs: BehaviorSubject<OutputMessage[]> = new BehaviorSubject<OutputMessage[]>([]);  // observable containing the outputted unit test progress 
  logValues: OutputMessage[] = []; // the current value of the observable
  private subscription!: Subscription;

  constructor(private websocketService: WebsocketService) {}
  ngOnInit() {
    this.resubscribe();
  }

  resubscribe() {
    // Listen for when the WebSocket message is received 
    this.subscription = this.websocketService.getOutputLogObservable().subscribe((message: WebSocketMessage | null) => {
      if (message) {
        let msg: OutputMessage = {message: message.message}
        if (message.suite) {
           msg.suite = message.suite; 
        }
        if (message.class) { 
          msg.class = message.class 
        }
        if (message.method) { 
          msg.method = message.method 
        }
        this.logValues.push(msg);
        this.logs.next(this.logValues);
      }
    });
  }

  ngOnDestroy() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }

  clearValues() {
    this.logValues = [];
    this.websocketService.resetLogSubject();
    this.resubscribe();
    this.logs.next([]); 
  }
}
