import { Component, OnInit } from '@angular/core';
import { Observable, map } from 'rxjs';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { CoverageRunIDsOutput, CoverageTabularDataOutput, CoverageTabularDataRowOutput } from 'src/app/generated';

@Component({
  selector: 'app-historical-results',
  templateUrl: './historical-results.component.html',
  styleUrls: ['./historical-results.component.scss']
})
export class HistoricalResultsComponent implements OnInit {
  runIDs$: Observable<number[]> | undefined;
  selectedRunID: number | null = null;
  tableData: CoverageTabularDataRowOutput[] = [];
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

  constructor(private covRestService: CoverageRestService) {}

  ngOnInit() {
    this.runIDs$ = this.covRestService.GetRunIDs().pipe(
      map((response: CoverageRunIDsOutput) => response.RunIDs || [])
    );
  }

  onRunIDChange(runID: number) {
    this.selectedRunID = runID;
    this.covRestService.GetClassLevelData(runID).subscribe((data: CoverageTabularDataOutput) => {
      this.tableData = data.results || [];
    });
  }
}
