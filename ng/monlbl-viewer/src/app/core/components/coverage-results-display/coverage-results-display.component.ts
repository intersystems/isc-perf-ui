import { Component, ViewChild, HostListener  } from '@angular/core';
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
  styleUrls: ['./coverage-results-display.component.css']
})
export class CoverageResultsDisplayComponent {
  @ViewChild('routineSelect') routineSelect!: MatSelect;
  covpaths$: Observable<CoverageRoutinePathsOutput | null> = this.covRestService.getCovpathsObservable();
  results$: Observable<any[]> = of([]);
  selectedPath: CoverageRoutinePathOutput | null = null;
  //isLoading$: Observable<boolean> = this.covRestService.getIsLoadingObservable(); 
  
  
  constructor(private covRestService: CoverageRestService, private router: Router, private websocketService: WebsocketService) {}

  ngOnInit() {
    // Listen for when the WebSocket message is received
    this.websocketService.getMessageReceivedObservable().subscribe((message: WebSocketMessage | null) => {
      if (message && message.RunID && this.covRestService.getIsLoading()) {
        console.log("call to get routines");
        this.covRestService.GetRoutines(message.RunID).subscribe();
      }
    });
  }

  ngAfterViewInit() {
    // Open the dropdown when covpaths$ emits its value
    this.covpaths$.subscribe(() => {
      setTimeout(() => this.routineSelect.open(), 0);
    });
  }


   // Listen for the beforeunload event
   @HostListener('window:beforeunload', ['$event'])
   beforeUnloadHandler(event: Event) {
     this.websocketService.Cleanup();
   }

  onPathChange(selectedPath: CoverageRoutinePathOutput) {
    console.log("path change", selectedPath.routine, selectedPath.testpath)
    if (selectedPath) {
      this.router.navigate(['/result-detail', selectedPath.routine, selectedPath.testpath]);
    }
  }

  cleanupWebSocket(): void {
    this.websocketService.Cleanup();
  }
  checkWebSocket(): void {
    this.websocketService.Check();
  }

}
