import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BehaviorSubject, ReplaySubject, Subject, catchError, throwError, tap, map, Observable, filter} from 'rxjs';
import { CoverageService,  CoverageResultsOutput,  CoverageRoutinePathsOutput, CoverageRoutinePathOutput } from 'src/app/generated';
@Injectable({
  providedIn: 'root'
})
export class CoverageRestService {
  
  constructor(protected covService: CoverageService ) { }
  private startCompletedSubject = new BehaviorSubject<boolean>(false);
  private covpathsSubject = new BehaviorSubject<CoverageRoutinePathsOutput | null>(null);

  Start(pConfig: any): Observable<any> {
    return this.covService.coverageStartPost({ CoverageConfigInput: pConfig }, 'body').pipe(
      tap(status => {
        this.startCompletedSubject.next(true);
      }),
      catchError((error) => {
        return throwError(() => new Error(error.message));
      })
    );
  }
  
  
  GetResults(routine?: string, testpath?: string): Observable<CoverageResultsOutput> {
    return this.covService.coverageResultsGet({routine: routine, testpath: testpath});
  }
  GetRoutines(): Observable<CoverageRoutinePathsOutput> {
    return this.covService.coverageRoutinepathsGet().pipe(
      tap((response: any) => {
        this.covpathsSubject.next(response);
      })
    );
  }

  getStartCompletedObservable(): Observable<boolean> {
    return this.startCompletedSubject.asObservable();
  }

  getCovpathsObservable(): Observable<CoverageRoutinePathsOutput> {
    return this.covpathsSubject.asObservable().pipe(
      filter((covpaths): covpaths is CoverageRoutinePathsOutput => covpaths !== null)
    );
  }
}
