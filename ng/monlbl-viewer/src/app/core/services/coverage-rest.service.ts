import { Injectable } from '@angular/core';
import { BehaviorSubject, ReplaySubject, Subject, tap, map, Observable} from 'rxjs';
import { CoverageService,  CoverageResultsOutput,  CoverageRoutinePathsOutput, CoverageRoutinePathOutput } from 'src/app/generated';
@Injectable({
  providedIn: 'root'
})
export class CoverageRestService {
  
  constructor(protected covService: CoverageService ) { }
  private startCompletedSubject = new BehaviorSubject<boolean>(false);
  private covpathsSubject = new BehaviorSubject<CoverageRoutinePathOutput[]>([]);

  Start(pConfig: any): Observable<any> {
    return this.covService.coverageStartPost({ CoverageConfigInput: pConfig }, 'body').pipe(
      tap(status => {
        this.startCompletedSubject.next(true);
      })
    );
  }
  
  
  GetResults(routine?: string, testpath?: string): Observable<CoverageResultsOutput> {
    return this.covService.coverageResultsGet({routine: routine, testpath: testpath});
  }
  GetRoutines(): Observable<CoverageRoutinePathOutput[]> {
    return this.covService.coverageRoutinepathsGet().pipe(
      tap((response: any) => {
        this.covpathsSubject.next(response.covpaths);
      }),
      map((response: any) => response.covpaths)
    );
  }

  getStartCompletedObservable(): Observable<boolean> {
    return this.startCompletedSubject.asObservable();
  }

  getCovpathsObservable(): Observable<CoverageRoutinePathOutput[]> {
    return this.covpathsSubject.asObservable();
  }
}
