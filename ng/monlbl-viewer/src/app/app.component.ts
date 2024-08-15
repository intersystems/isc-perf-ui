import { Component } from '@angular/core';
import { AuthenticationService } from './core/services/authentication.service';
import { PlatformUserOutput } from './generated';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {

  constructor(
      private authenticationService: AuthenticationService
  ) {
  }

  logout() {
      this.authenticationService.logout();
  }
}
