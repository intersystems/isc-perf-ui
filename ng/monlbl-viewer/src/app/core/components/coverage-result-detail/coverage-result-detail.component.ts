import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Observable, of } from 'rxjs';
import { map, switchMap } from 'rxjs/operators';
import { CoverageRestService } from '../../services/coverage-rest.service';

@Component({
  selector: 'app-coverage-result-detail',
  templateUrl: './coverage-result-detail.component.html',
  styleUrls: ['./coverage-result-detail.component.css']
})
export class CoverageResultDetailComponent implements OnInit {
  results$: Observable<any[]> = of([]);

  constructor(
    private route: ActivatedRoute,
    private covRestService: CoverageRestService
  ) {}

  ngOnInit() {
    this.route.paramMap.pipe(
      switchMap(params => {
        const routine = params.get('routine');
        const testpath = params.get('testpath');
        return this.covRestService.GetResults(routine!, testpath!);
      }),
      map((response: any) => response.results)
    ).subscribe(results => {
      this.results$ = of(results);
    });
  }
}