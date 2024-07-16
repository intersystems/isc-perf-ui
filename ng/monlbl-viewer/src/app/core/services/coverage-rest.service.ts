import { Injectable } from '@angular/core';
import { ReplaySubject, Observable, of} from 'rxjs';
import { TestcoverageService } from 'src/app/generated/api/testcoverage.service';
import { TestCoverageStatusOutput } from 'src/app/generated/model/testCoverageStatusOutput';

@Injectable({
  providedIn: 'root'
})
export class CoverageRestService {
  
  constructor(protected TestcovService: TestcoverageService ) { }
  private results$ = new ReplaySubject<TestCoverageStatusOutput>

  Start(pConfig: any): Observable<any> {
    
    return of("testing")
    // return this.TestcovService.testcoverageStartGet({})
  }
}
