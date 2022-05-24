import { RestService } from './rest.service';
import { Injectable } from '@angular/core';
import { Observable, ReplaySubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class CodeService {

  private status$: ReplaySubject<any> = new ReplaySubject<any>();

  private routine: string | undefined;

  constructor(private restService: RestService) { }

  getCurrentResults(): Observable<any> {
    return this.status$.asObservable();
  }

  setCurrentRoutine(routine: string): void {
    this.routine = routine;
    this.refreshResults();
  }

  refreshResults(): void {
    if (this.routine) {
      this.restService.getResults(this.routine).subscribe(result => {
        this.status$.next(result);
      });
    }
  }
}
