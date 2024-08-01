import { Injectable } from '@angular/core';
import { DefaultService } from 'src/app/generated';

@Injectable({
  providedIn: 'root'
})
export class AuthenticationService {
  constructor(
      private defaultService: DefaultService,
  ) {}

  logout() {
      this.defaultService.authLogoutPost().subscribe() //end iris session (because of shared cookies, does for all CSP applications)
      window.location.reload(); // forces a hard reload to re-show the iris login page
  }

}
