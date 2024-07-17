import { Injectable } from '@angular/core';
import { ReplaySubject, Subject, Observable} from 'rxjs';
import { CoverageService,  CoverageResultsOutput,  CoverageRoutinePathsOutput } from 'src/app/generated';
@Injectable({
  providedIn: 'root'
})
export class CoverageRestService {
  
  constructor(protected covService: CoverageService ) { }
  private startCompleted$ = new Subject<void>(); 

  Start(pConfig: any): Observable<any> {
    return new Observable(observer => {
      this.covService.coverageStartPost({CoverageConfigInput: pConfig}, 'body').subscribe(
        (status) => {
          console.log("finished successfully?");
          this.startCompleted$.next();
          observer.next(status);
          observer.complete();
        },
        (error) => {
          observer.error(error);
        }
      );
    });
  }
  GetResults(routine?: string, testpath?: string): Observable<CoverageResultsOutput> {
    return this.covService.coverageResultsGet({routine: routine, testpath: testpath});
  }

  GetRoutines(): Observable<CoverageRoutinePathsOutput> {
    return this.covService.coverageRoutinepathsGet();
  }

  getStartCompletedObservable(): Observable<void> {
    return this.startCompleted$.asObservable();
  }
}
