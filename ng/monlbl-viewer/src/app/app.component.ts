import { Component } from '@angular/core';
import { AuthenticationService } from './core/services/authentication.service';
import { PlatformUserOutput } from './generated';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  user: PlatformUserOutput | null = null;

  constructor(
      private authenticationService: AuthenticationService
  ) {
      this.authenticationService.user.subscribe(x => this.user = x);
  }

  logout() {
      this.authenticationService.logout();
  }
}
