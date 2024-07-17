import { Injectable } from '@angular/core';
import { ReplaySubject, Observable, of} from 'rxjs';
import { CoverageService, CoverageConfigInput, CoverageResultsOutput,  CoverageStatusOutput } from 'src/app/generated';

@Injectable({
  providedIn: 'root'
})
export class CoverageRestService {
  
  constructor(protected covService: CoverageService ) { }
  private results$ = new ReplaySubject<CoverageResultsOutput>
  private status$ = new ReplaySubject<CoverageStatusOutput>();

  Start(pConfig: any): Observable<any> {
    this.covService.coverageStartPost({CoverageConfigInput: pConfig},'body').subscribe((status) => {
       this.status$.next(status)
       console.log("finished successfully?")
    })
    return of("testing")
    // return this.TestcovService.testcoverageStartGet({})
  }
}
