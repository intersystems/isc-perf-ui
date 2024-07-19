import { AfterViewInit, Component, OnInit, ViewChild } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { Observable, of } from 'rxjs';
import { map, switchMap } from 'rxjs/operators';
import { CoverageResultOutput } from 'src/app/generated';
import { Location } from '@angular/common';
import { MatSort, Sort } from '@angular/material/sort';
import { MatTableDataSource } from '@angular/material/table';

@Component({
  selector: 'app-coverage-result-detail',
  templateUrl: './coverage-result-detail.component.html',
  styleUrls: ['./coverage-result-detail.component.css']
})
export class CoverageResultDetailComponent implements OnInit, AfterViewInit {
  displayedColumns: string[] = ['TIME', 'TotalTime', 'RtnLineCount', 'line', 'code'];
  dataSource: MatTableDataSource<CoverageResultOutput> = new MatTableDataSource<CoverageResultOutput>([]);
  sort: string = "";
  descending: number = 1;

  @ViewChild(MatSort) matSort!: MatSort;

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
      this.dataSource.data = results;
      console.log(results)
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

  announceSortChange(sortState: Sort) {
    if (sortState.direction) {
      console.log(`Sorted ${sortState.direction}ending`);
    } else {
      console.log('Sorting cleared');
    }
  }
}
