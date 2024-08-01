import { Component, ViewChild, HostListener, OnInit, AfterViewInit  } from '@angular/core';
import { Observable } from 'rxjs';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { CoverageRoutinePathsOutput, CoverageRoutinePathOutput } from 'src/app/generated';
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
  selectedPath: CoverageRoutinePathOutput | null = null; // which routine + testpath the user selects from the dropdown
  
  constructor(private covRestService: CoverageRestService, private router: Router, private websocketService: WebsocketService) {}

  ngOnInit() {
    // Listen for when the WebSocket message is received and get the routine + testpaths from the API 
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



   // When the user leaves the page, disconnect the websocket
   @HostListener('window:beforeunload', ['$event'])
   beforeUnloadHandler(event: Event) {
     this.websocketService.Cleanup();
   }

  // when the user selects a routine + testpath, navigate to that results page
  onPathChange(selectedPath: CoverageRoutinePathOutput) {
    if (selectedPath) {
      this.router.navigate(['/result-detail', selectedPath.routine, selectedPath.testpath]);
    }
  }

  // clear the run data
  clearResults(): void {
    this.covRestService.Clear();
  }

}
