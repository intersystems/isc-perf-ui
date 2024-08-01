import { Injectable } from '@angular/core';
import { DefaultService, MonitorService, PlatformUserOutput, CoverageService } from 'src/app/generated';

@Injectable({
  providedIn: 'root'
})
export class AuthenticationService {
  constructor(
      private defaultService: DefaultService,
  ) {}



  logout() {
      this.defaultService.authLogoutPost().subscribe()
      window.location.reload(); // True forces a hard reload
  }

}
