import { Component } from '@angular/core';
import { FormBuilder, FormControl } from '@angular/forms';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { BehaviorSubject } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';


@Component({
  selector: 'app-test-coverage-launcher',
  templateUrl: './test-coverage-launcher.component.html',
  styleUrls: ['./test-coverage-launcher.component.css']
})
export class TestCoverageLauncherComponent {
  constructor(
    private formBuilder: FormBuilder,
    private covRestService: CoverageRestService,
    private snackBar: MatSnackBar
  ) {}

  dataForm = this.formBuilder.group({
    UnitTestRoot: 'C:\\InterSystems\\TestCoverage\\internal\\testing\\unit_tests\\UnitTest\\',
    CoverageLevel: 1,
    CoverageClasses: '',
    CoverageRoutines: '',
    PidList: '',
    Timing: 1,
  });
  
  isLoading$ = new BehaviorSubject<boolean>(false);
  hasError$ = new BehaviorSubject<boolean>(false);
  errorMessage$ = new BehaviorSubject<string>('');
  timingsList: Number[] = [0, 1];
  CoverageLevels: Number[] = [0, 1, 2, 3];

  onSubmit() {
    this.isLoading$.next(true); // Show the spinner
    this.hasError$.next(false);
    this.errorMessage$.next('');
    this.covRestService.Start(this.dataForm.value).subscribe({
      next: () => {
        this.isLoading$.next(false); // Hide the spinner
        this.dataForm.reset();
      },
      error: (error) => {
        this.isLoading$.next(false); // Hide the spinner on error
        this.hasError$.next(true);


        this.snackBar.open(error.message, 'Close', { 
          duration: 5000,
          panelClass: ['error-snackbar']
        });
      }
    });
  }
}
