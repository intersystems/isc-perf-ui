import { Component } from '@angular/core';
import { FormBuilder, FormControl } from '@angular/forms';

@Component({
  selector: 'app-test-coverage-launcher',
  templateUrl: './test-coverage-launcher.component.html',
  styleUrls: ['./test-coverage-launcher.component.css']
})
export class TestCoverageLauncherComponent {
  constructor(
    private formBuilder: FormBuilder
  ) {
    
  }
    dataForm = this.formBuilder.group({
      UnitTestRoot: '',
      CoverageLevel: 1,
      CoverageClasses: '',
      CoverageRoutines: '',
      PidList: '',
      Timing: 0,
      MetricsTracked: ''
    });
    timingsList: Number[] = [0, 1];
    CoverageLevels: Number[] = [0, 1, 2, 3];
    onSubmit() 
    {
      console.log("hello world?");
      console.log(this.dataForm.value);
      this.dataForm.reset();
    }
}