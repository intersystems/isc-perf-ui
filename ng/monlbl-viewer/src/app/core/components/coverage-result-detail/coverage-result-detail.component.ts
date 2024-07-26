import { AfterViewInit, Component, OnInit, ViewChild } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { Observable, of } from 'rxjs';
import { map, switchMap, catchError } from 'rxjs/operators';
import { CoverageResultOutput, CoverageMethodResultOutput } from 'src/app/generated';
import { Location } from '@angular/common';
import { MatSort, Sort } from '@angular/material/sort';
import { MatTableDataSource } from '@angular/material/table';
import { LiveAnnouncer } from '@angular/cdk/a11y';
import { DomSanitizer } from '@angular/platform-browser';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  selector: 'app-coverage-result-detail',
  templateUrl: './coverage-result-detail.component.html',
  styleUrls: ['./coverage-result-detail.component.css']
})
export class CoverageResultDetailComponent implements OnInit, AfterViewInit {
  displayedColumns: string[] = ['TIME', 'TotalTime', 'RtnLineCount', 'line', 'code'];
  methodColumns: string[] = ['name', 'complexity'];
  dataSource: MatTableDataSource<CoverageResultOutput> = new MatTableDataSource<CoverageResultOutput>([]);
  methodDataSource: MatTableDataSource<CoverageMethodResultOutput> = new MatTableDataSource<CoverageMethodResultOutput>([]);
  sort: string = '';
  descending: number = 1;
  showMethodsTable: boolean = false; // Toggle flag for the methods table

  @ViewChild(MatSort) matSort!: MatSort;

  constructor(
    private route: ActivatedRoute,
    private covRestService: CoverageRestService,
    private location: Location,
    private _liveAnnouncer: LiveAnnouncer,
    private sanitizer: DomSanitizer,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit() {
    this.route.paramMap
      .pipe(
        switchMap((params) => {
          const routine = params.get('routine');
          const testpath = params.get('testpath');
          return this.covRestService.GetResults(routine!, testpath!).pipe(
            catchError((error: any) => {
              const errorMsg = error.message ? error.message : 'An unknown error occurred';
              this.snackBar.open(errorMsg, 'Close', { duration: 5000 });
              // Return an empty array or any default value in case of error
              return of({ results: [], MethodResults: [] });
            })
          );
        }),
        map((response: any) => {
          this.methodDataSource.data = response.MethodResults || [];
          console.log(response)
          return response.results;
        })
      )
      .subscribe((results) => {
        this.dataSource.data = results;
      });
  }

  ngAfterViewInit() {
    this.dataSource.sort = this.matSort;
    this.dataSource.sortingDataAccessor = (data: CoverageResultOutput, sortHeaderId: string): string | number => {
      const value = (data as any)[sortHeaderId];
      if (sortHeaderId === 'TIME' || sortHeaderId === 'TotalTime') {
        return value ? parseFloat(value) : 0;
      }
      return value !== null && value !== undefined ? value : '';
    };
  }

  goBack(): void {
    this.location.back();
  }

  toggleMethodsTable() {
    this.showMethodsTable = !this.showMethodsTable;
  }

  announceSortChange(sortState: Sort) {
    if (sortState.direction) {
      this._liveAnnouncer.announce(`Sorted ${sortState.direction}ending`);
    } else {
      this._liveAnnouncer.announce('Sorting cleared');
    }
  }

  getSafeHtml(html: string) {
    return this.sanitizer.bypassSecurityTrustHtml(html);
  }
}
