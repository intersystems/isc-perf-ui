import { AfterViewInit, Component, OnInit, ViewChild } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { CoverageRunIDsOutput, CoverageTabularDataOutput, CoverageTabularDataRowOutput } from 'src/app/generated';

@Component({
  selector: 'app-historical-results',
  templateUrl: './historical-results.component.html',
  styleUrls: ['./historical-results.component.scss']
})
export class HistoricalResultsComponent implements OnInit, AfterViewInit {
  runIDs$: Observable<number[]> | undefined;
  selectedRunID: number | null = null;
  dataSource = new MatTableDataSource<CoverageTabularDataRowOutput>();
  displayedColumns: string[] = [
    'Routine',
    'ExecutableLines',
    'LinesCovered',
    'PercentCoverage',
    'ExecutableMethods',
    'MethodsCovered',
    'MethodCoverage',
    'Time',
    'TotalTime'
  ];

  @ViewChild(MatSort, { static: true }) sort!: MatSort;

  constructor(private covRestService: CoverageRestService) {}

  ngOnInit() {
    this.runIDs$ = this.covRestService.GetRunIDs().pipe(
      map((response: CoverageRunIDsOutput) => response.RunIDs || [])
    );
  }

  ngAfterViewInit() {
    this.dataSource.sort = this.sort;
    this.dataSource.sortingDataAccessor = (item, property) => {
      switch (property) {
        case 'PercentCoverage':
        case 'MethodCoverage':
          return parseFloat(item[property]) || 0;
        case 'Time':
        case 'TotalTime':
          return parseFloat(item[property]) || 0;
        default:
          return item[property as keyof CoverageTabularDataRowOutput];
      }
    };
  }

  onRunIDChange(runID: number) {
    this.selectedRunID = runID;
    this.covRestService.GetClassLevelData(runID).subscribe((data: CoverageTabularDataOutput) => {
      this.dataSource.data = data.results || [];
    });
  }
}
