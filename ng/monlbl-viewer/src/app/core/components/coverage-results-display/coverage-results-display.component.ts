import { Component, ViewChild, HostListener, OnInit, AfterViewInit  } from '@angular/core';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { map, switchMap } from 'rxjs/operators';
import { CoverageRoutinePathsOutput, CoverageRoutinePathOutput  } from 'src/app/generated';
import { Router } from '@angular/router';
import { MatSelect } from '@angular/material/select';
import { WebsocketService } from '../../services/websocket.service';
import { WebSocketMessage } from '../../interfaces/web-socket-message';

@Component({
  selector: 'app-coverage-results-display',
  templateUrl: './coverage-results-display.component.html',
  styleUrls: ['./coverage-results-display.component.scss']
})
export class CoverageResultsDisplayComponent implements OnInit, AfterViewInit {
  @ViewChild('routineSelect') routineSelect!: MatSelect;
  covpaths$: Observable<CoverageRoutinePathsOutput | null> = this.covRestService.getCovpathsObservable();
  results$: Observable<any[]> = of([]);
  selectedPath: CoverageRoutinePathOutput | null = null;
  //isLoading$: Observable<boolean> = this.covRestService.getIsLoadingObservable();   
  
  constructor(private covRestService: CoverageRestService, private router: Router, private websocketService: WebsocketService) {}

  ngOnInit() {
    // Listen for when the WebSocket message is received
    this.websocketService.getMessageReceivedObservable().subscribe((message: WebSocketMessage | null) => {
      if (message && message.RunID && (this.covRestService.getFirstLoad() || this.covRestService.getIsLoading())) {
        this.covRestService.GetRoutines(message.RunID).subscribe();
      }
    });
  }

  ngAfterViewInit() {
    // Open the dropdown when covpaths$ emits its value
    this.covpaths$.subscribe((value) => {
      setTimeout(() => {
        if (value !== null) {
          this.routineSelect.open()
        }
      }, 0);
  });
  }



   // Listen for the beforeunload event
   @HostListener('window:beforeunload', ['$event'])
   beforeUnloadHandler(event: Event) {
     this.websocketService.Cleanup();
   }

  onPathChange(selectedPath: CoverageRoutinePathOutput) {
    if (selectedPath) {
      this.router.navigate(['/result-detail', selectedPath.routine, selectedPath.testpath]);
    }
  }

  clearResults(): void {
    this.covRestService.Clear();
  }

}
