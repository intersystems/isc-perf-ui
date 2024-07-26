import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { BehaviorSubject, Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DefaultService, MonitorService, PlatformUserOutput, CoverageService } from 'src/app/generated';

@Injectable({
  providedIn: 'root'
})
export class AuthenticationService {
  private userSubject: BehaviorSubject<PlatformUserOutput | null>;
  public user: Observable<PlatformUserOutput | null>;
  private loginStateSubject$: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);

  constructor(
      private router: Router,
      private defaultService: DefaultService,
      private monitorService: MonitorService,
      private coverageService: CoverageService,
      // private websocketService: 
  ) {
      const json = localStorage.getItem('user');
      this.userSubject = new BehaviorSubject<PlatformUserOutput | null>(json ? JSON.parse(json) : null);
      this.user = this.userSubject.asObservable();
  }

  public get userValue(): PlatformUserOutput | null {
      return this.userSubject.value;
  }

  login(username: string, password: string) {
    const authdata = window.btoa(username + ':' + password);
    this.defaultService.defaultHeaders = this.defaultService.defaultHeaders.set('Authorization',`Basic ${authdata}`);
    this.loginStateSubject$.next(true);
    return this.defaultService.authStatusGet('body').pipe(map(user => {
      localStorage.setItem('user', JSON.stringify(user));
      this.userSubject.next(user);
      this.monitorService.defaultHeaders = this.monitorService.defaultHeaders.set('Authorization',`Basic ${authdata}`);
      this.coverageService.defaultHeaders = this.coverageService.defaultHeaders.set('Authorization',`Basic ${authdata}`)
      return user;
    }));
  }

  logout() {
      // remove user from local storage to log user out
      localStorage.removeItem('user');
      this.loginStateSubject$.next(false);
      this.defaultService.defaultHeaders = this.defaultService.defaultHeaders.delete('Authorization');
      this.monitorService.defaultHeaders = this.monitorService.defaultHeaders.delete('Authorization');
      this.coverageService.defaultHeaders = this.coverageService.defaultHeaders.delete('Authorization')
      this.userSubject.next(null);
      this.defaultService.authLogoutPost().subscribe()
      this.router.navigate(['/login']);
  }

  loginStateChange(): Observable<boolean> {
    return this.loginStateSubject$;
  }
}
