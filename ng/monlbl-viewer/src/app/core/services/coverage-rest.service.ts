import { Injectable } from '@angular/core';
import { BehaviorSubject, ReplaySubject, Subject, catchError, throwError, tap, map, Observable, filter} from 'rxjs';
import { CoverageService,  CoverageResultsOutput,  CoverageRoutinePathsOutput, CoverageRoutinePathOutput } from 'src/app/generated';
@Injectable({
  providedIn: 'root'
})
export class CoverageRestService {
  //private startCompletedSubject = new BehaviorSubject<boolean>(false);
  private covpathsSubject = new BehaviorSubject<CoverageRoutinePathsOutput | null>(null);
  private isLoadingSubject = new BehaviorSubject<boolean>(false); // Add the isLoading subject
  private isLoading = false; 
  private RunID = 0; // the RunID of the RunTest that this websocket is listening to 

  constructor(protected covService: CoverageService ) { }
  
  Start(pConfig: any): Observable<any> {
    this.isLoadingSubject.next(true); // Set loading state to true when starting
    this.isLoading = true;
    return this.covService.coverageStartPost({ CoverageConfigInput: pConfig }, 'body').pipe(
      tap(status => {
        //this.startCompletedSubject.next(true);
      }),
      catchError((error) => {
        this.isLoadingSubject.next(false); // Set loading state to false on error
        this.isLoading = false; 
        return throwError(() => new Error(error.message));
      })
    );
  }
  
  
  GetResults(routine: string, testpath: string): Observable<CoverageResultsOutput> {
    return this.covService.coverageResultsGet({routine: routine, testpath: testpath, RunID: this.RunID});
  }
  GetRoutines(RunID: number): Observable<CoverageRoutinePathsOutput> {
    return this.covService.coverageRoutinepathsGet({RunID: RunID}).pipe(
      tap((response: any) => {
        console.log(response)
        this.covpathsSubject.next(response);
        this.isLoadingSubject.next(false); // Set loading state to false after fetching routines
        this.isLoading = false; 
        this.RunID = RunID; // safe to update this here, since we know we're replacing the data
      })
    );
  }

  // getStartCompletedObservable(): Observable<boolean> {
  //   return this.startCompletedSubject.asObservable();
  // }

  getCovpathsObservable(): Observable<CoverageRoutinePathsOutput> {
    return this.covpathsSubject.asObservable().pipe(
      filter((covpaths): covpaths is CoverageRoutinePathsOutput => covpaths !== null)
    );
  }
  getIsLoadingObservable(): Observable<boolean> { // Getter for isLoading observable for the spinner
    return this.isLoadingSubject.asObservable();
  }
  getIsLoading(): boolean {
    return this.isLoading;
  }
  
}
