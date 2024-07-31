import { Component } from '@angular/core';
import { BehaviorSubject, Observable, Subject } from 'rxjs';
import { WebsocketService } from '../../services/websocket.service';
import { WebSocketMessage } from '../../interfaces/web-socket-message';
import { OutputMessage } from '../../interfaces/output-message';
@Component({
  selector: 'app-output-log',
  templateUrl: './output-log.component.html',
  styleUrls: ['./output-log.component.scss']
})
export class OutputLogComponent {
  logs: Subject<OutputMessage[]> = new Subject(); 
  logValues: OutputMessage[] = []; 

  constructor(private websocketService: WebsocketService) {}
  ngOnInit() {
    // Listen for when the WebSocket message is received
    this.websocketService.getOutputLogObservable().subscribe((message: WebSocketMessage | null) => {
      if (message) {
        let msg: OutputMessage = {message: message.message}
        if (message.suite) {
           msg.suite = message.suite; 
           message.message = message.message 
        }
        if (message.class) { 
          msg.class = message.class 
          message.message =  message.message 
        }
        if (message.method) { 
          msg.method = message.method 
          message.message = message.message 
        }
        this.logValues.push(msg);
        this.logs.next(this.logValues);
      }
    });
  }

  clearValues() {
    this.logValues = [];
    this.logs.next([]); 
  }
}