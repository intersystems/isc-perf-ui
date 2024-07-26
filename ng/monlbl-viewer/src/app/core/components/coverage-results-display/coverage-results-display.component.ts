import { Component, ViewChild } from '@angular/core';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { map, switchMap } from 'rxjs/operators';
import { CoverageRoutinePathsOutput, CoverageRoutinePathOutput  } from 'src/app/generated';
import { Router } from '@angular/router';
import { MatSelect } from '@angular/material/select';



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

  constructor(private covRestService: CoverageRestService, private router: Router) {}

  ngOnInit() {
    // Listen for when the Start process is completed
    // Listen for when the Start process is completed
    this.covRestService.getStartCompletedObservable().subscribe(startCompleted => {
      if (startCompleted) {
        this.covRestService.GetRoutines().subscribe();
      }
    });
  }

  ngAfterViewInit() {
    // Open the dropdown when covpaths$ emits its value
    this.covpaths$.subscribe(() => {
      setTimeout(() => this.routineSelect.open(), 0);
    });
  }

  onPathChange(selectedPath: CoverageRoutinePathOutput) {
    if (selectedPath) {
      this.router.navigate(['/result-detail', selectedPath.routine, selectedPath.testpath]);
    }
  }
}
