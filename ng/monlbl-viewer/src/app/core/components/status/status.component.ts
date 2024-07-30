import { CodeService } from './../../services/code.service';
import { RestService } from './../../services/rest.service';
import { Component } from '@angular/core';
import { MdbModalService } from 'mdb-angular-ui-kit/modal';
import { LauncherComponent } from '../launcher/launcher.component';

@Component({
  selector: 'app-status',
  templateUrl: './status.component.html',
  styleUrls: ['./status.component.scss']
})
export class StatusComponent {
  constructor(public restService: RestService,
    public codeService: CodeService,
    private modalService: MdbModalService) {
    }

  routineChange(event: Event): void {
    const routine = (event.target as HTMLSelectElement).value;
    this.codeService.setCurrentRoutine(routine);
  }

  start(): void {
    this.modalService.open(LauncherComponent).onClose.subscribe((message: any) => {
      if (message) {
        this.restService.start(message);
      }
    })
  }
}
