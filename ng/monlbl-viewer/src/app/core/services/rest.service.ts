import { map } from 'rxjs/operators';
import { Injectable } from '@angular/core';
import { Observable, ReplaySubject, Subject } from 'rxjs';
import { LineByLineMonitorConfigInput, LineByLineMonitorStatusOutput, MonitorService } from 'src/app/generated';

@Injectable({
  providedIn: 'root'
})
export class RestService {

  constructor(
    protected monitorService: MonitorService,
  ) {
    this.monitorService.monitorStatusGet('body').subscribe((status) => {
      this.status$.next(status);
    });
  }

  private status$ = new ReplaySubject<LineByLineMonitorStatusOutput>();

  getStatus(): Subject<LineByLineMonitorStatusOutput> {
    return this.status$;
  }

  start(body: LineByLineMonitorConfigInput): void {
    this.monitorService.monitorStartPost({LineByLineMonitorConfigInput: body},'body').subscribe((status) => {
      this.status$.next(status);
    });
  }

  stop(): void {
    this.monitorService.monitorStopPost('body').subscribe((status) => {
      this.status$.next(status);
    });
  }

  pause(): void {
    this.monitorService.monitorPausePost('body').subscribe((status) => {
      this.status$.next(status);
    });
  }

  resume(): void {
    this.monitorService.monitorResumePost('body').subscribe((status) => {
      this.status$.next(status);
    });
  }

  getResults(routine?: string): Observable<any> {
    return this.monitorService.monitorResultsGet({routine:routine});
  }

  getMetrics(): Observable<Array<string>> {
    return this.monitorService.monitorListMetricsGet('body')
      .pipe(map(value => value.metrics));
  }

}
