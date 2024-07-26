import { Component } from '@angular/core';
import { FormBuilder, Validators, AbstractControl, ValidationErrors, FormGroup } from '@angular/forms';
import { CoverageRestService } from '../../services/coverage-rest.service';
import { BehaviorSubject, debounceTime, distinctUntilChanged, Subject, takeUntil } from 'rxjs';
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

  isLoading$ = new BehaviorSubject<boolean>(false);
  hasError$ = new BehaviorSubject<boolean>(false);
  errorMessage$ = new BehaviorSubject<string>('');
  dataForm!: FormGroup
  private destroy$ = new Subject<void>();

  timingsList = [
    { value: 1, viewValue: '1: include timing data' },
    { value: 0, viewValue: "0: don't include timing data" }
  ];

  CoverageLevels = [
    { value: 0, viewValue: '0: overall' },
    { value: 1, viewValue: '1: per test suite' },
    { value: 2, viewValue: '2: per test class' },
    { value: 3, viewValue: '3: per test method' }
  ];
  ngOnInit() {
    this.dataForm = this.formBuilder.group({
      UnitTestRoot: ['C:\\Users\\cge\\OneDrive - InterSystems Corporation\\Documents\\Training\\', [Validators.required, this.validatePath]],
      CoverageLevel: [0, Validators.required],
      CoverageClasses: ['', this.validateCoverageClasses],
      CoverageRoutines: ['', this.validateCoverageRoutines],
      PidList: ['', this.validatePidList],
      Timing: [1, Validators.required],
    });

    // Apply debounced validation to multiple fields
    this.applyDebouncedValidation({
      UnitTestRoot: this.validatePath,
      CoverageClasses: this.validateCoverageClasses,
      CoverageRoutines: this.validateCoverageRoutines,
      PidList: this.validatePidList
    });
  }
  applyDebouncedValidation(validationConfig: { [key: string]: (control: AbstractControl) => ValidationErrors | null }) {
    Object.keys(validationConfig).forEach(controlName => {
      const control = this.dataForm.get(controlName);
      if (control) {
        control.valueChanges.pipe(
          debounceTime(300),
          distinctUntilChanged(),
          takeUntil(this.destroy$)
        ).subscribe(() => {
          const errors = validationConfig[controlName](control);
          control.setErrors(errors);
        });
      }
    });
  }
  
  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }

  onSubmit() {
    if (this.dataForm.invalid) {
      return;
    }

    this.isLoading$.next(true); // Show the spinner
    this.hasError$.next(false);
    this.errorMessage$.next('');
    this.covRestService.Start(this.dataForm.value).subscribe({
      next: () => {
        this.isLoading$.next(false); // Hide the spinner
        // this.dataForm.reset();
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

  validatePath(control: AbstractControl): ValidationErrors | null {
    if (!control.value) return null;
    
    // This regex allows for spaces, dots, and other special characters in folder names
    const pathRegex = /^(?:[a-zA-Z]:(?:\\|\/)|\/)?(?:[\w\s.-]+(?:\\|\/))*([\w\s.-]+(?:\\|\/))?$/;
    
    return pathRegex.test(control.value) ? null : { invalidPath: true };
  }

  validateCoverageClasses(control: AbstractControl): ValidationErrors | null {
    if (!control.value) return null;
    // This regex checks for a comma-separated list of strings that don't end with .cls
    const classesRegex = /^(\s*[\w.]+(?<!\.cls)\s*,)*\s*[\w.]+(?<!\.cls)\s*$/i;
    return classesRegex.test(control.value) ? null : { invalidCoverageClasses: true };
  }

  validateCoverageRoutines(control: AbstractControl): ValidationErrors | null {
    if (!control.value) return null;
    // This regex checks for a comma-separated list of strings that don't end with .mac
    const routinesRegex = /^(\s*[\w.]+(?<!\.mac)\s*,)*\s*[\w.]+(?<!\.mac)\s*$/i;
    return routinesRegex.test(control.value) ? null : { invalidCoverageRoutines: true };
  }
  
  validatePidList(control: AbstractControl): ValidationErrors | null {
    if (!control.value) return null;
    const pidRegex = /^(Interop|[0-9]+)(\s*,\s*[0-9]+)*$/;
    return pidRegex.test(control.value) ? null : { invalidPidList: true };
  }
}
