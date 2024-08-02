import { Component, OnInit } from '@angular/core';
import { BehaviorSubject, Observable, Subject } from 'rxjs';
import { WebsocketService } from '../../services/websocket.service';
import { WebSocketMessage } from '../../interfaces/web-socket-message';
import { OutputMessage } from '../../interfaces/output-message';
@Component({
  selector: 'app-output-log',
  templateUrl: './output-log.component.html',
  styleUrls: ['./output-log.component.scss']
})
export class OutputLogComponent implements OnInit {
  logs: Subject<OutputMessage[]> = new Subject(); // observable containing the outputted unit test progress 
  logValues: OutputMessage[] = []; // the current value of the observable

  constructor(private websocketService: WebsocketService) {}
  ngOnInit() {
    // Listen for when the WebSocket message is received 
    this.websocketService.getOutputLogObservable().subscribe((message: WebSocketMessage | null) => {
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

  clearValues() {
    this.logValues = [];
    this.logs.next([]); 
  }
}
