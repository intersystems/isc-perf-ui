import { Component } from '@angular/core';
import { Observable, of } from 'rxjs';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { map, switchMap } from 'rxjs/operators';
import { CoverageRoutinePathOutput } from 'src/app/generated';
import { Router } from '@angular/router';


@Component({
  selector: 'app-coverage-results-display',
  templateUrl: './coverage-results-display.component.html',
  styleUrls: ['./coverage-results-display.component.css']
})
export class CoverageResultsDisplayComponent {
  covpaths$: Observable<any[]> = of([]);
  results$: Observable<any[]> = of([]);
  selectedPath: CoverageRoutinePathOutput | null = null;

  constructor(private covRestService: CoverageRestService, private router: Router) {}

  ngOnInit() {
    // Listen for when the Start process is completed
    this.covRestService.getStartCompletedObservable().pipe(
      switchMap(() => this.covRestService.GetRoutines()),
      map((response: any) => response.covpaths)
    ).subscribe(covpaths => {
      this.covpaths$ = of(covpaths);
    });
  }

  onPathChange(selectedPath: CoverageRoutinePathOutput) {
    if (selectedPath) {
      this.router.navigate(['/result-detail', selectedPath.routine, selectedPath.testpath]);
    }
  }
}
