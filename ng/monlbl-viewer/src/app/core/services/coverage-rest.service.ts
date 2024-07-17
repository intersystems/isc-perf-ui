import { Injectable } from '@angular/core';
import { ReplaySubject, Observable} from 'rxjs';
import { CoverageService,  CoverageResultsOutput,  CoverageStatusOutput } from 'src/app/generated';

@Injectable({
  providedIn: 'root'
})
export class CoverageRestService {
  
  constructor(protected covService: CoverageService ) { }
  private results$ = new ReplaySubject<CoverageResultsOutput>
  private status$ = new ReplaySubject<CoverageStatusOutput>();

  Start(pConfig: any): Observable<any> {
    return new Observable(observer => {
      this.covService.coverageStartPost({CoverageConfigInput: pConfig}, 'body').subscribe(
        (status) => {
          this.status$.next(status);
          console.log("finished successfully?");
          observer.next(status);
          observer.complete();
        },
        (error) => {
          observer.error(error);
        }
      );
    });
  }
  GetResults(routine?: string, testpath?: string): Observable<any> {
    return this.covService.coverageResultsGet({routine: routine, testpath: testpath});
  }
}
