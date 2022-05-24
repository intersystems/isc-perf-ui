import { Component } from '@angular/core';
import { MdbModalRef } from 'mdb-angular-ui-kit/modal';
import { Item } from 'src/app/shared/multi-dropdown/multi-dropdown.model';
import { RestService } from '../../services/rest.service';

const DEFAULT_METRICS = ['RtnLine','Time','TotalTime'];

@Component({
  selector: 'app-modal',
  templateUrl: './launcher.component.html',
})
export class LauncherComponent {
  routines: string = "";
  selectedMetrics: Array<Item> = [];

  constructor(private restService: RestService, public modalRef: MdbModalRef<LauncherComponent>) {
    this.restService.getMetrics().subscribe((metrics) => {
      metrics.forEach((metric) => {
        this.selectedMetrics.push({
          id: metric,
          name: metric,
          checked: DEFAULT_METRICS.includes(metric),
          visible: true
        });
      });
      this.selectedMetrics = [...this.selectedMetrics]; // Force notifying change
    })
  }

  startMonitor() {
    // TODO: Actually grab form field values
    this.modalRef.close({
      "metrics": this.selectedMetrics
        .filter(metric => metric.checked)
        .map((metric) => {
          return metric.name;
        }),
      "routines": this.routines.split('\n')
    })
  }

}
