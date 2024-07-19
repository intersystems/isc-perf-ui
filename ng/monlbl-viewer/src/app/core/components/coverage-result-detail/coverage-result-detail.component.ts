import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { Observable, of } from 'rxjs';
import { map, switchMap } from 'rxjs/operators';
import { CoverageResultOutput } from 'src/app/generated';
import { Location } from '@angular/common';


@Component({
  selector: 'app-coverage-result-detail',
  templateUrl: './coverage-result-detail.component.html',
  styleUrls: ['./coverage-result-detail.component.css']
})
export class CoverageResultDetailComponent implements OnInit {
  results$: Observable<any> = of([]);
  sort: string = "";
  descending: number = 1; 
  displayedColumns: string[] = ['TIME', 'TotalTime', 'RtnLineCount', 'code'];

  constructor(
    private route: ActivatedRoute,
    private covRestService: CoverageRestService,
    private location: Location
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

  goBack(): void {
    this.location.back();
  }
  viewInContext(lineNumber: number): void {
    let behavior: "auto" | "smooth" = "auto";
    if (this.sort === "") {
      behavior = "smooth";
    } else {
      this.sort = "";
      this.applySort();
    }

    // Scroll to line in context on next click.
    setTimeout(() => {
      const prevLine = (lineNumber < 11) ? 1 : lineNumber - 10;
      const el = document.getElementById("line" + lineNumber);
      if (el) {
        document.getElementById("line" + prevLine)?.scrollIntoView({ behavior });
        if (el.style.backgroundColor === 'rgb(255, 255, 0)') {
          el.style.backgroundColor = '';
        } else {
          el.style.backgroundColor = 'rgb(255, 255, 0)';
        }
      }
    }, 0);
  }

  applySort(): void {
    this.results$.pipe(
      map(results => {
        if (!results) {
          return results;
        }
        return [...results].sort((first, second) => {

          let firstValue = null; 
          let secondValue = null; 
          if (this.sort === "TIME" || this.sort === "TotalTime") {
            firstValue = first.hasOwnProperty(this.sort) ? parseFloat((first as any)[this.sort]) : null;
            secondValue = second.hasOwnProperty(this.sort) ? parseFloat((second as any)[this.sort]) : null;
          }
          else {
            firstValue = (first as any)[this.sort];
            secondValue = (second as any)[this.sort];
          }
            
          // Convert strings to numbers for TIME and TotalTime columns
          if (this.sort === "TIME" || this.sort === "TotalTime") {
            firstValue = firstValue !== null ? parseFloat(firstValue) : null;
            secondValue = secondValue !== null ? parseFloat(secondValue) : null;
          }
          // Handle null values
          if (firstValue === null) {
            if (secondValue === null) {
              return 0;
            }
            else {
              return 1; 
            }
          }
          else if (secondValue === null) {
            return -1; 
          }
  
          const compare = firstValue < secondValue ? 1 : firstValue > secondValue ? -1 : 0;
          return compare * this.descending;
        });
      })
    ).subscribe(sortedResults => {
      this.results$ = of(sortedResults);
    });
  }

  toggleSort(metric: string) {
    if (this.sort === metric) {
      this.sort = "line";
      this.descending = -1;
      this.applySort();
      return;
    }
    this.sort = metric;
    this.descending = 1; 
    this.applySort();
  }
}
