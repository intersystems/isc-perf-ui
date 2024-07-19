import { Component } from '@angular/core';
import { FormBuilder, FormControl } from '@angular/forms';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { BehaviorSubject } from 'rxjs';

@Component({
  selector: 'app-test-coverage-launcher',
  templateUrl: './test-coverage-launcher.component.html',
  styleUrls: ['./test-coverage-launcher.component.css']
})
export class TestCoverageLauncherComponent {
  constructor(
    private formBuilder: FormBuilder,
    private covRestService: CoverageRestService
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
  timingsList: Number[] = [0, 1];
  CoverageLevels: Number[] = [0, 1, 2, 3];

  onSubmit() {
    console.log("hello world?");
    console.log(this.dataForm.value);
    this.isLoading$.next(true); // Show the spinner
    this.covRestService.Start(this.dataForm.value).subscribe({
      next: () => {
        this.isLoading$.next(false); // Hide the spinner
        this.dataForm.reset();
      },
      error: () => {
        this.isLoading$.next(false); // Hide the spinner on error
      }
    });
  }
}
