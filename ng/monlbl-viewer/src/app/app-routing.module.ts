import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HomeComponent } from './core/components/home/home.component';
import { AuthGuard } from './core/guards/auth.guard';
import { CoverageResultDetailComponent } from './core/components/coverage-result-detail/coverage-result-detail.component';
import { StatusComponent } from './core/components/status/status.component';
import { HistoricalResultsComponent } from './core/components/historical-results/historical-results.component';

const routes: Routes = [
  { path: '', component: StatusComponent, canActivate: [AuthGuard] },
  { path: 'testcoverage', component: HomeComponent, canActivate: [AuthGuard] },
  { path: 'result-detail/:routine/:testpath', component: CoverageResultDetailComponent},
  { path: 'historical', component: HistoricalResultsComponent},

  // otherwise redirect to home
  { path: '**', redirectTo: '' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
