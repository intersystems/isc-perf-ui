import { Injectable } from '@angular/core';
import { BehaviorSubject, catchError, throwError, tap, map, Observable} from 'rxjs';
import { CoverageService,  CoverageResultsOutput,  CoverageRoutinePathsOutput } from 'src/app/generated';
@Injectable({
  providedIn: 'root'
})
export class CoverageRestService {


  private covpathsSubject = new BehaviorSubject<CoverageRoutinePathsOutput | null>(null); // observable of an object with a list of routine+testpaths
  // will be surfaced in the dropdown in CoverageResultsDisplay
  
  private isLoadingSubject = new BehaviorSubject<boolean>(false); // Observable of whether we're currently waiting for a coverage run
  private isLoading = false; // current value for isLoading
  //important for knowing whether or not to listen to an incoming websocket message
 
  private firstLoad = true; // if the page hasn't had results yet, we'll listen to the first broadcast if there is one
  // if you just open a tab and there's a current test running, we'll listen to that test's results
  
  private RunID = 0; // the RunID of the RunTest that this websocket is listening to
  constructor(protected covService: CoverageService ) { }
  
  // wrapper for making the API call to start runtest
  Start(pConfig: any): Observable<any> {
    this.isLoadingSubject.next(true); // Set loading state to true when starting
    this.isLoading = true;
    return this.covService.coverageStartPost({ CoverageConfigInput: pConfig }, 'body').pipe(
      catchError((error) => {
        this.isLoadingSubject.next(false); // Set loading state to false on error
        this.isLoading = false; 
        return throwError(() => new Error(error.message));
      })
    );
  }
  
  // wrapper for the API call to get the coverage results for a specific routine and testpath
  GetResults(routine: string, testpath: string): Observable<CoverageResultsOutput> {
    return this.covService.coverageResultsGet({routine: routine, testpath: testpath, RunID: this.RunID});
  }

  //wrapper for the API call to get the 
  GetRoutines(RunID: number): Observable<CoverageRoutinePathsOutput> {
    return this.covService.coverageRoutinepathsGet({ RunID: RunID }).pipe(
      map((response: CoverageRoutinePathsOutput) => {
        if (response.covpaths) {
          // Sort the covpaths by routine first and then by testpath
          response.covpaths.sort((a, b) => {
            if (a.routine === b.routine) {
              return a.testpath.localeCompare(b.testpath);
            }
            return a.routine.localeCompare(b.routine);
          });
        }
        return response; // Return the sorted response
      }),
      tap((response: CoverageRoutinePathsOutput) => {
        this.covpathsSubject.next(response);
        this.isLoadingSubject.next(false); // Set loading state to false after fetching routines
        this.isLoading = false;
        this.firstLoad = false;
        this.RunID = RunID; // Safe to update this here, since we know we're replacing the data
      })
    );
  }

  Clear(): void {
    this.covService.coverageClearPost().subscribe(); 
    this.isLoading = false;
    this.isLoadingSubject.next(false);
    this.covpathsSubject.next(null);
    return 
  }

  // getStartCompletedObservable(): Observable<boolean> {
  //   return this.startCompletedSubject.asObservable();
  // }

  getCovpathsObservable(): Observable<CoverageRoutinePathsOutput | null> {
    return this.covpathsSubject.asObservable()
  }
  getIsLoadingObservable(): Observable<boolean> { // Getter for isLoading observable for the spinner
    return this.isLoadingSubject.asObservable();
  }
  getIsLoading(): boolean {
    return this.isLoading;
  }
  getFirstLoad(): Boolean {
    return this.firstLoad;
  }
  
}
