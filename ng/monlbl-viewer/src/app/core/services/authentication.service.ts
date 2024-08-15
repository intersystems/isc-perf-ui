import { Injectable } from '@angular/core';
import { DefaultService } from 'src/app/generated';
import { Router } from '@angular/router';
@Injectable({
  providedIn: 'root'
})
export class AuthenticationService {
  constructor(
      private defaultService: DefaultService,
      private router: Router,
  ) {}

  logout() {
    //end iris session (because of shared cookies, does for all CSP applications)
      this.defaultService.authLogoutPost().subscribe({
        next: () => {
          let url = window.location.href;
          // Remove everything after "monlbl-viewer/"
          const targetSegment = 'monlbl-viewer/';
          const targetIndex = url.indexOf(targetSegment);

          if (targetIndex !== -1) {
            url = url.substring(0, targetIndex + targetSegment.length);
          }
          window.location.href = url; 
        }
      }) 
      
  }

}
